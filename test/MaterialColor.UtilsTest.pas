unit MaterialColor.UtilsTest;

interface

uses
  System.UITypes,
  DUnitX.TestFramework,
  MaterialColor.Utils;

const
  kMatrix: TMat3 = (
    (1, 2, 3),
    (-4, 5, -6),
    (-7, -8, -9)
  );

type
  [TestFixture]
  TestUtils = class
  public
    [TestCase('Signum', '')]
    procedure TestSignum;

    [TestCase('RotationIsPositiveForCounterclockwise', '')]
    procedure TestRotationIsPositiveForCounterclockwise;

    [TestCase('RotationIsNegativeForClockwise', '')]
    procedure TestRotationIsNegativeForClockwise;

    [TestCase('AngleDifference', '')]
    procedure TestAngleDifference;

    [TestCase('AngleSanitation', '')]
    procedure TestAngleSanitation;

    [TestCase('MatrixMultiply', '')]
    procedure TestMatrixMultiply;

    [TestCase('AlphaFromInt', '')]
    procedure TestAlphaFromInt;

    [TestCase('RedFromInt', '')]
    procedure TestRedFromInt;

    [TestCase('GreenFromInt', '')]
    procedure TestGreenFromInt;

    [TestCase('BlueFromInt', '')]
    procedure TestBlueFromInt;

    [TestCase('Opaqueness', '')]
    procedure TestOpaqueness;

    [TestCase('LinearizedComponents', '')]
    procedure TestLinearizedComponents;

    [TestCase('DelinearizedComponents', '')]
    procedure TestDelinearizedComponents;

    [TestCase('DelinearizedIsLeftInverseOfLinearized', '')]
    procedure TestDelinearizedIsLeftInverseOfLinearized;

    [TestCase('ArgbFromLinrgb', '')]
    procedure TestArgbFromLinrgb;

    [TestCase('LstarFromArgb', '')]
    procedure TestLstarFromArgb;

    [TestCase('HexFromArgb', '')]
    procedure TestHexFromArgb;

    [TestCase('IntFromLstar', '')]
    procedure TestIntFromLstar;

    [TestCase('LstarArgbRoundtripProperty', '')]
    procedure TestLstarArgbRoundtripProperty;

    [TestCase('ArgbLstarRoundtripProperty', '')]
    procedure TestArgbLstarRoundtripProperty;

    [TestCase('YFromLstar', '')]
    procedure TestYFromLstar;

    [TestCase('LstarFromY', '')]
    procedure TestLstarFromY;

    [TestCase('YLstarRoundtripProperty', '')]
    procedure TestYLstarRoundtripProperty;

    [TestCase('LstarYRoundtripProperty', '')]
    procedure LstarYRoundtripProperty;
  end;

implementation

{ TestUtils }

procedure TestUtils.TestSignum;
begin
  Assert.AreEqual(Signum(0.001), 1);
  Assert.AreEqual(Signum(3.0), 1);
  Assert.AreEqual(Signum(100.0), 1);
  Assert.AreEqual(Signum(-0.002), -1);
  Assert.AreEqual(Signum(-4.0), -1);
  Assert.AreEqual(Signum(-101.0), -1);
  Assert.AreEqual(Signum(0.0), 0);
end;

procedure TestUtils.TestRotationIsPositiveForCounterclockwise;
begin
  Assert.AreEqual<Double>(RotationDirection(0.0, 30.0), 1.0);
  Assert.AreEqual<Double>(RotationDirection(0.0, 60.0), 1.0);
  Assert.AreEqual<Double>(RotationDirection(0.0, 150.0), 1.0);
  Assert.AreEqual<Double>(RotationDirection(90.0, 240.0), 1.0);
  Assert.AreEqual<Double>(RotationDirection(300.0, 30.0), 1.0);
  Assert.AreEqual<Double>(RotationDirection(270.0, 60.0), 1.0);
  Assert.AreEqual<Double>(RotationDirection(360.0 * 2, 15.0), 1.0);
  Assert.AreEqual<Double>(RotationDirection(360.0 * 3 + 15.0, -360.0 * 4 + 30.0), 1.0);
end;

