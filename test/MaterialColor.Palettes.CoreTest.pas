unit MaterialColor.Palettes.CoreTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.CAM,
  MaterialColor.Palettes.Core;

type
  [TestFixture]
  TestPalettesCoreTest = class
  public
    [TestCase('HueRotatesRed', '')]
    procedure TestHueRotatesRed;

    [TestCase('HueRotatesGreen', '')]
    procedure TestHueRotatesGreen;

    [TestCase('HueRotatesBlue', '')]
    procedure TestHueRotatesBlue;

    [TestCase('HueWrapsWhenRotating', '')]
    procedure TestHueWrapsWhenRotating;
  end;


implementation

{ TestPalettesCoreTest }

procedure TestPalettesCoreTest.TestHueRotatesRed;
begin
  var color: TARGB := $ffff0000;

  var palette := TCorePalette.&Of(color);

  var delta_hue := DiffDegrees(CamFromInt(palette.Tertiary.Get(50)).hue,
                              CamFromInt(palette.Primary.Get(50)).hue);
  Assert.AreEqual(delta_hue, 60.0, 2.0);
end;

procedure TestPalettesCoreTest.TestHueRotatesGreen;
begin
  var color: TARGB := $ff00ff00;

  var palette := TCorePalette.&Of(color);

  var delta_hue := DiffDegrees(CamFromInt(palette.Tertiary.Get(50)).hue,
                              CamFromInt(palette.Primary.Get(50)).hue);
  Assert.AreEqual(delta_hue, 60.0, 2.0);
end;

procedure TestPalettesCoreTest.TestHueRotatesBlue;
begin
  var color: TARGB := $ff0000ff;

  var palette := TCorePalette.&Of(color);

  var delta_hue := DiffDegrees(CamFromInt(palette.Tertiary.Get(50)).hue,
                              CamFromInt(palette.Primary.Get(50)).hue);
  Assert.AreEqual(delta_hue, 60.0, 1.0);
end;

procedure TestPalettesCoreTest.TestHueWrapsWhenRotating;
begin
  var cam := CamFromInt(IntFromHcl(350, 48, 50));

  var palette := TCorePalette.&Of(cam.hue, cam.chroma);

  var a1_hue := CamFromInt(palette.Primary.Get(50)).hue;
  var a3_hue := CamFromInt(palette.Tertiary.Get(50)).hue;
  Assert.AreEqual(DiffDegrees(a1_hue, a3_hue), 60.0, 1.0);
  Assert.AreEqual(a3_hue, 50, 1.0);
end;

initialization
  TDUnitX.RegisterTestFixture(TestPalettesCoreTest);

end.
