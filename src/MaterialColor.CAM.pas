unit MaterialColor.CAM;

interface

uses
  System.SysUtils, System.Math, System.UITypes,
  MaterialColor.Utils,
  MaterialColor.CAM.ViewingConditions;

type
  TCam = record
    hue: Double;
    chroma: Double;
    j: Double;
    q: Double;
    m: Double;
    s: Double;

    jstar: Double;
    astar: Double;
    bstar: Double;

    constructor Create(hue, chroma, j, q, m, s, jstar, astar, bstar: Double);
  end;

function CamFromInt(argb: TARGB): TCam;
function CamFromIntAndViewingConditions(argb: TARGB;
                                        const viewing_conditions: TViewingConditions): TCam;
function IntFromHcl(hue, chroma, lstar: Double): TARGB;
function IntFromCam(cam: TCam): TARGB;
function CamFromUcsAndViewingConditions(jstar, astar, bstar: Double;
                                        const viewing_conditions: TViewingConditions): TCam;
(**
 * Given color expressed in the XYZ color space and viewed
 * in [viewingConditions], converts the color to CAM16.
 *)
function CamFromXyzAndViewingConditions(x, y, z: Double;
                                        const viewing_conditions: TViewingConditions): TCam;

implementation

uses
  MaterialColor.CAM.HCTSolver;

function CamFromJchAndViewingConditions(j, c, h: Double; viewing_conditions: TViewingConditions): TCam;
var
  q, m, alpha, s, hue_radians: Double;
  jstar, mstar, astar, bstar: Double;
begin
  q := (4.0 / viewing_conditions.c) * Sqrt(j / 100.0) * (viewing_conditions.aw + 4.0) * (viewing_conditions.fl_root);
  m := c * viewing_conditions.fl_root;
  alpha := c / Sqrt(j / 100.0);
  s := 50.0 * Sqrt((alpha * viewing_conditions.c) / (viewing_conditions.aw + 4.0));
  hue_radians := h * kPi / 180.0;
  jstar := (1.0 + 100.0 * 0.007) * j / (1.0 + 0.007 * j);
  mstar := 1.0 / 0.0228 * Log10(1.0 + 0.0228 * m);
  astar := mstar * Cos(hue_radians);
  bstar := mstar * Sin(hue_radians);

  Result := TCam.Create(h, c, j, q, m, s, jstar, astar, bstar);
end;

function CamFromUcsAndViewingConditions(jstar, astar, bstar: Double;
                                        const viewing_conditions: TViewingConditions): TCam;
var
  a, b, m, m_2, c, h, j: Double;
begin
  a := astar;
  b := bstar;
  m := Sqrt(a * a + b * b);
  m_2 := (Exp(m * 0.0228) - 1.0) / 0.0228;
  c := m_2 / viewing_conditions.fl_root;
  h := ArcTan2(b, a) * (180.0 / kPi);
  if h < 0.0 then
    h := h + 360.0;
  j := jstar / (1 - (jstar - 100) * 0.007);

  Result := CamFromJchAndViewingConditions(j, c, h, viewing_conditions);
end;

function CamFromIntAndViewingConditions(argb: TARGB;
                                        const viewing_conditions: TViewingConditions): TCam;
var
  red, green, blue: Integer;
  red_l, green_l, blue_l: Double;
  x, y, z: Double;
  r_c, g_c, b_c: Double;
  r_d, g_d, b_d: Double;
  r_af, g_af, b_af: Double;
  r_a, g_a, b_a: Double;
  a, b, u, p2: Double;
  radians, degrees, hue, hue_radians, ac: Double;
  j, q, hue_prime, e_hue, p1, t, alpha, c, m, s, jstar, mstar, astar, bstar: Double;
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

  // Convert XYZ to 'cone'/'rgb' responses
  r_c := 0.401288 * x + 0.650173 * y - 0.051461 * z;
  g_c := -0.250268 * x + 1.204414 * y + 0.045854 * z;
  b_c := -0.002079 * x + 0.048952 * y + 0.953127 * z;

  // Discount illuminant.
  r_d := viewing_conditions.rgb_d[0] * r_c;
  g_d := viewing_conditions.rgb_d[1] * g_c;
  b_d := viewing_conditions.rgb_d[2] * b_c;

  // Chromatic adaptation.
  r_af := Power(viewing_conditions.fl * Abs(r_d) / 100.0, 0.42);
  g_af := Power(viewing_conditions.fl * Abs(g_d) / 100.0, 0.42);
  b_af := Power(viewing_conditions.fl * Abs(b_d) / 100.0, 0.42);
  r_a := Signum(r_d) * 400.0 * r_af / (r_af + 27.13);
  g_a := Signum(g_d) * 400.0 * g_af / (g_af + 27.13);
  b_a := Signum(b_d) * 400.0 * b_af / (b_af + 27.13);

  // Redness-greenness
  a := (11.0 * r_a + -12.0 * g_a + b_a) / 11.0;
  b := (r_a + g_a - 2.0 * b_a) / 9.0;
  u := (20.0 * r_a + 20.0 * g_a + 21.0 * b_a) / 20.0;
  p2 := (40.0 * r_a + 20.0 * g_a + b_a) / 20.0;

  radians := ArcTan2(b, a);
  degrees := radians * 180.0 / kPi;
  hue := SanitizeDegreesDouble(degrees);
  hue_radians := hue * kPi / 180.0;
  ac := p2 * viewing_conditions.nbb;

  j := 100.0 * Power(ac / viewing_conditions.aw, viewing_conditions.c * viewing_conditions.z);
  q := (4.0 / viewing_conditions.c) * Sqrt(j / 100.0) * (viewing_conditions.aw + 4.0) * viewing_conditions.fl_root;

  if hue < 20.14 then
    hue_prime := hue + 360
  else
   hue_prime := hue;

  e_hue := 0.25 * (Cos(hue_prime * kPi / 180.0 + 2.0) + 3.8);
  p1 := 50000.0 / 13.0 * e_hue * viewing_conditions.n_c * viewing_conditions.ncb;
  t := p1 * Sqrt(a * a + b * b) / (u + 0.305);
  alpha := Power(t, 0.9) * Power(1.64 - Power(0.29, viewing_conditions.background_y_to_white_point_y), 0.73);
  c := alpha * Sqrt(j / 100.0);
  m := c * viewing_conditions.fl_root;
  s := 50.0 * Sqrt((alpha * viewing_conditions.c) / (viewing_conditions.aw + 4.0));
  jstar := (1.0 + 100.0 * 0.007) * j / (1.0 + 0.007 * j);
  mstar := 1.0 / 0.0228 * Log10(1.0 + 0.0228 * m);
  astar := mstar * Cos(hue_radians);
  bstar := mstar * Sin(hue_radians);

  Result := TCam.Create(hue, c, j, q, m, s, jstar, astar, bstar);
