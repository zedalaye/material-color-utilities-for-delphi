unit MaterialColor.CAM.HTCSolverTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.CAM, MaterialColor.CAM.HCTSolver;

type
  [TestFixture]
  TestHCTSolver = class
  public
    [TestCase('Red', '')]
    procedure TestRed;
    [TestCase('Green', '')]
    procedure TestGreen;
    [TestCase('Blue', '')]
    procedure TestBlue;

    [TestCase('Exhaustive', ''), Ignore] // +/- 1 minute
    procedure TestExhaustive;
  end;

implementation

{ TestHCTSolver }

procedure TestHCTSolver.TestRed;
begin
  // Compute HCT
  var color: TARGB := $FFFE0315;
  var cam := CamFromInt(color);
  var tone := LstarFromArgb(color);

  // Compute input
  var recovered := SolveToInt(cam.hue, cam.chroma, tone);
  Assert.AreEqual(recovered, color);
end;

procedure TestHCTSolver.TestGreen;
begin
  // Compute HCT
  var color: TARGB := $FF15FE03;
  var cam := CamFromInt(color);
  var tone := LstarFromArgb(color);

  // Compute input
  var recovered := SolveToInt(cam.hue, cam.chroma, tone);
  Assert.AreEqual(recovered, color);
end;

procedure TestHCTSolver.TestBlue;
begin
  // Compute HCT
  var color: TARGB := $FF0315FE;
  var cam := CamFromInt(color);
  var tone := LstarFromArgb(color);

  // Compute input
  var recovered := SolveToInt(cam.hue, cam.chroma, tone);
  Assert.AreEqual(recovered, color);
end;

procedure TestHCTSolver.TestExhaustive;
begin
  for var colorIndex := 0 to $FFFFFF do
  begin
    var color := $FF000000 + colorIndex;
    var cam := CamFromInt(color);
    var tone := LstarFromArgb(color);

    // Compute input
    var recovered := SolveToInt(cam.hue, cam.chroma, tone);
    Assert.AreEqual(recovered, color);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TestHCTSolver);

end.
