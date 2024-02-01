unit MaterialColor.DynamicColor.MaterialDynamicColor;

interface

uses
  System.Math,
  MaterialColor.DynamicColor;

type
  TMaterialDynamicColors = record
    class function PrimaryPaletteKeyColor: IDynamicColor; static;
    class function SecondaryPaletteKeyColor: IDynamicColor; static;
    class function TertiaryPaletteKeyColor: IDynamicColor; static;
    class function NeutralPaletteKeyColor: IDynamicColor; static;
    class function NeutralVariantPaletteKeyColor: IDynamicColor; static;
    class function Background: IDynamicColor; static;
    class function OnBackground: IDynamicColor; static;
    class function Surface: IDynamicColor; static;
    class function SurfaceDim: IDynamicColor; static;
    class function SurfaceBright: IDynamicColor; static;
    class function SurfaceContainerLowest: IDynamicColor; static;
    class function SurfaceContainerLow: IDynamicColor; static;
    class function SurfaceContainer: IDynamicColor; static;
    class function SurfaceContainerHigh: IDynamicColor; static;
    class function SurfaceContainerHighest: IDynamicColor; static;
    class function OnSurface: IDynamicColor; static;
    class function SurfaceVariant: IDynamicColor; static;
    class function OnSurfaceVariant: IDynamicColor; static;
    class function InverseSurface: IDynamicColor; static;
    class function InverseOnSurface: IDynamicColor; static;
    class function Outline: IDynamicColor; static;
    class function OutlineVariant: IDynamicColor; static;
    class function Shadow: IDynamicColor; static;
    class function Scrim: IDynamicColor; static;
    class function SurfaceTint: IDynamicColor; static;
    class function Primary: IDynamicColor; static;
    class function OnPrimary: IDynamicColor; static;
    class function PrimaryContainer: IDynamicColor; static;
    class function OnPrimaryContainer: IDynamicColor; static;
    class function InversePrimary: IDynamicColor; static;
    class function Secondary: IDynamicColor; static;
    class function OnSecondary: IDynamicColor; static;
    class function SecondaryContainer: IDynamicColor; static;
    class function OnSecondaryContainer: IDynamicColor; static;
    class function Tertiary: IDynamicColor; static;
    class function OnTertiary: IDynamicColor; static;
    class function TertiaryContainer: IDynamicColor; static;
    class function OnTertiaryContainer: IDynamicColor; static;
    class function Error: IDynamicColor; static;
    class function OnError: IDynamicColor; static;
    class function ErrorContainer: IDynamicColor; static;
    class function OnErrorContainer: IDynamicColor; static;
    class function PrimaryFixed: IDynamicColor; static;
    class function PrimaryFixedDim: IDynamicColor; static;
    class function OnPrimaryFixed: IDynamicColor; static;
    class function OnPrimaryFixedVariant: IDynamicColor; static;
    class function SecondaryFixed: IDynamicColor; static;
    class function SecondaryFixedDim: IDynamicColor; static;
    class function OnSecondaryFixed: IDynamicColor; static;
    class function OnSecondaryFixedVariant: IDynamicColor; static;
    class function TertiaryFixed: IDynamicColor; static;
    class function TertiaryFixedDim: IDynamicColor; static;
    class function OnTertiaryFixed: IDynamicColor; static;
    class function OnTertiaryFixedVariant: IDynamicColor; static;
  end;

implementation

uses
  MaterialColor.Utils,
  MaterialColor.Dislike,

  MaterialColor.CAM,
  MaterialColor.CAM.HCT,
  MaterialColor.CAM.ViewingConditions,
  MaterialColor.Palettes.Tones,
  MaterialColor.DynamicColor.Variant,
  MaterialColor.DynamicColor.ContrastCurve,
  MaterialColor.DynamicColor.DynamicScheme;

function IsFidelity(const scheme: TDynamicScheme): Boolean;
begin
  Result := (scheme.variant = TDynamicColorVariant.kFidelity) or
            (scheme.variant = TDynamicColorVariant.kContent);
end;

