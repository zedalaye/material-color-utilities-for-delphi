unit MaterialColor.Palettes.Core;

interface

uses
  System.Math,
  MaterialColor.Utils,
  MaterialColor.CAM,
  MaterialColor.Palettes.Tones;

(**
 * An intermediate concept between the key color for a UI theme, and a full
 * color scheme. 5 tonal palettes are generated, all except one use the same
 * hue as the key color, and all vary in chroma.
 *)
type
  TCorePalette  = record
  private
    FPrimary: TTonalPalette;
    FSecondary: TTonalPalette;
    FTertiary: TTonalPalette;
    FNeutral: TTonalPalette;
    FNeutralVariant: TTonalPalette;
    FError: TTonalPalette;

    constructor Create(hue, chroma: Double; is_content: Boolean);
  public
    (**
     * Creates a CorePalette from a hue and a chroma.
     *)
    class function &Of(hue, chroma: Double): TCorePalette; overload; static;

    (**
     * Creates a CorePalette from a source color in ARGB format.
     *)
    class function &Of(argb: TARGB): TCorePalette; overload; static;

    (**
     * Creates a content CorePalette from a hue and a chroma.
     *)
    class function ContentOf(hue, chroma: Double): TCorePalette; overload; static;

    (**
     * Creates a content CorePalette from a source color in ARGB format.
     *)
    class function ContentOf(argb: TARGB): TCorePalette; overload; static;

    property Primary: TTonalPalette read FPrimary;
    property Secondary: TTonalPalette read FSecondary;
    property Tertiary: TTonalPalette read FTertiary;
    property Neutral: TTonalPalette read FNeutral;
    property NeutralVariant: TTonalPalette read FNeutralVariant;
    property Error: TTonalPalette read FError;
  end;

implementation

function PrimaryChroma(chroma: Double; is_content: Boolean): Double;
begin
  if is_content then
    Result := chroma
  else
    Result := Max(chroma, 48.0);
end;

function SecondaryChroma(chroma: Double; is_content: Boolean): Double;
begin
  if is_content then
    Result := chroma / 3.0
  else
    Result := 16.0;
end;

function TertiaryChroma(chroma: Double; is_content: Boolean): Double;
begin
  if is_content then
    Result := chroma / 2.0
  else
    Result := 24.0;
end;

function NeutralChroma(chroma: Double; is_content: Boolean): Double;
begin
  if is_content then
    Result := Min(chroma / 12.0, 4.0)
  else
    Result := 4;
end;

function NeutralVariantChroma(chroma: Double; is_content: Boolean): Double;
begin
  if is_content then
    Result := Min(chroma / 6.0, 8.0)
  else
    Result := 8;
end;

{ TCorePalette }

constructor TCorePalette.Create(hue, chroma: Double; is_content: Boolean);
begin
  FPrimary        := TTonalPalette.Create(hue, PrimaryChroma(chroma, is_content));
  FSecondary      := TTonalPalette.Create(hue, SecondaryChroma(chroma, is_content));
  FTertiary       := TTonalPalette.Create(hue + 60.0, TertiaryChroma(chroma, is_content));
  FNeutral        := TTonalPalette.Create(hue, NeutralChroma(chroma, is_content));
  FNeutralVariant := TTonalPalette.Create(hue, NeutralVariantChroma(chroma, is_content));
  FError          := TTonalPalette.Create(25.0, 84.0);
end;

class function TCorePalette.&Of(hue, chroma: Double): TCorePalette;
begin
  Result := TCorePalette.Create(hue, chroma, False);
end;

class function TCorePalette.ContentOf(hue, chroma: Double): TCorePalette;
begin
  Result := TCorePalette.Create(hue, chroma, True);
end;

class function TCorePalette.&Of(argb: TARGB): TCorePalette;
begin
  var cam := CamFromInt(argb);
  Result := TCorePalette.Create(cam.hue, cam.chroma, False);
end;

class function TCorePalette.ContentOf(argb: TARGB): TCorePalette;
begin
  var cam := CamFromInt(argb);
  Result := TCorePalette.Create(cam.hue, cam.chroma, True);
end;

end.
