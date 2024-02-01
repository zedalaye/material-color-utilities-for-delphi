unit MaterialColor.Dislike;

interface

uses
  MaterialColor.CAM.HCT;

(**
 * @return whether the color is disliked.
 *
 * Disliked is defined as a dark yellow-green that is not neutral.
 * @param hct The color to be tested.
 *)
function IsDisliked(hct: THCT): Boolean;

(**
 * If a color is disliked, lightens it to make it likable.
 *
 * The original color is not modified.
 *
 * @param hct The color to be tested (and fixed, if needed).
 * @return The original color if it is not disliked; otherwise, the fixed
 *     color.
 *)
function FixIfDisliked(hct: THCT): THCT;

implementation

function IsDisliked(hct: THCT): Boolean;
var
  rounded_hue: Double;
  hue_passes, chroma_passes, tone_passes: Boolean;
begin
  rounded_hue := Round(hct.Hue);

  hue_passes := (rounded_hue >= 90.0) and (rounded_hue <= 111.0);
  chroma_passes := Round(hct.Chroma) > 16.0;
  tone_passes := Round(hct.Tone) < 65.0;

  Result := hue_passes and chroma_passes and tone_passes;
end;

function FixIfDisliked(hct: THCT): THCT;
begin
  Result := hct;
  if (IsDisliked(hct)) then
    Result := THCT.Create(hct.Hue, hct.Chroma, 70.0);
end;

end.