function IsMonochrome(const scheme: TDynamicScheme): Boolean;
begin
  Result := (scheme.variant = TDynamicColorVariant.kMonochrome);
end;

function XyzInViewingConditions(cam: TCam; viewing_conditions: TViewingConditions): TVec3;
var
  alpha, t, h_rad, e_hue, ac, p1, p2, h_sin, h_cos, gamma: Double;
  a, b, r_a, g_a, b_a: Double;
  r_c_base, r_c, g_c_base, g_c, b_c_base, b_c: Double;
  r_f, g_f, b_f: Double;
  x, y, z: Double;
begin
  if (cam.chroma = 0.0) or (cam.j = 0.0) then
    alpha := 0.0
  else
    alpha := cam.chroma / Sqrt(cam.j / 100.0);

  t := Power(alpha / Power(1.64 - Power(0.29, viewing_conditions.background_y_to_white_point_y), 0.73), 1.0 / 0.9);

  h_rad := cam.hue * kPI / 180.0;  // M_PI !

  e_hue := 0.25 * (cos(h_rad + 2.0) + 3.8);
  ac := viewing_conditions.aw * Power(cam.j / 100.0, 1.0 / viewing_conditions.c / viewing_conditions.z);
  p1 := e_hue * (50000.0 / 13.0) * viewing_conditions.n_c * viewing_conditions.ncb;

  p2 := (ac / viewing_conditions.nbb);

  h_sin := Sin(h_rad);
  h_cos := Cos(h_rad);

  gamma := 23.0 * (p2 + 0.305) * t / (23.0 * p1 + 11 * t * h_cos + 108.0 * t * h_sin);
  a := gamma * h_cos;
  b := gamma * h_sin;
  r_a := (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0;
  g_a := (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0;
  b_a := (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0;

  r_c_base := Max(0, (27.13 * Abs(r_a)) / (400.0 - Abs(r_a)));
  r_c := Signum(r_a) * (100.0 / viewing_conditions.fl) * Power(r_c_base, 1.0 / 0.42);
  g_c_base := Max(0, (27.13 * Abs(g_a)) / (400.0 - Abs(g_a)));
  g_c := Signum(g_a) * (100.0 / viewing_conditions.fl) * Power(g_c_base, 1.0 / 0.42);
  b_c_base := Max(0, (27.13 * Abs(b_a)) / (400.0 - Abs(b_a)));
  b_c := Signum(b_a) * (100.0 / viewing_conditions.fl) * Power(b_c_base, 1.0 / 0.42);
  r_f := r_c / viewing_conditions.rgb_d[0];
  g_f := g_c / viewing_conditions.rgb_d[1];
  b_f := b_c / viewing_conditions.rgb_d[2];

  x := 1.86206786 * r_f - 1.01125463 * g_f + 0.14918677 * b_f;
  y := 0.38752654 * r_f + 0.62144744 * g_f - 0.00897398 * b_f;
  z := -0.01584150 * r_f - 0.03412294 * g_f + 1.04996444 * b_f;

  Result := TVec3.Create(x, y, z);
end;

function InViewingConditions(hct: THCT; vc: TViewingConditions): THCT;
var
  cam16, recast_in_vc: TCam;
  viewed_in_vc: TVec3;
  recast_hct: THCT;
begin
  // 1. Use CAM16 to find XYZ coordinates of color in specified VC.
  cam16 := CamFromInt(hct.ToInt());
  viewed_in_vc := XyzInViewingConditions(cam16, vc);

  // 2. Create CAM16 of those XYZ coordinates in default VC.
  recast_in_vc :=
      CamFromXyzAndViewingConditions(viewed_in_vc.a, viewed_in_vc.b,
                                     viewed_in_vc.c, kDefaultViewingConditions);

  // 3. Create HCT from:
  // - CAM16 using default VC with XYZ coordinates in specified VC.
  // - L* converted from Y in XYZ coordinates in specified VC.
  recast_hct := THCT.Create(recast_in_vc.hue, recast_in_vc.chroma, LstarFromY(viewed_in_vc.b));
  Result := recast_hct;
end;

function FindDesiredChromaByTone(hue, chroma, tone: Double; by_decreasing_tone: Boolean): Double;
var
  answer: Double;
  closest_to_chroma: THCT;
begin
  answer := tone;

  closest_to_chroma := THCT.Create(hue, chroma, tone);
  if (closest_to_chroma.Chroma < chroma) then
  begin
    var chroma_peak: Double := closest_to_chroma.Chroma;
    while (closest_to_chroma.Chroma < chroma) do
    begin
      if by_decreasing_tone then
        answer := answer - 1.0
      else
        answer := answer + 1.0;

      var potential_solution := THCT.Create(hue, chroma, answer);

      if chroma_peak > potential_solution.Chroma then
        Break;

      if Abs(potential_solution.Chroma - chroma) < 0.4 then
        Break;

      var potential_delta: Double := Abs(potential_solution.Chroma - chroma);
      var current_delta: Double := Abs(closest_to_chroma.Chroma - chroma);
      if potential_delta < current_delta then
        closest_to_chroma := potential_solution;

      chroma_peak := Max(chroma_peak, potential_solution.Chroma);
    end;
  end;

  Result := answer;
end;

const
  kContentAccentToneDelta: Double = 15.0;

function HighestSurface(const s: TDynamicScheme): IDynamicColor;
begin
  if s.is_dark then
    Result := TMaterialDynamicColors.SurfaceBright()
  else
    Result := TMaterialDynamicColors.SurfaceDim();
end;

{ TMaterialDynamicColors }

class function TMaterialDynamicColors.PrimaryPaletteKeyColor: IDynamicColor;
begin
  Result := TDynamicColor.FromPalette(
    'primary_palette_key_color',
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    function(s: TDynamicScheme): Double
    begin
      Result := s.primary_palette.KeyColor.Tone;
    end
  );
end;

class function TMaterialDynamicColors.SecondaryPaletteKeyColor: IDynamicColor;
begin
  Result := TDynamicColor.FromPalette(
    'secondary_palette_key_color',
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.secondary_palette;
    end,
    function(s: TDynamicScheme): Double
    begin
      Result := s.secondary_palette.KeyColor.Tone;
    end
  );
end;

class function TMaterialDynamicColors.TertiaryPaletteKeyColor: IDynamicColor;
begin
  Result := TDynamicColor.FromPalette(
    'tertiary_palette_key_color',
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.tertiary_palette;
    end,
    function(s: TDynamicScheme): Double
    begin
      Result := s.tertiary_palette.KeyColor.Tone;
    end
  );
end;

class function TMaterialDynamicColors.NeutralPaletteKeyColor: IDynamicColor;
begin
  Result := TDynamicColor.FromPalette(
    'neutral_palette_key_color',
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    function(s: TDynamicScheme): Double
    begin
      Result := s.neutral_palette.KeyColor.Tone;
    end
  );
end;

class function TMaterialDynamicColors.NeutralVariantPaletteKeyColor: IDynamicColor;
begin
  Result := TDynamicColor.FromPalette(
    'neutral_variant_palette_key_color',
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_variant_palette;
    end,
    function(s: TDynamicScheme): Double
    begin
      Result := s.neutral_variant_palette.KeyColor.Tone;
    end
  );
end;

class function TMaterialDynamicColors.Background: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'background',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 6.0
      else
        Result := 98.0;
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.OnBackground: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_background',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 90.0
      else
        Result := 10.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := Background();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(3.0, 3.0, 4.5, 7.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.Surface: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 6.0
      else
        Result := 98.0
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SurfaceDim: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface_dim',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 6.0
      else
        Result := GetContrast(87.0, 87.0, 80.0, 75.0, s.contrast_level);
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SurfaceBright: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface_bright',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := GetContrast(24.0, 24.0, 29.0, 34.0, s.contrast_level)
      else
        Result := 98.0;
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SurfaceContainerLowest: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface_container_lowest',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := GetContrast(4.0, 4.0, 2.0, 0.0, s.contrast_level)
      else
        Result := 100.0;
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SurfaceContainerLow: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface_container_low',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := GetContrast(10.0, 10.0, 11.0, 12.0, s.contrast_level)
      else
        Result := GetContrast(96.0, 96.0, 96.0, 95.0, s.contrast_level);
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SurfaceContainer: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface_container',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := GetContrast(12.0, 12.0, 16.0, 20.0, s.contrast_level)
      else
        Result := GetContrast(94.0, 94.0, 92.0, 90.0, s.contrast_level);
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SurfaceContainerHigh: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface_container_high',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := GetContrast(17.0, 17.0, 21.0, 25.0, s.contrast_level)
      else
        Result := GetContrast(92.0, 92.0, 88.0, 85.0, s.contrast_level);
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SurfaceContainerHighest: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface_container_highest',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := GetContrast(22.0, 22.0, 26.0, 30.0, s.contrast_level)
      else
        Result := GetContrast(90.0, 90.0, 84.0, 80.0, s.contrast_level);
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.OnSurface: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_surface',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 90.0
      else
        Result := 10.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SurfaceVariant: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface_variant',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_variant_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 30.0
      else
        Result := 90.0;
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.OnSurfaceVariant: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_surface_variant',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_variant_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 80.0
      else
        Result := 30.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(3.0, 4.5, 7.0, 11.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.InverseSurface: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'inverse_surface',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 90.0
      else
        Result := 20.0;
    end,
    (* isBackground *) False,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.InverseOnSurface: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'inverse_on_surface',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 20.0
      else
        Result := 95.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := InverseSurface();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.Outline: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'outline',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_variant_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 60.0
      else
        Result := 50.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.5, 3.0, 4.5, 7.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.OutlineVariant: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'outline_variant',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_variant_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 30.0
      else
        Result := 80.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.Shadow: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'shadow',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      Result := 0.0;
    end,
    (* isBackground *) False,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.Scrim: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'scrim',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.neutral_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      Result := 0.0;
    end,
    (* isBackground *) False,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SurfaceTint: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'surface_tint',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 80.0
      else
        Result := 40.0;
    end,
    (* isBackground *) True,
    (* background *) nil,
    (* secondBackground *) nil,
    (* contrastCurve *) nil,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.Primary: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'primary',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        if s.is_dark then
          Result := 100.0
        else
          Result := 0.0
      else
        if s.is_dark then
          Result := 80.0
        else
          Result := 40.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(3.0, 4.5, 7.0, 7.0) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        PrimaryContainer(), Primary(), 10.0,
        TTonePolarity.kNearer, False
      );
    end
  );
end;

class function TMaterialDynamicColors.OnPrimary: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_primary',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        if s.is_dark then
          Result := 10.0
        else
          Result := 90.0
      else
        if s.is_dark then
          Result := 20.0
        else
          Result := 100.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := Primary();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.PrimaryContainer: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'primary_container',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsFidelity(s) then
        Result := s.source_color_hct.Tone
      else
        if IsMonochrome(s) then
          if s.is_dark then
            Result := 85.0
          else
            Result := 25.0
        else
          if s.is_dark then
            Result := 30.0
          else
            Result := 90.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        PrimaryContainer(), Primary(), 10.0,
        TTonePolarity.kNearer, False
      );
    end
  );
end;

class function TMaterialDynamicColors.OnPrimaryContainer: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_primary_container',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsFidelity(s) then
        Result := ForegroundTone(PrimaryContainer().GetTone(s), 4.5)
      else
        if IsMonochrome(s) then
          if s.is_dark then
            Result := 0.0
          else
            Result := 100.0
        else
          if s.is_dark then
            Result := 90.0
          else
            Result := 10.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := PrimaryContainer();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.InversePrimary: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'inverse_primary',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 40.0
      else
        Result := 80.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := InverseSurface();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(3.0, 4.5, 7.0, 7.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.Secondary: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'secondary',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.secondary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 80.0
      else
        Result := 40.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(3.0, 4.5, 7.0, 7.0) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        SecondaryContainer(), Secondary(), 10.0,
        TTonePolarity.kNearer, False
      );
    end
  );
