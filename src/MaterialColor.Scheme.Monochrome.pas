unit MaterialColor.Scheme.Monochrome;

interface

uses
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.DynamicScheme;

type
  TSchemeMonochrome = class(TDynamicSchemeBuilder)
    class function Construct(set_source_color_hct: THCT; set_is_dark: Boolean; set_contrast_level: Double = 0.0): TDynamicScheme; override;
  end;

implementation

uses
  MaterialColor.Utils,
  MaterialColor.DynamicColor.Variant,
  MaterialColor.Palettes.Tones;

{ TSchemeMonochrome }

class function TSchemeMonochrome.Construct(set_source_color_hct: THCT;
  set_is_dark: Boolean; set_contrast_level: Double): TDynamicScheme;
begin
  Result := TDynamicScheme.Create(
    (* source_color_argb: *) set_source_color_hct.ToInt(),
    (* variant: *) TDynamicColorVariant.kMonochrome,
    (* contrast_level: *) set_contrast_level,
    (* is_dark: *) set_is_dark,
    (* primary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 0.0),
    (* secondary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 0.0),
    (* tertiary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 0.0),
    (* neutral_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 0.0),
    (* neutral_variant_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 0.0)
  );
end;

end.
