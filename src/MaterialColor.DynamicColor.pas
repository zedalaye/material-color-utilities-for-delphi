unit MaterialColor.DynamicColor;

interface

uses
  System.SysUtils, System.Math,
  MaterialColor.Utils,
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.ContrastCurve,
  MaterialColor.DynamicColor.ToneDeltaPair,
  MaterialColor.DynamicColor.DynamicScheme,
  MaterialColor.Palettes.Tones;

type
  IDynamicColor = interface; { forward definition }

  (**
   * Describes the different in tone between colors.
   *)
  TTonePolarity = (kDarker, kLighter, kNearer, kFarther);

  (**
   * Documents a constraint between two DynamicColors, in which their tones must
   * have a certain distance from each other.
   *
   * Prefer a DynamicColor with a background, this is for special cases when
   * designers want tonal distance, literally contrast, between two colors that
   * don't have a background / foreground relationship or a contrast guarantee.
   *)
  TToneDeltaPair = record
    role_a: IDynamicColor;
    role_b: IDynamicColor;
    delta: Double;
    polarity: TTonePolarity;
    stay_together: Boolean;

    (**
     * Documents a constraint in tone distance between two DynamicColors.
     *
     * The polarity is an adjective that describes "A", compared to "B".
     *
     * For instance, ToneDeltaPair(A, B, 15, 'darker', stayTogether) states that
     * A's tone should be at least 15 darker than B's.
     *
     * 'nearer' and 'farther' describes closeness to the surface roles. For
     * instance, ToneDeltaPair(A, B, 10, 'nearer', stayTogether) states that A
     * should be 10 lighter than B in light mode, and 10 darker than B in dark
     * mode.
     *
     * @param roleA The first role in a pair.
     * @param roleB The second role in a pair.
     * @param delta Required difference between tones. Absolute value, negative
     * values have undefined behavior.
     * @param polarity The relative relation between tones of roleA and roleB,
     * as described above.
     * @param stayTogether Whether these two roles should stay on the same side of
     * the "awkward zone" (T50-59). This is necessary for certain cases where
     * one role has two backgrounds.
     *)
    constructor Create(const role_a, role_b: IDynamicColor; delta: Double;
      polarity: TTonePolarity; stay_together: Boolean);
  end;

  IDynamicColor = interface
    ['{F4CF6757-59F2-46B7-A716-89C4DC6ECD79}']
    function GetName: string;
    function GetPaletteFunc: TFunc<TDynamicScheme, TTonalPalette>;
    function GetToneFunc: TFunc<TDynamicScheme, Double>;
    function GetIsBackground: Boolean;
    function GetBackgroundFunc: TFunc<TDynamicScheme, IDynamicColor>;
    function GetSecondBackgroundFunc: TFunc<TDynamicScheme, IDynamicColor>;
    function GetContrastCurve: IContrastCurve;
    function GetToneDeltaPairFunc: TFunc<TDynamicScheme, TToneDeltaPair>;

    (* useful methods *)

    function GetArgb(const scheme: TDynamicScheme): TARGB;
    function GetHct(const scheme: TDynamicScheme): THCT;
    function GetTone(const scheme: TDynamicScheme): Double;

    (* accessors to internal properties *)

    property Name: string read GetName;

    property Palette: TFunc<TDynamicScheme, TTonalPalette> read GetPaletteFunc;
    property Tone: TFunc<TDynamicScheme, Double> read GetToneFunc;
    property IsBackground: Boolean read GetIsBackground;
    property Background: TFunc<TDynamicScheme, IDynamicColor> read GetBackgroundFunc;
    property SecondBackground: TFunc<TDynamicScheme, IDynamicColor> read GetSecondBackgroundFunc;
    property ContrastCurve: IContrastCurve read GetContrastCurve;
    property ToneDeltaPair: TFunc<TDynamicScheme, TToneDeltaPair> read GetToneDeltaPairFunc;
  end;

