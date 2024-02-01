unit MaterialColor.ScoreTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.Score;

type
  [TestFixture]
  TestScore = class
  public
    [TestCase('PrioritizesChroma', '')]
    procedure TestPrioritizesChroma;

    [TestCase('PrioritizesChromaWhenProportionsEqual', '')]
    procedure TestPrioritizesChromaWhenProportionsEqual;

    [TestCase('GeneratesGblueWhenNoColorsAvailable', '')]
    procedure TestGeneratesGblueWhenNoColorsAvailable;

    [TestCase('DedupesNearbyHues', '')]
    procedure TestDedupesNearbyHues;

    [TestCase('MaximizesHueDistance', '')]
    procedure TestMaximizesHueDistance;

    [TestCase('GeneratedScenarioOne', '')]
    procedure TestGeneratedScenarioOne;

    [TestCase('GeneratedScenarioTwo', '')]
    procedure TestGeneratedScenarioTwo;

    [TestCase('GeneratedScenarioThree', '')]
    procedure TestGeneratedScenarioThree;

    [TestCase('GeneratedScenarioFour', '')]
    procedure TestGeneratedScenarioFour;

    [TestCase('GeneratedScenarioFive', '')]
    procedure TestGeneratedScenarioFive;

    [TestCase('GeneratedScenarioSix', '')]
    procedure TestGeneratedScenarioSix;

    [TestCase('GeneratedScenarioSeven', '')]
    procedure TestGeneratedScenarioSeven;

    [TestCase('GeneratedScenarioEight', '')]
    procedure TestGeneratedScenarioEight;

    [TestCase('GeneratedScenarioNine', '')]
    procedure TestGeneratedScenarioNine;

    [TestCase('GeneratedScenarioTen', '')]
    procedure TestGeneratedScenarioTen;
  end;

implementation

{ TestScore }

