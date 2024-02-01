unit MaterialColor.Score;

interface

uses
  System.Math, System.Generics.Collections, System.Generics.Defaults,
  MaterialColor.Utils;

type
  (**
   * Default options for ranking colors based on usage counts.
   * `desired`: is the max count of the colors returned.
   * `fallback_color_argb`: Is the default color that should be used if no
   *                        other colors are suitable.
   * `filter`: controls if the resulting colors should be filtered to not include
   *         hues that are not used often enough, and colors that are effectively
   *         grayscale.
   *)
  TScoreOptions = record
    desired: Integer;
    fallback_color_argb: TARGB;
    filter: Boolean;

    class function Default: TScoreOptions; static;

    constructor Create(Desired: Integer); overload;
    constructor Create(Desired: Integer; FallbackColor: TARGB; Filter: Boolean); overload;
  end;

  TArgbToPopulationMap = TDictionary<TARGB, Cardinal>;

(**
 * Given a map with keys of colors and values of how often the color appears,
 * rank the colors based on suitability for being used for a UI theme.
 *
 * The list returned is of length <= [desired]. The recommended color is the
 * first item, the least suitable is the last. There will always be at least
 * one color returned. If all the input colors were not suitable for a theme,
 * a default fallback color will be provided, Google Blue, or supplied fallback
 * color. The default number of colors returned is 4, simply because that's the
 * # of colors display in Android 12's wallpaper picker.
 *)
function RankedSuggestions(argb_to_population: TArgbToPopulationMap; options: TScoreOptions): TArray<TARGB>;

implementation

uses
  MaterialColor.CAM.HCT;

const
  kTargetChroma:            Double = 48.0;  // A1 Chroma
  kWeightProportion:        Double = 0.7;
  kWeightChromaAbove:       Double = 0.3;
  kWeightChromaBelow:       Double = 0.1;
  kCutoffChroma:            Double = 5.0;
  kCutoffExcitedProportion: Double = 0.01;

type
  TScoredHCT = record
    hct: THCT;
    score: Double;
    constructor Create(hct: THCT; score: Double);
  end;

function CompareScoredHCT(const a, b: TScoredHCT): Integer;
begin
  Result := CompareValue(b.score, a.score);
end;

function RankedSuggestions(argb_to_population: TArgbToPopulationMap; options: TScoreOptions): TArray<TARGB>;
var
  colors_hct: TList<THCT>;
  hue_population: array[0..360-1] of Cardinal;
  hue_excited_proportions: array[0..360-1] of Double;
  population_sum: Double;
  scored_hcts: TList<TScoredHCT>;
  chosen_colors: TList<THCT>;
  colors: TList<TARGB>;
begin
  // Get the HCT color for each Argb value, while finding the per hue count and
  // total count.
  colors_hct := TList<THCT>.Create;
  scored_hcts := TList<TScoredHCT>.Create;
  chosen_colors := TList<THCT>.Create;
  try
    for var I := 0 to 359 do
    begin
      hue_population[I] := 0;
      hue_excited_proportions[I] := 0;
    end;

    population_sum := 0;
    for var P in argb_to_population do
    begin
      var hct := THCT.Create(P.Key);
      colors_hct.Add(hct);
      var hue := Floor(hct.Hue);
      hue_population[hue] := hue_population[hue] + P.Value;
      population_sum := population_sum + P.Value;
    end;

    // Hues with more usage in neighboring 30 degree slice get a larger number.
    for var hue := 0 to High(hue_population) do
    begin
      var proportion := hue_population[hue] / population_sum;
      for var I := hue - 14 to (hue + 16) -1 do
      begin
        var neighbor_hue := SanitizeDegreesInt(i);
        hue_excited_proportions[neighbor_hue] := hue_excited_proportions[neighbor_hue] + proportion;
      end;
    end;

    // Scores each HCT color based on usage and chroma, while optionally
    // filtering out values that do not have enough chroma or usage.
    for var hct in colors_hct do
    begin
      var hue := SanitizeDegreesInt(Round(hct.Hue));
      var proportion := hue_excited_proportions[hue];
      if options.filter and ((hct.Chroma < kCutoffChroma) or
                             (proportion <= kCutoffExcitedProportion)) then
        Continue;

      var proportion_score := proportion * 100.0 * kWeightProportion;

      var chroma_weight: Double;
      if hct.Chroma < kTargetChroma then
        chroma_weight := kWeightChromaBelow
      else
        chroma_weight := kWeightChromaAbove;

      var chroma_score := (hct.Chroma - kTargetChroma) * chroma_weight;
      var score := proportion_score + chroma_score;

      scored_hcts.Add(TScoredHCT.Create(hct, score));
    end;

    // Sorted so that colors with higher scores come first.
    scored_hcts.Sort(
      TComparer<TScoredHCT>.Construct(
        function(const Left, Right: TScoredHCT): Integer
        begin
          Result := CompareScoredHCT(Left, Right);
        end
      )
    );

    // Iterates through potential hue differences in degrees in order to select
    // the colors with the largest distribution of hues possible. Starting at
    // 90 degrees(maximum difference for 4 colors) then decreasing down to a
    // 15 degree minimum.

    (*
        auto duplicate_hue = std::find_if(
            chosen_colors.begin(), chosen_colors.end(),
            [&hct, difference_degrees](Hct chosen_hct) {
              return DiffDegrees(hct.get_hue(), chosen_hct.get_hue()) <
                     difference_degrees;
            });
        if (duplicate_hue == chosen_colors.end()) {
          chosen_colors.push_back(hct);
          if (chosen_colors.size() >= options.desired) break;
        }
      }
      if (chosen_colors.size() >= options.desired) break;
    *)

    for var difference_degrees := 90 downto 15 do
    begin
      chosen_colors.Clear;
      for var entry in scored_hcts do
      begin
        var hct := entry.hct;
        var duplicate_hue: Boolean := False;
        for var chosen_hct in chosen_colors do
          if DiffDegrees(hct.Hue, chosen_hct.Hue) < difference_degrees then
          begin
            duplicate_hue := True;
            Break;
          end;
        if not duplicate_hue then
        begin
          chosen_colors.Add(hct);
          if chosen_colors.Count >= options.desired then
            Break;
        end;
      end;
      if chosen_colors.Count >= options.desired then
        Break;
    end;

    colors := TList<TARGB>.Create;
    try
      if chosen_colors.Count = 0 then
        colors.Add(options.fallback_color_argb);
      for var chosen_hct in chosen_colors do
        colors.Add(chosen_hct.ToInt);
      Result := colors.ToArray;
    finally
      colors.Free;
    end;
  finally
    chosen_colors.Free;
    scored_hcts.Free;
    colors_hct.Free;
  end;
end;

{ TScoreOptions }

constructor TScoreOptions.Create(Desired: Integer);
begin
  Self := Default;
  Self.desired := Desired;
end;

constructor TScoreOptions.Create(Desired: Integer; FallbackColor: TARGB;
  Filter: Boolean);
begin
  Self.desired := Desired;
  Self.fallback_color_argb := FallbackColor;
  Self.filter := Filter;
end;

class function TScoreOptions.Default: TScoreOptions;
begin
  Result.desired := 4; // 4 colors matches the Android wallpaper picker.
  Result.fallback_color_argb := $ff4285f4;  // Google Blue.
  Result.filter := True; // Avoid unsuitable colors.
end;

{ TScoredHCT }

constructor TScoredHCT.Create(hct: THCT; score: Double);
begin
  Self.hct := hct;
  Self.score := score;
end;

end.
