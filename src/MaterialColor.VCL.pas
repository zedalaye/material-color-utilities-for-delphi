unit MaterialColor.VCL;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.UITypes, System.Math,
  Vcl.Graphics,
  MaterialColor.Utils,
  MaterialColor.Quantize.Celebi, MaterialColor.Score;

function PictureToRankedColors(const Picture: TPicture): TArray<TColor>;

function PictureToColor(const Picture: TPicture): TColor;

function ARGB(Color: TColor): TARGB;

implementation

function ARGB(Color: TColor): TARGB;
begin
  Result := $ff000000 or TAlphaColor(Color);
end;

function PictureToRankedColors(const Picture: TPicture): TArray<TColor>;
var
  H, W: Integer;
  B: TBitmap;
  Pixels: TArray<TARGB>;
begin
  { Resize Picture to 128x128 }
  with Picture do
    if Width > Height then
    begin
      W := Min(Width, 128);
      H := Round(W * (Height / Width));
    end
    else
    begin
      H := Min(Height, 128);
      W := Round(H * (Width / Height));
    end;

  B := TBitmap.Create;
  try
    B.SetSize(W, H);
    // Quickest way to downscale an image
    B.Canvas.StretchDraw(Rect(0, 0, W, H), Picture.Graphic);

    B.PixelFormat := pf32bit;
    SetLength(Pixels, B.Width * B.Height);

    // Could be replaced by ScanLine[]
    GetBitmapBits(B.Handle, B.Width * B.Height * SizeOf(TAlphaColor), @Pixels[0]);
  finally
    B.Free;
  end;

  { If *all* pixels in the image have transparency, make them opaque }

  var OpaqueCount := 0;
  for var P in Pixels do
    if IsOpaque(P) then
      Inc(OpaqueCount);

  if OpaqueCount = 0 then
    for var I := 0 to Length(Pixels) -1 do
      Pixels[I] := $ff000000 or Pixels[I];

  { Quantize Image }
  var QR := QuantizeCelebi(Pixels, 128);

  { Rank (and deduplicate) colors }
  var RankedColors := RankedSuggestions(QR.color_to_count, TScoreOptions.Create(8));

  { Convert TARGB/TAlphaColor to TColor }
  SetLength(Result, Length(RankedColors));
  for var I := 0 to Length(RankedColors) -1 do
    Result[I] := TAlphaColorRec.ColorToRGB(RankedColors[I]);
end;

function PictureToColor(const Picture: TPicture): TColor;
begin
  Result := PictureToRankedColors(Picture)[0];
end;

end.