end;

class function TMaterialDynamicColors.OnSecondary: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_secondary',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.secondary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        if s.is_dark then
          Result := 10.0
        else
          Result := 100.0
      else
        if s.is_dark then
          Result := 20.0
        else
          Result := 100.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := Secondary();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SecondaryContainer: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'secondary_container',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.secondary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    var
      initial_tone: Double;
    begin
      if s.is_dark then
        initial_tone := 30.0
      else
        initial_tone := 90.0;

      if IsMonochrome(s) then
        if s.is_dark then
          Result := 30.0
        else
          Result := 85.0
      else if not IsFidelity(s) then
        Result := initial_tone
      else
        Result := FindDesiredChromaByTone(
          s.secondary_palette.Hue, s.secondary_palette.Chroma,
          initial_tone, not s.is_dark
        );
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        SecondaryContainer(), Secondary(), 10.0,
        TTonePolarity.kNearer, False
      );
    end
  );
end;

class function TMaterialDynamicColors.OnSecondaryContainer: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_secondary_container',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.secondary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if not IsFidelity(s) then
        if s.is_dark then
          Result := 90.0
        else
          Result := 10.0
      else
        Result := ForegroundTone(SecondaryContainer().GetTone(s), 4.5);
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := SecondaryContainer();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.Tertiary: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'tertiary',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.tertiary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        if s.is_dark then
          Result := 90.0
        else
          Result := 25.0
      else
        if s.is_dark then
          Result := 80.0
        else
          Result := 40.0
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(3.0, 4.5, 7.0, 7.0) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        TertiaryContainer(), Tertiary(), 10.0,
        TTonePolarity.kNearer, False
      );
    end
  );
