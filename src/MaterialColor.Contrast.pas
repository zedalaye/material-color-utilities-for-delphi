unit MaterialColor.Contrast;

interface

uses
  MaterialColor.Utils;

(**
 * Utility methods for calculating contrast given two colors, or calculating a
 * color given one color and a contrast ratio.
 *
 * Contrast ratio is calculated using XYZ's Y. When linearized to match human
 * perception, Y becomes HCT's tone and L*a*b*'s' L*. Informally, this is the
 * lightness of a color.
 *
 * Methods refer to tone, T in the the HCT color space.
 * Tone is equivalent to L* in the L*a*b* color space, or L in the LCH color
 * space.
 *)

(**
 * @return a contrast ratio, which ranges from 1 to 21.
 * @param tone_a Tone between 0 and 100. Values outside will be clamped.
 * @param tone_b Tone between 0 and 100. Values outside will be clamped.
 *)
function RatioOfTones(tone_a, tone_b: Double): Double;

(**
 * @return a tone >= [tone] that ensures [ratio].
 * Return value is between 0 and 100.
 * Returns -1 if [ratio] cannot be achieved with [tone].
 *
 * @param tone Tone return value must contrast with.
 * Range is 0 to 100. Invalid values will result in -1 being returned.
 * @param ratio Contrast ratio of return value and [tone].
 * Range is 1 to 21, invalid values have undefined behavior.
 *)
function Lighter(tone, ratio: Double): Double;

(**
 * @return a tone <= [tone] that ensures [ratio].
 * Return value is between 0 and 100.
 * Returns -1 if [ratio] cannot be achieved with [tone].
 *
 * @param tone Tone return value must contrast with.
 * Range is 0 to 100. Invalid values will result in -1 being returned.
 * @param ratio Contrast ratio of return value and [tone].
 * Range is 1 to 21, invalid values have undefined behavior.
 *)
function Darker(tone, ratio: Double): Double;

(**
 * @return a tone >= [tone] that ensures [ratio].
 * Return value is between 0 and 100.
 * Returns 100 if [ratio] cannot be achieved with [tone].
 *
 * This method is unsafe because the returned value is guaranteed to be in
 * bounds for tone, i.e. between 0 and 100. However, that value may not reach
 * the [ratio] with [tone]. For example, there is no color lighter than T100.
 *
 * @param tone Tone return value must contrast with.
 * Range is 0 to 100. Invalid values will result in 100 being returned.
 * @param ratio Desired contrast ratio of return value and tone parameter.
 * Range is 1 to 21, invalid values have undefined behavior.
 *)
function LighterUnsafe(tone, ratio: Double): Double;

(**
 * @return a tone <= [tone] that ensures [ratio].
 * Return value is between 0 and 100.
 * Returns 0 if [ratio] cannot be achieved with [tone].
 *
 * This method is unsafe because the returned value is guaranteed to be in
 * bounds for tone, i.e. between 0 and 100. However, that value may not reach
 * the [ratio] with [tone]. For example, there is no color darker than T0.
 *
 * @param tone Tone return value must contrast with.
 * Range is 0 to 100. Invalid values will result in 0 being returned.
 * @param ratio Desired contrast ratio of return value and tone parameter.
 * Range is 1 to 21, invalid values have undefined behavior.
 *)
function DarkerUnsafe(tone, ratio: Double): Double;

implementation

// Given a color and a contrast ratio to reach, the luminance of a color that
// reaches that ratio with the color can be calculated. However, that luminance
// may not contrast as desired, i.e. the contrast ratio of the input color
// and the returned luminance may not reach the contrast ratio  asked for.
//
// When the desired contrast ratio and the result contrast ratio differ by
// more than this amount,  an error value should be returned, or the method
// should be documented as 'unsafe', meaning, it will return a valid luminance
// but that luminance may not meet the requested contrast ratio.
//
// 0.04 selected because it ensures the resulting ratio rounds to the
// same tenth.
const
  CONTRAST_RATIO_EPSILON: Double = 0.04;

