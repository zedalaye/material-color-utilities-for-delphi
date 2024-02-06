unit MaterialColor.Scheme.TonalSpot;

interface

uses
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.DynamicScheme;

type
  TSchemeTonalSpot = class(TDynamicSchemeBuilder)
    class function Construct(set_source_color_hct: THCT; set_is_dark: Boolean; set_contrast_level: Double = 0.0): TDynamicScheme; override;
  end;

implementation

uses
  MaterialColor.Utils,
  MaterialColor.DynamicColor.Variant,
  MaterialColor.Palettes.Tones;

{ TSchemeTonalSpot }

class function TSchemeTonalSpot.Construct(set_source_color_hct: THCT;
  set_is_dark: Boolean; set_contrast_level: Double): TDynamicScheme;
begin
  Result := TDynamicScheme.Create(
    (* source_color_argb: *) set_source_color_hct.ToInt(),
    (* variant: *) TDynamicColorVariant.kTonalSpot,
    (* contrast_level: *) set_contrast_level,
    (* is_dark: *) set_is_dark,
    (* primary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 36.0),
    (* secondary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 16.0),
    (* tertiary_palette: *)
    TTonalPalette.Create(
        SanitizeDegreesDouble(set_source_color_hct.Hue + 60), 24.0),
    (* neutral_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 6.0),
    (* neutral_variant_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 8.0)
  );
end;

end.
