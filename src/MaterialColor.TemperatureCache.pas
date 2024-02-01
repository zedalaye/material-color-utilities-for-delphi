unit MaterialColor.TemperatureCache;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Math,
  System.Generics.Collections, System.Generics.Defaults,
  MaterialColor.CAM.HCT;

type
  ITemperatureCache = interface
    ['{FAE2A401-A758-4F8C-9406-2C0E398A9318}']
    function GetComplement: THCT;
    function GetAnalogousColors: TArray<THCT>; overload;
    function GetAnalogousColors(count, divisions: Integer): TArray<THCT>; overload;
    function GetRelativeTemperature(hct: THCT): Double;
  end;

  TTemperatureCache = class(TInterfacedObject, ITemperatureCache)
  private
    FInput: THCT;
    FHasPrecomputedComplement: Boolean;
    FPrecomputedComplement: THCT;
    FPrecomputedHCTSByTemp: TArray<THCT>;
    FPrecomputedHCTSByHue: TArray<THCT>;
    FHCTEqualityComparer: IEqualityComparer<THCT>;
    FPrecomputedTempsByHCT: TDictionary<THCT, Double>;

    (** Coldest color with same chroma and tone as input. *)
    function GetColdest: THCT;

    (** Warmest color with same chroma and tone as input. *)
    function GetWarmest: THCT;

    (** Determines if an angle is between two other angles, rotating clockwise. *)
    class function IsBetween(angle, a, b: Double): Boolean;

    (**
     * HCTs for all colors with the same chroma/tone as the input.
     *
     * <p>Sorted by hue, ex. index 0 is hue 0.
     *)
    function GetHctsByHue: TArray<THCT>;

    (**
     * HCTs for all colors with the same chroma/tone as the input.
     *
     * <p>Sorted from coldest first to warmest last.
     *)
    function GetHctsByTemp: TArray<THCT>;

    (** Keys of HCTs in GetHctsByTemp, values of raw temperature. *)
    function GetTempsByHct: TDictionary<THCT, Double>;
  public
    (**
     * Create a cache that allows calculation of ex. complementary and analogous
     * colors.
     *
     * @param input Color to find complement/analogous colors of. Any colors will
     * have the same tone, and chroma as the input color, modulo any restrictions
     * due to the other hues having lower limits on chroma.
     *)
    constructor Create(input: THCT);
    destructor Destroy; override;

    (**
     * A color that complements the input color aesthetically.
     *
     * <p>In art, this is usually described as being across the color wheel.
     * History of this shows intent as a color that is just as cool-warm as the
     * input color is warm-cool.
     *)
    function GetComplement: THCT;

    (**
     * 5 colors that pair well with the input color.
     *
     * <p>The colors are equidistant in temperature and adjacent in hue.
     *)
    function GetAnalogousColors: TArray<THCT>; overload;

    (**
     * A set of colors with differing hues, equidistant in temperature.
     *
     * <p>In art, this is usually described as a set of 5 colors on a color wheel
     * divided into 12 sections. This method allows provision of either of those
     * values.
     *
     * <p>Behavior is undefined when count or divisions is 0. When divisions <
     * count, colors repeat.
     *
     * @param count The number of colors to return, includes the input color.
     * @param divisions The number of divisions on the color wheel.
     *)
    function GetAnalogousColors(count, divisions: Integer): TArray<THCT>; overload;

    (**
     * Temperature relative to all colors with the same chroma and tone.
     *
     * @param hct HCT to find the relative temperature of.
     * @return Value on a scale from 0 to 1.
     *)
    function GetRelativeTemperature(hct: THCT): Double;

    (**
     * Value representing cool-warm factor of a color. Values below 0 are
     * considered cool, above, warm.
     *
     * <p>Color science has researched emotion and harmony, which art uses to
     * select colors. Warm-cool is the foundation of analogous and complementary
     * colors. See: - Li-Chen Ou's Chapter 19 in Handbook of Color Psychology
     * (2015). - Josef Albers' Interaction of Color chapters 19 and 21.
     *
     * <p>Implementation of Ou, Woodcock and Wright's algorithm, which uses
     * Lab/LCH color space. Return value has these properties:<br>
     * - Values below 0 are cool, above 0 are warm.<br>
     * - Lower bound: -9.66. Chroma is infinite. Assuming max of Lab chroma
     * 130.<br>
     * - Upper bound: 8.61. Chroma is infinite. Assuming max of Lab chroma 130.
     *)
    class function RawTemperature(color: THCT): Double;
  end;

implementation

uses
  MaterialColor.Utils, MaterialColor.Utils.Lab;

{ TTemperatureCache }

constructor TTemperatureCache.Create(input: THCT);
begin
  inherited Create;
  FInput := input;
  FHCTEqualityComparer := THCTEqualityComparer.Create;
  FPrecomputedTempsByHCT := TDictionary<THCT, Double>.Create(FHCTEqualityComparer);
  FHasPrecomputedComplement := False;
end;

