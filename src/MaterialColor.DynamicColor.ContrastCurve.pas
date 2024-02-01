unit MaterialColor.DynamicColor.ContrastCurve;

interface

uses
  MaterialColor.Utils;

(**
 * A class containing a value that changes with the contrast level.
 *
 * Usually represents the contrast requirements for a dynamic color on its
 * background. The four values correspond to values for contrast levels -1.0,
 * 0.0, 0.5, and 1.0, respectively.
 *)

type
  IContrastCurve = interface
    ['{54066FF9-1629-40EE-B859-73C5E4AE1FEC}']
    function Get(contrast_level: Double): Double;
  end;

  TContrastCurve = class(TInterfacedObject, IContrastCurve)
  private
    FLow: Double;
    FNormal: Double;
    FMedium: Double;
    FHigh: Double;
  public
    (**
     * Creates a `ContrastCurve` object.
     *
     * @param low Value for contrast level -1.0
     * @param normal Value for contrast level 0.0
     * @param medium Value for contrast level 0.5
     * @param high Value for contrast level 1.0
     *)
    constructor Create(low, normal, medium, high: Double);

    (**
     * Returns the value at a given contrast level.
     *
     * @param contrastLevel The contrast level. 0.0 is the default (normal); -1.0
     *     is the lowest; 1.0 is the highest.
     * @return The value. For contrast ratios, a number between 1.0 and 21.0.
     *)
    function Get(contrast_level: Double): Double;
  end;

function GetContrast(low, normal, medium, high: Double; contrast_level: Double): Double;

implementation

function GetContrast(low, normal, medium, high: Double; contrast_level: Double): Double;
begin
  var CC: IContrastCurve := TContrastCurve.Create(low, normal, medium, high);
  Result := CC.Get(contrast_level);
end;

{ TContrastCurve }

constructor TContrastCurve.Create(low, normal, medium, high: Double);
begin
  inherited Create;
  FLow := low;
  FNormal := normal;
  FMedium := medium;
  FHigh := high;
end;

function TContrastCurve.Get(contrast_level: Double): Double;
begin
  if (contrast_level <= -1.0) then
    Result := FLow
  else if (contrast_level < 0.0) then
    Result := Lerp(FLow, FNormal, (contrast_level - (-1)) / 1)
  else if (contrast_level < 0.5) then
    Result := Lerp(FNormal, FMedium, (contrast_level - 0) / 0.5)
  else if (contrast_level < 1.0) then
    Result := Lerp(FMedium, FHigh, (contrast_level - 0.5) / 0.5)
  else
    Result := FHigh;
end;

end.
