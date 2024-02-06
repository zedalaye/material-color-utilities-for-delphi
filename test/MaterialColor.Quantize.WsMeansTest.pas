unit MaterialColor.Quantize.WsMeansTest;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  System.Diagnostics,
  MaterialColor.Utils,
  MaterialColor.Quantize.WsMeans;

type
  [TestFixture]
  TestQuantizeWsMeans = class
  public
    [TestCase('FullImage', '')]
    procedure TestFullImage;

    [TestCase('OneRedAndO', '')]
    procedure TestOneRedAndO;

    [TestCase('OneRed', '')]
    procedure TestOneRed;

    [TestCase('OneGreen', '')]
    procedure TestOneGreen;

    [TestCase('OneBlue', '')]
    procedure TestOneBlue;

    [TestCase('FiveBlue', '')]
    procedure TestFiveBlue;
  end;

implementation

{ TestQuantizeWsMeans }

procedure TestQuantizeWsMeans.TestFullImage;
const
  ITERATIONS = 1;
  MAX_COLORS = 128;
var
  StopWatch: TStopwatch;
  TimeSpent: Double;
  pixels, starting_clusters: TArray<TARGB>;
begin
  SetLength(pixels, 12544);
  for var i: Cardinal := 0 to Length(pixels) -1 do
    pixels[i] := TARGB($ff000000 + (i mod 8000));

  TimeSpent := 0.0;

  StopWatch := TStopwatch.Create;
  for var i := 0 to ITERATIONS -1 do
  begin
    StopWatch.Start;
    var result := QuantizeWsmeans(pixels, starting_clusters, MAX_COLORS);
    StopWatch.Stop;
    TimeSpent := TimeSpent + StopWatch.Elapsed.TotalSeconds;

    // Original test has no assert, suppose the implementation is correct
    Assert.AreEqual(result.color_to_count.Count, 17);
  end;

  Log(TLogLevel.Information, Format('TestQuantizeWsMeans.TestFullImage - TimeSpent=%f', [TimeSpent]));
end;

procedure TestQuantizeWsMeans.TestOneRedAndO;
const
  pixels: TArray<TARGB> = [$ff141216];
var
  starting_clusters: TArray<TARGB>;
  count: Cardinal;
begin
  var result := QuantizeWsmeans(pixels, starting_clusters, 256);
  Assert.AreEqual(result.color_to_count.Count, 1);
  if result.color_to_count.TryGetValue($ff141216, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeWsMeans.TestOneRed;
const
  pixels: TArray<TARGB> = [$ffff0000];
var
  starting_clusters: TArray<TARGB>;
  count: Cardinal;
begin
  var result := QuantizeWsmeans(pixels, starting_clusters, 256);
  Assert.AreEqual(result.color_to_count.Count, 1);
  if result.color_to_count.TryGetValue($ffff0000, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeWsMeans.TestOneGreen;
const
  pixels: TArray<TARGB> = [$ff00ff00];
var
  starting_clusters: TArray<TARGB>;
  count: Cardinal;
begin
  var result := QuantizeWsmeans(pixels, starting_clusters, 256);
  Assert.AreEqual(result.color_to_count.Count, 1);
  if result.color_to_count.TryGetValue($ff00ff00, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeWsMeans.TestOneBlue;
const
  pixels: TArray<TARGB> = [$ff0000ff];
var
  starting_clusters: TArray<TARGB>;
  count: Cardinal;
begin
  var result := QuantizeWsmeans(pixels, starting_clusters, 256);
  Assert.AreEqual(result.color_to_count.Count, 1);
  if result.color_to_count.TryGetValue($ff0000ff, count) then
    Assert.AreEqual(count, 1)
  else
    Assert.IsTrue(False);
end;

procedure TestQuantizeWsMeans.TestFiveBlue;
const
  pixels: TArray<TARGB> = [$ff0000ff, $ff0000ff, $ff0000ff, $ff0000ff, $ff0000ff];
var
  starting_clusters: TArray<TARGB>;
  count: Cardinal;
begin
  var result := QuantizeWsmeans(pixels, starting_clusters, 256);
  Assert.AreEqual(result.color_to_count.Count, 1);
  if result.color_to_count.TryGetValue($ff0000ff, count) then
    Assert.AreEqual(count, 5)
  else
    Assert.IsTrue(False);
end;

initialization
  TDUnitX.RegisterTestFixture(TestQuantizeWsMeans);

end.