destructor TTemperatureCache.Destroy;
begin
  FPrecomputedTempsByHCT.Free;
  FHCTEqualityComparer := nil;
  inherited;
end;

function TTemperatureCache.GetComplement: THCT;
var
  coldest_hue, coldest_temp: Double;
  warmest_hue, warmest_temp: Double;
  range: Double;
  start_hue_is_coldest_to_warmest: Boolean;
  start_hue, end_hue: Double;
  direction_of_rotation: Double;
  smallest_error: Double;
  answer: THCT;
  complement_relative_temp: Double;
begin
  if FHasPrecomputedComplement then
    Exit(FPrecomputedComplement);

  coldest_hue := GetColdest.Hue;
  coldest_temp := GetTempsByHct[GetColdest];

  warmest_hue := GetWarmest.Hue;
  warmest_temp := GetTempsByHct[GetWarmest];
  range := warmest_temp - coldest_temp;
  start_hue_is_coldest_to_warmest := IsBetween(FInput.Hue, coldest_hue, warmest_hue);

  if start_hue_is_coldest_to_warmest then
  begin
    start_hue := warmest_hue;
    end_hue := coldest_hue;
  end
  else
  begin
    start_hue := coldest_hue;
    end_hue := warmest_hue;
  end;

  direction_of_rotation := 1.0;
  smallest_error := 1000.0;
  answer := GetHctsByHue[Round(Finput.Hue)];

  if range <> 0.0 then // avoid DivisionByZero
  begin
    complement_relative_temp := (1.0 - GetRelativeTemperature(Finput));
    // Find the color in the other section, closest to the inverse percentile
    // of the input color. This is the complement.
    var hue_addend := 0.0;
    while hue_addend <= 360.0 do
    begin
      var hue := SanitizeDegreesDouble(start_hue + direction_of_rotation * hue_addend);
      if IsBetween(hue, start_hue, end_hue) then
      begin
        var possible_answer := GetHctsByHue[Round(hue)];
        var relative_temp := (GetTempsByHct[possible_answer] - coldest_temp) / range;
        var error := Abs(complement_relative_temp - relative_temp);
        if (error < smallest_error) then
        begin
          smallest_error := error;
          answer := possible_answer;
        end;
      end;
      hue_addend := hue_addend + 1.0;
    end;
  end;

  FPrecomputedComplement := answer;
  FHasPrecomputedComplement := True;

  Result := FPrecomputedComplement;
end;

function TTemperatureCache.GetAnalogousColors: TArray<THCT>;
begin
  Result := GetAnalogousColors(5, 12);
end;

function TTemperatureCache.GetAnalogousColors(count,
  divisions: Integer): TArray<THCT>;
var
  start_hue: Integer;
  start_hct: THCT;
  last_temp: Double;
  all_colors, answers: TList<THCT>;
  absolute_total_temp_delta: Double;
  hue_addend: Integer;
  temp_step: Double;
  total_temp_delta: Double;
  ccw_count, cw_count: Integer;
begin
  // The starting hue is the hue of the input color.
  start_hue := Round(Finput.Hue);
  start_hct := GetHctsByHue[start_hue];
  last_temp := GetRelativeTemperature(start_hct);

  all_colors := TList<THCT>.Create;
  try
    all_colors.Add(start_hct);

    absolute_total_temp_delta := 0.0;
    for var i := 0 to 360 -1 do
    begin
      var hue := SanitizeDegreesInt(start_hue + i);
      var hct := GetHctsByHue[hue];
      var temp := GetRelativeTemperature(hct);
      var temp_delta := Abs(temp - last_temp);
      last_temp := temp;
      absolute_total_temp_delta := absolute_total_temp_delta + temp_delta;
    end;

    hue_addend := 1;
    temp_step := absolute_total_temp_delta / Double(divisions);
    total_temp_delta := 0.0;
    last_temp := GetRelativeTemperature(start_hct);
    while all_colors.Count < divisions do
    begin
      var hue := SanitizeDegreesInt(start_hue + hue_addend);
      var hct := GetHctsByHue[hue];
      var temp := GetRelativeTemperature(hct);
      var temp_delta := Abs(temp - last_temp);
      total_temp_delta := total_temp_delta + temp_delta;

      var desired_total_temp_delta_for_index := (all_colors.Count * temp_step);
      var index_satisfied := total_temp_delta >= desired_total_temp_delta_for_index;
      var index_addend := 1;
      // Keep adding this hue to the answers until its temperature is
      // insufficient. This ensures consistent behavior when there aren't
      // `divisions` discrete steps between 0 and 360 in hue with `temp_step`
      // delta in temperature between them.
      //
      // For example, white and black have no analogues: there are no other
      // colors at T100/T0. Therefore, they should just be added to the array
      // as answers.
      while index_satisfied and (all_colors.Count < divisions) do
      begin
        all_colors.Add(hct);
        desired_total_temp_delta_for_index := ((all_colors.Count + index_addend) * temp_step);
        index_satisfied := total_temp_delta >= desired_total_temp_delta_for_index;
        Inc(index_addend);
      end;
      last_temp := temp;
      Inc(hue_addend);

      if hue_addend > 360 then
      begin
        while all_colors.Count < divisions do
          all_colors.Add(hct);
        Break;
      end;
    end;

    answers := TList<THCT>.Create;
    try
      answers.Add(FInput);

      ccw_count := Floor((Double(count) - 1.0) / 2.0);
      for var i := 1 to ccw_count do  // i < (ccw_count + 1)
      begin
        var index := 0 - i;
        while index < 0 do
          index := all_colors.Count + index;

        if index >= all_colors.Count then
          index := index mod all_colors.Count;

        answers.Insert(0, all_colors[index]);
      end;

      cw_count := count - ccw_count - 1;
      for var i := 1 to cw_count do  // i < (cw_count + 1)
      begin
        var index := i;
        while index < 0 do
          index := all_colors.Count + index;
        if index >= all_colors.Count then
          index := index mod all_colors.Count;
        answers.Add(all_colors[index]);
      end;

      Result := answers.ToArray;
    finally
      answers.Free;
    end;
  finally
    all_colors.Free;
  end;
