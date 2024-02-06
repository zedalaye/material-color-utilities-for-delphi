unit MaterialColor.SchemeTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.Scheme;

type
  [TestFixture]
  TestScheme = class
  public
    [TestCase('SurfaceTones', '')]
    procedure TestSurfaceTones;

    [TestCase('BlueLightScheme', '')]
    procedure TestBlueLightScheme;

    [TestCase('BlueDarkScheme', '')]
    procedure TestBlueDarkScheme;

    [TestCase('ThirdPartyLightScheme', '')]
    procedure TestThirdPartyLightScheme;

    [TestCase('ThirdPartyDarkScheme', '')]
    procedure TestThirdPartyDarkScheme;

    [TestCase('LightSchemeFromHighChromaColor', '')]
    procedure TestLightSchemeFromHighChromaColor;

    [TestCase('DarkSchemeFromHighChromaColor', '')]
    procedure TestDarkSchemeFromHighChromaColor;

    [TestCase('LightContentSchemeFromHighChromaColor', '')]
    procedure TestLightContentSchemeFromHighChromaColor;

    [TestCase('DarkContentSchemeFromHighChromaColor', '')]
    procedure TestDarkContentSchemeFromHighChromaColor;
  end;

implementation

{$WARN SYMBOL_DEPRECATED OFF}

{ TestScheme }

procedure TestScheme.TestSurfaceTones;
begin
  var color: TARGB := $ff0000ff;

  var dark := MaterialDarkColorScheme(color);
  Assert.AreEqual(LstarFromArgb(dark.surface), 10.0, 0.5);

  var light := MaterialLightColorScheme(color);
  Assert.AreEqual(LstarFromArgb(light.surface), 99.0, 0.5);
end;

procedure TestScheme.TestBlueLightScheme;
begin
  var scheme := MaterialLightColorScheme($ff0000ff);
  Assert.AreEqual(HexFromArgb(scheme.primary), 'ff343dff');
end;

procedure TestScheme.TestBlueDarkScheme;
begin
  var scheme := MaterialDarkColorScheme($ff0000ff);
  Assert.AreEqual(HexFromArgb(scheme.primary), 'ffbec2ff');
end;

procedure TestScheme.TestThirdPartyLightScheme;
begin
  var scheme := MaterialLightColorScheme($ff6750a4);
  Assert.AreEqual(HexFromArgb(scheme.primary), 'ff6750a4');
  Assert.AreEqual(HexFromArgb(scheme.secondary), 'ff625b71');
  Assert.AreEqual(HexFromArgb(scheme.tertiary), 'ff7e5260');
  Assert.AreEqual(HexFromArgb(scheme.surface), 'fffffbff');
  Assert.AreEqual(HexFromArgb(scheme.on_surface), 'ff1c1b1e');
end;

procedure TestScheme.TestThirdPartyDarkScheme;
begin
  var scheme := MaterialDarkColorScheme($ff6750a4);
  Assert.AreEqual(HexFromArgb(scheme.primary), 'ffcfbcff');
  Assert.AreEqual(HexFromArgb(scheme.secondary), 'ffcbc2db');
  Assert.AreEqual(HexFromArgb(scheme.tertiary), 'ffefb8c8');
  Assert.AreEqual(HexFromArgb(scheme.surface), 'ff1c1b1e');
  Assert.AreEqual(HexFromArgb(scheme.on_surface), 'ffe6e1e6');
end;

procedure TestScheme.TestLightSchemeFromHighChromaColor;
begin
  var scheme := MaterialLightColorScheme($fffa2bec);
  Assert.AreEqual(HexFromArgb(scheme.primary), 'ffab00a2');
  Assert.AreEqual(HexFromArgb(scheme.on_primary), 'ffffffff');
  Assert.AreEqual(HexFromArgb(scheme.primary_container), 'ffffd7f3');
  Assert.AreEqual(HexFromArgb(scheme.on_primary_container), 'ff390035');
  Assert.AreEqual(HexFromArgb(scheme.secondary), 'ff6e5868');
  Assert.AreEqual(HexFromArgb(scheme.on_secondary), 'ffffffff');
  Assert.AreEqual(HexFromArgb(scheme.secondary_container), 'fff8daee');
  Assert.AreEqual(HexFromArgb(scheme.on_secondary_container), 'ff271624');
  Assert.AreEqual(HexFromArgb(scheme.tertiary), 'ff815343');
  Assert.AreEqual(HexFromArgb(scheme.on_tertiary), 'ffffffff');
  Assert.AreEqual(HexFromArgb(scheme.tertiary_container), 'ffffdbd0');
  Assert.AreEqual(HexFromArgb(scheme.on_tertiary_container), 'ff321207');
  Assert.AreEqual(HexFromArgb(scheme.error), 'ffba1a1a');
  Assert.AreEqual(HexFromArgb(scheme.on_error), 'ffffffff');
  Assert.AreEqual(HexFromArgb(scheme.error_container), 'ffffdad6');
  Assert.AreEqual(HexFromArgb(scheme.on_error_container), 'ff410002');
  Assert.AreEqual(HexFromArgb(scheme.background), 'fffffbff');
  Assert.AreEqual(HexFromArgb(scheme.on_background), 'ff1f1a1d');
  Assert.AreEqual(HexFromArgb(scheme.surface), 'fffffbff');
  Assert.AreEqual(HexFromArgb(scheme.on_surface), 'ff1f1a1d');
  Assert.AreEqual(HexFromArgb(scheme.surface_variant), 'ffeedee7');
  Assert.AreEqual(HexFromArgb(scheme.on_surface_variant), 'ff4e444b');
  Assert.AreEqual(HexFromArgb(scheme.outline), 'ff80747b');
  Assert.AreEqual(HexFromArgb(scheme.outline_variant), 'ffd2c2cb');
  Assert.AreEqual(HexFromArgb(scheme.shadow), 'ff000000');
  Assert.AreEqual(HexFromArgb(scheme.scrim), 'ff000000');
  Assert.AreEqual(HexFromArgb(scheme.inverse_surface), 'ff342f32');
  Assert.AreEqual(HexFromArgb(scheme.inverse_on_surface), 'fff8eef2');
  Assert.AreEqual(HexFromArgb(scheme.inverse_primary), 'ffffabee');
