unit MaterialColor.Utils;

interface

uses
  System.SysUtils, System.UITypes, System.Math;

type
  PARGB = ^TARGB;
  TARGB = TAlphaColor;

type
  TVec3 = record
    A, B, C: Double;
    constructor Create(A, B, C: Double);
  end;
  TColorArray = array[0..2] of Double;
  TMat3 = array[0..2] of TColorArray;

const
  kPI: Double = 3.141592653589793;

const
  kWhitePointD65: TColorArray = (95.047, 100.0, 108.883);

(**
 * Returns the red component of a color in ARGB format.
 *)
function RedFromInt(const argb: TARGB): Integer; inline;

(**
 * Returns the green component of a color in ARGB format.
 *)
function GreenFromInt(const argb: TARGB): Integer; inline;

(**
 * Returns the blue component of a color in ARGB format.
 *)
function BlueFromInt(const argb: TARGB): Integer; inline;

(**
 * Returns the alpha component of a color in ARGB format.
 *)
function AlphaFromInt(const argb: TARGB): Integer; inline;

(**
 * Converts a color from RGB components to ARGB format.
 *)
function ArgbFromRgb(const red, green, blue: Integer): TARGB; inline;

(**
 * Converts a color from linear RGB components to ARGB format.
 *)
function ArgbFromLinrgb(linrgb: TVec3): TARGB;

(**
 * Returns whether a color in ARGB format is opaque.
 *)
function IsOpaque(const argb: TARGB): Boolean;

(**
 * Sanitizes a degree measure as an integer.
 *
 * @return a degree measure between 0 (inclusive) and 360 (exclusive).
 *)
function SanitizeDegreesInt(const degrees: Integer): Integer;

(**
 * Sanitizes a degree measure as an floating-point number.
 *
 * @return a degree measure between 0.0 (inclusive) and 360.0 (exclusive).
 *)
function SanitizeDegreesDouble(const degrees: Double): Double;

(**
 * Distance of two points on a circle, represented using degrees.
 *)
function DiffDegrees(const a, b: Double): Double;

(**
 * Sign of direction change needed to travel from one angle to
 * another.
 *
 * For angles that are 180 degrees apart from each other, both
 * directions have the same travel distance, so either direction is
 * shortest. The value 1.0 is returned in this case.
 *
 * @param from The angle travel starts from, in degrees.
 *
 * @param to The angle travel ends at, in degrees.
 *
 * @return -1 if decreasing from leads to the shortest travel
 * distance, 1 if increasing from leads to the shortest travel
 * distance.
 *)
function RotationDirection(const from, &to: Double): Double;

(**
 * Computes the L* value of a color in ARGB representation.
 *
 * @param argb ARGB representation of a color
 *
 * @return L*, from L*a*b*, coordinate of the color
 *)
function LstarFromArgb(const argb: TARGB): Double;

(**
 * Returns the hexadecimal representation of a color.
 *)
function HexFromArgb(argb: TARGB): string;

(**
 * Linearizes an RGB component.
 *
 * @param rgb_component 0 <= rgb_component <= 255, represents R/G/B
 * channel
 *
 * @return 0.0 <= output <= 100.0, color channel converted to
 * linear RGB space
 *)
function Linearized(const rgb_component: Integer): Double;

(**
 * Delinearizes an RGB component.
 *
 * @param rgb_component 0.0 <= rgb_component <= 100.0, represents linear
 * R/G/B channel
 *
 * @return 0 <= output <= 255, color channel converted to regular
 * RGB space
 *)
function Delinearized(const rgb_component: Double): Integer;

(**
 * Converts an L* value to a Y value.
 *
 * L* in L*a*b* and Y in XYZ measure the same quantity, luminance.
 *
 * L* measures perceptual luminance, a linear scale. Y in XYZ
 * measures relative luminance, a logarithmic scale.
 *
 * @param lstar L* in L*a*b*. 0.0 <= L* <= 100.0
 *
 * @return Y in XYZ. 0.0 <= Y <= 100.0
 *)
function YFromLstar(const lstar: Double): Double;

(**
 * Converts a Y value to an L* value.
 *
 * L* in L*a*b* and Y in XYZ measure the same quantity, luminance.
 *
 * L* measures perceptual luminance, a linear scale. Y in XYZ
 * measures relative luminance, a logarithmic scale.
 *
 * @param y Y in XYZ. 0.0 <= Y <= 100.0
 *
 * @return L* in L*a*b*. 0.0 <= L* <= 100.0
 *)
function LstarFromY(const y: Double): Double;

(**
 * Converts an L* value to an ARGB representation.
 *
 * @param lstar L* in L*a*b*. 0.0 <= L* <= 100.0
 *
 * @return ARGB representation of grayscale color with lightness matching L*
 *)
function IntFromLstar(const lstar: Double): TARGB;

(**
 * The signum function.
 *
 * @return 1 if num > 0, -1 if num < 0, and 0 if num = 0
 *)
function Signum(num: Double): Integer;

(**
 * The linear interpolation function.
 *
 * @return start if amount = 0 and stop if amount = 1
 *)
function Lerp(start, stop, amount: Double): Double;

(**
 * Multiplies a 1x3 row vector with a 3x3 matrix, returning the product.
 *)
function MatrixMultiply(input: TVec3; const matrix: TMat3): TVec3;

// port of std::clamp()
function Clamp(Value, Minimum, Maximum: Integer): Integer; overload;
function Clamp(Value, Minimum, Maximum: Double): Double; overload;

implementation

function Clamp(Value, Minimum, Maximum: Integer): Integer;
begin
  Result := Value;
  if Result < Minimum then
    Result := Minimum
  else if Maximum < Value then
    Result := Maximum;
end;