procedure TestScore.TestPrioritizesChroma;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff000000, 1);
    argb_to_population.Add($ffffffff, 1);
    argb_to_population.Add($ff0000ff, 1);

    var ranked := RankedSuggestions(argb_to_population, TScoreOptions.Create(4));

    Assert.AreEqual(Length(ranked), 1);
    Assert.AreEqual(ranked[0], $ff0000ff);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestPrioritizesChromaWhenProportionsEqual;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ffff0000, 1);
    argb_to_population.Add($ff00ff00, 1);
    argb_to_population.Add($ff0000ff, 1);

    var ranked := RankedSuggestions(argb_to_population, TScoreOptions.Create(4));

    Assert.AreEqual(Length(ranked), 3);
    Assert.AreEqual(ranked[0], $ffff0000);
    Assert.AreEqual(ranked[1], $ff00ff00);
    Assert.AreEqual(ranked[2], $ff0000ff);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratesGblueWhenNoColorsAvailable;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff000000, 1);

    var ranked := RankedSuggestions(argb_to_population, TScoreOptions.Create(4));

    Assert.AreEqual(Length(ranked), 1);
    Assert.AreEqual(ranked[0], TScoreOptions.Default.fallback_color_argb { $ff4285f4 });
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestDedupesNearbyHues;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff008772, 1);
    argb_to_population.Add($ff318477, 1);

    var ranked := RankedSuggestions(argb_to_population, TScoreOptions.Create(4));

    Assert.AreEqual(Length(ranked), 1);
    Assert.AreEqual(ranked[0], $ff008772);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestMaximizesHueDistance;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff008772, 1);
    argb_to_population.Add($ff008587, 1);
    argb_to_population.Add($ff007ebc, 1);

    var ranked := RankedSuggestions(argb_to_population, TScoreOptions.Create(2));

    Assert.AreEqual(Length(ranked), 2);
    Assert.AreEqual(ranked[0], $ff007ebc);
    Assert.AreEqual(ranked[1], $ff008772);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioOne;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff7ea16d, 67);
    argb_to_population.Add($ffd8ccae, 67);
    argb_to_population.Add($ff835c0d, 49);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(3, $ff8d3819, False)
    );

    Assert.AreEqual(Length(ranked), 3);
    Assert.AreEqual(ranked[0], $ff7ea16d);
    Assert.AreEqual(ranked[1], $ffd8ccae);
    Assert.AreEqual(ranked[2], $ff835c0d);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioTwo;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ffd33881, 14);
    argb_to_population.Add($ff3205cc, 77);
    argb_to_population.Add($ff0b48cf, 36);
    argb_to_population.Add($ffa08f5d, 81);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(4, $ff7d772b, True)
    );

    Assert.AreEqual(Length(ranked), 3);
    Assert.AreEqual(ranked[0], $ff3205cc);
    Assert.AreEqual(ranked[1], $ffa08f5d);
    Assert.AreEqual(ranked[2], $ffd33881);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioThree;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ffbe94a6, 23);
    argb_to_population.Add($ffc33fd7, 42);
    argb_to_population.Add($ff899f36, 90);
    argb_to_population.Add($ff94c574, 82);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(3, $ffaa79a4, True)
    );

    Assert.AreEqual(Length(ranked), 3);
    Assert.AreEqual(ranked[0], $ff94c574);
    Assert.AreEqual(ranked[1], $ffc33fd7);
    Assert.AreEqual(ranked[2], $ffbe94a6);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioFour;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ffdf241c, 85);
    argb_to_population.Add($ff685859, 44);
    argb_to_population.Add($ffd06d5f, 34);
    argb_to_population.Add($ff561c54, 27);
    argb_to_population.Add($ff713090, 88);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(5, $ff58c19c, False)
    );

    Assert.AreEqual(Length(ranked), 2);
    Assert.AreEqual(ranked[0], $ffdf241c);
    Assert.AreEqual(ranked[1], $ff561c54);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioFive;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ffbe66f8, 41);
    argb_to_population.Add($ff4bbda9, 88);
    argb_to_population.Add($ff80f6f9, 44);
    argb_to_population.Add($ffab8017, 43);
    argb_to_population.Add($ffe89307, 65);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(3, $ff916691, False)
    );

    Assert.AreEqual(Length(ranked), 3);
    Assert.AreEqual(ranked[0], $ffab8017);
    Assert.AreEqual(ranked[1], $ff4bbda9);
    Assert.AreEqual(ranked[2], $ffbe66f8);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioSix;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff18ea8f, 93);
    argb_to_population.Add($ff327593, 18);
    argb_to_population.Add($ff066a18, 53);
    argb_to_population.Add($fffa8a23, 74);
    argb_to_population.Add($ff04ca1f, 62);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(2, $ff4c377a, False)
    );

    Assert.AreEqual(Length(ranked), 2);
    Assert.AreEqual(ranked[0], $ff18ea8f);
    Assert.AreEqual(ranked[1], $fffa8a23);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioSeven;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff2e05ed, 23);
    argb_to_population.Add($ff153e55, 90);
    argb_to_population.Add($ff9ab220, 23);
    argb_to_population.Add($ff153379, 66);
    argb_to_population.Add($ff68bcc3, 81);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(2, $fff588dc, True)
    );

    Assert.AreEqual(Length(ranked), 2);
    Assert.AreEqual(ranked[0], $ff2e05ed);
    Assert.AreEqual(ranked[1], $ff9ab220);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioEight;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff816ec5, 24);
    argb_to_population.Add($ff6dcb94, 19);
    argb_to_population.Add($ff3cae91, 98);
    argb_to_population.Add($ff5b542f, 25);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(1, $ff84b0fd, False)
    );

    Assert.AreEqual(Length(ranked), 1);
    Assert.AreEqual(ranked[0], $ff3cae91);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioNine;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff206f86, 52);
    argb_to_population.Add($ff4a620d, 96);
    argb_to_population.Add($fff51401, 85);
    argb_to_population.Add($ff2b8ebf,  3);
    argb_to_population.Add($ff277766, 59);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(3, $ff02b415, True)
    );

    Assert.AreEqual(Length(ranked), 3);
    Assert.AreEqual(ranked[0], $fff51401);
    Assert.AreEqual(ranked[1], $ff4a620d);
    Assert.AreEqual(ranked[2], $ff2b8ebf);
  finally
    argb_to_population.Free;
  end;
end;

procedure TestScore.TestGeneratedScenarioTen;
var
  argb_to_population: TArgbToPopulationMap;
begin
  argb_to_population := TArgbToPopulationMap.Create;
  try
    argb_to_population.Add($ff8b1d99, 54);
    argb_to_population.Add($ff27effe, 43);
    argb_to_population.Add($ff6f558d,  2);
    argb_to_population.Add($ff77fdf2, 78);

    var ranked := RankedSuggestions(argb_to_population,
      TScoreOptions.Create(4, $ff5e7a10, True)
    );

    Assert.AreEqual(Length(ranked), 3);
    Assert.AreEqual(ranked[0], $ff27effe);
    Assert.AreEqual(ranked[1], $ff8b1d99);
    Assert.AreEqual(ranked[2], $ff6f558d);
  finally
    argb_to_population.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TestScore);

end.