end;

procedure TestScheme.TestDarkSchemeFromHighChromaColor;
begin
  var scheme := MaterialDarkColorScheme($fffa2bec);
  Assert.AreEqual(HexFromArgb(scheme.primary), 'ffffabee');
  Assert.AreEqual(HexFromArgb(scheme.on_primary), 'ff5c0057');
  Assert.AreEqual(HexFromArgb(scheme.primary_container), 'ff83007b');
  Assert.AreEqual(HexFromArgb(scheme.on_primary_container), 'ffffd7f3');
  Assert.AreEqual(HexFromArgb(scheme.secondary), 'ffdbbed1');
  Assert.AreEqual(HexFromArgb(scheme.on_secondary), 'ff3e2a39');
  Assert.AreEqual(HexFromArgb(scheme.secondary_container), 'ff554050');
  Assert.AreEqual(HexFromArgb(scheme.on_secondary_container), 'fff8daee');
  Assert.AreEqual(HexFromArgb(scheme.tertiary), 'fff5b9a5');
  Assert.AreEqual(HexFromArgb(scheme.on_tertiary), 'ff4c2619');
  Assert.AreEqual(HexFromArgb(scheme.tertiary_container), 'ff663c2d');
  Assert.AreEqual(HexFromArgb(scheme.on_tertiary_container), 'ffffdbd0');
  Assert.AreEqual(HexFromArgb(scheme.error), 'ffffb4ab');
  Assert.AreEqual(HexFromArgb(scheme.on_error), 'ff690005');
  Assert.AreEqual(HexFromArgb(scheme.error_container), 'ff93000a');
  Assert.AreEqual(HexFromArgb(scheme.on_error_container), 'ffffb4ab');
  Assert.AreEqual(HexFromArgb(scheme.background), 'ff1f1a1d');
  Assert.AreEqual(HexFromArgb(scheme.on_background), 'ffeae0e4');
  Assert.AreEqual(HexFromArgb(scheme.surface), 'ff1f1a1d');
  Assert.AreEqual(HexFromArgb(scheme.on_surface), 'ffeae0e4');
  Assert.AreEqual(HexFromArgb(scheme.surface_variant), 'ff4e444b');
  Assert.AreEqual(HexFromArgb(scheme.on_surface_variant), 'ffd2c2cb');
  Assert.AreEqual(HexFromArgb(scheme.outline), 'ff9a8d95');
  Assert.AreEqual(HexFromArgb(scheme.outline_variant), 'ff4e444b');
  Assert.AreEqual(HexFromArgb(scheme.shadow), 'ff000000');
  Assert.AreEqual(HexFromArgb(scheme.scrim), 'ff000000');
  Assert.AreEqual(HexFromArgb(scheme.inverse_surface), 'ffeae0e4');
  Assert.AreEqual(HexFromArgb(scheme.inverse_on_surface), 'ff342f32');
  Assert.AreEqual(HexFromArgb(scheme.inverse_primary), 'ffab00a2');
end;

