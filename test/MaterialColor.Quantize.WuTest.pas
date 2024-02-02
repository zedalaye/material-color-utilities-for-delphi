unit MaterialColor.Quantize.WuTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.Quantize.Wu;

type
  [TestFixture]
  TestQuantizeWu = class
  public
    [TestCase('FullImage', '')]
    procedure TestFullImage;

    [TestCase('TwoRedThreeGreen', '')]
    procedure TestTwoRedThreeGreen;

    [TestCase('OneRed', '')]
    procedure TestOneRed;

    [TestCase('OneGreen', '')]
    procedure TestOneGreen;

    [TestCase('OneBlue', '')]
    procedure TestOneBlue;

    [TestCase('FiveBlue', '')]
    procedure TestFiveBlue;

    [TestCase('OneRedAndO', '')]
    procedure TestOneRedAndO;

    [TestCase('RedGreenBlue', '')]
    procedure TestRedGreenBlue;

  end;

implementation

{ TestQuantizeWu }

procedure TestQuantizeWu.TestFullImage;
var
  pixels, result: TArray<TARGB>;
begin
  SetLength(pixels, 12544);
  for var i := 0 to Length(pixels) -1 do
    pixels[i] := i mod 8000;

  result := QuantizeWu(pixels, 128);

  // Original test has no assert
  Assert.AreEqual(Length(result), 128);
end;

procedure TestQuantizeWu.TestTwoRedThreeGreen;
const
  pixels: TArray<TARGB> = [$ffff0000, $ffff0000, $ffff0000, $ff00ff00, $ff00ff00];
begin
  var result := QuantizeWu(pixels, 256);
  Assert.AreEqual(Length(result), 2);
end;

procedure TestQuantizeWu.TestOneRed;
const
  pixels: TArray<TARGB> = [$ffff0000];
begin
  var result := QuantizeWu(pixels, 256);
  Assert.AreEqual(Length(result), 1);
  Assert.AreEqual(Result[0], $ffff0000);
end;

procedure TestQuantizeWu.TestOneGreen;
const
  pixels: TArray<TARGB> = [$ff00ff00];
begin
  var result := QuantizeWu(pixels, 256);
  Assert.AreEqual(Length(result), 1);
  Assert.AreEqual(Result[0], $ff00ff00);
end;

procedure TestQuantizeWu.TestOneBlue;
const
  pixels: TArray<TARGB> = [$ff0000ff];
begin
  var result := QuantizeWu(pixels, 256);
  Assert.AreEqual(Length(result), 1);
  Assert.AreEqual(Result[0], $ff0000ff);
end;

procedure TestQuantizeWu.TestFiveBlue;
const
  pixels: TArray<TARGB> = [$ff0000ff, $ff0000ff, $ff0000ff, $ff0000ff, $ff0000ff];
begin
  var result := QuantizeWu(pixels, 256);
  Assert.AreEqual(Length(result), 1);
  Assert.AreEqual(Result[0], $ff0000ff);
end;

procedure TestQuantizeWu.TestOneRedAndO;
const
  pixels: TArray<TARGB> = [$ff141216];
begin
  var result := QuantizeWu(pixels, 256);
  Assert.AreEqual(Length(result), 1);
  Assert.AreEqual(Result[0], $ff141216);
end;

procedure TestQuantizeWu.TestRedGreenBlue;
const
  pixels: TArray<TARGB> = [$ffff0000, $ff00ff00, $ff0000ff];
begin
  var result := QuantizeWu(pixels, 256);
  Assert.AreEqual(Length(result), 3);
  Assert.AreEqual(Result[0], $ff0000ff);
  Assert.AreEqual(Result[1], $ffff0000);
  Assert.AreEqual(Result[2], $ff00ff00);
end;

initialization
  TDUnitX.RegisterTestFixture(TestQuantizeWu);

end.