end;

class function TMaterialDynamicColors.OnTertiary: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_tertiary',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.tertiary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        if s.is_dark then
          Result := 10.0
        else
          Result := 90.0
      else
        if s.is_dark then
          Result := 20.0
        else
          Result := 100.0
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := Tertiary();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.TertiaryContainer: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'tertiary_container',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.tertiary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        if s.is_dark then
          Result := 60.0
        else
          Result := 49.0
      else if not IsFidelity(s) then
        if s.is_dark then
          Result := 30.0
        else
          Result := 90.0
      else
      begin
        var proposed_hct := THCT.Create(s.tertiary_palette.Get(s.source_color_hct.Tone));
        Result := FixIfDisliked(proposed_hct).Tone;
      end;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        TertiaryContainer(), Tertiary(), 10.0,
        TTonePolarity.kNearer, False
      );
    end
  );
end;

class function TMaterialDynamicColors.OnTertiaryContainer: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_tertiary_container',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.tertiary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        if s.is_dark then
          Result := 0.0
        else
          Result := 100.0
      else if not IsFidelity(s) then
        if s.is_dark then
          Result := 90.0
        else
          Result := 10.0
      else
        Result := ForegroundTone(TertiaryContainer().GetTone(s), 4.5);
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := TertiaryContainer();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.Error: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'error',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.error_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 80.0
      else
        Result := 40.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(3.0, 4.5, 7.0, 7.0) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        ErrorContainer(), Error(), 10.0,
        TTonePolarity.kNearer, False
      );
    end
  );
