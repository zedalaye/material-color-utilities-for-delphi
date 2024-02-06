unit MaterialColor.DynamicColor.DynamicScheme;

interface

uses
  MaterialColor.Utils,
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.Variant,
  MaterialColor.Palettes.Tones;

type
  TDynamicScheme = record
    source_color_hct: THCT;
    variant: TDynamicColorVariant;
    is_dark: Boolean;
    contrast_level: Double;

    primary_palette: TTonalPalette;
    secondary_palette: TTonalPalette;
    tertiary_palette: TTonalPalette;
    neutral_palette: TTonalPalette;
    neutral_variant_palette: TTonalPalette;
    error_palette: TTonalPalette;

    constructor Create(
      source_color_argb: TARGB; variant: TDynamicColorVariant; contrast_level: Double;
      is_dark: Boolean; primary_palette, secondary_palette, tertiary_palette,
      neutral_palette, neutral_variant_palette: TTonalPalette
    );

    class function GetRotatedHue(source_color: THCT; hues, rotations: TArray<Double>): Double; static;

    function SourceColorArgb: TARGB;

    function GetPrimaryPaletteKeyColor: TARGB;
    function GetSecondaryPaletteKeyColor: TARGB;
    function GetTertiaryPaletteKeyColor: TARGB;
    function GetNeutralPaletteKeyColor: TARGB;
    function GetNeutralVariantPaletteKeyColor: TARGB;
    function GetBackground: TARGB;
    function GetOnBackground: TARGB;
    function GetSurface: TARGB;
    function GetSurfaceDim: TARGB;
    function GetSurfaceBright: TARGB;
    function GetSurfaceContainerLowest: TARGB;
    function GetSurfaceContainerLow: TARGB;
    function GetSurfaceContainer: TARGB;
    function GetSurfaceContainerHigh: TARGB;
    function GetSurfaceContainerHighest: TARGB;
    function GetOnSurface: TARGB;
    function GetSurfaceVariant: TARGB;
    function GetOnSurfaceVariant: TARGB;
    function GetInverseSurface: TARGB;
    function GetInverseOnSurface: TARGB;
    function GetOutline: TARGB;
    function GetOutlineVariant: TARGB;
    function GetShadow: TARGB;
    function GetScrim: TARGB;
    function GetSurfaceTint: TARGB;
    function GetPrimary: TARGB;
    function GetOnPrimary: TARGB;
    function GetPrimaryContainer: TARGB;
    function GetOnPrimaryContainer: TARGB;
    function GetInversePrimary: TARGB;
    function GetSecondary: TARGB;
    function GetOnSecondary: TARGB;
    function GetSecondaryContainer: TARGB;
    function GetOnSecondaryContainer: TARGB;
    function GetTertiary: TARGB;
    function GetOnTertiary: TARGB;
    function GetTertiaryContainer: TARGB;
    function GetOnTertiaryContainer: TARGB;
    function GetError: TARGB;
    function GetOnError: TARGB;
    function GetErrorContainer: TARGB;
    function GetOnErrorContainer: TARGB;
    function GetPrimaryFixed: TARGB;
    function GetPrimaryFixedDim: TARGB;
    function GetOnPrimaryFixed: TARGB;
    function GetOnPrimaryFixedVariant: TARGB;
    function GetSecondaryFixed: TARGB;
    function GetSecondaryFixedDim: TARGB;
    function GetOnSecondaryFixed: TARGB;
    function GetOnSecondaryFixedVariant: TARGB;
    function GetTertiaryFixed: TARGB;
    function GetTertiaryFixedDim: TARGB;
    function GetOnTertiaryFixed: TARGB;
    function GetOnTertiaryFixedVariant: TARGB;
  end;

  TDynamicSchemeBuilder = class abstract
    class function Construct(set_source_color_hct: THCT; set_is_dark: Boolean; set_contrast_level: Double = 0.0): TDynamicScheme; virtual; abstract;
  end;

  TDynamicSchemeBuilderClass = class of TDynamicSchemeBuilder;

implementation

uses
  MaterialColor.DynamicColor.MaterialDynamicColor;

{ TDynamicScheme }

constructor TDynamicScheme.Create(source_color_argb: TARGB;
  variant: TDynamicColorVariant; contrast_level: Double; is_dark: Boolean;
  primary_palette, secondary_palette, tertiary_palette, neutral_palette,
  neutral_variant_palette: TTonalPalette);
begin
  Self.source_color_hct := THCT.Create(source_color_argb);
  Self.variant := variant;
  Self.contrast_level := contrast_level;
  Self.is_dark := is_dark;
  Self.primary_palette := primary_palette;
  Self.secondary_palette := secondary_palette;
  Self.tertiary_palette := tertiary_palette;
  Self.neutral_palette := neutral_palette;
  Self.neutral_variant_palette := neutral_variant_palette;
  Self.error_palette := TTonalPalette.Create(25.0, 84.0);
end;

class function TDynamicScheme.GetRotatedHue(source_color: THCT; hues,
  rotations: TArray<Double>): Double;