procedure TestUtils.TestRotationIsNegativeForClockwise;
begin
  Assert.AreEqual<Double>(RotationDirection(30.0, 0.0), -1.0);
  Assert.AreEqual<Double>(RotationDirection(60.0, 0.0), -1.0);
  Assert.AreEqual<Double>(RotationDirection(150.0, 0.0), -1.0);
  Assert.AreEqual<Double>(RotationDirection(240.0, 90.0), -1.0);
  Assert.AreEqual<Double>(RotationDirection(30.0, 300.0), -1.0);
  Assert.AreEqual<Double>(RotationDirection(60.0, 270.0), -1.0);
  Assert.AreEqual<Double>(RotationDirection(15.0, -360.0 * 2), -1.0);
  Assert.AreEqual<Double>(RotationDirection(-360.0 * 4 + 270.0, 360.0 * 5 + 180.0), -1.0);
end;

procedure TestUtils.TestAngleDifference;
begin
  Assert.AreEqual<Double>(DiffDegrees(0.0, 30.0), 30.0);
  Assert.AreEqual<Double>(DiffDegrees(0.0, 60.0), 60.0);
  Assert.AreEqual<Double>(DiffDegrees(0.0, 150.0), 150.0);
  Assert.AreEqual<Double>(DiffDegrees(90.0, 240.0), 150.0);
  Assert.AreEqual<Double>(DiffDegrees(300.0, 30.0), 90.0);
  Assert.AreEqual<Double>(DiffDegrees(270.0, 60.0), 150.0);

  Assert.AreEqual<Double>(DiffDegrees(30.0, 0.0), 30.0);
  Assert.AreEqual<Double>(DiffDegrees(60.0, 0.0), 60.0);
  Assert.AreEqual<Double>(DiffDegrees(150.0, 0.0), 150.0);
  Assert.AreEqual<Double>(DiffDegrees(240.0, 90.0), 150.0);
  Assert.AreEqual<Double>(DiffDegrees(30.0, 300.0), 90.0);
  Assert.AreEqual<Double>(DiffDegrees(60.0, 270.0), 150.0);
end;

procedure TestUtils.TestAngleSanitation;
begin
  Assert.AreEqual(SanitizeDegreesInt(30), 30);
  Assert.AreEqual(SanitizeDegreesInt(240), 240);
  Assert.AreEqual(SanitizeDegreesInt(360), 0);
  Assert.AreEqual(SanitizeDegreesInt(-30), 330);
  Assert.AreEqual(SanitizeDegreesInt(-750), 330);
  Assert.AreEqual(SanitizeDegreesInt(-54321), 39);

  Assert.AreEqual(SanitizeDegreesDouble(30.0), 30.0, 1e-4);
  Assert.AreEqual(SanitizeDegreesDouble(240.0), 240.0, 1e-4);
  Assert.AreEqual(SanitizeDegreesDouble(360.0), 0.0, 1e-4);
  Assert.AreEqual(SanitizeDegreesDouble(-30.0), 330.0, 1e-4);
  Assert.AreEqual(SanitizeDegreesDouble(-750.0), 330.0, 1e-4);
  Assert.AreEqual(SanitizeDegreesDouble(-54321.0), 39.0, 1e-4);
  Assert.AreEqual(SanitizeDegreesDouble(360.125), 0.125, 1e-4);
  Assert.AreEqual(SanitizeDegreesDouble(-11111.11), 48.89, 1e-4);
end;

procedure TestUtils.TestMatrixMultiply;
begin
  var vector_one := MatrixMultiply(TVec3.Create(1, 3, 5), kMatrix);
  Assert.AreEqual(vector_one.a, 22, 1e-4);
  Assert.AreEqual(vector_one.b, -19, 1e-4);
  Assert.AreEqual(vector_one.c, -76, 1e-4);

  var vector_two := MatrixMultiply(TVec3.Create(-11.1, 22.2, -33.3), kMatrix);
  Assert.AreEqual(vector_two.a, -66.6, 1e-4);
  Assert.AreEqual(vector_two.b, 355.2, 1e-4);
  Assert.AreEqual(vector_two.c, 199.8, 1e-4);
end;

procedure TestUtils.TestAlphaFromInt;
begin
  Assert.AreEqual(AlphaFromInt($ff123456), $ff);
  Assert.AreEqual(AlphaFromInt($ffabcdef), $ff);
end;

procedure TestUtils.TestRedFromInt;
begin
  Assert.AreEqual(RedFromInt($ff123456), $12);
  Assert.AreEqual(RedFromInt($ffabcdef), $ab);
end;

procedure TestUtils.TestGreenFromInt;
begin
  Assert.AreEqual(GreenFromInt($ff123456), $34);
  Assert.AreEqual(GreenFromInt($ffabcdef), $cd);
end;

procedure TestUtils.TestBlueFromInt;
begin
  Assert.AreEqual(BlueFromInt($ff123456), $56);
  Assert.AreEqual(BlueFromInt($ffabcdef), $ef);
end;

