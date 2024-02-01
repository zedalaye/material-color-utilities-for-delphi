unit MaterialColor.Scheme;

interface

uses
  MaterialColor.Utils,
  MaterialColor.Palettes.Core;

type
  TScheme = record
    primary: TARGB;
    on_primary: TARGB;
    primary_container: TARGB;
    on_primary_container: TARGB;
    secondary: TARGB;
    on_secondary: TARGB;
    secondary_container: TARGB;
    on_secondary_container: TARGB;
    tertiary: TARGB;
    on_tertiary: TARGB;
    tertiary_container: TARGB;
    on_tertiary_container: TARGB;
    error: TARGB;
    on_error: TARGB;
    error_container: TARGB;
    on_error_container: TARGB;
    background: TARGB;
    on_background: TARGB;
    surface: TARGB;
    on_surface: TARGB;
    surface_variant: TARGB;
    on_surface_variant: TARGB;
    outline: TARGB;
    outline_variant: TARGB;
    shadow: TARGB;
    scrim: TARGB;
    inverse_surface: TARGB;
    inverse_on_surface: TARGB;
    inverse_primary: TARGB;
  end;

(**
 * Returns the light material color scheme based on the given core palette.
 *)
function MaterialLightColorSchemeFromPalette(palette: TCorePalette): TScheme;

(**
 * Returns the dark material color scheme based on the given core palette.
 *)
function MaterialDarkColorSchemeFromPalette(palette: TCorePalette): TScheme;

(**
 * Returns the light material color scheme based on the given color,
 * in ARGB format.
 *)
function MaterialLightColorScheme(color: TARGB): TScheme;

(**
 * Returns the dark material color scheme based on the given color,
 * in ARGB format.
 *)
function MaterialDarkColorScheme(color: TARGB): TScheme;

(**
 * Returns the light material content color scheme based on the given color,
 * in ARGB format.
 *)
function MaterialLightContentColorScheme(color: TARGB): TScheme;

(**
 * Returns the dark material content color scheme based on the given color,
 * in ARGB format.
 *)
function MaterialDarkContentColorScheme(color: TARGB): TScheme;

implementation

function MaterialLightColorSchemeFromPalette(palette: TCorePalette): TScheme;
begin
  Result.primary := palette.Primary.Get(40);
  Result.on_primary := palette.Primary.Get(100);
  Result.primary_container := palette.Primary.Get(90);
  Result.on_primary_container := palette.Primary.Get(10);
  Result.secondary := palette.Secondary.Get(40);
  Result.on_secondary := palette.Secondary.Get(100);
  Result.secondary_container := palette.Secondary.Get(90);
  Result.on_secondary_container := palette.Secondary.Get(10);
  Result.tertiary := palette.Tertiary.Get(40);
  Result.on_tertiary := palette.Tertiary.Get(100);
  Result.tertiary_container := palette.Tertiary.Get(90);
  Result.on_tertiary_container := palette.Tertiary.Get(10);
  Result.error := palette.Error.Get(40);
  Result.on_error := palette.Error.Get(100);
  Result.error_container := palette.Error.Get(90);
  Result.on_error_container := palette.Error.Get(10);
  Result.background := palette.Neutral.Get(99);
  Result.on_background := palette.Neutral.Get(10);
  Result.surface := palette.Neutral.Get(99);
  Result.on_surface := palette.Neutral.Get(10);
  Result.surface_variant := palette.NeutralVariant.Get(90);
  Result.on_surface_variant := palette.NeutralVariant.Get(30);
  Result.outline := palette.NeutralVariant.Get(50);
  Result.outline_variant := palette.NeutralVariant.Get(80);
  Result.shadow := palette.Neutral.Get(0);
  Result.scrim := palette.Neutral.Get(0);
  Result.inverse_surface := palette.Neutral.Get(20);
  Result.inverse_on_surface := palette.Neutral.Get(95);
  Result.inverse_primary := palette.Primary.Get(80);
end;

function MaterialDarkColorSchemeFromPalette(palette: TCorePalette): TScheme;
begin
  Result.primary := palette.Primary.Get(80);
  Result.on_primary := palette.Primary.Get(20);
  Result.primary_container := palette.Primary.Get(30);
  Result.on_primary_container := palette.Primary.Get(90);
  Result.secondary := palette.Secondary.Get(80);
  Result.on_secondary := palette.Secondary.Get(20);
  Result.secondary_container := palette.Secondary.Get(30);
  Result.on_secondary_container := palette.Secondary.Get(90);
  Result.tertiary := palette.Tertiary.Get(80);
  Result.on_tertiary := palette.Tertiary.Get(20);
  Result.tertiary_container := palette.Tertiary.Get(30);
  Result.on_tertiary_container := palette.Tertiary.Get(90);
  Result.error := palette.Error.Get(80);
  Result.on_error := palette.Error.Get(20);
  Result.error_container := palette.Error.Get(30);
  Result.on_error_container := palette.Error.Get(80);
  Result.background := palette.Neutral.Get(10);
  Result.on_background := palette.Neutral.Get(90);
  Result.surface := palette.Neutral.Get(10);
  Result.on_surface := palette.Neutral.Get(90);
  Result.surface_variant := palette.NeutralVariant.Get(30);
  Result.on_surface_variant := palette.NeutralVariant.Get(80);
  Result.outline := palette.NeutralVariant.Get(60);
  Result.outline_variant := palette.NeutralVariant.Get(30);
  Result.shadow := palette.Neutral.Get(0);
  Result.scrim := palette.Neutral.Get(0);
  Result.inverse_surface := palette.Neutral.Get(90);
  Result.inverse_on_surface := palette.Neutral.Get(20);
  Result.inverse_primary := palette.Primary.Get(40);
end;

function MaterialLightColorScheme(color: TARGB): TScheme;
begin
  Result := MaterialLightColorSchemeFromPalette(TCorePalette.&Of(color));
end;

function MaterialDarkColorScheme(color: TARGB): TScheme;
begin
  Result := MaterialDarkColorSchemeFromPalette(TCorePalette.&Of(color));
end;

function MaterialLightContentColorScheme(color: TARGB): TScheme;
begin
  Result := MaterialLightColorSchemeFromPalette(TCorePalette.ContentOf(color));
end;

function MaterialDarkContentColorScheme(color: TARGB): TScheme;
begin
  Result := MaterialDarkColorSchemeFromPalette(TCorePalette.ContentOf(color));
end;

end.