(**
 * @param name_ The name of the dynamic color.
 * @param palette_ Function that provides a TonalPalette given
 * DynamicScheme. A TonalPalette is defined by a hue and chroma, so this
 * replaces the need to specify hue/chroma. By providing a tonal palette, when
 * contrast adjustments are made, intended chroma can be preserved.
 * @param tone_ Function that provides a tone given DynamicScheme.
 * @param is_background_ Whether this dynamic color is a background, with
 * some other color as the foreground.
 * @param background_ The background of the dynamic color (as a function of a
 *     `DynamicScheme`), if it exists.
 * @param second_background_ A second background of the dynamic color (as a
 *     function of a `DynamicScheme`), if it
 * exists.
 * @param contrast_curve_ A `ContrastCurve` object specifying how its contrast
 * against its background should behave in various contrast levels options.
 * @param tone_delta_pair_ A `ToneDeltaPair` object specifying a tone delta
 * constraint between two colors. One of them must be the color being
 * constructed.
 *)

  TDynamicColor = class(TInterfacedObject, IDynamicColor)
  private
    FName: string;

    FPalette: TFunc<TDynamicScheme, TTonalPalette>;
    FTone: TFunc<TDynamicScheme, Double>;
    FIsBackground: Boolean;

    FBackground: TFunc<TDynamicScheme, IDynamicColor>;
    FSecondBackground: TFunc<TDynamicScheme, IDynamicColor>;
    FContrastCurve: IContrastCurve;
    FToneDeltaPair: TFunc<TDynamicScheme, TToneDeltaPair>;

    function GetName: string;
    function GetPaletteFunc: TFunc<TDynamicScheme, TTonalPalette>;
    function GetToneFunc: TFunc<TDynamicScheme, Double>;
    function GetIsBackground: Boolean;
    function GetBackgroundFunc: TFunc<TDynamicScheme, IDynamicColor>;
    function GetSecondBackgroundFunc: TFunc<TDynamicScheme, IDynamicColor>;
    function GetContrastCurve: IContrastCurve;
    function GetToneDeltaPairFunc: TFunc<TDynamicScheme, TToneDeltaPair>;
  public
    (** The default constructor. *)
    constructor Create(
      const Name: string;
      Palette: TFunc<TDynamicScheme, TTonalPalette>;
      Tone: TFunc<TDynamicScheme, Double>;
      IsBackground: Boolean;

      Background: TFunc<TDynamicScheme, IDynamicColor>;
      SecondBackground: TFunc<TDynamicScheme, IDynamicColor>;
      ContrastCurve: IContrastCurve;
      ToneDeltaPair: TFunc<TDynamicScheme, TToneDeltaPair>
    );

    class function FromPalette(
      const Name: string;
      Palette: TFunc<TDynamicScheme, TTonalPalette>;
      Tone: TFunc<TDynamicScheme, Double>
    ): IDynamicColor;

    function GetArgb(const scheme: TDynamicScheme): TARGB;

    function GetHct(const scheme: TDynamicScheme): THCT;

    function GetTone(const scheme: TDynamicScheme): Double;
  end;

(**
 * Given a background tone, find a foreground tone, while ensuring they reach
 * a contrast ratio that is as close to [ratio] as possible.
 *
 * [bgTone] Tone in HCT. Range is 0 to 100, undefined behavior when it falls
 * outside that range.
 * [ratio] The contrast ratio desired between [bgTone] and the return value.
 *)
function ForegroundTone(bg_tone, ratio: Double): Double;

(**
 * Adjust a tone such that white has 4.5 contrast, if the tone is
 * reasonably close to supporting it.
 *)
function EnableLightForeground(tone: Double): Double;

(**
 * Returns whether [tone] prefers a light foreground.
 *
 * People prefer white foregrounds on ~T60-70. Observed over time, and also
 * by Andrew Somers during research for APCA.
 *
 * T60 used as to create the smallest discontinuity possible when skipping
 * down to T49 in order to ensure light foregrounds.
 *
 * Since `tertiaryContainer` in dark monochrome scheme requires a tone of
 * 60, it should not be adjusted. Therefore, 60 is excluded here.
 *)
function TonePrefersLightForeground(tone: Double): Boolean;