end;

function TTemperatureCache.GetRelativeTemperature(hct: THCT): Double;
var
  range, difference_from_coldest: Double;
begin
  range := GetTempsByHct[GetWarmest] - GetTempsByHct[GetColdest];
  difference_from_coldest := GetTempsByHct[hct] - GetTempsByHct[GetColdest];
  // Handle when there's no difference in temperature between warmest and
  // coldest: for example, at T100, only one color is available, white.
  if range = 0.0 then
    Result := 0.5
  else
    Result := difference_from_coldest / range;
end;

class function TTemperatureCache.RawTemperature(color: THCT): Double;
var
  lab: TLab;
  hue, chroma: Double;
begin
  lab := LabFromInt(color.ToInt);
  hue := SanitizeDegreesDouble(ArcTan2(lab.b, lab.a) * 180.0 / kPi);
  chroma := Hypot(lab.a, lab.b);
  Result := -0.5 + 0.02 * Power(chroma, 1.07) * Cos(SanitizeDegreesDouble(hue - 50.0) * kPi / 180);
end;

function TTemperatureCache.GetColdest: THCT;
begin
  Result := GetHctsByTemp[0];
end;

function TTemperatureCache.GetHctsByHue: TArray<THCT>;
var
  hcts: TList<THCT>;
begin
  if Length(FPrecomputedHCTSByHue) > 0 then
    Exit(FPrecomputedHCTSByHue);

  hcts := TList<THCT>.Create;
  try
    var hue: Double := 0.0;
    while hue <= 360.0 do
    begin
      var color_at_hue := THCT.Create(hue, FInput.Chroma, FInput.Tone);
      hcts.Add(color_at_hue);
      hue := hue + 1.0;
    end;

    FPrecomputedHCTSByHue := hcts.ToArray;
    Result := FPrecomputedHCTSByHue;
  finally
    hcts.Free;
  end;
end;

function TTemperatureCache.GetHctsByTemp: TArray<THCT>;
var
  hcts: TList<THCT>;
  temps_by_hct: TDictionary<THCT, Double>;
begin
  if Length(FPrecomputedHCTSByTemp) > 0 then
    Exit(FPrecomputedHCTSByTemp);

  hcts := TList<THCT>.Create;
  try
    hcts.AddRange(GetHctsByHue);
    hcts.Add(FInput);

    temps_by_hct := GetTempsByHct;
    hcts.Sort(
      TComparer<THCT>.Construct(
        function(const A, B: THCT): Integer
        begin
          Result := CompareValue(temps_by_hct[A], temps_by_hct[B]);
        end
      )
    );

    FPrecomputedHCTSByTemp := hcts.ToArray;
    Result := FPrecomputedHCTSByTemp;
  finally
    hcts.Free;
  end;
end;

function TTemperatureCache.GetTempsByHct: TDictionary<THCT, Double>;
var
  all_hcts: TList<THCT>;
begin
  if FPrecomputedTempsByHCT.Count > 0 then
    Exit(FPrecomputedTempsByHCT);

  all_hcts := TList<THCT>.Create;
  try
    all_hcts.AddRange(GetHctsByHue);
    all_hcts.Add(FInput);

    for var hct in all_hcts do
      FPrecomputedTempsByHCT.AddOrSetValue(hct, RawTemperature(hct));

    Result := FPrecomputedTempsByHCT;
  finally
    all_hcts.Free;
  end;
end;

function TTemperatureCache.GetWarmest: THCT;
begin
  Result := GetHctsByTemp[Length(GetHctsByTemp) - 1];
end;

class function TTemperatureCache.IsBetween(angle, a, b: Double): Boolean;
begin
  if (a < b) then
    Result := (a <= angle) and (angle <= b)
  else
    Result := (a <= angle) or (angle <= b);
end;

end.