// Color spaces that measure luminance, such as Y in XYZ, L* in L*a*b*,
// or T in HCT, are known as  perceptual accurate color spaces.
//
// To be displayed, they must gamut map to a "display space", one that has
// a defined limit on the number of colors. Display spaces include sRGB,
// more commonly understood as RGB/HSL/HSV/HSB.
//
// Gamut mapping is undefined and not defined by the color space. Any
// gamut mapping algorithm must choose how to sacrifice accuracy in hue,
// saturation, and/or lightness.
//
// A principled solution is to maintain lightness, thus maintaining
// contrast/a11y, maintain hue, thus maintaining aesthetic intent, and reduce
// chroma until the color is in gamut.
//
// HCT chooses this solution, but, that doesn't mean it will _exactly_ matched
// desired lightness, if only because RGB is quantized: RGB is expressed as
// a set of integers: there may be an RGB color with, for example,
// 47.892 lightness, but not 47.891.
//
// To allow for this inherent incompatibility between perceptually accurate
// color spaces and display color spaces, methods that take a contrast ratio
// and luminance, and return a luminance that reaches that contrast ratio for
// the input luminance, purposefully darken/lighten their result such that
// the desired contrast ratio will be reached even if inaccuracy is introduced.
//
// 0.4 is generous, ex. HCT requires much less delta. It was chosen because
// it provides a rough guarantee that as long as a percetual color space
// gamut maps lightness such that the resulting lightness rounds to the same
// as the requested, the desired contrast ratio will be reached.
const
  LUMINANCE_GAMUT_MAP_TOLERANCE: Double = 0.4;

function RatioOfYs(y1, y2: Double): Double;
var
  lighter, darker: Double;
begin
  if y1 > y2 then
    lighter := y1
  else
    lighter := y2;

  if lighter = y2 then
    darker := y1
  else
    darker := y2;

  Result := (lighter + 5.0) / (darker + 5.0);
end;

function RatioOfTones(tone_a, tone_b: Double): Double;
begin
  tone_a := Clamp(tone_a, 0.0, 100.0);
  tone_b := Clamp(tone_b, 0.0, 100.0);
  Result := RatioOfYs(YFromLstar(tone_a), YFromLstar(tone_b));
end;

function Lighter(tone, ratio: Double): Double;
var
  dark_y, light_y, real_contrast, delta, value: Double;
begin
  if (tone < 0.0) or (tone > 100.0) then
    Exit(-1.0);

  dark_y := YFromLstar(tone);
  light_y := ratio * (dark_y + 5.0) - 5.0;
  real_contrast := RatioOfYs(light_y, dark_y);
  delta := abs(real_contrast - ratio);
  if (real_contrast < ratio) and (delta > CONTRAST_RATIO_EPSILON) then
    Exit(-1.0);

  // ensure gamut mapping, which requires a 'range' on tone, will still result
  // the correct ratio by darkening slightly.
  value := LstarFromY(light_y) + LUMINANCE_GAMUT_MAP_TOLERANCE;
  if (value < 0) or (value > 100) then
    Exit(-1.0);

  Result := value;
end;

function Darker(tone, ratio: Double): Double;
var
  dark_y, light_y, real_contrast, delta, value: Double;
begin
  if (tone < 0.0) or (tone > 100.0) then
    Exit(-1.0);

  light_y := YFromLstar(tone);
  dark_y := ((light_y + 5.0) / ratio) - 5.0;
  real_contrast := RatioOfYs(light_y, dark_y);

  delta := Abs(real_contrast - ratio);
  if (real_contrast < ratio) and (delta > CONTRAST_RATIO_EPSILON) then
    Exit(-1.0);

  // ensure gamut mapping, which requires a 'range' on tone, will still result
  // the correct ratio by darkening slightly.
  value := LstarFromY(dark_y) - LUMINANCE_GAMUT_MAP_TOLERANCE;
  if (value < 0) or (value > 100) then
    Exit(-1.0);

  Result := value;
end;

function LighterUnsafe(tone, ratio: Double): Double;
var
  lighter_safe: Double;
begin
  lighter_safe := Lighter(tone, ratio);
  if (lighter_safe < 0.0) then
    Result := 100.0
  else
    Result := lighter_safe;
end;

function DarkerUnsafe(tone, ratio: Double): Double;
var
  darker_safe: Double;
begin
  darker_safe := Darker(tone, ratio);
  if (darker_safe < 0.0) then
    Result := 0.0
  else
    Result := darker_safe;
end;

end.