var
  source_hue: Double;
begin
  source_hue := source_color.Hue;

  if (Length(rotations) = 1) then
    Exit(SanitizeDegreesDouble(source_color.Hue + rotations[0]));

  for var i := 0 to Length(hues) -2 do
  begin
    var this_hue := hues[i];
    var next_hue := hues[i + 1];
    if (this_hue < source_hue) and (source_hue < next_hue) then
      Exit(SanitizeDegreesDouble(source_hue + rotations[i]));
  end;

  Result := source_hue;
end;

function TDynamicScheme.SourceColorArgb: TARGB;
begin
  Result := source_color_hct.ToInt;
end;

function TDynamicScheme.GetPrimaryPaletteKeyColor: TARGB;
begin
  Result := TMaterialDynamicColors.PrimaryPaletteKeyColor().GetArgb(Self);
end;

function TDynamicScheme.GetSecondaryPaletteKeyColor: TARGB;
begin
  Result := TMaterialDynamicColors.SecondaryPaletteKeyColor().GetArgb(Self);
end;

function TDynamicScheme.GetTertiaryPaletteKeyColor: TARGB;
begin
  Result := TMaterialDynamicColors.TertiaryPaletteKeyColor().GetArgb(Self);
end;

function TDynamicScheme.GetNeutralPaletteKeyColor: TARGB;
begin
  Result := TMaterialDynamicColors.NeutralPaletteKeyColor().GetArgb(Self);
end;

function TDynamicScheme.GetNeutralVariantPaletteKeyColor: TARGB;
begin
  Result := TMaterialDynamicColors.NeutralVariantPaletteKeyColor().GetArgb(Self);
end;

function TDynamicScheme.GetBackground: TARGB;
begin
  Result := TMaterialDynamicColors.Background().GetArgb(Self);
end;

function TDynamicScheme.GetOnBackground: TARGB;
begin
  Result := TMaterialDynamicColors.OnBackground().GetArgb(Self);
end;

function TDynamicScheme.GetSurface: TARGB;
begin
  Result := TMaterialDynamicColors.Surface().GetArgb(Self);
end;

function TDynamicScheme.GetSurfaceDim: TARGB;
begin
  Result := TMaterialDynamicColors.SurfaceDim().GetArgb(Self);
end;

function TDynamicScheme.GetSurfaceBright: TARGB;
begin
  Result := TMaterialDynamicColors.SurfaceBright().GetArgb(Self);
end;

function TDynamicScheme.GetSurfaceContainerLowest: TARGB;
begin
  Result := TMaterialDynamicColors.SurfaceContainerLowest().GetArgb(Self);
end;

function TDynamicScheme.GetSurfaceContainerLow: TARGB;
begin
  Result := TMaterialDynamicColors.SurfaceContainerLow().GetArgb(Self);
end;

function TDynamicScheme.GetSurfaceContainer: TARGB;
begin
  Result := TMaterialDynamicColors.SurfaceContainer().GetArgb(Self);
end;

function TDynamicScheme.GetSurfaceContainerHigh: TARGB;
begin
  Result := TMaterialDynamicColors.SurfaceContainerHigh().GetArgb(Self);
end;

function TDynamicScheme.GetSurfaceContainerHighest: TARGB;
begin
  Result := TMaterialDynamicColors.SurfaceContainerHighest().GetArgb(Self);
end;

function TDynamicScheme.GetOnSurface: TARGB;
begin
  Result := TMaterialDynamicColors.OnSurface().GetArgb(Self);
end;

function TDynamicScheme.GetSurfaceVariant: TARGB;
begin
  Result := TMaterialDynamicColors.SurfaceVariant().GetArgb(Self);
end;

function TDynamicScheme.GetOnSurfaceVariant: TARGB;
begin
  Result := TMaterialDynamicColors.OnSurfaceVariant().GetArgb(Self);
end;

function TDynamicScheme.GetInverseSurface: TARGB;
begin
  Result := TMaterialDynamicColors.InverseSurface().GetArgb(Self);
end;

function TDynamicScheme.GetInverseOnSurface: TARGB;
begin
  Result := TMaterialDynamicColors.InverseOnSurface().GetArgb(Self);
end;

function TDynamicScheme.GetOutline: TARGB;
begin
  Result := TMaterialDynamicColors.Outline().GetArgb(Self);
end;

function TDynamicScheme.GetOutlineVariant: TARGB;
begin
  Result := TMaterialDynamicColors.OutlineVariant().GetArgb(Self);
end;

function TDynamicScheme.GetShadow: TARGB;
begin
  Result := TMaterialDynamicColors.Shadow().GetArgb(Self);
end;

function TDynamicScheme.GetScrim: TARGB;
begin
  Result := TMaterialDynamicColors.Scrim().GetArgb(Self);
end;

function TDynamicScheme.GetSurfaceTint: TARGB;
begin
  Result := TMaterialDynamicColors.SurfaceTint().GetArgb(Self);
