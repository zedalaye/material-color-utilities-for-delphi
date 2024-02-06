unit MaterialColor.Quantize.CelebiTest;

interface

uses
  System.SysUtils, System.Diagnostics,
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.Quantize.WsMeans,
  MaterialColor.Quantize.Celebi;

type
  [TestFixture]
  TestQuantizeCelebi = class
  public
    [TestCase('FullImage', '')]
    procedure TestFullImage;

    [TestCase('OneRed', '')]
    procedure TestOneRed;

    [TestCase('OneGreen', '')]
    procedure TestOneGreen;

    [TestCase('OneBlue', '')]
    procedure TestOneBlue;

    [TestCase('FiveBlue', '')]
    procedure TestFiveBlue;

    [TestCase('OneRedOneGreenOneBlue', '')]
    procedure TestOneRedOneGreenOneBlue;

    [TestCase('TwoRedThreeGreen', '')]
    procedure TestTwoRedThreeGreen;

    [TestCase('NoColors', '')]
    procedure TestNoColors;

    [TestCase('SingleTransparent', '')]
    procedure TestSingleTransparent;

    [TestCase('TooManyColors', '')]
    procedure TestTooManyColors;

  end;

implementation

{ TestQuantizeCelebi }

procedure TestQuantizeCelebi.TestFullImage;
const
  ITERATIONS = 1;
  MAX_COLORS = 128;
var
  StopWatch: TStopwatch;
  TimeSpent: Double;
  pixels: TArray<TARGB>;
begin
  SetLength(pixels, 12544);
  for var i: Cardinal := 0 to Length(pixels) -1 do
    pixels[i] := TARGB($ff000000 + (i mod 8000));

  TimeSpent := 0.0;

  StopWatch := TStopwatch.Create;
  for var i := 0 to ITERATIONS -1 do
  begin
    StopWatch.Start;
    var result := QuantizeCelebi(pixels, MAX_COLORS);
    StopWatch.Stop;
    TimeSpent := TimeSpent + StopWatch.Elapsed.TotalSeconds;

    // Original test has no assert, suppose the implementation is correct
    Assert.AreEqual(result.color_to_count.Count, 128);
  end;

  Log(TLogLevel.Information, Format('TestQuantizeWsMeans.TestFullImage - TimeSpent=%f', [TimeSpent]));
end;

procedure TestQuantizeCelebi.TestOneRed;
const
  pixels: TArray<TARGB> = [$ffff0000];
var
  count: Cardinal;
begin
  var result := QuantizeCelebi(pixels, 256);
  Assert.AreEqual(result.color_to_count.Count, 1);
  if result.color_to_count.TryGetValue($ffff0000, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeCelebi.TestOneGreen;
const
  pixels: TArray<TARGB> = [$ff00ff00];
var
  count: Cardinal;
begin
  var result := QuantizeCelebi(pixels, 256);
  Assert.AreEqual(result.color_to_count.Count, 1);
  if result.color_to_count.TryGetValue($ff00ff00, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeCelebi.TestOneBlue;
const
  pixels: TArray<TARGB> = [$ff0000ff];
var
  count: Cardinal;
begin
  var result := QuantizeCelebi(pixels, 256);
  Assert.AreEqual(result.color_to_count.Count, 1);
  if result.color_to_count.TryGetValue($ff0000ff, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeCelebi.TestFiveBlue;
const
  pixels: TArray<TARGB> = [$ff0000ff, $ff0000ff, $ff0000ff, $ff0000ff, $ff0000ff];
var
  count: Cardinal;
begin
  var result := QuantizeCelebi(pixels, 256);
  Assert.AreEqual(result.color_to_count.Count, 1);
  if result.color_to_count.TryGetValue($ff0000ff, count) then
    Assert.AreEqual(count, 5)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeCelebi.TestOneRedOneGreenOneBlue;
const
  pixels: TArray<TARGB> = [$ffff0000, $ff00ff00, $ff0000ff];
var
  count: Cardinal;
begin
  var result := QuantizeCelebi(pixels, 256);
  Assert.AreEqual(result.color_to_count.Count, 3);
  if result.color_to_count.TryGetValue($ffff0000, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
  if result.color_to_count.TryGetValue($ff00ff00, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
  if result.color_to_count.TryGetValue($ff0000ff, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeCelebi.TestTwoRedThreeGreen;
const
  pixels: TArray<TARGB> = [$ffff0000, $ffff0000, $ff00ff00, $ff00ff00, $ff00ff00];
var
  count: Cardinal;
begin
  var result := QuantizeCelebi(pixels, 256);
  Assert.AreEqual(result.color_to_count.Count, 2);
  if result.color_to_count.TryGetValue($ffff0000, count) then
    Assert.AreEqual(count, 2)
  else
    Assert.IsTrue(False);
  if result.color_to_count.TryGetValue($ff00ff00, count) then
    Assert.AreEqual(count, 3)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeCelebi.TestNoColors;
const
  pixels: TArray<TARGB> = [$FFFFFFFF];
begin
  var result := QuantizeCelebi(pixels, 0);
  Assert.AreEqual(result.color_to_count.Count, 0);
  Assert.AreEqual(result.input_pixel_to_cluster_pixel.Count, 0);
end;

procedure TestQuantizeCelebi.TestSingleTransparent;
const
  pixels: TArray<TARGB> = [$20F93013];
begin
  var result := QuantizeCelebi(pixels, 1);
  Assert.AreEqual(result.color_to_count.Count, 0);
  Assert.AreEqual(result.input_pixel_to_cluster_pixel.Count, 0);
end;

procedure TestQuantizeCelebi.TestTooManyColors;
const
  pixels: TArray<TARGB> = [$FFFFFFFF];
begin
  var result := QuantizeCelebi(pixels, 32767);
  Assert.AreEqual(result.color_to_count.Count, 1);
  Assert.AreEqual(result.input_pixel_to_cluster_pixel.Count, 1);
end;

initialization
  TDUnitX.RegisterTestFixture(TestQuantizeCelebi);

end.
