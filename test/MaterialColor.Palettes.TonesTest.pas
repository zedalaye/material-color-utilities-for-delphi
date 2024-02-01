unit MaterialColor.Palettes.TonesTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.Palettes.Tones;

type
  [TestFixture]
  TestPalettesTonesTest = class
  public
    [TestCase('Blue', '')]
    procedure TestBlue;
  end;

implementation

{ TestPalettesTonesTest }

procedure TestPalettesTonesTest.TestBlue;
begin
  var color: TARGB := $ff0000ff;
  var tonal_palette := TTonalPalette.Create(color);
  Assert.AreEqual(HexFromArgb(tonal_palette.get(100)), 'ffffffff');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(95)), 'fff1efff');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(90)), 'ffe0e0ff');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(80)), 'ffbec2ff');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(70)), 'ff9da3ff');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(60)), 'ff7c84ff');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(50)), 'ff5a64ff');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(40)), 'ff343dff');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(30)), 'ff0000ef');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(20)), 'ff0001ac');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(10)), 'ff00006e');
  Assert.AreEqual(HexFromArgb(tonal_palette.get(0)), 'ff000000');
end;

initialization
  TDUnitX.RegisterTestFixture(TestPalettesTonesTest);

end.
