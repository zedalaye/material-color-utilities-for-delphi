program ConsoleTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  TestInsight.DUnitX,
  MaterialColor.Blend in 'src\MaterialColor.Blend.pas',
  MaterialColor.CAM.HCT in 'src\MaterialColor.CAM.HCT.pas',
  MaterialColor.CAM.HCTSolver in 'src\MaterialColor.CAM.HCTSolver.pas',
  MaterialColor.CAM in 'src\MaterialColor.CAM.pas',
  MaterialColor.CAM.ViewingConditions in 'src\MaterialColor.CAM.ViewingConditions.pas',
  MaterialColor.Contrast in 'src\MaterialColor.Contrast.pas',
  MaterialColor.Dislike in 'src\MaterialColor.Dislike.pas',
  MaterialColor.DynamicColor.ContrastCurve in 'src\MaterialColor.DynamicColor.ContrastCurve.pas',
  MaterialColor.DynamicColor.DynamicScheme in 'src\MaterialColor.DynamicColor.DynamicScheme.pas',
  MaterialColor.DynamicColor.MaterialDynamicColor in 'src\MaterialColor.DynamicColor.MaterialDynamicColor.pas',
  MaterialColor.DynamicColor in 'src\MaterialColor.DynamicColor.pas',
  MaterialColor.DynamicColor.ToneDeltaPair in 'src\MaterialColor.DynamicColor.ToneDeltaPair.pas',
  MaterialColor.DynamicColor.Variant in 'src\MaterialColor.DynamicColor.Variant.pas',
  MaterialColor.Palettes.Core in 'src\MaterialColor.Palettes.Core.pas',
  MaterialColor.Palettes.Tones in 'src\MaterialColor.Palettes.Tones.pas',
  MaterialColor.Quantize.WsMeans in 'src\MaterialColor.Quantize.WsMeans.pas',
  MaterialColor.Quantize.Wu in 'src\MaterialColor.Quantize.Wu.pas',
  MaterialColor.Scheme.Content in 'src\MaterialColor.Scheme.Content.pas',
  MaterialColor.Scheme.Expressive in 'src\MaterialColor.Scheme.Expressive.pas',
  MaterialColor.Scheme.Fidelity in 'src\MaterialColor.Scheme.Fidelity.pas',
  MaterialColor.Scheme.FruitSalad in 'src\MaterialColor.Scheme.FruitSalad.pas',
  MaterialColor.Scheme.Monochrome in 'src\MaterialColor.Scheme.Monochrome.pas',
  MaterialColor.Scheme.Neutral in 'src\MaterialColor.Scheme.Neutral.pas',
  MaterialColor.Scheme in 'src\MaterialColor.Scheme.pas',
  MaterialColor.Scheme.Rainbow in 'src\MaterialColor.Scheme.Rainbow.pas',
  MaterialColor.Scheme.TonalSpot in 'src\MaterialColor.Scheme.TonalSpot.pas',
  MaterialColor.Scheme.Vibrant in 'src\MaterialColor.Scheme.Vibrant.pas',
  MaterialColor.Score in 'src\MaterialColor.Score.pas',
  MaterialColor.TemperatureCache in 'src\MaterialColor.TemperatureCache.pas',
  MaterialColor.Utils.Lab in 'src\MaterialColor.Utils.Lab.pas',
  MaterialColor.Utils in 'src\MaterialColor.Utils.pas',
  MaterialColor.BlendTest in 'test\MaterialColor.BlendTest.pas',
  MaterialColor.CAM.CAMTest in 'test\MaterialColor.CAM.CAMTest.pas',
  MaterialColor.CAM.HCTTest in 'test\MaterialColor.CAM.HCTTest.pas',
  MaterialColor.CAM.HTCSolverTest in 'test\MaterialColor.CAM.HTCSolverTest.pas',
  MaterialColor.ContrastTest in 'test\MaterialColor.ContrastTest.pas',
  MaterialColor.DislikeTest in 'test\MaterialColor.DislikeTest.pas',
  MaterialColor.DynamicColorTest in 'test\MaterialColor.DynamicColorTest.pas',
  MaterialColor.Palettes.CoreTest in 'test\MaterialColor.Palettes.CoreTest.pas',
  MaterialColor.Palettes.TonesTest in 'test\MaterialColor.Palettes.TonesTest.pas',
  MaterialColor.Quantize.WsMeansTest in 'test\MaterialColor.Quantize.WsMeansTest.pas',
  MaterialColor.Quantize.WuTest in 'test\MaterialColor.Quantize.WuTest.pas',
  MaterialColor.Scheme.MonochromeTest in 'test\MaterialColor.Scheme.MonochromeTest.pas',
  MaterialColor.SchemeTest in 'test\MaterialColor.SchemeTest.pas',
  MaterialColor.ScoreTest in 'test\MaterialColor.ScoreTest.pas',
  MaterialColor.TemperatureCacheTest in 'test\MaterialColor.TemperatureCacheTest.pas',
  MaterialColor.UtilsTest in 'test\MaterialColor.UtilsTest.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  RunRegisteredTests;
end.