(**
 * Returns whether [tone] can reach a contrast ratio of 4.5 with a lighter
 * color.
 *)
function ToneAllowsLightForeground(tone: Double): Boolean;

implementation

uses
  MaterialColor.Contrast;

function ForegroundTone(bg_tone, ratio: Double): Double;
var
  lighter_tone, darker_tone, lighter_ratio, darker_ratio: Double;
  prefer_lighter: Boolean;
  negligible_difference: Boolean;
begin
  lighter_tone   := LighterUnsafe( { tone } bg_tone, { ratio } ratio);
  darker_tone    := DarkerUnsafe( { tone } bg_tone, { ratio } ratio);
  lighter_ratio  := RatioOfTones(lighter_tone, bg_tone);
  darker_ratio   := RatioOfTones(darker_tone, bg_tone);
  prefer_lighter := TonePrefersLightForeground(bg_tone);

  if (prefer_lighter) then
  begin
    negligible_difference :=
        ((Abs(lighter_ratio - darker_ratio) < 0.1) and (lighter_ratio < ratio) and
         (darker_ratio < ratio));

    if (lighter_ratio >= ratio) or (lighter_ratio >= darker_ratio) or negligible_difference then
      Result := lighter_tone
    else
      Result := darker_tone;
  end
  else if (darker_ratio >= ratio) or (darker_ratio >= lighter_ratio) then
    Result := darker_tone
  else
    Result := lighter_tone;
end;

function EnableLightForeground(tone: Double): Double;
begin
  Result := tone;
  if TonePrefersLightForeground(tone) and (not ToneAllowsLightForeground(tone)) then
    Result := 49.0;
end;

function TonePrefersLightForeground(tone: Double): Boolean;
begin
  Result := Round(tone) < 60;
end;

function ToneAllowsLightForeground(tone: Double): Boolean;
begin
  Result := Round(tone) <= 49;
end;

{ TToneDeltaPair }

constructor TToneDeltaPair.Create(const role_a, role_b: IDynamicColor;
  delta: Double; polarity: TTonePolarity; stay_together: Boolean);
begin
  Self.role_a := role_a;
  Self.role_b := role_b;
  Self.delta := delta;
  Self.polarity := polarity;
  Self.stay_together := stay_together;
end;

{ TDynamicColor }

constructor TDynamicColor.Create(const Name: string;
  Palette: TFunc<TDynamicScheme, TTonalPalette>;
  Tone: TFunc<TDynamicScheme, Double>; IsBackground: Boolean; Background,
  SecondBackground: TFunc<TDynamicScheme, IDynamicColor>;
  ContrastCurve: IContrastCurve;
  ToneDeltaPair: TFunc<TDynamicScheme, TToneDeltaPair>);
begin
  inherited Create;
  FName := Name;
  FPalette := Palette;
  FTone := Tone;
  FIsBackground := IsBackground;
  FBackground := Background;
  FSecondBackground := SecondBackground;
  FContrastCurve := ContrastCurve;
  FToneDeltaPair := ToneDeltaPair;
end;

class function TDynamicColor.FromPalette(const Name: string;
  Palette: TFunc<TDynamicScheme, TTonalPalette>;
  Tone: TFunc<TDynamicScheme, Double>): IDynamicColor;
begin
  Result := TDynamicColor.Create(
    Name, Palette, Tone,
    { IsBackground } False,
    { Background } nil,
    { SecondaryBackground } nil,
    { ContrastCurve } nil,
    { ToneDeltaPair} nil
  )
end;

(* accessors *)

function TDynamicColor.GetName: string;
begin
  Result := FName;
end;

function TDynamicColor.GetPaletteFunc: TFunc<TDynamicScheme, TTonalPalette>;
begin
  Result := FPalette;
end;

function TDynamicColor.GetToneFunc: TFunc<TDynamicScheme, Double>;
begin
  Result := FTone;
end;

function TDynamicColor.GetIsBackground: Boolean;
begin
  Result := FIsBackground;
end;