end;

class function TMaterialDynamicColors.OnError: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_error',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.error_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 20.0
      else
        Result := 100.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := Error();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.ErrorContainer: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'error_container',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.error_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 30.0
      else
        Result := 90.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        ErrorContainer(), Error(), 10.0,
        TTonePolarity.kNearer, False
      );
    end
  );
end;

class function TMaterialDynamicColors.OnErrorContainer: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_error_container',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.error_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if s.is_dark then
        Result := 90.0
      else
        Result := 10.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := ErrorContainer();
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.PrimaryFixed: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'primary_fixed',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 40.0
      else
        Result := 90.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        PrimaryFixed(), PrimaryFixedDim(), 10.0,
        TTonePolarity.kLighter, True
      );
    end
  );
end;

class function TMaterialDynamicColors.PrimaryFixedDim: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'primary_fixed_dim',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 30.0
      else
        Result := 80.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        PrimaryFixed(), PrimaryFixedDim(), 10.0,
        TTonePolarity.kLighter, True
      );
    end
  );
end;

class function TMaterialDynamicColors.OnPrimaryFixed: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_primary_fixed',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 100.0
      else
        Result := 10.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := PrimaryFixedDim();
    end,
    (* secondBackground *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := PrimaryFixed();
    end,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.OnPrimaryFixedVariant: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_primary_fixed_variant',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.primary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 90.0
      else
        Result := 30.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := PrimaryFixedDim();
    end,
    (* secondBackground *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := PrimaryFixed();
    end,
    (* contrastCurve *) TContrastCurve.Create(3.0, 4.5, 7.0, 11.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.SecondaryFixed: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'secondary_fixed',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.secondary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 80.0
      else
        Result := 90.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        SecondaryFixed(), SecondaryFixedDim(), 10.0,
        TTonePolarity.kLighter, True
      );
    end
  );
end;

class function TMaterialDynamicColors.SecondaryFixedDim: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'secondary_fixed_dim',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.secondary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 70.0
      else
        Result := 80.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        PrimaryFixed(), PrimaryFixedDim(), 10.0,
        TTonePolarity.kLighter, True
      );
    end
  );
