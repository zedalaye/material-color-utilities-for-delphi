unit MaterialColor.BlendTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.Blend;

type
  [TestFixture]
  TestBlend = class
  public
    [TestCase('RedToBlue', '')]
    procedure TestRedToBlue;
  end;

implementation

{ TestBlend }

procedure TestBlend.TestRedToBlue;
begin
  var blended := BlendHctHue($ffff0000, $ff0000ff, 0.8);
  Assert.AreEqual(HexFromArgb(blended), 'ff905eff');
end;

initialization
  TDUnitX.RegisterTestFixture(TestBlend);

end.
