unit MaterialColor.CAM.HCT;

interface

uses
  System.Math,
  System.Generics.Defaults, System.Hash,
  MaterialColor.Utils,
  MaterialColor.CAM.HCTSolver, MaterialColor.CAM;

(**
 * HCT: hue, chroma, and tone.
 *
 * A color system built using CAM16 hue and chroma, and L* (lightness) from
 * the L*a*b* color space, providing a perceptually accurate
 * color measurement system that can also accurately render what colors
 * will appear as in different lighting environments.
 *
 * Using L* creates a link between the color system, contrast, and thus
 * accessibility. Contrast ratio depends on relative luminance, or Y in the XYZ
 * color space. L*, or perceptual luminance can be calculated from Y.
 *
 * Unlike Y, L* is linear to human perception, allowing trivial creation of
 * accurate color tones.
 *
 * Unlike contrast ratio, measuring contrast in L* is linear, and simple to
 * calculate. A difference of 40 in HCT tone guarantees a contrast ratio >= 3.0,
 * and a difference of 50 guarantees a contrast ratio >= 4.5.
 *)

type
  THCT = record
  private
    FHue, FChroma, FTone: Double;
    FArgb: TARGB;

    (**
     * Sets the Hct object to represent an sRGB color.
     *
     * @param argb the new color as an integer in ARGB format.
     *)
    procedure SetInternalState(argb: TARGB);

    procedure SetChroma(const Value: Double);
    procedure SetHue(const Value: Double);
    procedure SetTone(const Value: Double);
  public
    (**
     * Creates an HCT color from hue, chroma, and tone.
     *
     * @param hue 0 <= hue < 360; invalid values are corrected.
     * @param chroma >= 0; the maximum value of chroma depends on the hue
     * and tone. May be lower than the requested chroma.
     * @param tone 0 <= tone <= 100; invalid values are corrected.
     * @return HCT representation of a color in default viewing conditions.
     *)
    constructor Create(hue, chroma, tone: Double); overload;

    (**
     * Creates an HCT color from a color.
     *
     * @param argb ARGB representation of a color.
     * @return HCT representation of a color in default viewing conditions
     *)
    constructor Create(argb: TARGB); overload;

    (**
     * Returns the color in ARGB format.
     *
     * @return an integer, representing the color in ARGB format.
     *)
    function ToInt: TARGB;

//    (**
//     * For using HCT as a key in a ordered map.
//     *)
//    class operator LessThan(const A, B: THCT): Boolean;

    (**
     * Returns the hue of the color.
     *
     * @return hue of the color, in degrees.
     *)

    (**
     * Sets the hue of this color. Chroma may decrease because chroma has a
     * different maximum for any given hue and tone.
     *
     * @param new_hue 0 <= new_hue < 360; invalid values are corrected.
     *)
    property Hue: Double read FHue write SetHue;

    (**
     * Returns the chroma of the color.
     *
     * @return chroma of the color.
     *)

    (**
     * Sets the chroma of this color. Chroma may decrease because chroma has a
     * different maximum for any given hue and tone.
     *
     * @param new_chroma 0 <= new_chroma < ?
     *)
    property Chroma: Double read FChroma write SetChroma;

    (**
     * Returns the tone of the color.
     *
     * @return tone of the color, satisfying 0 <= tone <= 100.
     *)

    (**
     * Sets the tone of this color. Chroma may decrease because chroma has a
     * different maximum for any given hue and tone.
     *
     * @param new_tone 0 <= new_tone <= 100; invalid valids are corrected.
     *)
    property Tone: Double read FTone write SetTone;
  end;

  THCTEqualityComparer = class(TEqualityComparer<THCT>)
    function Equals(const Left, Right: THCT): Boolean; override;
    function GetHashCode(const Value: THCT): Integer; override;
  end;

implementation

{ THCT }

constructor THCT.Create(hue, chroma, tone: Double);
begin
  FHue := 0.0;
  FChroma := 0.0;
  FTone := 0.0;
  FArgb := 0;
  SetInternalState(SolveToInt(hue, chroma, tone))
end;

constructor THCT.Create(argb: TARGB);
begin
  FHue := 0.0;
  FChroma := 0.0;
  FTone := 0.0;
  FArgb := 0;
  SetInternalState(argb);
end;

procedure THCT.SetInternalState(argb: TARGB);
begin
  FArgb := argb;
  var cam := CamFromInt(argb);
  FHue := cam.hue;
  FChroma := cam.chroma;
  FTone := LstarFromArgb(argb);
end;

procedure THCT.SetChroma(const Value: Double);
begin
  SetInternalState(SolveToInt(FHue, Value, FTone));
end;

procedure THCT.SetHue(const Value: Double);
begin
  SetInternalState(SolveToInt(Value, FChroma, FTone));
end;

procedure THCT.SetTone(const Value: Double);
begin
  SetInternalState(SolveToInt(FHue, FChroma, Value));
end;

function THCT.ToInt: TARGB;
begin
  Result := FArgb;
end;

//class operator THCT.LessThan(const A, B: THCT): Boolean;
//begin
//  Result := A.FHue < B.FHue;
//end;

{ THCTEqualityComparer }

function THCTEqualityComparer.Equals(const Left, Right: THCT): Boolean;
begin
  Result := SameValue(Left.Hue, Right.Hue);
end;

function THCTEqualityComparer.GetHashCode(const Value: THCT): Integer;
begin
  Result := THashBobJenkins.GetHashValue(Value.Hue, SizeOf(Double));
end;

end.
