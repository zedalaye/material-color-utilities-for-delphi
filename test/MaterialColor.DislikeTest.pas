unit MaterialColor.DislikeTest;

interface

uses
  DUnitX.TestFramework,
  MaterialColor.Utils,
  MaterialColor.CAM.HCT,
  MaterialColor.Dislike;

type
  [TestFixture]
  TestDislike = class
  public
    [TestCase('MonkSkinToneScaleColorsLiked', '')]
    procedure TestMonkSkinToneScaleColorsLiked;

    [TestCase('BileColorsDisliked', '')]
    procedure TestBileColorsDisliked;

    [TestCase('BileColorsFixed', '')]
    procedure TestBileColorsFixed;

    [TestCase('Tone67Liked', '')]
    procedure TestTone67Liked;
  end;

implementation

{ TestDislike }

procedure TestDislike.TestMonkSkinToneScaleColorsLiked;
const
  SKIN_TONE: array[0..9] of TARGB = ($fff6ede4, $fff3e7db, $fff7ead0, $ffeadaba,
                                     $ffd7bd96, $ffa07e56, $ff825c43, $ff604134,
                                     $ff3a312a, $ff292420);
begin
  for var argb in SKIN_TONE do
    Assert.IsFalse(IsDisliked(THCT.Create(argb)));
end;

procedure TestDislike.TestBileColorsDisliked;
const
  BILE: array[0..4] of TARGB = ($ff95884B, $ff716B40, $ffB08E00, $ff4C4308,
                                $ff464521);
begin
  for var argb in BILE do
    Assert.IsTrue(IsDisliked(THCT.Create(argb)));
end;

procedure TestDislike.TestBileColorsFixed;
const
  BILE: array[0..4] of TARGB = ($ff95884B, $ff716B40, $ffB08E00, $ff4C4308,
                                $ff464521);
begin
  for var argb in BILE do
  begin
    var bile_color := THCT.Create(argb);
    Assert.IsTrue(IsDisliked(bile_color));
    var fixed_bile_color := FixIfDisliked(bile_color);
    Assert.IsFalse(IsDisliked(fixed_bile_color));
  end;
end;

procedure TestDislike.TestTone67Liked;
begin
  var color := THCT.Create(100.0, 50.0, 67.0);
  Assert.IsFalse(IsDisliked(color));
  Assert.AreEqual(FixIfDisliked(color).ToInt, color.ToInt);
end;

initialization
  TDUnitX.RegisterTestFixture(TestDislike);

end.