procedure TestUtils.TestOpaqueness;
begin
  Assert.IsTrue(IsOpaque($ff123456));
  Assert.IsFalse(IsOpaque($f0123456));
  Assert.IsFalse(IsOpaque($00123456));
end;

procedure TestUtils.TestLinearizedComponents;
begin
  Assert.AreEqual(Linearized(0), 0.0, 1e-4);
  Assert.AreEqual(Linearized(1), 0.0303527, 1e-4);
  Assert.AreEqual(Linearized(2), 0.0607054, 1e-4);
  Assert.AreEqual(Linearized(8), 0.242822, 1e-4);
  Assert.AreEqual(Linearized(9), 0.273174, 1e-4);
  Assert.AreEqual(Linearized(16), 0.518152, 1e-4);
  Assert.AreEqual(Linearized(32), 1.44438, 1e-4);
  Assert.AreEqual(Linearized(64), 5.12695, 1e-4);
  Assert.AreEqual(Linearized(128), 21.5861, 1e-4);
  Assert.AreEqual(Linearized(255), 100.0, 1e-4);
end;

procedure TestUtils.TestDelinearizedComponents;
begin
  Assert.AreEqual(Delinearized(0.0), 0);
  Assert.AreEqual(Delinearized(0.0303527), 1);
  Assert.AreEqual(Delinearized(0.0607054), 2);
  Assert.AreEqual(Delinearized(0.242822), 8);
  Assert.AreEqual(Delinearized(0.273174), 9);
  Assert.AreEqual(Delinearized(0.518152), 16);
  Assert.AreEqual(Delinearized(1.44438), 32);
  Assert.AreEqual(Delinearized(5.12695), 64);
  Assert.AreEqual(Delinearized(21.5861), 128);
  Assert.AreEqual(Delinearized(100.0), 255);

  Assert.AreEqual(Delinearized(25.0), 137);
  Assert.AreEqual(Delinearized(50.0), 188);
  Assert.AreEqual(Delinearized(75.0), 225);

  // Delinearized clamps out-of-range inputs.
  Assert.AreEqual(Delinearized(-1.0), 0);
  Assert.AreEqual(Delinearized(-10000.0), 0);
  Assert.AreEqual(Delinearized(101.0), 255);
  Assert.AreEqual(Delinearized(10000.0), 255);
end;

procedure TestUtils.TestDelinearizedIsLeftInverseOfLinearized;
begin
  Assert.AreEqual(Delinearized(Linearized(0)), 0);
  Assert.AreEqual(Delinearized(Linearized(1)), 1);
  Assert.AreEqual(Delinearized(Linearized(2)), 2);
  Assert.AreEqual(Delinearized(Linearized(8)), 8);
  Assert.AreEqual(Delinearized(Linearized(9)), 9);
  Assert.AreEqual(Delinearized(Linearized(16)), 16);
  Assert.AreEqual(Delinearized(Linearized(32)), 32);
  Assert.AreEqual(Delinearized(Linearized(64)), 64);
  Assert.AreEqual(Delinearized(Linearized(128)), 128);
  Assert.AreEqual(Delinearized(Linearized(255)), 255);
end;

procedure TestUtils.TestArgbFromLinrgb;
begin
  Assert.AreEqual(ArgbFromLinrgb(TVec3.Create(25.0, 50.0, 75.0)), $ff89bce1);
  Assert.AreEqual(ArgbFromLinrgb(TVec3.Create(0.03, 0.06, 0.12)), $ff010204);
end;

procedure TestUtils.TestLstarFromArgb;
begin
  Assert.AreEqual(LstarFromArgb($ff89bce1), 74.011, 1e-4);
  Assert.AreEqual(LstarFromArgb($ff010204), 0.529651, 1e-4);
end;

procedure TestUtils.TestHexFromArgb;
begin
  Assert.AreEqual(HexFromArgb($ff89bce1), 'ff89bce1');
  Assert.AreEqual(HexFromArgb($ff010204), 'ff010204');
end;

