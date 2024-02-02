unit MaterialColor.Utils.Lab;

interface

uses
  System.SysUtils, System.Math, System.UITypes,
  MaterialColor.Utils;

type
  TLab = record
    l, a, b: Double;

    function DeltaE(const lab: TLab): Double;
    function ToString(): string;

    constructor Create(l, a, b: Double);
  end;

function IntFromLab(const lab: TLab): TARGB;
function LabFromInt(const argb: TARGB): TLab;

implementation

function IntFromLab(const lab: TLab): TARGB;
var
  e, kappa, ke: Double;
  fy, fx, fz, fx3, x_normalized, y_normalized, fz3, z_normalized, x, y, z: Double;
  rL, gL, bL: Double;
  red, green, blue: Integer;
begin
  e := 216.0 / 24389.0;
  kappa := 24389.0 / 27.0;
  ke := 8.0;

  fy := (lab.l + 16.0) / 116.0;
  fx := (lab.a / 500.0) + fy;
  fz := fy - (lab.b / 200.0);

  fx3 := fx * fx * fx;
  if fx3 > e then
    x_normalized := fx3
  else
    x_normalized :=  (116.0 * fx - 16.0) / kappa;

  if lab.l > ke then
    y_normalized := fy * fy * fy
  else
    y_normalized := lab.l / kappa;

  fz3 := fz * fz * fz;
  if fz3 > e then
    z_normalized := fz3
  else
    z_normalized := (116.0 * fz - 16.0) / kappa;

  x := x_normalized * kWhitePointD65[0];
  y := y_normalized * kWhitePointD65[1];
  z := z_normalized * kWhitePointD65[2];

  // intFromXyz
  rL := 3.2406 * x - 1.5372 * y - 0.4986 * z;
  gL := -0.9689 * x + 1.8758 * y + 0.0415 * z;
  bL := 0.0557 * x - 0.2040 * y + 1.0570 * z;

  red := Delinearized(rL);
  green := Delinearized(gL);
  blue := Delinearized(bL);

  Result := ArgbFromRgb(red, green, blue);
end;

function LabFromInt(const argb: TARGB): TLab;
var
  red, green, blue: Integer;
  red_l, green_l, blue_l: Double;
  x, y, z, y_normalized, e, kappa, fy: Double;
  x_normalized, fx: Double;
  z_normalized, fz: Double;
begin
  red := RedFromInt(argb);
  green := GreenFromInt(argb);
  blue := BlueFromInt(argb);

  red_l := Linearized(red);
  green_l := Linearized(green);
  blue_l := Linearized(blue);
  x := 0.41233895 * red_l + 0.35762064 * green_l + 0.18051042 * blue_l;
  y := 0.2126 * red_l + 0.7152 * green_l + 0.0722 * blue_l;
  z := 0.01932141 * red_l + 0.11916382 * green_l + 0.95034478 * blue_l;
  y_normalized := y / kWhitePointD65[1];
  e := 216.0 / 24389.0;
  kappa := 24389.0 / 27.0;

  if y_normalized > e then
    fy := Power(y_normalized, 1.0 / 3.0)
  else
    fy := (kappa * y_normalized + 16) / 116;

  x_normalized := x / kWhitePointD65[0];
  if x_normalized > e then
    fx := Power(x_normalized, 1.0 / 3.0)
  else
    fx := (kappa * x_normalized + 16) / 116;

  z_normalized := z / kWhitePointD65[2];
  if (z_normalized > e) then
    fz := Power(z_normalized, 1.0 / 3.0)
  else
    fz := (kappa * z_normalized + 16) / 116;

  Result.l := 116.0 * fy - 16;
  Result.a := 500.0 * (fx - fy);
  Result.b := 200.0 * (fy - fz);
end;

{ TLab }

constructor TLab.Create(l, a, b: Double);
begin
  Self.l := l;
  Self.a := a;
  Self.b := b;
end;

function TLab.DeltaE(const lab: TLab): Double;
var
  d_l, d_a, d_b: Double;
begin
  d_l := l - lab.l;
  d_a := a - lab.a;
  d_b := b - lab.b;
  Result := (d_l * d_l) + (d_a * d_a) + (d_b * d_b);
end;

function TLab.ToString: string;
begin
  Result := Format('Lab: L* %f a* %f b* %s', [l, a, b]);
end;

end.
