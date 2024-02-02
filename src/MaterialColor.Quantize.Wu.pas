unit MaterialColor.Quantize.Wu;

interface

uses
  System.UITypes,
  System.Generics.Collections,
  MaterialColor.Utils;

function QuantizeWu(const pixels: TArray<TARGB>; max_colors: Word): TArray<TARGB>;

implementation

type
  TBox = record
    r0, r1: Integer;
    g0, g1: Integer;
    b0, b1: Integer;
    vol: Integer;
  end;

  TDirection = (kRed, kGreen, kBlue);

const
  kIndexBits  = 5;
  kIndexCount = (1 shl kIndexBits) + 1;
  kTotalSize  = kIndexCount * kIndexCount * kIndexCount;
  kMaxColors  = 256;

type
  TIntArray = TArray<Int64>;
  TDoubleArray = TArray<Double>;

function GetIndex(r, g, b: Integer): Integer;
begin
  Result := (r shl (kIndexBits * 2))
          + (r shl (kIndexBits + 1))
          + (g shl kIndexBits)
          + r + g + b;
end;

procedure ConstructHistogram(const pixels: TArray<TARGB>;
                             var weights: TIntArray;
                             var m_r, m_g, m_b: TIntArray;
                             var moments: TDoubleArray);
begin
  for var pixel in pixels do
  begin
    var red := RedFromInt(pixel);
    var green := GreenFromInt(pixel);
    var blue := BlueFromInt(pixel);

    var bits_to_remove := 8 - kIndexBits;
    var index_r := (red shr bits_to_remove) + 1;
    var index_g := (green shr bits_to_remove) + 1;
    var index_b := (blue shr bits_to_remove) + 1;
    var index := GetIndex(index_r, index_g, index_b);

    weights[index] := weights[index] + 1;
    m_r[index] := m_r[index] + red;
    m_g[index] := m_g[index] + green;
    m_b[index] := m_b[index] + blue;
    moments[index] := moments[index] + (red * red) + (green * green) + (blue * blue);
  end;
end;

procedure ComputeMoments(var weights, m_r, m_g, m_b: TIntArray; moments: TDoubleArray);
var
  area: array[0..kIndexCount-1] of Int64;
  area_r: array[0..kIndexCount-1] of Int64;
  area_g: array[0..kIndexCount-1] of Int64;
  area_b: array[0..kIndexCount-1] of Int64;
  area_2: array[0..kIndexCount-1] of Double;
begin
  for var r := 1 to kIndexCount -1 do
  begin
    FillChar(area[0], kIndexCount * SizeOf(Int64), 0);
    FillChar(area_r[0], kIndexCount * SizeOf(Int64), 0);
    FillChar(area_g[0], kIndexCount * SizeOf(Int64), 0);
    FillChar(area_b[0], kIndexCount * SizeOf(Int64), 0);
    FillChar(area_2[0], kIndexCount * SizeOf(Double), 0);

    for var g := 1 to kIndexCount -1 do
    begin
      var line: Int64 := 0;
      var line_r: Int64 := 0;
      var line_g: Int64 := 0;
      var line_b: Int64 := 0;
      var line_2: Double := 0.0;

      for var b := 1 to kIndexCount -1 do
      begin
        var index := GetIndex(r, g, b);
        line := line + weights[index];
        line_r := line_r + m_r[index];
        line_g := line_g + m_g[index];
        line_b := line_b + m_b[index];
        line_2 := line_2 + moments[index];

        area[b] := area[b] + line;
        area_r[b] := area_r[b] + line_r;
        area_g[b] := area_g[b] + line_g;
        area_b[b] := area_b[b] + line_b;
        area_2[b] := area_2[b] + line_2;

        var previous_index := GetIndex(r - 1, g, b);
        weights[index] := weights[previous_index] + area[b];
        m_r[index] := m_r[previous_index] + area_r[b];
        m_g[index] := m_g[previous_index] + area_g[b];
        m_b[index] := m_b[previous_index] + area_b[b];
        moments[index] := moments[previous_index] + area_2[b];
      end;
    end;
  end;
end;

function Top(const cube: TBox; const direction: TDirection; const position: Integer;
             const moment: TIntArray): Int64;
begin
  if direction = TDirection.kRed then
    Result := moment[GetIndex(position, cube.g1, cube.b1)] -
              moment[GetIndex(position, cube.g1, cube.b0)] -
              moment[GetIndex(position, cube.g0, cube.b1)] +
              moment[GetIndex(position, cube.g0, cube.b0)]
  else if direction = TDirection.kGreen then
    Result := moment[GetIndex(cube.r1, position, cube.b1)] -
              moment[GetIndex(cube.r1, position, cube.b0)] -
              moment[GetIndex(cube.r0, position, cube.b1)] +
              moment[GetIndex(cube.r0, position, cube.b0)]
  else
    Result := moment[GetIndex(cube.r1, cube.g1, position)] -
              moment[GetIndex(cube.r1, cube.g0, position)] -
              moment[GetIndex(cube.r0, cube.g1, position)] +
              moment[GetIndex(cube.r0, cube.g0, position)];
