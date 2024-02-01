unit MaterialColor.CAM.ViewingConditions;

interface

uses
  System.SysUtils, System.Math,
  MaterialColor.Utils;

type
  TViewingConditions = record
    adapting_luminance: Double;
    background_lstar: Double;
    surround: Double;
    discounting_illuminant: Boolean;
    background_y_to_white_point_y: Double;
    aw: Double;
    nbb: Double;
    ncb: Double;
    c: Double;
    n_c: Double;
    fl: Double;
    fl_root: Double;
    z: Double;

    white_point: TColorArray;
    rgb_d: TColorArray;

    constructor Create(const white_point: TColorArray;
                       const adapting_luminance: Double;
                       const background_lstar: Double;
                       const surround: Double;
                       const discounting_illuminant: Boolean);
  end;

  function DefaultWithBackgroundLstar(const background_lstar: Double): TViewingConditions;

const
  kDefaultViewingConditions: TViewingConditions = (
    adapting_luminance: 11.725676537;
    background_lstar: 50.000000000;
    surround: 2.000000000;
    discounting_illuminant: False;
    background_y_to_white_point_y: 0.184186503;
    aw: 29.981000900;
    nbb: 1.016919255;
    ncb: 1.016919255;
    c: 0.689999998;
    n_c: 1.000000000;
    fl: 0.388481468;
    fl_root: 0.789482653;
    z: 1.909169555;
    white_point: (95.047, 100.0, 108.883);
    rgb_d: (1.021177769, 0.986307740, 0.933960497);
  );

implementation

function DefaultWithBackgroundLstar(const background_lstar: Double): TViewingConditions;
begin
  Result := TViewingConditions.Create(kWhitePointD65,
                                      (200.0 / kPi * YFromLstar(50.0) / 100.0),
                                      background_lstar, 2.0, False);
end;

{ TViewingConditions }

constructor TViewingConditions.Create(const white_point: TColorArray;
  const adapting_luminance, background_lstar, surround: Double;
  const discounting_illuminant: Boolean);
var
  background_lstar_corrected: Double;
  rgb_w, rgb_d, rgb_a_factors, rgb_a: TColorArray;
  f, c, d, nc: Double;
  k, k4, k4f, fl, fl_root, n, z, nbb, ncb: Double;
  aw: Double;
begin
  background_lstar_corrected := Min(background_lstar, 30.0);

  rgb_w[0] :=  0.401288 * white_point[0] + 0.650173 * white_point[1] - 0.051461 * white_point[2];
  rgb_w[1] := -0.250268 * white_point[0] + 1.204414 * white_point[1] + 0.045854 * white_point[2];
  rgb_w[2] := -0.002079 * white_point[0] + 0.048952 * white_point[1] + 0.953127 * white_point[2];

  f := 0.8 + (surround / 10.0);
  if f >= 0.9 then
    c := lerp(0.59, 0.69, (f - 0.9) * 10.0)
  else
    c := lerp(0.525, 0.59, (f - 0.8) * 10.0);

  if discounting_illuminant then
    d := 1.0
  else
    d := f * (1.0 - ((1.0 / 3.6) * Exp((-adapting_luminance - 42.0) / 92.0)));

  if d > 1.0 then
    d := 1.0
  else if d < 0.0 then
    d := 0.0;

  nc := f;
  rgb_d[0] := (d * (100.0 / rgb_w[0]) + 1.0 - d);
  rgb_d[1] := (d * (100.0 / rgb_w[1]) + 1.0 - d);
  rgb_d[2] := (d * (100.0 / rgb_w[2]) + 1.0 - d);

  k := 1.0 / (5.0 * adapting_luminance + 1.0);
  k4 := k * k * k * k;
  k4f := 1.0 - k4;
  fl := (k4 * adapting_luminance) + (0.1 * k4f * k4f * Power(5.0 * adapting_luminance, 1.0 / 3.0));
  fl_root := Power(fl, 0.25);
  n := YFromLstar(background_lstar_corrected) / white_point[1];
  z := 1.48 + Sqrt(n);
  nbb := 0.725 / Power(n, 0.2);
  ncb := nbb;

  rgb_a_factors[0] := Power(fl * rgb_d[0] * rgb_w[0] / 100.0, 0.42);
  rgb_a_factors[1] := Power(fl * rgb_d[1] * rgb_w[1] / 100.0, 0.42);
  rgb_a_factors[2] := Power(fl * rgb_d[2] * rgb_w[2] / 100.0, 0.42);

  rgb_a[0] := 400.0 * rgb_a_factors[0] / (rgb_a_factors[0] + 27.13);
  rgb_a[1] := 400.0 * rgb_a_factors[1] / (rgb_a_factors[1] + 27.13);
  rgb_a[2] := 400.0 * rgb_a_factors[2] / (rgb_a_factors[2] + 27.13);

  aw := (40.0 * rgb_a[0] + 20.0 * rgb_a[1] + rgb_a[2]) / 20.0 * nbb;

  Self.adapting_luminance := adapting_luminance;
  Self.background_lstar := background_lstar_corrected;
  Self.surround := surround;
  Self.discounting_illuminant := discounting_illuminant;
  Self.background_y_to_white_point_y := n;
  Self.aw := aw;
  Self.nbb := nbb;
  Self.ncb := ncb;
  Self.c := c;
  Self.n_c := nc;
  Self.fl := fl;
  Self.fl_root := fl_root;
  Self.z := z;
  Self.white_point := white_point;
  Self.rgb_d := rgb_d;
end;

procedure PrintDefaultFrame();
var
  frame: TViewingConditions;
begin
  frame := TViewingConditions.Create(
    kWhitePointD65, (200.0 / kPi * YFromLstar(50.0) / 100.0), 50.0, 2.0, False);

  Write('(Frame){');
  WriteLn(frame.adapting_luminance, ',');
  WriteLn(frame.background_lstar, ',');
  WriteLn(frame.surround, ',');
  WriteLn(frame.discounting_illuminant, ',');
  WriteLn(frame.background_y_to_white_point_y, ',');
  WriteLn(frame.aw, ',');
  WriteLn(frame.nbb, ',');
  WriteLn(frame.ncb, ',');
  WriteLn(frame.c, ',');
  WriteLn(frame.n_c, ',');
  WriteLn(frame.fl, ',');
  WriteLn(frame.fl_root, ',');
  WriteLn(frame.z, ',');
  WriteLn(frame.rgb_d[0], ',');
  WriteLn(frame.rgb_d[1], ',');
  WriteLn(frame.rgb_d[2]);
  WriteLn('};');
end;

end.