procedure TestScheme.TestLightContentSchemeFromHighChromaColor;
begin
  var scheme := MaterialLightContentColorScheme($fffa2bec);
  Assert.AreEqual(HexFromArgb(scheme.primary), 'ffab00a2');
  Assert.AreEqual(HexFromArgb(scheme.on_primary), 'ffffffff');
  Assert.AreEqual(HexFromArgb(scheme.primary_container), 'ffffd7f3');
  Assert.AreEqual(HexFromArgb(scheme.on_primary_container), 'ff390035');
  Assert.AreEqual(HexFromArgb(scheme.secondary), 'ff7f4e75');
  Assert.AreEqual(HexFromArgb(scheme.on_secondary), 'ffffffff');
  Assert.AreEqual(HexFromArgb(scheme.secondary_container), 'ffffd7f3');
  Assert.AreEqual(HexFromArgb(scheme.on_secondary_container), 'ff330b2f');
  Assert.AreEqual(HexFromArgb(scheme.tertiary), 'ff9c4323');
  Assert.AreEqual(HexFromArgb(scheme.on_tertiary), 'ffffffff');
  Assert.AreEqual(HexFromArgb(scheme.tertiary_container), 'ffffdbd0');
  Assert.AreEqual(HexFromArgb(scheme.on_tertiary_container), 'ff390c00');
  Assert.AreEqual(HexFromArgb(scheme.error), 'ffba1a1a');
  Assert.AreEqual(HexFromArgb(scheme.on_error), 'ffffffff');
  Assert.AreEqual(HexFromArgb(scheme.error_container), 'ffffdad6');
  Assert.AreEqual(HexFromArgb(scheme.on_error_container), 'ff410002');
  Assert.AreEqual(HexFromArgb(scheme.background), 'fffffbff');
  Assert.AreEqual(HexFromArgb(scheme.on_background), 'ff1f1a1d');
  Assert.AreEqual(HexFromArgb(scheme.surface), 'fffffbff');
  Assert.AreEqual(HexFromArgb(scheme.on_surface), 'ff1f1a1d');
  Assert.AreEqual(HexFromArgb(scheme.surface_variant), 'ffeedee7');
  Assert.AreEqual(HexFromArgb(scheme.on_surface_variant), 'ff4e444b');
  Assert.AreEqual(HexFromArgb(scheme.outline), 'ff80747b');
  Assert.AreEqual(HexFromArgb(scheme.outline_variant), 'ffd2c2cb');
  Assert.AreEqual(HexFromArgb(scheme.shadow), 'ff000000');
  Assert.AreEqual(HexFromArgb(scheme.scrim), 'ff000000');
  Assert.AreEqual(HexFromArgb(scheme.inverse_surface), 'ff342f32');
  Assert.AreEqual(HexFromArgb(scheme.inverse_on_surface), 'fff8eef2');
  Assert.AreEqual(HexFromArgb(scheme.inverse_primary), 'ffffabee');
end;

procedure TestScheme.TestDarkContentSchemeFromHighChromaColor;
begin
  var scheme := MaterialDarkContentColorScheme($fffa2bec);
  Assert.AreEqual(HexFromArgb(scheme.primary), 'ffffabee');
  Assert.AreEqual(HexFromArgb(scheme.on_primary), 'ff5c0057');
  Assert.AreEqual(HexFromArgb(scheme.primary_container), 'ff83007b');
  Assert.AreEqual(HexFromArgb(scheme.on_primary_container), 'ffffd7f3');
  Assert.AreEqual(HexFromArgb(scheme.secondary), 'fff0b4e1');
  Assert.AreEqual(HexFromArgb(scheme.on_secondary), 'ff4b2145');
  Assert.AreEqual(HexFromArgb(scheme.secondary_container), 'ff64375c');
  Assert.AreEqual(HexFromArgb(scheme.on_secondary_container), 'ffffd7f3');
  Assert.AreEqual(HexFromArgb(scheme.tertiary), 'ffffb59c');
  Assert.AreEqual(HexFromArgb(scheme.on_tertiary), 'ff5c1900');
  Assert.AreEqual(HexFromArgb(scheme.tertiary_container), 'ff7d2c0d');
  Assert.AreEqual(HexFromArgb(scheme.on_tertiary_container), 'ffffdbd0');
  Assert.AreEqual(HexFromArgb(scheme.error), 'ffffb4ab');
  Assert.AreEqual(HexFromArgb(scheme.on_error), 'ff690005');
  Assert.AreEqual(HexFromArgb(scheme.error_container), 'ff93000a');
  Assert.AreEqual(HexFromArgb(scheme.on_error_container), 'ffffb4ab');
  Assert.AreEqual(HexFromArgb(scheme.background), 'ff1f1a1d');
  Assert.AreEqual(HexFromArgb(scheme.on_background), 'ffeae0e4');
  Assert.AreEqual(HexFromArgb(scheme.surface), 'ff1f1a1d');
  Assert.AreEqual(HexFromArgb(scheme.on_surface), 'ffeae0e4');
  Assert.AreEqual(HexFromArgb(scheme.surface_variant), 'ff4e444b');
  Assert.AreEqual(HexFromArgb(scheme.on_surface_variant), 'ffd2c2cb');
  Assert.AreEqual(HexFromArgb(scheme.outline), 'ff9a8d95');
  Assert.AreEqual(HexFromArgb(scheme.outline_variant), 'ff4e444b');
  Assert.AreEqual(HexFromArgb(scheme.shadow), 'ff000000');
  Assert.AreEqual(HexFromArgb(scheme.scrim), 'ff000000');
  Assert.AreEqual(HexFromArgb(scheme.inverse_surface), 'ffeae0e4');
  Assert.AreEqual(HexFromArgb(scheme.inverse_on_surface), 'ff342f32');
  Assert.AreEqual(HexFromArgb(scheme.inverse_primary), 'ffab00a2');
end;

initialization
  TDUnitX.RegisterTestFixture(TestScheme);

end.