function Clamp(Value, Minimum, Maximum: Double): Double;
begin
  Result := Value;
  if Result < Minimum then
    Result := Minimum
  else if Maximum < Value then
    Result := Maximum;
end;

function RedFromInt(const argb: TARGB): Integer;
begin
  Result := (argb and $00ff0000) shr 16;
end;

function GreenFromInt(const argb: TARGB): Integer;
begin
  Result := (argb and $0000ff00) shr 8;
end;

function BlueFromInt(const argb: TARGB): Integer;
begin
  Result := (argb and $000000ff);
end;

function AlphaFromInt(const argb: TARGB): Integer;
begin
  Result := (argb and $ff000000) shr 24;
end;

function ArgbFromRgb(const red, green, blue: Integer): TARGB;
begin
  Result := $ff000000
         + ((TAlphaColor(red)   and $ff) shl 16)
         + ((TAlphaColor(green) and $ff) shl 8)
         +  (TAlphaColor(blue)  and $ff);
end;

function ArgbFromLinrgb(linrgb: TVec3): TARGB;
var
  r, g, b: Integer;
begin
  r := Delinearized(linrgb.a);
  g := Delinearized(linrgb.b);
  b := Delinearized(linrgb.c);

  //  Result := $ff000000 and ((r and $0ff) shl 16) + ((g and $0ff) shl 8) + (b and $0ff);
  Result := ArgbFromRgb(r, g, b);
end;

function IsOpaque(const argb: TARGB): Boolean;
begin
  Result := AlphaFromInt(argb) = 255;
end;

function SanitizeDegreesInt(const degrees: Integer): Integer;
begin
  if degrees < 0 then
    Result := (degrees mod 360) + 360
  else if degrees >= 360 then
    Result := degrees mod 360
  else
    Result := degrees;
end;

function SanitizeDegreesDouble(const degrees: Double): Double;
begin
  if degrees < 0.0 then
    Result := FMod(degrees, 360.0) + 360.0
  else if degrees >= 360.0 then
    Result := FMod(degrees, 360.0)
  else
    Result := degrees;
end;

function DiffDegrees(const a, b: Double): Double;
begin
  Result := 180.0 - Abs(Abs(a - b) - 180.0);
end;

function RotationDirection(const from, &to: Double): Double;
var
  increasing_difference: Double;
begin
  increasing_difference := SanitizeDegreesDouble(&to - from);
  if increasing_difference <= 180.0 then
    Result := 1.0
  else
    Result := -1.0;
end;

function LstarFromArgb(const argb: TARGB): Double;
var
  red, green, blue: Integer;
  red_l, green_l, blue_l: Double;
  y: Double;
begin
  // xyz from argb
  red     := RedFromInt(argb);   // (argb and $00ff0000) shr 16
  green   := GreenFromInt(argb); // (argb and $0000ff00) shr 8
  blue    := BlueFromInt(argb);  // (argb and $000000ff)
  red_l   := Linearized(red);
  green_l := Linearized(green);
  blue_l  := Linearized(blue);
  y := 0.2126 * red_l + 0.7152 * green_l + 0.0722 * blue_l;
  Result := LstarFromY(y);
end;

function HexFromArgb(argb: TARGB): string;
begin
  Result := LowerCase(IntToHex(argb));
end;

function Linearized(const rgb_component: Integer): Double;
var
  normalized: Double;
begin
  normalized := rgb_component / 255.0;
  if (normalized <= 0.040449936) then
    Result := normalized / 12.92 * 100.0
  else
    Result := Power((normalized + 0.055) / 1.055, 2.4) * 100.0;
end;

function Delinearized(const rgb_component: Double): Integer;
var
  normalized, delinearized: Double;
begin
  normalized := rgb_component / 100.0;
  if normalized <= 0.0031308 then
    delinearized := normalized * 12.92
  else
    delinearized := 1.055 * Power(normalized, 1.0 / 2.4) - 0.055;
  Result := Clamp(Round(delinearized * 255.0), 0, 255);
end;

function YFromLstar(const lstar: Double): Double;
const
  KE: Double = 8.0;
var
  cube_root, cube: Double;
begin
  if (lstar > KE) then
  begin
    cube_root := (lstar + 16.0) / 116.0;
    cube := cube_root * cube_root * cube_root;
    Result := cube * 100.0;
  end
  else
    Result := lstar / (24389.0 / 27.0) * 100.0;
end;

function LstarFromY(const y: Double): Double;
const
  E: Double = 216.0 / 24389.0;
var
  yNormalized: Double;
begin
  yNormalized := y / 100.0;
  if yNormalized <= E then
    Result := (24389.0 / 27.0) * yNormalized
  else
    Result := 116.0 * Power(yNormalized, 1.0 / 3.0) - 16.0;
end;

function IntFromLstar(const lstar: Double): TARGB;
var
  y: Double;
  component: Integer;
begin
  y := YFromLstar(lstar);
  component := Delinearized(y);
  Result := ArgbFromRgb(component, component, component);
end;

function Signum(num: Double): Integer;
begin
  Result := Sign(num);
end;

function Lerp(start, stop, amount: Double): Double;
begin
  Result := (1.0 - amount) * start + amount * stop;
end;

function MatrixMultiply(input: TVec3; const matrix: TMat3): TVec3;
begin
  Result.a := input.a * matrix[0][0] + input.b * matrix[0][1] + input.c * matrix[0][2];
  Result.b := input.a * matrix[1][0] + input.b * matrix[1][1] + input.c * matrix[1][2];
  Result.c := input.a * matrix[2][0] + input.b * matrix[2][1] + input.c * matrix[2][2];
end;

{ TVec3 }

constructor TVec3.Create(A, B, C: Double);
begin
  Self.A := A;
  Self.B := B;
  Self.C := C;
end;

end.
