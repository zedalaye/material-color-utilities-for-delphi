unit MaterialColor.Scheme.Expressive;

interface

uses
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.DynamicScheme;

type
  TSchemeExpressive = record
    class function Construct(set_source_color_hct: THCT; set_is_dark: Boolean; set_contrast_level: Double = 0.0): TDynamicScheme; static;
  end;

implementation

uses
  MaterialColor.DynamicColor.Variant,
  MaterialColor.Palettes.Tones;

{ TSchemeExpressive }

const
  kHues: TArray<Double> = [0, 21, 51, 121, 151, 191, 271, 321, 360];

  kSecondaryRotations: TArray<Double> = [45, 95, 45, 20, 45,
                                         90, 45, 45, 45];

  kTertiaryRotations: TArray<Double> = [120, 120, 20,  45, 20,
                                        15,  20,  120, 120];


class function TSchemeExpressive.Construct(set_source_color_hct: THCT;
  set_is_dark: Boolean; set_contrast_level: Double): TDynamicScheme;
begin
  Result := TDynamicScheme.Create(
    (* source_color_argb *) set_source_color_hct.ToInt,
    (* variant *) TDynamicColorVariant.kExpressive,
    (* contrast_level *) set_contrast_level,
    (* is_dark *) set_is_dark,
    (* primary_palette *)
    TTonalPalette.Create(set_source_color_hct.Hue + 240.0, 40.0),
    (* secondary_palette: *)
    TTonalPalette.Create(TDynamicScheme.GetRotatedHue(set_source_color_hct, kHues, kSecondaryRotations), 24.0),
    (* tertiary_palette: *)
    TTonalPalette.Create(TDynamicScheme.GetRotatedHue(set_source_color_hct, kHues, kTertiaryRotations), 32.0),
    (* neutral_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue + 15.0, 8.0),
    (* neutral_variant_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue + 15, 12.0)
  );
end;

end.
