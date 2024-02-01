unit MaterialColor.CAM.HCTTest;

interface

uses
  System.UITypes,
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.CAM,
  MaterialColor.CAM.HCT;

type
  [TestFixture]
  TestHCT = class
  private
    procedure TestHCT(hue, chroma, tone: Double);
  public
    [TestCase('LimitedToSRGB', '')]
    procedure TestLimitedToSRGB;

    [TestCase('TruncatesColors', '')]
    procedure TestTruncatesColors;

    [TestCase('Correctness', '')]
    procedure TestCorrectness;
  end;

implementation

function IsOnBoundary(rgb_component: Integer): Boolean;
begin
  Result := (rgb_component = 0) or (rgb_component = 255);
end;

function ColorIsOnBoundary(argb: TARGB): Boolean;
begin
  result := IsOnBoundary(RedFromInt(argb))
         or IsOnBoundary(GreenFromInt(argb))
         or IsOnBoundary(BlueFromInt(argb));
end;

{ TestHCT }

procedure TestHCT.TestLimitedToSRGB;
begin
  // Ensures that the HCT class can only represent sRGB colors.
  // An impossibly high chroma is used.
  var hct := THCT.Create( { hue } 120.0, { chroma } 200.0, { tone } 50.0);
  var argb := hct.ToInt();

  // The hue, chroma, and tone members of hct should actually
  // represent the sRGB color.
  Assert.AreEqual<Double>(CamFromInt(argb).hue, hct.hue);
  Assert.AreEqual<Double>(CamFromInt(argb).chroma, hct.chroma);
  Assert.AreEqual<Double>(LstarFromArgb(argb), hct.tone);
end;

procedure TestHCT.TestTruncatesColors;
begin
  // Ensures that HCT truncates colors.
  var hct := THCT.Create( { hue } 120.0, { chroma } 60.0, { tone } 50.0);
  var chroma := hct.chroma;
  Assert.IsTrue(chroma < 60.0);

  // The new chroma should be lower than the original.
  hct.tone := 180.0;
  Assert.IsTrue(hct.chroma < chroma);
end;

procedure TestHCT.TestCorrectness;
const
  HUES:    array[0..11] of Double = (15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345);
  CHROMAS: array[0..10] of Double = ( 0, 10, 20,  30,  40,  50,  60,  70,  80,  90, 100);
  TONES:   array[0..6]  of Double = (20, 30, 40,  50,  60,  70,  80);
begin
  for var hue in HUES do
    for var chroma in CHROMAS do
      for var tone in TONES do
          TestHCT(hue, chroma, tone);
end;

procedure TestHCT.TestHCT(hue, chroma, tone: Double);
begin
  var color := THCT.Create(hue, chroma, tone);

  if (chroma > 0) then
    Assert.AreEqual(color.Hue, hue, 4.0);

  Assert.IsTrue(color.Chroma < (chroma + 2.5));

  if (color.Chroma < (chroma - 2.5)) then
    Assert.IsTrue(ColorIsOnBoundary(color.ToInt));

  Assert.AreEqual(color.Tone, tone, 0.5);
end;

initialization
  TDUnitX.RegisterTestFixture(TestHCT);

end.