end;

class function TMaterialDynamicColors.OnSecondaryFixed: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_secondary_fixed',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.secondary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      Result := 10.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := SecondaryFixedDim();
    end,
    (* secondBackground *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := SecondaryFixed();
    end,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.OnSecondaryFixedVariant: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_secondary_fixed_variant',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.secondary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 25.0
      else
        Result := 30.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := SecondaryFixedDim();
    end,
    (* secondBackground *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := SecondaryFixed();
    end,
    (* contrastCurve *) TContrastCurve.Create(3.0, 4.5, 7.0, 11.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.TertiaryFixed: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'tertiary_fixed',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.tertiary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 40.0
      else
        Result := 90.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        TertiaryFixed(), TertiaryFixedDim(), 10.0,
        TTonePolarity.kLighter, True
      );
    end
  );
end;

class function TMaterialDynamicColors.TertiaryFixedDim: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'tertiary_fixed_dim',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.tertiary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 30.0
      else
        Result := 90.0;
    end,
    (* isBackground *) True,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := HighestSurface(s);
    end,
    (* secondBackground *) nil,
    (* contrastCurve *) TContrastCurve.Create(1.0, 1.0, 3.0, 4.5) as IContrastCurve,
    (* toneDeltaPair *)
    function(s: TDynamicScheme): TToneDeltaPair
    begin
      Result := TToneDeltaPair.Create(
        TertiaryFixed(), TertiaryFixedDim(), 10.0,
        TTonePolarity.kLighter, True
      );
    end
  );
end;

class function TMaterialDynamicColors.OnTertiaryFixed: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_tertiary_fixed',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.tertiary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 100.0
      else
        Result := 10.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := TertiaryFixedDim();
    end,
    (* secondBackground *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := TertiaryFixed();
    end,
    (* contrastCurve *) TContrastCurve.Create(4.5, 7.0, 11.0, 21.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

class function TMaterialDynamicColors.OnTertiaryFixedVariant: IDynamicColor;
begin
  Result := TDynamicColor.Create(
    (* name *) 'on_tertiary_fixed_variant',
    (* palette *)
    function(s: TDynamicScheme): TTonalPalette
    begin
      Result := s.tertiary_palette;
    end,
    (* tone *)
    function(s: TDynamicScheme): Double
    begin
      if IsMonochrome(s) then
        Result := 90.0
      else
        Result := 30.0;
    end,
    (* isBackground *) False,
    (* background *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := TertiaryFixedDim();
    end,
    (* secondBackground *)
    function(s: TDynamicScheme): IDynamicColor
    begin
      Result := TertiaryFixed();
    end,
    (* contrastCurve *) TContrastCurve.Create(3.0, 4.5, 7.0, 11.0) as IContrastCurve,
    (* toneDeltaPair *) nil
  );
end;

end.
