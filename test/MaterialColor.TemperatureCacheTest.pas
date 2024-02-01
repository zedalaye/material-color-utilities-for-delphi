unit MaterialColor.TemperatureCacheTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.CAM.HCT,
  MaterialColor.TemperatureCache;

type
  [TestFixture]
  TestTemperatureCache = class
  public
    [TestCase('RawTemperature', '')]
    procedure TestRawTemperature;

    [TestCase('Complement', '')]
    procedure TestComplement;

    [TestCase('Analogous', '')]
    procedure TestAnalogous;
  end;


implementation

{ TestTemperatureCache }

procedure TestTemperatureCache.TestRawTemperature;
begin
  var blue_hct := THCT.Create($ff0000ff);
  var blue_temp := TTemperatureCache.RawTemperature(blue_hct);
  Assert.AreEqual(-1.393, blue_temp, 0.001);

  var red_hct := THCT.Create($ffff0000);
  var red_temp := TTemperatureCache.RawTemperature(red_hct);
  Assert.AreEqual(2.351, red_temp, 0.001);

  var green_hct := THCT.Create($ff00ff00);
  var green_temp := TTemperatureCache.RawTemperature(green_hct);
  Assert.AreEqual(-0.267, green_temp, 0.001);

  var white_hct := THCT.Create($ffffffff);
  var white_temp := TTemperatureCache.RawTemperature(white_hct);
  Assert.AreEqual(-0.5, white_temp, 0.001);

  var black_hct := THCT.Create($ff000000);
  var black_temp := TTemperatureCache.RawTemperature(black_hct);
  Assert.AreEqual(-0.5, black_temp, 0.001);
end;

procedure TestTemperatureCache.TestComplement;
var
  TC: ITemperatureCache;
begin
  TC := TTemperatureCache.Create(THCT.Create($ff0000ff));
  var blue_complement := TC.GetComplement.ToInt;
  Assert.AreEqual($ff9d0002, blue_complement);

  TC := TTemperatureCache.Create(THCT.Create($ffff0000));
  var red_complement := TC.GetComplement.ToInt;
  Assert.AreEqual($ff007bfc, red_complement);

  TC := TTemperatureCache.Create(THCT.Create($ff00ff00));
  var green_complement := TC.GetComplement.ToInt;
  Assert.AreEqual($ffffd2c9, green_complement);

  TC := TTemperatureCache.Create(THCT.Create($ffffffff));
  var white_complement := TC.GetComplement.ToInt;
  Assert.AreEqual($ffffffff, white_complement);

  TC := TTemperatureCache.Create(THCT.Create($ff000000));
  var black_complement := TC.GetComplement.ToInt;
  Assert.AreEqual($ff000000, black_complement);
end;

procedure TestTemperatureCache.TestAnalogous;
begin
  var blue_analogous := (TTemperatureCache.Create(THCT.Create($ff0000ff)) as ITemperatureCache).GetAnalogousColors;
  Assert.AreEqual($ff00590c, blue_analogous[0].ToInt);
  Assert.AreEqual($ff00564e, blue_analogous[1].ToInt);
  Assert.AreEqual($ff0000ff, blue_analogous[2].ToInt);
  Assert.AreEqual($ff6700cc, blue_analogous[3].ToInt);
  Assert.AreEqual($ff81009f, blue_analogous[4].ToInt);

  var red_analogous := (TTemperatureCache.Create(THCT.Create($ffff0000)) as ITemperatureCache).GetAnalogousColors;
  Assert.AreEqual($fff60082, red_analogous[0].ToInt);
  Assert.AreEqual($fffc004c, red_analogous[1].ToInt);
  Assert.AreEqual($ffff0000, red_analogous[2].ToInt);
  Assert.AreEqual($ffd95500, red_analogous[3].ToInt);
  Assert.AreEqual($ffaf7200, red_analogous[4].ToInt);

  var green_analogous := (TTemperatureCache.Create(THCT.Create($ff00ff00)) as ITemperatureCache).GetAnalogousColors;
  Assert.AreEqual($ffcee900, green_analogous[0].ToInt);
  Assert.AreEqual($ff92f500, green_analogous[1].ToInt);
  Assert.AreEqual($ff00ff00, green_analogous[2].ToInt);
  Assert.AreEqual($ff00fd6f, green_analogous[3].ToInt);
  Assert.AreEqual($ff00fab3, green_analogous[4].ToInt);

  var black_analogous := (TTemperatureCache.Create(THCT.Create($ff000000)) as ITemperatureCache).GetAnalogousColors;
  Assert.AreEqual($ff000000, black_analogous[0].ToInt);
  Assert.AreEqual($ff000000, black_analogous[1].ToInt);
  Assert.AreEqual($ff000000, black_analogous[2].ToInt);
  Assert.AreEqual($ff000000, black_analogous[3].ToInt);
  Assert.AreEqual($ff000000, black_analogous[4].ToInt);

  var white_analogous := (TTemperatureCache.Create(THCT.Create($ffffffff)) as ITemperatureCache).GetAnalogousColors;
  Assert.AreEqual($ffffffff, white_analogous[0].ToInt);
  Assert.AreEqual($ffffffff, white_analogous[1].ToInt);
  Assert.AreEqual($ffffffff, white_analogous[2].ToInt);
  Assert.AreEqual($ffffffff, white_analogous[3].ToInt);
  Assert.AreEqual($ffffffff, white_analogous[4].ToInt);
end;

initialization
  TDUnitX.RegisterTestFixture(TestTemperatureCache);

end.