end;

function CamFromInt(argb: TARGB): TCam;
begin
  Result := CamFromIntAndViewingConditions(argb, kDefaultViewingConditions);
end;

function IntFromCamAndViewingConditions(cam: TCam; viewing_conditions: TViewingConditions): TARGB;
var
  alpha: Double;
  t, h_rad, e_hue, ac, p1, p2, h_sin, h_cos, gamma, a, b: Double;
  r_a, g_a, b_a: Double;
  r_c_base, r_c: Double;
  g_c_base, g_c: Double;
  b_c_base, b_c: Double;
  r_x, g_x, b_x: Double;
  x, y, z: Double;
  r_l, g_l, b_l: Double;
  red, green, blue: Integer;
begin
  if (cam.chroma = 0.0) or (cam.j = 0.0) then
    alpha := 0.0
  else
    alpha := cam.chroma / Sqrt(cam.j / 100.0);

  t := Power(alpha / Power(1.64 - Power(0.29, viewing_conditions.background_y_to_white_point_y), 0.73), 1.0 / 0.9);
  h_rad := cam.hue * kPi / 180.0;
  e_hue := 0.25 * (Cos(h_rad + 2.0) + 3.8);
  ac := viewing_conditions.aw * Power(cam.j / 100.0, 1.0 / viewing_conditions.c / viewing_conditions.z);
  p1 := e_hue * (50000.0 / 13.0) * viewing_conditions.n_c * viewing_conditions.ncb;
  p2 := ac / viewing_conditions.nbb;
  h_sin := Sin(h_rad);
  h_cos := Cos(h_rad);
  gamma := 23.0 * (p2 + 0.305) * t / (23.0 * p1 + 11.0 * t * h_cos + 108.0 * t * h_sin);
  a := gamma * h_cos;
  b := gamma * h_sin;
  r_a := (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0;
  g_a := (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0;
  b_a := (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0;

  r_c_base := Max(0, (27.13 * Abs(r_a)) / (400.0 - Abs(r_a)));
  r_c := Signum(r_a) * (100.0 / viewing_conditions.fl) * Power(r_c_base, 1.0 / 0.42);
  g_c_base := Max(0, (27.13 * Abs(g_a)) / (400.0 - Abs(g_a)));
  g_c := Signum(g_a) * (100.0 / viewing_conditions.fl) * Power(g_c_base, 1.0 / 0.42);
  b_c_base := Max(0, (27.13 * Abs(b_a)) / (400.0 - Abs(b_a)));
  b_c := Signum(b_a) * (100.0 / viewing_conditions.fl) * Power(b_c_base, 1.0 / 0.42);

  r_x := r_c / viewing_conditions.rgb_d[0];
  g_x := g_c / viewing_conditions.rgb_d[1];
  b_x := b_c / viewing_conditions.rgb_d[2];
  x := 1.86206786 * r_x - 1.01125463 * g_x + 0.14918677 * b_x;
  y := 0.38752654 * r_x + 0.62144744 * g_x - 0.00897398 * b_x;
  z := -0.01584150 * r_x - 0.03412294 * g_x + 1.04996444 * b_x;

  // intFromXyz
  r_l := 3.2406 * x - 1.5372 * y - 0.4986 * z;
  g_l := -0.9689 * x + 1.8758 * y + 0.0415 * z;
  b_l := 0.0557 * x - 0.2040 * y + 1.0570 * z;

  red := Delinearized(r_l);
  green := Delinearized(g_l);
  blue := Delinearized(b_l);

  Result := ArgbFromRgb(red, green, blue);
end;

function IntFromCam(cam: TCam): TARGB;
begin
  Result := IntFromCamAndViewingConditions(cam, kDefaultViewingConditions);
end;

function CamDistance(a, b: TCam): Double;
var
  d_j, d_a, d_b, d_e_prime, d_e: Double;
begin
  d_j := a.jstar - b.jstar;
  d_a := a.astar - b.astar;
  d_b := a.bstar - b.bstar;
  d_e_prime := Sqrt(d_j * d_j + d_a * d_a + d_b * d_b);
  d_e := 1.41 * Power(d_e_prime, 0.63);
  Result := d_e;
end;

function IntFromHcl(hue, chroma, lstar: Double): TARGB;
begin
  Result := SolveToInt(hue, chroma, lstar);
end;

function CamFromXyzAndViewingConditions(x, y, z: Double;
  const viewing_conditions: TViewingConditions): TCam;
var
  r_c, g_c, b_c: Double;
  r_d, g_d, b_d: Double;
  r_af, g_af, b_af, r_a, g_a, b_a: Double;
  a, b, u, p2: Double;
  radians, degrees, hue, hue_radians, ac: Double;
  j, q, hue_prime, e_hue, p1, t, alpha, c, m, s: Double;
  jstar, mstar, astar, bstar: Double;
begin
  // Convert XYZ to 'cone'/'rgb' responses
  r_c := 0.401288 * x + 0.650173 * y - 0.051461 * z;
  g_c := -0.250268 * x + 1.204414 * y + 0.045854 * z;
  b_c := -0.002079 * x + 0.048952 * y + 0.953127 * z;

  // Discount illuminant.
  r_d := viewing_conditions.rgb_d[0] * r_c;
  g_d := viewing_conditions.rgb_d[1] * g_c;
  b_d := viewing_conditions.rgb_d[2] * b_c;

  // Chromatic adaptation.
  r_af := Power(viewing_conditions.fl * Abs(r_d) / 100.0, 0.42);
  g_af := Power(viewing_conditions.fl * Abs(g_d) / 100.0, 0.42);
  b_af := Power(viewing_conditions.fl * Abs(b_d) / 100.0, 0.42);
  r_a := Signum(r_d) * 400.0 * r_af / (r_af + 27.13);
  g_a := Signum(g_d) * 400.0 * g_af / (g_af + 27.13);
  b_a := Signum(b_d) * 400.0 * b_af / (b_af + 27.13);

  // Redness-greenness
  a := (11.0 * r_a + -12.0 * g_a + b_a) / 11.0;
  b := (r_a + g_a - 2.0 * b_a) / 9.0;
  u := (20.0 * r_a + 20.0 * g_a + 21.0 * b_a) / 20.0;
  p2 := (40.0 * r_a + 20.0 * g_a + b_a) / 20.0;

  radians := ArcTan2(b, a);
  degrees := radians * 180.0 / kPi;
  hue := SanitizeDegreesDouble(degrees);
  hue_radians := hue * kPi / 180.0;
  ac := p2 * viewing_conditions.nbb;

  j := 100.0 * Power(ac / viewing_conditions.aw, viewing_conditions.c * viewing_conditions.z);
  q := (4.0 / viewing_conditions.c) * Sqrt(j / 100.0) * (viewing_conditions.aw + 4.0) * viewing_conditions.fl_root;

  if hue < 20.14 then
    hue_prime := hue + 360
  else
    hue_prime := hue;

  e_hue := 0.25 * (Cos(hue_prime * kPi / 180.0 + 2.0) + 3.8);
  p1 := 50000.0 / 13.0 * e_hue * viewing_conditions.n_c * viewing_conditions.ncb;
  t := p1 * Sqrt(a * a + b * b) / (u + 0.305);
  alpha := Power(t, 0.9) * Power(1.64 - Power(0.29, viewing_conditions.background_y_to_white_point_y), 0.73);
  c := alpha * Sqrt(j / 100.0);
  m := c * viewing_conditions.fl_root;
  s := 50.0 * Sqrt((alpha * viewing_conditions.c) / (viewing_conditions.aw + 4.0));
  jstar := (1.0 + 100.0 * 0.007) * j / (1.0 + 0.007 * j);
  mstar := 1.0 / 0.0228 * Log10(1.0 + 0.0228 * m);
  astar := mstar * Cos(hue_radians);
  bstar := mstar * Sin(hue_radians);

  Result := TCam.Create(hue, c, j, q, m, s, jstar, astar, bstar);
end;

{ TCam }

constructor TCam.Create(hue, chroma, j, q, m, s, jstar, astar, bstar: Double);
begin
  Self.hue := hue;
  Self.chroma := chroma;
  Self.j := j;
  Self.q := q;
  Self.m := m;
  Self.s := s;
  Self.jstar := jstar;
  Self.astar := astar;
  Self.bstar := bstar;
end;

end.
