unit MaterialColor.CAM.CAMTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.CAM;

const
  RED: TARGB   = $ffff0000;
  GREEN: TARGB = $ff00ff00;
  BLUE: TARGB  = $ff0000ff;
  WHITE: TARGB = $ffffffff;
  BLACK: TARGB = $ff000000;

type
  [TestFixture]
  TestCAM = class
  public
    [TestCase('Red', '')]
    procedure TestRed;
    [TestCase('Green', '')]
    procedure TestGreen;
    [TestCase('Blue', '')]
    procedure TestBlue;
    [TestCase('White', '')]
    procedure TestWhite;
    [TestCase('Black', '')]
    procedure TestBlack;

    [TestCase('RedRoundTrip', '')]
    procedure TestRedRoundTrip;
    [TestCase('GreenRoundTrip', '')]
    procedure TestGreenRoundTrip;
    [TestCase('BlueRoundTrip', '')]
    procedure TestBlueRoundTrip;
  end;

implementation

{ TestCAM }

procedure TestCAM.TestRed;
begin
  var cam := CamFromInt(RED);

  Assert.AreEqual(cam.hue, 27.408, 0.001);
  Assert.AreEqual(cam.chroma, 113.357, 0.001);
  Assert.AreEqual(cam.j, 46.445, 0.001);
  Assert.AreEqual(cam.m, 89.494, 0.001);
  Assert.AreEqual(cam.s, 91.889, 0.001);
  Assert.AreEqual(cam.q, 105.988, 0.001);
end;

procedure TestCAM.TestGreen;
begin
  var cam := CamFromInt(GREEN);

  Assert.AreEqual(cam.hue, 142.139, 0.001);
  Assert.AreEqual(cam.chroma, 108.410, 0.001);
  Assert.AreEqual(cam.j, 79.331, 0.001);
  Assert.AreEqual(cam.m, 85.587, 0.001);
  Assert.AreEqual(cam.s, 78.604, 0.001);
  Assert.AreEqual(cam.q, 138.520, 0.001);
end;

procedure TestCAM.TestBlue;
begin
  var cam := CamFromInt(BLUE);

  Assert.AreEqual(cam.hue, 282.788, 0.001);
  Assert.AreEqual(cam.chroma, 87.230, 0.001);
  Assert.AreEqual(cam.j, 25.465, 0.001);
  Assert.AreEqual(cam.m, 68.867, 0.001);
  Assert.AreEqual(cam.s, 93.674, 0.001);
  Assert.AreEqual(cam.q, 78.481, 0.001);
end;

procedure TestCAM.TestWhite;
begin
  var cam := CamFromInt(WHITE);

  Assert.AreEqual(cam.hue, 209.492, 0.001);
  Assert.AreEqual(cam.chroma, 2.869, 0.001);
  Assert.AreEqual(cam.j, 100.0, 0.001);
  Assert.AreEqual(cam.m, 2.265, 0.001);
  Assert.AreEqual(cam.s, 12.068, 0.001);
  Assert.AreEqual(cam.q, 155.521, 0.001);
end;

procedure TestCAM.TestBlack;
begin
  var cam := CamFromInt(BLACK);

  Assert.AreEqual(cam.hue, 0.0, 0.001);
  Assert.AreEqual(cam.chroma, 0.0, 0.001);
  Assert.AreEqual(cam.j, 0.0, 0.001);
  Assert.AreEqual(cam.m, 0.0, 0.001);
  Assert.AreEqual(cam.s, 0.0, 0.001);
  Assert.AreEqual(cam.q, 0.0, 0.001);
end;

procedure TestCAM.TestRedRoundTrip;
begin
  var cam := CamFromInt(RED);
  var argb := IntFromCam(cam);
  Assert.AreEqual(argb, RED);
end;

procedure TestCAM.TestGreenRoundTrip;
begin
  var cam := CamFromInt(GREEN);
  var argb := IntFromCam(cam);
  Assert.AreEqual(argb, GREEN);
end;

procedure TestCAM.TestBlueRoundTrip;
begin
  var cam := CamFromInt(BLUE);
  var argb := IntFromCam(cam);
  Assert.AreEqual(argb, BLUE);
end;

initialization
  TDUnitX.RegisterTestFixture(TestCAM);

end.