procedure TestUtils.TestIntFromLstar;
begin
  // Given an L* brightness value in [0, 100], IntFromLstar returns a greyscale
  // color in ARGB format with that brightness.
  // For L* outside the domain [0, 100], returns black or white.

  Assert.AreEqual(IntFromLstar(0.0), $ff000000);
  Assert.AreEqual(IntFromLstar(0.25), $ff010101);
  Assert.AreEqual(IntFromLstar(0.5), $ff020202);
  Assert.AreEqual(IntFromLstar(1.0), $ff040404);
  Assert.AreEqual(IntFromLstar(2.0), $ff070707);
  Assert.AreEqual(IntFromLstar(4.0), $ff0e0e0e);
  Assert.AreEqual(IntFromLstar(8.0), $ff181818);
  Assert.AreEqual(IntFromLstar(25.0), $ff3b3b3b);
  Assert.AreEqual(IntFromLstar(50.0), $ff777777);
  Assert.AreEqual(IntFromLstar(75.0), $ffb9b9b9);
  Assert.AreEqual(IntFromLstar(99.0), $fffcfcfc);
  Assert.AreEqual(IntFromLstar(100.0), $ffffffff);

  Assert.AreEqual(IntFromLstar(-1.0), $ff000000);
  Assert.AreEqual(IntFromLstar(-2.0), $ff000000);
  Assert.AreEqual(IntFromLstar(-3.0), $ff000000);
  Assert.AreEqual(IntFromLstar(-9999999.0), $ff000000);

  Assert.AreEqual(IntFromLstar(101.0), $ffffffff);
  Assert.AreEqual(IntFromLstar(111.0), $ffffffff);
  Assert.AreEqual(IntFromLstar(9999999.0), $ffffffff);
end;

procedure TestUtils.TestLstarArgbRoundtripProperty;
begin
  // Confirms that L* -> ARGB -> L* preserves original value
  // (taking ARGB rounding into consideration).
  Assert.AreEqual(LstarFromArgb(IntFromLstar(0.0)), 0.0, 1.0);
  Assert.AreEqual(LstarFromArgb(IntFromLstar(1.0)), 1.0, 1.0);
  Assert.AreEqual(LstarFromArgb(IntFromLstar(2.0)), 2.0, 1.0);
  Assert.AreEqual(LstarFromArgb(IntFromLstar(8.0)), 8.0, 1.0);
  Assert.AreEqual(LstarFromArgb(IntFromLstar(25.0)), 25.0, 1.0);
  Assert.AreEqual(LstarFromArgb(IntFromLstar(50.0)), 50.0, 1.0);
  Assert.AreEqual(LstarFromArgb(IntFromLstar(75.0)), 75.0, 1.0);
  Assert.AreEqual(LstarFromArgb(IntFromLstar(99.0)), 99.0, 1.0);
  Assert.AreEqual(LstarFromArgb(IntFromLstar(100.0)), 100.0, 1.0);
end;

procedure TestUtils.TestArgbLstarRoundtripProperty;
begin
  // Confirms that ARGB -> L* -> ARGB preserves original value
  // for greyscale colors.
  Assert.AreEqual(IntFromLstar(LstarFromArgb($ff000000)), $ff000000);
  Assert.AreEqual(IntFromLstar(LstarFromArgb($ff010101)), $ff010101);
  Assert.AreEqual(IntFromLstar(LstarFromArgb($ff020202)), $ff020202);
  Assert.AreEqual(IntFromLstar(LstarFromArgb($ff111111)), $ff111111);
  Assert.AreEqual(IntFromLstar(LstarFromArgb($ff333333)), $ff333333);
  Assert.AreEqual(IntFromLstar(LstarFromArgb($ff777777)), $ff777777);
  Assert.AreEqual(IntFromLstar(LstarFromArgb($ffbbbbbb)), $ffbbbbbb);
  Assert.AreEqual(IntFromLstar(LstarFromArgb($fffefefe)), $fffefefe);
  Assert.AreEqual(IntFromLstar(LstarFromArgb($ffffffff)), $ffffffff);
end;

