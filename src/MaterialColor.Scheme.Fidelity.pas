unit MaterialColor.Scheme.Fidelity;

interface

uses
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.DynamicScheme;

type
  TSchemeFidelity = record
    class function Construct(set_source_color_hct: THCT; set_is_dark: Boolean; set_contrast_level: Double = 0.0): TDynamicScheme; static;
  end;

implementation

uses
  System.Math,
  MaterialColor.Dislike,
  MaterialColor.DynamicColor.Variant,
  MaterialColor.Palettes.Tones,
  MaterialColor.TemperatureCache;

{ TSchemeFidelity }

class function TSchemeFidelity.Construct(set_source_color_hct: THCT;
  set_is_dark: Boolean; set_contrast_level: Double): TDynamicScheme;

  function TertiaryPaletteKeyColor: THCT;
  begin
    var cache: ITemperatureCache := TTemperatureCache.Create(set_source_color_hct);
    Result := cache.GetComplement;
  end;

begin
  Result := TDynamicScheme.Create(
    (* source_color_argb: *) set_source_color_hct.ToInt,
    (* variant: *) TDynamicColorVariant.kFidelity,
    (* contrast_level: *) set_contrast_level,
    (* is_dark: *) set_is_dark,
    (* primary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue,
                         set_source_color_hct.Chroma),
    (* secondary_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue,
                         Max(set_source_color_hct.Chroma - 32.0, set_source_color_hct.Chroma * 0.5)),
    (* tertiary_palette: *)
    TTonalPalette.Create(FixIfDisliked(TertiaryPaletteKeyColor)),
    (* neutral_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue,
                         set_source_color_hct.Chroma / 8.0),
    (* neutral_variant_palette: *)
    TTonalPalette.Create(set_source_color_hct.Hue,
                         set_source_color_hct.Chroma / 8.0 + 4.0)
  );
end;

end.
