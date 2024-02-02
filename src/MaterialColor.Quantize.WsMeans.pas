unit MaterialColor.Quantize.WsMeans;

interface

uses
  System.Math,
  System.Generics.Collections, System.Generics.Defaults,
  MaterialColor.Utils;

type
  IQuantizerResult = interface
    ['{C847B59E-5BD5-4A16-BA67-0840D4D52DFA}']
    function GetColorToCount: TDictionary<TARGB, Cardinal>;
    function GetInputPixelToClusterPixel: TDictionary<TARGB, TARGB>;

    property color_to_count: TDictionary<TARGB, Cardinal> read GetColorToCount;
    property input_pixel_to_cluster_pixel: TDictionary<TARGB, TARGB> read GetInputPixelToClusterPixel;
  end;

  TQuantizerResult = class(TInterfacedObject, IQuantizerResult)
  private
    FColorToCount: TDictionary<TARGB, Cardinal>;
    FInputPixelToClusterPixel: TDictionary<TARGB, TARGB>;

    function GetColorToCount: TDictionary<TARGB, Cardinal>;
    function GetInputPixelToClusterPixel: TDictionary<TARGB, TARGB>;
  public
    constructor Create;
    destructor Destroy; override;
  end;

function QuantizeWsmeans(const input_pixels: TArray<TARGB>;
                         const starting_clusters: TArray<TARGB>;
                         max_colors: Word): IQuantizerResult;

implementation

uses
  MaterialColor.Utils.Lab;

const
  kMaxIterations = 100;
  kMinDeltaE: Double = 3.0;

type
  TSwatch = record
    argb: TARGB;
    population: Integer;
  end;

  TDistanceToIndex = record
    distance: Double;
    index: Integer;
  end;

function QuantizeWsmeans(const input_pixels: TArray<TARGB>;
                         const starting_clusters: TArray<TARGB>;
                         max_colors: Word): IQuantizerResult;
var
  pixel_to_count: TDictionary<TARGB, Integer>;
  pixels: TList<TARGB>;
  points: TList<TLab>;
  clusters: TList<TLab>;
  cluster_indices: TList<Integer>;
  swatches: TList<TSwatch>;
  cluster_argbs: TList<TARGB>;
  all_cluster_argbs: TList<TARGB>;

  pixel_count: Integer;
  cluster_count: Integer;
  pixel_count_sums: array[0..256-1] of Integer;
  additional_clusters_needed: Integer;
  index_matrix: array of array of Integer;
  distance_to_index_matrix: array of array of TDistanceToIndex;
  component_a_sums: array[0..256-1] of Double;
  component_b_sums: array[0..256-1] of Double;
  component_c_sums: array[0..256-1] of Double;