procedure TestUtils.TestYFromLstar;
begin
  Assert.AreEqual(YFromLstar(0.0), 0.0, 1e-5);
  Assert.AreEqual(YFromLstar(0.1), 0.0110705, 1e-5);
  Assert.AreEqual(YFromLstar(0.2), 0.0221411, 1e-5);
  Assert.AreEqual(YFromLstar(0.3), 0.0332116, 1e-5);
  Assert.AreEqual(YFromLstar(0.4), 0.0442822, 1e-5);
  Assert.AreEqual(YFromLstar(0.5), 0.0553528, 1e-5);
  Assert.AreEqual(YFromLstar(1.0), 0.1107056, 1e-5);
  Assert.AreEqual(YFromLstar(2.0), 0.2214112, 1e-5);
  Assert.AreEqual(YFromLstar(3.0), 0.3321169, 1e-5);
  Assert.AreEqual(YFromLstar(4.0), 0.4428225, 1e-5);
  Assert.AreEqual(YFromLstar(5.0), 0.5535282, 1e-5);
  Assert.AreEqual(YFromLstar(8.0), 0.8856451, 1e-5);
  Assert.AreEqual(YFromLstar(10.0), 1.1260199, 1e-5);
  Assert.AreEqual(YFromLstar(15.0), 1.9085832, 1e-5);
  Assert.AreEqual(YFromLstar(20.0), 2.9890524, 1e-5);
  Assert.AreEqual(YFromLstar(25.0), 4.4154767, 1e-5);
  Assert.AreEqual(YFromLstar(30.0), 6.2359055, 1e-5);
  Assert.AreEqual(YFromLstar(40.0), 11.2509737, 1e-5);
  Assert.AreEqual(YFromLstar(50.0), 18.4186518, 1e-5);
  Assert.AreEqual(YFromLstar(60.0), 28.1233342, 1e-5);
  Assert.AreEqual(YFromLstar(70.0), 40.7494157, 1e-5);
  Assert.AreEqual(YFromLstar(80.0), 56.6812907, 1e-5);
  Assert.AreEqual(YFromLstar(90.0), 76.3033539, 1e-5);
  Assert.AreEqual(YFromLstar(95.0), 87.6183294, 1e-5);
  Assert.AreEqual(YFromLstar(99.0), 97.4360239, 1e-5);
  Assert.AreEqual(YFromLstar(100.0), 100.0, 1e-5);
end;

procedure TestUtils.TestLstarFromY;
begin
  Assert.AreEqual(LstarFromY(0.0), 0.0, 1e-5);
  Assert.AreEqual(LstarFromY(0.1), 0.9032962, 1e-5);
  Assert.AreEqual(LstarFromY(0.2), 1.8065925, 1e-5);
  Assert.AreEqual(LstarFromY(0.3), 2.7098888, 1e-5);
  Assert.AreEqual(LstarFromY(0.4), 3.6131851, 1e-5);
  Assert.AreEqual(LstarFromY(0.5), 4.5164814, 1e-5);
  Assert.AreEqual(LstarFromY(0.8856451), 8.0, 1e-5);
  Assert.AreEqual(LstarFromY(1.0), 8.9914424, 1e-5);
  Assert.AreEqual(LstarFromY(2.0), 15.4872443, 1e-5);
  Assert.AreEqual(LstarFromY(3.0), 20.0438970, 1e-5);
  Assert.AreEqual(LstarFromY(4.0), 23.6714419, 1e-5);
  Assert.AreEqual(LstarFromY(5.0), 26.7347653, 1e-5);
  Assert.AreEqual(LstarFromY(10.0), 37.8424304, 1e-5);
  Assert.AreEqual(LstarFromY(15.0), 45.6341970, 1e-5);
  Assert.AreEqual(LstarFromY(20.0), 51.8372115, 1e-5);
  Assert.AreEqual(LstarFromY(25.0), 57.0754208, 1e-5);
  Assert.AreEqual(LstarFromY(30.0), 61.6542222, 1e-5);
  Assert.AreEqual(LstarFromY(40.0), 69.4695307, 1e-5);
  Assert.AreEqual(LstarFromY(50.0), 76.0692610, 1e-5);
  Assert.AreEqual(LstarFromY(60.0), 81.8381891, 1e-5);
  Assert.AreEqual(LstarFromY(70.0), 86.9968642, 1e-5);
  Assert.AreEqual(LstarFromY(80.0), 91.6848609, 1e-5);
  Assert.AreEqual(LstarFromY(90.0), 95.9967686, 1e-5);
  Assert.AreEqual(LstarFromY(95.0), 98.0335184, 1e-5);
  Assert.AreEqual(LstarFromY(99.0), 99.6120372, 1e-5);
  Assert.AreEqual(LstarFromY(100.0), 100.0, 1e-5);
end;

procedure TestUtils.TestYLstarRoundtripProperty;
begin
  // Confirms that Y -> L* -> Y preserves original value.
  var y: Double := 0.0;
  while y <= 100 do
  begin
    var lstar := LstarFromY(y);
    var reconstructedY := YFromLstar(lstar);
    Assert.AreEqual(reconstructedY, y, 1e-8);

    y := y + 0.1;
  end;
end;

procedure TestUtils.LstarYRoundtripProperty;
begin
  // Confirms that L* -> Y -> L* preserves original value.
  var lstar: Double := 0.0;
  while lstar <= 100 do
  begin
    var y := YFromLstar(lstar);
    var reconstructedLstar := LstarFromY(y);
    Assert.AreEqual(reconstructedLstar, lstar, 1e-8);

    lstar := lstar + 0.1;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TestUtils);

end.
