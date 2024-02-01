unit MaterialColor.Palettes.Tones;

interface

uses
  MaterialColor.Utils,
  MaterialColor.CAM.HCT, MaterialColor.CAM;

type
  TTonalPalette = record
  private
    FHue: Double;
    FChroma: Double;
    FKeyColor: THCT;

    function CreateKeyColor(hue, chroma: Double): THCT;
  public
    constructor Create(argb: TARGB); overload;
    constructor Create(hct: THCT); overload;
    constructor Create(hue, chroma: Double); overload;
    constructor Create(hue, chroma: Double; key_color: THCT); overload;

    (**
     * Returns the color for a given tone in this palette.
     *
     * @param tone 0.0 <= tone <= 100.0
     * @return a color as an integer, in ARGB format.
     *)
    function Get(tone: Double): TARGB;

    property Hue: Double read FHue;
    property Chroma: Double read FChroma;
    property KeyColor: THCT read FKeyColor;
  end;

implementation

{ TTonalPalette }

constructor TTonalPalette.Create(argb: TARGB);
begin
  var cam := CamFromInt(argb);
  FHue := cam.hue;
  FChroma := cam.chroma;
  FKeyColor := CreateKeyColor(cam.hue, cam.chroma);
end;

constructor TTonalPalette.Create(hct: THCT);
begin
  FKeyColor := THCT.Create(hct.hue, hct.chroma, hct.tone);
  FHue := hct.Hue;
  FChroma := hct.Chroma;
end;

constructor TTonalPalette.Create(hue, chroma: Double; key_color: THCT);
begin
  FkeyColor := THCT.Create(key_color.Hue, key_color.Chroma, key_color.Tone);
  FHue := hue;
  FChroma := chroma;
end;

constructor TTonalPalette.Create(hue, chroma: Double);
begin
  FKeyColor := THCT.Create(hue, chroma, 0.0);
  FHue := hue;
  FChroma := chroma;
  FKeyColor := CreateKeyColor(hue, chroma);
end;

function TTonalPalette.Get(tone: Double): TARGB;
begin
  Result := IntFromHcl(FHue, FChroma, tone);
end;

function TTonalPalette.CreateKeyColor(hue, chroma: Double): THCT;
var
  start_tone: Double;
  smallest_delta_hct: THCT;
  smallest_delta: Double;
begin
  start_tone := 50.0;
  smallest_delta_hct := THCT.Create(hue, chroma, start_tone);
  smallest_delta := Abs(smallest_delta_hct.Chroma - chroma);
  // Starting from T50, check T+/-delta to see if they match the requested
  // chroma.
  //
  // Starts from T50 because T50 has the most chroma available, on
  // average. Thus it is most likely to have a direct answer and minimize
  // iteration.
  var delta := 1.0;
  while delta < 50.0 do
  begin
    // Termination condition rounding instead of minimizing delta to avoid
    // case where requested chroma is 16.51, and the closest chroma is 16.49.
    // Error is minimized, but when rounded and displayed, requested chroma
    // is 17, key color's chroma is 16.
    if (Round(chroma) = Round(smallest_delta_hct.Chroma)) then
      Exit(smallest_delta_hct);

    var hct_add := THCT.Create(hue, chroma, start_tone + delta);
    var hct_add_delta: Double := Abs(hct_add.Chroma - chroma);
    if (hct_add_delta < smallest_delta) then
    begin
      smallest_delta := hct_add_delta;
      smallest_delta_hct := hct_add;
    end;

    var hct_subtract := THCT.Create(hue, chroma, start_tone - delta);
    var hct_subtract_delta: Double := Abs(hct_subtract.Chroma - chroma);
    if (hct_subtract_delta < smallest_delta) then
    begin
      smallest_delta := hct_subtract_delta;
      smallest_delta_hct := hct_subtract;
    end;

    delta := delta + 1.0;
  end;

  Result := smallest_delta_hct;
end;

end.
