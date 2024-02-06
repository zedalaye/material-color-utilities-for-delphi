unit MaterialColor.Scheme.Neutral;

interface

uses
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.DynamicScheme;

type
  TSchemeNeutral = class(TDynamicSchemeBuilder)
    class function Construct(set_source_color_hct: THCT; set_is_dark: Boolean; set_contrast_level: Double = 0.0): TDynamicScheme; override;
  end;

implementation

uses
  MaterialColor.Utils,
  MaterialColor.DynamicColor.Variant,
  MaterialColor.Palettes.Tones;

{ TSchemeNeutral }

class function TSchemeNeutral.Construct(set_source_color_hct: THCT;
  set_is_dark: Boolean; set_contrast_level: Double): TDynamicScheme;
begin
  Result := TDynamicScheme.Create(
    (* source_color_argb: *) set_source_color_hct.ToInt(),
    (* variant: *) TDynamicColorVariant.kNeutral,
    (* contrast_level: *) set_contrast_level,
    (* is_dark: *) set_is_dark,
    (* primary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 12.0),
    (* secondary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 8.0),
    (* tertiary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 16.0),
    (* neutral_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 2.0),
    (* neutral_variant_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue, 2.0)
  );
end;

end.
