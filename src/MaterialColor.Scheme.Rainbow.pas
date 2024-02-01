unit MaterialColor.Scheme.Rainbow;

interface

uses
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.DynamicScheme;

type
  TSchemeRainbow = record
    class function Construct(set_source_color_hct: THCT; set_is_dark: Boolean; set_contrast_level: Double = 0.0): TDynamicScheme; static;
  end;

implementation

uses
  MaterialColor.Utils,
  MaterialColor.DynamicColor.Variant,
  MaterialColor.Palettes.Tones;

{ TSchemeRainbow }

class function TSchemeRainbow.Construct(set_source_color_hct: THCT;
  set_is_dark: Boolean; set_contrast_level: Double): TDynamicScheme;
begin
  Result := TDynamicScheme.Create(
    (* source_color_argb: *) set_source_color_hct.ToInt(),
    (* variant: *) TDynamicColorVariant.kRainbow,
    (* contrast_level: *) set_contrast_level,
    (* is_dark: *) set_is_dark,
    (* primary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 48.0),
    (* secondary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 16.0),
    (* tertiary_palette: *)
    TTonalPalette.Create(
        SanitizeDegreesDouble(set_source_color_hct.Hue + 60.0),
        24.0),
    (* neutral_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 0.0),
    (* neutral_variant_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 0.0)
  );
end;

end.