end;

function Bottom(const cube: TBox; const direction: TDirection;
                const moment: TIntArray): Int64;
begin
  if direction = TDirection.kRed then
    Result := -moment[GetIndex(cube.r0, cube.g1, cube.b1)] +
               moment[GetIndex(cube.r0, cube.g1, cube.b0)] +
               moment[GetIndex(cube.r0, cube.g0, cube.b1)] -
               moment[GetIndex(cube.r0, cube.g0, cube.b0)]
  else if direction = TDirection.kGreen then
    Result := -moment[GetIndex(cube.r1, cube.g0, cube.b1)] +
               moment[GetIndex(cube.r1, cube.g0, cube.b0)] +
               moment[GetIndex(cube.r0, cube.g0, cube.b1)] -
               moment[GetIndex(cube.r0, cube.g0, cube.b0)]
  else
    Result := -moment[GetIndex(cube.r1, cube.g1, cube.b0)] +
               moment[GetIndex(cube.r1, cube.g0, cube.b0)] +
               moment[GetIndex(cube.r0, cube.g1, cube.b0)] -
               moment[GetIndex(cube.r0, cube.g0, cube.b0)];
end;

function Vol(const cube: TBox; const moment: TIntArray): Int64;
begin
  Result := moment[GetIndex(cube.r1, cube.g1, cube.b1)] -
            moment[GetIndex(cube.r1, cube.g1, cube.b0)] -
            moment[GetIndex(cube.r1, cube.g0, cube.b1)] +
            moment[GetIndex(cube.r1, cube.g0, cube.b0)] -
            moment[GetIndex(cube.r0, cube.g1, cube.b1)] +
            moment[GetIndex(cube.r0, cube.g1, cube.b0)] +
            moment[GetIndex(cube.r0, cube.g0, cube.b1)] -
            moment[GetIndex(cube.r0, cube.g0, cube.b0)];
end;

function Variance(const cube: TBox; const weights: TIntArray;
                  const m_r, m_g, m_b: TIntArray;
                  const moments: TDoubleArray): Double;
var
  dr, dg, db, xx, hypotenuse, volume: Double;
begin
  dr := Vol(cube, m_r);
  dg := Vol(cube, m_g);
  db := Vol(cube, m_b);
  xx := moments[GetIndex(cube.r1, cube.g1, cube.b1)] -
        moments[GetIndex(cube.r1, cube.g1, cube.b0)] -
        moments[GetIndex(cube.r1, cube.g0, cube.b1)] +
        moments[GetIndex(cube.r1, cube.g0, cube.b0)] -
        moments[GetIndex(cube.r0, cube.g1, cube.b1)] +
        moments[GetIndex(cube.r0, cube.g1, cube.b0)] +
        moments[GetIndex(cube.r0, cube.g0, cube.b1)] -
        moments[GetIndex(cube.r0, cube.g0, cube.b0)];
  hypotenuse := dr * dr + dg * dg + db * db;
  volume := Vol(cube, weights);
  Result := xx - hypotenuse / volume;
end;

function Maximize(const cube: TBox; const direction: TDirection;
                  const first, last: Integer; var cut: Integer;
                  const whole_w, whole_r, whole_g, whole_b: Int64;
                  const weights: TIntArray;
                  const m_r, m_g, m_b: TIntArray): Double;
var
  bottom_r, bottom_g, bottom_b, bottom_w: Int64;
  max: Double;
  half_r, half_g, half_b, half_w: Int64;
begin
  bottom_r := Bottom(cube, direction, m_r);
  bottom_g := Bottom(cube, direction, m_g);
  bottom_b := Bottom(cube, direction, m_b);
  bottom_w := Bottom(cube, direction, weights);

  max := 0.0;
  cut := -1;

  for var i := first to last -1 do
  begin
    half_r := bottom_r + Top(cube, direction, i, m_r);
    half_g := bottom_g + Top(cube, direction, i, m_g);
    half_b := bottom_b + Top(cube, direction, i, m_b);
    half_w := bottom_w + Top(cube, direction, i, weights);

    if half_w = 0 then
      Continue;

    var temp := (Double(half_r) * half_r +
                 Double(half_g) * half_g +
                 Double(half_b) * half_b) / Double(half_w);

    half_r := whole_r - half_r;
    half_g := whole_g - half_g;
    half_b := whole_b - half_b;
    half_w := whole_w - half_w;

    if half_w = 0 then
      Continue;

    temp := temp + (Double(half_r) * half_r +
                    Double(half_g) * half_g +
                    Double(half_b) * half_b) / Double(half_w);

    if temp > max then
    begin
      max := temp;
      cut := i;
    end;
  end;

  Result := max;
end;

function Cut(var box1, box2: TBox; const weights, m_r, m_g, m_b: TIntArray): Boolean;
var
  whole_r, whole_g, whole_b, whole_w: Int64;
  cut_r, cut_g, cut_b: Integer;
  max_r, max_g, max_b: Double;
  direction: TDirection;