function TDynamicColor.GetBackgroundFunc: TFunc<TDynamicScheme, IDynamicColor>;
begin
  Result := FBackground;
end;

function TDynamicColor.GetSecondBackgroundFunc: TFunc<TDynamicScheme, IDynamicColor>;
begin
  Result := FSecondBackground;
end;

function TDynamicColor.GetContrastCurve: IContrastCurve;
begin
  Result := FContrastCurve;
end;

function TDynamicColor.GetToneDeltaPairFunc: TFunc<TDynamicScheme, TToneDeltaPair>;
begin
  Result := FToneDeltaPair;
end;

(* useful methods *)

function TDynamicColor.GetArgb(const scheme: TDynamicScheme): TARGB;
begin
  Result := FPalette(Scheme).Get(GetTone(Scheme));
end;

function TDynamicColor.GetHct(const scheme: TDynamicScheme): THCT;
begin
  Result := THCT.Create(GetArgb(scheme));
end;

function TDynamicColor.GetTone(const scheme: TDynamicScheme): Double;
var
  decreasingContrast: Boolean;
  tone_delta_pair: TToneDeltaPair;
  role_a, role_b: IDynamicColor;
begin
  decreasingContrast := scheme.contrast_level < 0;

  // Case 1: dual foreground, pair of colors with delta constraint.
  if Assigned(FToneDeltaPair) then
  begin
    tone_delta_pair := FToneDeltaPair(scheme);
    role_a := tone_delta_pair.role_a;
    role_b := tone_delta_pair.role_b;
    var delta: Double := tone_delta_pair.delta;
    var polarity: TTonePolarity := tone_delta_pair.polarity;
    var stay_together: Boolean := tone_delta_pair.stay_together;

    var bg: IDynamicColor := FBackground(scheme);
    var bg_tone: Double := bg.GetTone(scheme);

    var a_is_nearer :=
        (polarity = TTonePolarity.kNearer) or
        ((polarity = TTonePolarity.kLighter) and (not scheme.is_dark)) or
        ((polarity = TTonePolarity.kDarker) and scheme.is_dark);

    var nearer: IDynamicColor;
    var farther: IDynamicColor;
    if a_is_nearer then
    begin
      nearer := role_a;
      farther := role_b;
    end
    else
    begin
      nearer := role_b;
      farther := role_a;
    end;

    var am_nearer := FName = nearer.Name;

    var expansion_dir: Double;
    if scheme.is_dark then
      expansion_dir := 1
    else
      expansion_dir := -1;

    // 1st round: solve to min, each
    var n_contrast: Double :=
        nearer.ContrastCurve.Get(scheme.contrast_level);
    var f_contrast: Double :=
        farther.ContrastCurve.Get(scheme.contrast_level);

    // If a color is good enough, it is not adjusted.
    // Initial and adjusted tones for `nearer`
    var n_initial_tone: Double := nearer.Tone(scheme);
    var n_tone: Double;
    if RatioOfTones(bg_tone, n_initial_tone) >= n_contrast then
      n_tone := n_initial_tone
    else
      n_tone := ForegroundTone(bg_tone, n_contrast);

    // Initial and adjusted tones for `farther`
    var f_initial_tone: Double := farther.Tone(scheme);
    var f_tone: Double;
    if RatioOfTones(bg_tone, f_initial_tone) >= f_contrast then
      f_tone := f_initial_tone
    else
      f_tone := ForegroundTone(bg_tone, f_contrast);

    if (decreasingContrast) then
    begin
      // If decreasing contrast, adjust color to the "bare minimum"
      // that satisfies contrast.
      n_tone := ForegroundTone(bg_tone, n_contrast);
      f_tone := ForegroundTone(bg_tone, f_contrast);
    end;

    if ((f_tone - n_tone) * expansion_dir >= delta) then
      // Good! Tones satisfy the constraint; no change needed.
    else
    begin
      // 2nd round: expand farther to match delta.
      f_tone := Clamp(n_tone + delta * expansion_dir, 0.0, 100.0);
      if ((f_tone - n_tone) * expansion_dir >= delta) then
        // Good! Tones now satisfy the constraint; no change needed.
      else
        // 3rd round: contract nearer to match delta.
        n_tone := Clamp(f_tone - delta * expansion_dir, 0.0, 100.0);
    end;

    // Avoids the 50-59 awkward zone.
    if (50 <= n_tone) and (n_tone < 60) then
      // If `nearer` is in the awkward zone, move it away, together with
      // `farther`.
      if (expansion_dir > 0) then
      begin
        n_tone := 60;
        f_tone := Max(f_tone, n_tone + delta * expansion_dir);
      end
      else
      begin
        n_tone := 49;
        f_tone := Min(f_tone, n_tone + delta * expansion_dir);
      end
    else if (50 <= f_tone) and (f_tone < 60) then
      if (stay_together) then
        // Fixes both, to avoid two colors on opposite sides of the "awkward
        // zone".
        if (expansion_dir > 0) then
        begin
          n_tone := 60;
          f_tone := Max(f_tone, n_tone + delta * expansion_dir);
        end
        else
        begin
          n_tone := 49;
          f_tone := Min(f_tone, n_tone + delta * expansion_dir);
        end
      else
        // Not required to stay together; fixes just one.
        if (expansion_dir > 0) then
          f_tone := 60
        else
          f_tone := 49;

    // Returns `n_tone` if this color is `nearer`, otherwise `f_tone`.
    if am_nearer then
      Exit(n_tone)
     else
      Exit(f_tone);
  end
  else
  begin
    // Case 2: No contrast pair; just solve for itself.
    var answer: Double := FTone(scheme);

    if not Assigned(FBackground) then
      Exit(answer); // No adjustment for colors with no background.

    var bg_tone: Double := FBackground(scheme).GetTone(scheme);

    var desired_ratio: Double := FContrastCurve.Get(scheme.contrast_level);

    if (RatioOfTones(bg_tone, answer) >= desired_ratio) then
      // Don't "improve" what's good enough.
    else
      // Rough improvement.
      answer := ForegroundTone(bg_tone, desired_ratio);

    if (decreasingContrast) then
      answer := ForegroundTone(bg_tone, desired_ratio);

    if FIsBackground and (50 <= answer) and (answer < 60) then
      // Must adjust
      if (RatioOfTones(49, bg_tone) >= desired_ratio) then
        answer := 49
      else
        answer := 60;

    if Assigned(FSecondBackground) then
    begin
      // Case 3: Adjust for dual backgrounds.

      var bg_tone_1: Double := FBackground(scheme).GetTone(scheme);
      var bg_tone_2: Double := FSecondBackground(scheme).GetTone(scheme);

      var upper: Double := Max(bg_tone_1, bg_tone_2);
      var lower: Double := Min(bg_tone_1, bg_tone_2);

      if (RatioOfTones(upper, answer) >= desired_ratio) and
         (RatioOfTones(lower, answer) >= desired_ratio) then
        Exit(answer);

      // The darkest light tone that satisfies the desired ratio,
      // or -1 if such ratio cannot be reached.
      var lightOption: Double := Lighter(upper, desired_ratio);

      // The lightest dark tone that satisfies the desired ratio,
      // or -1 if such ratio cannot be reached.
      var darkOption: Double := Darker(lower, desired_ratio);

      // Tones suitable for the foreground.
      var availables: TArray<Double>;
      if (lightOption <> -1) then
      begin
        SetLength(availables, 1);
        availables[0] := lightOption;
      end;
      if (darkOption <> -1) then
      begin
        SetLength(availables, 1);
        availables[0] := darkOption;
      end;

      var prefersLight := TonePrefersLightForeground(bg_tone_1) or
                          TonePrefersLightForeground(bg_tone_2);

      if (prefersLight) then
        if lightOption < 0 then
          Exit(100)
        else
          Exit(lightOption);

      if Length(availables) = 1 then
        Exit(availables[0]);

      if darkOption < 0 then
        Exit(0)
      else
        Exit(darkOption);
    end;

    Result := answer;
  end;
end;

end.