begin
  if (max_colors = 0) or (Length(input_pixels) = 0) then
  begin
    Result := TQuantizerResult.Create;
    Exit;
  end;

  pixel_to_count := TDictionary<TARGB, Integer>.Create;
  pixels := TList<TARGB>.Create;
  points := TList<TLab>.Create;
  clusters := TList<TLab>.Create;
  cluster_indices := TList<Integer>.Create;
  swatches := TList<TSwatch>.Create;
  cluster_argbs := TList<TARGB>.Create;
  all_cluster_argbs := TList<TARGB>.Create;
  try
    // If colors is outside the range, just set it the max.
    if max_colors > 256 then
      max_colors := 256;

    pixel_count := Length(input_pixels);
    pixels.Capacity := pixel_count;
    points.Capacity := pixel_count;

    for var pixel in input_pixels do
    begin
      // tested over 1000 runs with 128 colors, 12544 (112 x 112)
      // std::map 10.9 ms
      // std::unordered_map 10.2 ms
      // absl::btree_map 9.0 ms
      // absl::flat_hash_map 8.0 ms
      var count: Integer;
      if pixel_to_count.TryGetValue(pixel, count) then
        pixel_to_count[pixel] := count + 1
      else
      begin
        pixels.Add(pixel);
        points.Add(LabFromInt(pixel));
        pixel_to_count.Add(pixel, 1);
      end;
    end;

    cluster_count := Min(max_colors, points.Count);

    if Length(starting_clusters) > 0 then
      cluster_count := Min(cluster_count, Length(starting_clusters));

    clusters.Capacity := Length(starting_clusters);
    for var argb in starting_clusters do
      clusters.Add(LabFromInt(argb));

    RandSeed := 42688;

    additional_clusters_needed := cluster_count - clusters.Count;
    if (Length(starting_clusters) = 0) and (additional_clusters_needed > 0) then
      for var i := 0 to additional_clusters_needed -1 do
      begin
        // Adds a random Lab color to clusters.
        var lab: TLab;
        lab.l := Random() * (100.0) + 0.0;
        lab.a := Random() * (100.0 - -100.0) - 100.0;
        lab.b := Random() * (100.0 - -100.0) - 100.0;
        clusters.Add(lab);
      end;

    RandSeed := 42688;
    cluster_indices.Capacity := points.Count;
    for var i := 0 to points.Count -1 do
      cluster_indices.Add(Random(cluster_count));

  //  std::vector<std::vector<int>> index_matrix(
  //      cluster_count, std::vector<int>(cluster_count, 0));
    SetLength(index_matrix, cluster_count, cluster_count);

  //  std::vector<std::vector<DistanceToIndex>> distance_to_index_matrix(
  //      cluster_count, std::vector<DistanceToIndex>(cluster_count));
    SetLength(distance_to_index_matrix, cluster_count, cluster_count);

    for var iteration := 0 to kMaxIterations -1 do
    begin
      // Calculate cluster distances
      for var i := 0 to cluster_count -1 do
      begin
        distance_to_index_matrix[i][i].distance := 0;
        distance_to_index_matrix[i][i].index := i;
        for var j := i + 1 to cluster_count -1 do
        begin
          var distance := clusters[i].DeltaE(clusters[j]);

          distance_to_index_matrix[j][i].distance := distance;
          distance_to_index_matrix[j][i].index := i;
          distance_to_index_matrix[i][j].distance := distance;
          distance_to_index_matrix[i][j].index := j;
        end;

        var row := distance_to_index_matrix[i];
        TArray.Sort<TDistanceToIndex>(row,
          TComparer<TDistanceToIndex>.Construct(
            function(const Me, A: TDistanceToIndex): Integer
            begin
               // return me.distance < a.distance
               Result := CompareValue(Me.distance, A.distance);
            end
          )
        );

        for var j := 0 to cluster_count -1 do
          index_matrix[i][j] := row[j].index;
      end;

      // Reassign points
      var color_moved := False;
      for var i := 0 to points.Count -1 do
      begin
        var point := points[i];

        var previous_cluster_index := cluster_indices[i];
        var previous_cluster := clusters[previous_cluster_index];
        var previous_distance := point.DeltaE(previous_cluster);
        var minimum_distance := previous_distance;
        var new_cluster_index := -1;

        for var j := 0 to cluster_count - 1 do
        begin
          if (distance_to_index_matrix[previous_cluster_index][j].distance >=
              4 * previous_distance) then
            Continue;

          var distance := point.DeltaE(clusters[j]);
          if (distance < minimum_distance) then
          begin
            minimum_distance := distance;
            new_cluster_index := j;
          end;
        end;
        if (new_cluster_index <> -1) then
        begin
          var distanceChange := Abs(Sqrt(minimum_distance) - Sqrt(previous_distance));
          if (distanceChange > kMinDeltaE) then
          begin
            color_moved := true;
            cluster_indices[i] := new_cluster_index;
          end;
        end;
      end;

      if (not color_moved) and (iteration <> 0) then
        Break;

      // Recalculate cluster centers
      FillChar(component_a_sums[0], SizeOf(component_a_sums), 0);
      FillChar(component_b_sums[0], SizeOf(component_b_sums), 0);
      FillChar(component_c_sums[0], SizeOf(component_c_sums), 0);

      for var i := 0 to cluster_count -1 do
        pixel_count_sums[i] := 0;

      for var i := 0 to points.Count -1 do
      begin
        var clusterIndex := cluster_indices[i];
        var point := points[i];
        var count := pixel_to_count[pixels[i]];

        pixel_count_sums[clusterIndex] := pixel_count_sums[clusterIndex] + count;
        component_a_sums[clusterIndex] := component_a_sums[clusterIndex] + (point.l * count);
        component_b_sums[clusterIndex] := component_b_sums[clusterIndex] + (point.a * count);
        component_c_sums[clusterIndex] := component_c_sums[clusterIndex] + (point.b * count);
      end;

      for var i := 0 to cluster_count -1 do
      begin
        var count := pixel_count_sums[i];
        if (count = 0) then
        begin
          clusters[i] := TLab.Create(0, 0, 0);
          Continue;
        end;
        var a := component_a_sums[i] / count;
        var b := component_b_sums[i] / count;
        var c := component_c_sums[i] / count;
        clusters[i] := TLab.Create(a, b, c);
      end;
    end;

    for var i := 0 to cluster_count -1 do
    begin
      var possible_new_cluster := IntFromLab(clusters[i]);
      all_cluster_argbs.Add(possible_new_cluster);

      var count := pixel_count_sums[i];
      if (count = 0) then
        Continue;

      var use_new_cluster := 1;
      for var j := 0 to swatches.Count -1 do
        if (swatches[j].argb = possible_new_cluster) then
        begin
          var swatch := swatches[j];
          swatch.population := swatch.population + count;
          swatches[j] := swatch;
          use_new_cluster := 0;
          Break;
        end;

      if (use_new_cluster = 0) then
        Continue;

      cluster_argbs.Add(possible_new_cluster);

      var swatch: TSwatch;
      swatch.argb := possible_new_cluster;
      swatch.population := count;
      swatches.Add(swatch);
    end;

    swatches.Sort(
      TComparer<TSwatch>.Construct(
        function(const A, B: TSwatch): Integer
        begin
          // return population > b.population;
          Result := CompareValue(B.population, A.population);
        end
      )
    );

    // Constructs the quantizer result to return.

    Result := TQuantizerResult.Create;

    for var i := 0 to swatches.Count -1 do
      Result.color_to_count.Add(swatches[i].argb, swatches[i].population);

    for var i := 0 to points.Count -1 do
    begin
      var pixel := pixels[i];
      var cluster_index := cluster_indices[i];
      var cluster_argb := all_cluster_argbs[cluster_index];
      Result.input_pixel_to_cluster_pixel.Add(pixel, cluster_argb);
    end;
  finally
    all_cluster_argbs.Free;
    cluster_argbs.Free;
    swatches.Free;
    cluster_indices.Free;
    clusters.Free;
    points.Free;
    pixels.Free;
    pixel_to_count.Free;
  end;
end;

{ TQuantizerResult }

constructor TQuantizerResult.Create;
begin
  inherited Create;
  FColorToCount := TDictionary<TARGB, Cardinal>.Create;
  FInputPixelToClusterPixel := TDictionary<TARGB, TARGB>.Create;
end;

destructor TQuantizerResult.Destroy;
begin
  FInputPixelToClusterPixel.Free;
  FColorToCount.Free;
  inherited;
end;

function TQuantizerResult.GetColorToCount: TDictionary<TARGB, Cardinal>;
begin
  Result := FColorToCount;
end;

function TQuantizerResult.GetInputPixelToClusterPixel: TDictionary<TARGB, TARGB>;
begin
  Result := FInputPixelToClusterPixel;
end;

end.