begin
  whole_r := Vol(box1, m_r);
  whole_g := Vol(box1, m_g);
  whole_b := Vol(box1, m_b);
  whole_w := Vol(box1, weights);

  max_r := Maximize(box1, TDirection.kRed, box1.r0 + 1, box1.r1, cut_r, whole_w,
                    whole_r, whole_g, whole_b, weights, m_r, m_g, m_b);

  max_g := Maximize(box1, TDirection.kGreen, box1.g0 + 1, box1.g1, cut_g, whole_w,
                    whole_r, whole_g, whole_b, weights, m_r, m_g, m_b);

  max_b := Maximize(box1, TDirection.kBlue, box1.b0 + 1, box1.b1, cut_b, whole_w,
                    whole_r, whole_g, whole_b, weights, m_r, m_g, m_b);

  if (max_r >= max_g) and (max_r >= max_b) then
  begin
    direction := TDirection.kRed;
    if (cut_r < 0) then
      Exit(False);
  end
  else if (max_g >= max_r) and (max_g >= max_b) then
    direction := TDirection.kGreen
  else
    direction := TDirection.kBlue;

  box2.r1 := box1.r1;
  box2.g1 := box1.g1;
  box2.b1 := box1.b1;

  if (direction = TDirection.kRed) then
  begin
    box2.r0 := cut_r; box1.r1 := cut_r;
    box2.g0 := box1.g0;
    box2.b0 := box1.b0;
  end
  else if (direction = TDirection.kGreen) then
  begin
    box2.r0 := box1.r0;
    box2.g0 := cut_g; box1.g1 := cut_g;
    box2.b0 := box1.b0;
  end
  else
  begin
    box2.r0 := box1.r0;
    box2.g0 := box1.g0;
    box2.b0 := cut_b; box1.b1 := cut_b;
  end;

  box1.vol := (box1.r1 - box1.r0) * (box1.g1 - box1.g0) * (box1.b1 - box1.b0);
  box2.vol := (box2.r1 - box2.r0) * (box2.g1 - box2.g0) * (box2.b1 - box2.b0);

  Result := True;
end;

function QuantizeWu(const pixels: TArray<TARGB>; max_colors: Word): TArray<TARGB>;
var
  weights: TIntArray;
  moments_red, moments_green, moments_blue: TIntArray;
  moments: TDoubleArray;
  cubes: array[0..kMaxColors-1] of TBox;
  volume_variance: array[0..kMaxColors-1] of Double;
  next, i: Integer;
begin
  if (max_colors <= 0) or (max_colors > 256) or (Length(pixels) = 0) then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  { Setlength() initializes newly allocated space to 0 }
  SetLength(weights, kTotalSize);
  SetLength(moments_red, kTotalSize);
  SetLength(moments_green, kTotalSize);
  SetLength(moments_blue, kTotalSize);
  SetLength(moments, kTotalSize);

  ConstructHistogram(pixels, weights, moments_red, moments_green, moments_blue, moments);
  ComputeMoments(weights, moments_red, moments_green, moments_blue, moments);

  cubes[0].r0 := 0;
  cubes[0].g0 := 0;
  cubes[0].b0 := 0;
  cubes[0].r1 := kIndexCount -1;
  cubes[0].g1 := kIndexCount -1;
  cubes[0].b1 := kIndexCount -1;

  next := 0;
  i := 1;
  while i < max_colors do
  begin
    if (Cut(cubes[next], cubes[i], weights, moments_red, moments_green, moments_blue)) then
    begin
      if cubes[next].vol > 1 then
        volume_variance[next] := Variance(cubes[next], weights, moments_red,
                                          moments_green, moments_blue, moments)
      else
        volume_variance[next] := 0.0;

      if cubes[i].vol > 1 then
        volume_variance[i] := Variance(cubes[i], weights, moments_red,
                                       moments_green, moments_blue, moments)
      else
        volume_variance[i] := 0.0;
    end
    else
    begin
      volume_variance[next] := 0.0;
      Dec(i);
    end;

    next := 0;
    var temp := volume_variance[0];
    for var j := 1 to i do
      if volume_variance[j] > temp then
      begin
        temp := volume_variance[j];
        next := j;
      end;

    if temp <= 0.0 then
    begin
      max_colors := i + 1;
      Break;
    end;

    Inc(i);
  end;

  var out_colors: TList<TARGB> := TList<TARGB>.Create;
  try
    for i := 0 to max_colors -1 do
    begin
      var weight := Vol(cubes[i], weights);
      if weight > 0 then
      begin
        var red: Integer   := Vol(cubes[i], moments_red)   div weight;
        var green: Integer := Vol(cubes[i], moments_green) div weight;
        var blue: Integer  := Vol(cubes[i], moments_blue)  div weight;

        var argb := ArgbFromRgb(red, green, blue);
        out_colors.Add(argb);
      end;
    end;

    Result := out_colors.ToArray;
  finally
    out_colors.Free;
  end;
end;

end.
