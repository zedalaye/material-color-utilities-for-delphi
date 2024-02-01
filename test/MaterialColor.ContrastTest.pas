unit MaterialColor.ContrastTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.Contrast;

type
  [TestFixture]
  TestContrast = class
  public
    [TestCase('RatioOfTonesOutOfBoundsInput', '')]
    procedure TestRatioOfTonesOutOfBoundsInput;

    [TestCase('LighterImpossibleRatioErrors', '')]
    procedure TestLighterImpossibleRatioErrors;

    [TestCase('LighterOutOfBoundsInputAboveErrors', '')]
    procedure TestLighterOutOfBoundsInputAboveErrors;

    [TestCase('LighterOutOfBoundsInputBelowErrors', '')]
    procedure TestLighterOutOfBoundsInputBelowErrors;

    [TestCase('LighterUnsafeReturnsMaxTone', '')]
    procedure TestLighterUnsafeReturnsMaxTone;

    [TestCase('DarkerImpossibleRatioErrors', '')]
    procedure TestDarkerImpossibleRatioErrors;

    [TestCase('DarkerOutOfBoundsInputAboveErrors', '')]
    procedure TestDarkerOutOfBoundsInputAboveErrors;

    [TestCase('DarkerOutOfBoundsInputBelowErrors', '')]
    procedure TestDarkerOutOfBoundsInputBelowErrors;

    [TestCase('DarkerUnsafeReturnsMinTone', '')]
    procedure TestDarkerUnsafeReturnsMinTone;
  end;

implementation

{ TestContrast }

procedure TestContrast.TestRatioOfTonesOutOfBoundsInput;
begin
  Assert.AreEqual(RatioOfTones(-10.0, 110.0), 21.0, 0.001);
end;

procedure TestContrast.TestLighterImpossibleRatioErrors;
begin
  Assert.AreEqual(Lighter(90.0, 10.0), -1.0, 0.001);
end;

procedure TestContrast.TestLighterOutOfBoundsInputAboveErrors;
begin
  Assert.AreEqual(Lighter(110.0, 2.0), -1.0, 0.001);
end;

procedure TestContrast.TestLighterOutOfBoundsInputBelowErrors;
begin
  Assert.AreEqual(Lighter(-10.0, 2.0), -1.0, 0.001);
end;

procedure TestContrast.TestLighterUnsafeReturnsMaxTone;
begin
  Assert.AreEqual(LighterUnsafe(100.0, 2.0), 100, 0.001);
end;

procedure TestContrast.TestDarkerImpossibleRatioErrors;
begin
  Assert.AreEqual(Darker(10.0, 20.0), -1.0, 0.001);
end;

procedure TestContrast.TestDarkerOutOfBoundsInputAboveErrors;
begin
  Assert.AreEqual(Darker(110.0, 2.0), -1.0, 0.001);
end;

procedure TestContrast.TestDarkerOutOfBoundsInputBelowErrors;
begin
  Assert.AreEqual(Darker(-10.0, 2.0), -1.0, 0.001);
end;

procedure TestContrast.TestDarkerUnsafeReturnsMinTone;
begin
  Assert.AreEqual(DarkerUnsafe(0.0, 2.0), 0.0, 0.001);
end;

initialization
  TDUnitX.RegisterTestFixture(TestContrast);

end.
