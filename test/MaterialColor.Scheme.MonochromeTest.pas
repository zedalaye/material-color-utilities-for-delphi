unit MaterialColor.Scheme.MonochromeTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.Scheme.Monochrome;

type
  [TestFixture]
  TestSchemeMonochrome = class
  public
    [TestCase('DarkThemeMonochromeSpec', '')]
    procedure TestDarkThemeMonochromeSpec;

    [TestCase('LightThemeMonochromeSpec', '')]
    procedure TestLightThemeMonochromeSpec;
  end;

implementation

uses
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.MaterialDynamicColor;

{ TestSchemeMonochrome }

procedure TestSchemeMonochrome.TestDarkThemeMonochromeSpec;
begin
  var scheme := TSchemeMonochrome.Construct(THCT.Create($ff0000ff), True, 0.0);

  Assert.AreEqual(TMaterialDynamicColors.Primary().GetHct(scheme).Tone, 100.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnPrimary().GetHct(scheme).Tone, 10.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.PrimaryContainer().GetHct(scheme).Tone, 85.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnPrimaryContainer().GetHct(scheme).Tone, 0.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.Secondary().GetHct(scheme).Tone, 80.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnSecondary().GetHct(scheme).Tone, 10.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.SecondaryContainer().GetHct(scheme).Tone, 30.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnSecondaryContainer().GetHct(scheme).Tone, 90.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.Tertiary().GetHct(scheme).Tone, 90.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnTertiary().GetHct(scheme).Tone, 10.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.TertiaryContainer().GetHct(scheme).Tone, 60.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnTertiaryContainer().GetHct(scheme).Tone, 0.0, 1.0);
end;

procedure TestSchemeMonochrome.TestLightThemeMonochromeSpec;
begin
  var scheme := TSchemeMonochrome.Construct(THCT.Create($ff0000ff), False, 0.0);

  Assert.AreEqual(TMaterialDynamicColors.Primary().GetHct(scheme).Tone, 0.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnPrimary().GetHct(scheme).Tone, 90.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.PrimaryContainer().GetHct(scheme).Tone, 25.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnPrimaryContainer().GetHct(scheme).Tone, 100.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.Secondary().GetHct(scheme).Tone, 40.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnSecondary().GetHct(scheme).Tone, 100.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.SecondaryContainer().GetHct(scheme).Tone, 85.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnSecondaryContainer().GetHct(scheme).Tone, 10.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.Tertiary().GetHct(scheme).Tone, 25.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnTertiary().GetHct(scheme).Tone, 90.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.TertiaryContainer().GetHct(scheme).Tone, 49.0, 1.0);
  Assert.AreEqual(TMaterialDynamicColors.OnTertiaryContainer().GetHct(scheme).Tone, 100.0, 1.0);
end;

initialization
  TDUnitX.RegisterTestFixture(TestSchemeMonochrome);

end.