end;

function TDynamicScheme.GetPrimary: TARGB;
begin
  Result := TMaterialDynamicColors.Primary().GetArgb(Self);
end;

function TDynamicScheme.GetOnPrimary: TARGB;
begin
  Result := TMaterialDynamicColors.OnPrimary().GetArgb(Self);
end;

function TDynamicScheme.GetPrimaryContainer: TARGB;
begin
  Result := TMaterialDynamicColors.PrimaryContainer().GetArgb(Self);
end;

function TDynamicScheme.GetOnPrimaryContainer: TARGB;
begin
  Result := TMaterialDynamicColors.OnPrimaryContainer().GetArgb(Self);
end;

function TDynamicScheme.GetInversePrimary: TARGB;
begin
  Result := TMaterialDynamicColors.InversePrimary().GetArgb(Self);
end;

function TDynamicScheme.GetSecondary: TARGB;
begin
  Result := TMaterialDynamicColors.Secondary().GetArgb(Self);
end;

function TDynamicScheme.GetOnSecondary: TARGB;
begin
  Result := TMaterialDynamicColors.OnSecondary().GetArgb(Self);
end;

function TDynamicScheme.GetSecondaryContainer: TARGB;
begin
  Result := TMaterialDynamicColors.SecondaryContainer().GetArgb(Self);
end;

function TDynamicScheme.GetOnSecondaryContainer: TARGB;
begin
  Result := TMaterialDynamicColors.OnSecondaryContainer().GetArgb(Self);
end;

function TDynamicScheme.GetTertiary: TARGB;
begin
  Result := TMaterialDynamicColors.Tertiary().GetArgb(Self);
end;

function TDynamicScheme.GetOnTertiary: TARGB;
begin
  Result := TMaterialDynamicColors.OnTertiary().GetArgb(Self);
end;

function TDynamicScheme.GetTertiaryContainer: TARGB;
begin
  Result := TMaterialDynamicColors.TertiaryContainer().GetArgb(Self);
end;

function TDynamicScheme.GetOnTertiaryContainer: TARGB;
begin
  Result := TMaterialDynamicColors.OnTertiaryContainer().GetArgb(Self);
end;

function TDynamicScheme.GetError: TARGB;
begin
  Result := TMaterialDynamicColors.Error().GetArgb(Self);
end;

function TDynamicScheme.GetOnError: TARGB;
begin
  Result := TMaterialDynamicColors.OnError().GetArgb(Self);
end;

function TDynamicScheme.GetErrorContainer: TARGB;
begin
  Result := TMaterialDynamicColors.ErrorContainer().GetArgb(Self);
end;

function TDynamicScheme.GetOnErrorContainer: TARGB;
begin
  Result := TMaterialDynamicColors.OnErrorContainer().GetArgb(Self);
end;

function TDynamicScheme.GetPrimaryFixed: TARGB;
begin
  Result := TMaterialDynamicColors.PrimaryFixed().GetArgb(Self);
end;

function TDynamicScheme.GetPrimaryFixedDim: TARGB;
begin
  Result := TMaterialDynamicColors.PrimaryFixedDim().GetArgb(Self);
end;

function TDynamicScheme.GetOnPrimaryFixed: TARGB;
begin
  Result := TMaterialDynamicColors.OnPrimaryFixed().GetArgb(Self);
end;

function TDynamicScheme.GetOnPrimaryFixedVariant: TARGB;
begin
  Result := TMaterialDynamicColors.OnPrimaryFixedVariant().GetArgb(Self);
end;

function TDynamicScheme.GetSecondaryFixed: TARGB;
begin
  Result := TMaterialDynamicColors.SecondaryFixed().GetArgb(Self);
end;

function TDynamicScheme.GetSecondaryFixedDim: TARGB;
begin
  Result := TMaterialDynamicColors.SecondaryFixedDim().GetArgb(Self);
end;

function TDynamicScheme.GetOnSecondaryFixed: TARGB;
begin
  Result := TMaterialDynamicColors.OnSecondaryFixed().GetArgb(Self);
end;

function TDynamicScheme.GetOnSecondaryFixedVariant: TARGB;
begin
  Result := TMaterialDynamicColors.OnSecondaryFixedVariant().GetArgb(Self);
end;

function TDynamicScheme.GetTertiaryFixed: TARGB;
begin
  Result := TMaterialDynamicColors.TertiaryFixed().GetArgb(Self);
end;

function TDynamicScheme.GetTertiaryFixedDim: TARGB;
begin
  Result := TMaterialDynamicColors.TertiaryFixedDim().GetArgb(Self);
end;

function TDynamicScheme.GetOnTertiaryFixed: TARGB;
begin
  Result := TMaterialDynamicColors.OnTertiaryFixed().GetArgb(Self);
end;

function TDynamicScheme.GetOnTertiaryFixedVariant: TARGB;
begin
  Result := TMaterialDynamicColors.OnTertiaryFixedVariant().GetArgb(Self);
end;

end.
