unit MaterialColor.DynamicColorTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils;

type
  [TestFixture]
  TestDynamicColor = class
  public
    [TestCase('One', '')]
    procedure TestOne;
  end;

implementation

uses
  MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.MaterialDynamicColor,
  MaterialColor.Scheme.Vibrant;

{ TestDynamicColor }

procedure TestDynamicColor.TestOne;
begin
  var s := TSchemeVibrant.Construct(THCT.Create($FFFF0000), False, 0.5);

  Assert.AreEqual(TMaterialDynamicColors.Background().GetArgb(s), $fffff8f6);
  Assert.AreEqual(TMaterialDynamicColors.OnBackground().GetArgb(s), $ff271815);
  Assert.AreEqual(TMaterialDynamicColors.Surface().GetArgb(s), $fffff8f6);
  Assert.AreEqual(TMaterialDynamicColors.SurfaceDim().GetArgb(s), $ffdcc0bc);
  Assert.AreEqual(TMaterialDynamicColors.SurfaceBright().GetArgb(s), $fffff8f6);
  Assert.AreEqual(TMaterialDynamicColors.SurfaceContainerLowest().GetArgb(s), $ffffffff);
  Assert.AreEqual(TMaterialDynamicColors.SurfaceContainerLow().GetArgb(s), $fffff0ee);
  Assert.AreEqual(TMaterialDynamicColors.SurfaceContainer().GetArgb(s), $ffffe2dd);
  Assert.AreEqual(TMaterialDynamicColors.SurfaceContainerHigh().GetArgb(s), $fff3d7d2);
  Assert.AreEqual(TMaterialDynamicColors.SurfaceContainerHighest().GetArgb(s), $ffe7cbc7);
  Assert.AreEqual(TMaterialDynamicColors.OnSurface().GetArgb(s), $ff1b0e0b);
  Assert.AreEqual(TMaterialDynamicColors.SurfaceVariant().GetArgb(s), $fffddbd5);
  Assert.AreEqual(TMaterialDynamicColors.OnSurfaceVariant().GetArgb(s), $ff46312e);
  Assert.AreEqual(TMaterialDynamicColors.InverseSurface().GetArgb(s), $ff3d2c29);
  Assert.AreEqual(TMaterialDynamicColors.InverseOnSurface().GetArgb(s), $ffffedea);
  Assert.AreEqual(TMaterialDynamicColors.Outline().GetArgb(s), $ff654d49);
  Assert.AreEqual(TMaterialDynamicColors.OutlineVariant().GetArgb(s), $ff816763);
  Assert.AreEqual(TMaterialDynamicColors.Shadow().GetArgb(s), $ff000000);
  Assert.AreEqual(TMaterialDynamicColors.Scrim().GetArgb(s), $ff000000);
  Assert.AreEqual(TMaterialDynamicColors.SurfaceTint().GetArgb(s), $ffc00100);
  Assert.AreEqual(TMaterialDynamicColors.Primary().GetArgb(s), $ff740100);
  Assert.AreEqual(TMaterialDynamicColors.OnPrimary().GetArgb(s), $ffffffff);
  Assert.AreEqual(TMaterialDynamicColors.PrimaryContainer().GetArgb(s), $ffdc0100);
  Assert.AreEqual(TMaterialDynamicColors.OnPrimaryContainer().GetArgb(s), $ffffffff);
  Assert.AreEqual(TMaterialDynamicColors.InversePrimary().GetArgb(s), $ffffb4a8);
  Assert.AreEqual(TMaterialDynamicColors.Secondary().GetArgb(s), $ff522d19);
  Assert.AreEqual(TMaterialDynamicColors.OnSecondary().GetArgb(s), $ffffffff);
  Assert.AreEqual(TMaterialDynamicColors.SecondaryContainer().GetArgb(s), $ff91624b);
  Assert.AreEqual(TMaterialDynamicColors.OnSecondaryContainer().GetArgb(s), $ffffffff);
  Assert.AreEqual(TMaterialDynamicColors.Tertiary().GetArgb(s), $ff532d00);
  Assert.AreEqual(TMaterialDynamicColors.OnTertiary().GetArgb(s), $ffffffff);
  Assert.AreEqual(TMaterialDynamicColors.TertiaryContainer().GetArgb(s), $ff946230);
  Assert.AreEqual(TMaterialDynamicColors.OnTertiaryContainer().GetArgb(s), $ffffffff);
  Assert.AreEqual(TMaterialDynamicColors.Error().GetArgb(s), $ff740006);
  Assert.AreEqual(TMaterialDynamicColors.OnError().GetArgb(s), $ffffffff);
  Assert.AreEqual(TMaterialDynamicColors.ErrorContainer().GetArgb(s), $ffcf2c27);
  Assert.AreEqual(TMaterialDynamicColors.OnErrorContainer().GetArgb(s), $ffffffff);
end;

initialization
  TDUnitX.RegisterTestFixture(TestDynamicColor);

end.
