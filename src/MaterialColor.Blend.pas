unit MaterialColor.Blend;

interface

uses
  System.SysUtils, System.Math,
  MaterialColor.Utils,
  MaterialColor.CAM, MaterialColor.CAM.HCT, MaterialColor.CAM.ViewingConditions;

function BlendHarmonize(const design_color, key_color: TARGB): TARGB;
function BlendHctHue(const from, &to: TARGB; const amount: Double): TARGB;
function BlendCam16Ucs(const from, &to: TARGB; const amount: Double): TARGB;

implementation

function BlendHarmonize(const design_color, key_color: TARGB): TARGB;
var
  from_hct, to_hct: THCT;
  difference_degrees, rotation_degrees, output_hue: Double;
begin
  from_hct := THCT.Create(design_color);
  to_hct := THCT.Create(key_color);
  difference_degrees := DiffDegrees(from_hct.Hue, to_hct.Hue);
  rotation_degrees := Min(difference_degrees * 0.5, 15.0);
  output_hue := SanitizeDegreesDouble(from_hct.Hue + rotation_degrees * RotationDirection(from_hct.Hue, to_hct.Hue));
  from_hct.Hue := output_hue;
  Result := from_hct.ToInt;
end;

function BlendHctHue(const from, &to: TARGB; const amount: Double): TARGB;
var
  ucs: TARGB;
  ucs_hct, from_hct: THCT;
begin
  ucs := BlendCam16Ucs(from, &to, amount);
  ucs_hct := THCT.Create(ucs);
  from_hct := THCT.Create(from);
  from_hct.Hue := ucs_hct.Hue;
  Result := from_hct.ToInt;
end;

function BlendCam16Ucs(const from, &to: TARGB; const amount: Double): TARGB;
var
  from_cam, to_cam, blended: TCam;
  a_j, a_a, a_b: Double;
  b_j, b_a, b_b: Double;
  jstar, astar, bstar: Double;
begin
  from_cam := CamFromInt(from);
  to_cam := CamFromInt(&to);

  a_j := from_cam.jstar;
  a_a := from_cam.astar;
  a_b := from_cam.bstar;

  b_j := to_cam.jstar;
  b_a := to_cam.astar;
  b_b := to_cam.bstar;

  jstar := a_j + (b_j - a_j) * amount;
  astar := a_a + (b_a - a_a) * amount;
  bstar := a_b + (b_b - a_b) * amount;

  blended := CamFromUcsAndViewingConditions(jstar, astar, bstar, kDefaultViewingConditions);

  Result := IntFromCam(blended);
end;

end.
