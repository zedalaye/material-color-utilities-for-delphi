unit MaterialColor.Quantize.Celebi;

interface

uses
  System.Generics.Collections,
  MaterialColor.Utils,
  MaterialColor.Quantize.WsMeans;

function QuantizeCelebi(const pixels: TArray<TARGB>; max_colors: Word): IQuantizerResult;

implementation

uses
  MaterialColor.Quantize.Wu;

function QuantizeCelebi(const pixels: TArray<TARGB>; max_colors: Word): IQuantizerResult;
var
  pixel_count: Integer;
  opaque_pixels, wu_result: TArray<TARGB>;
begin
  if (max_colors = 0) or (Length(pixels) = 0) then
  begin
    Result := TQuantizerResult.Create;
    Exit;
  end;

  if max_colors > 256 then
    max_colors := 256;

  SetLength(opaque_pixels, Length(pixels));

  pixel_count := 0;
  for var pixel in pixels do
  begin
    if not IsOpaque(pixel) then
      Continue;
    opaque_pixels[pixel_count] := pixel;
    Inc(pixel_count);
  end;

  SetLength(opaque_pixels, pixel_count);

  wu_result := QuantizeWu(opaque_pixels, max_colors);

  Result := QuantizeWsmeans(opaque_pixels, wu_result, max_colors);
end;

end.
