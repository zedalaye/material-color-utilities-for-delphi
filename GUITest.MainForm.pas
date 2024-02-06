unit GUITest.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.UITypes, System.Math,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg,
  MaterialColor.VCL,
  MaterialColor.Quantize.Celebi, MaterialColor.Quantize.WsMeans,
  MaterialColor.Score,
  MaterialColor.Utils,
  MaterialColor.CAM, MaterialColor.CAM.HCT,
  MaterialColor.DynamicColor.DynamicScheme, MaterialColor.DynamicColor.Variant,
  MaterialColor.DynamicColor.MaterialDynamicColor;

type
  TForm2 = class(TForm)
    ImageOpenDialog: TFileOpenDialog;
    ImagePanel: TPanel;
    Image1: TImage;
    SamplesPanel: TFlowPanel;
    SamplePanel1: TPanel;
    SamplePanel2: TPanel;
    SamplePanel3: TPanel;
    SamplePanel4: TPanel;
    SamplePanel5: TPanel;
    SamplePanel6: TPanel;
    SamplePanel7: TPanel;
    SamplePanel8: TPanel;
    PalettesPanel: TFlowPanel;
    PrimaryPanel: TPanel;
    SecondaryPanel: TPanel;
    TertiaryPanel: TPanel;
    ErrorPanel: TPanel;
    LightOrDarkPanel: TPanel;
    pLight: TPanel;
    pDark: TPanel;
    SchemesPanel: TPanel;
    procedure Image1Click(Sender: TObject);
    procedure SamplePanelClick(Sender: TObject);
    procedure LightOrDarkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SchemePanelClick(Sender: TObject);
  private
    { Déclarations privées }
    FSchemePanels: array[TDynamicColorVariant] of TPanel;
    FScoredColors: TArray<TColor>;
    FSelectedColor: TColor;
    FIsDark: Boolean;
    FSchemeBuilder: TDynamicSchemeBuilderClass;
    procedure ProcessImage;
    procedure UpdateSchemes(const Scheme: TDynamicScheme);
    procedure UpdateSamples;
    procedure UpdateTheme;
  public
    { Déclarations publiques }
  end;

var
  Form2: TForm2;

implementation

uses
  MaterialColor.Scheme.Content,
  MaterialColor.Scheme.Expressive,
  MaterialColor.Scheme.Fidelity,
  MaterialColor.Scheme.FruitSalad,
  MaterialColor.Scheme.Monochrome,
  MaterialColor.Scheme.Neutral,
  MaterialColor.Scheme.Rainbow,
  MaterialColor.Scheme.TonalSpot,
  MaterialColor.Scheme.Vibrant;

{$R *.dfm}

const
  SCHEMES: array[TDynamicColorVariant] of TDynamicSchemeBuilderClass = (
    TSchemeMonochrome, TSchemeNeutral, TSchemeTonalSpot,
    TSchemeVibrant, TSchemeExpressive, TSchemeFidelity,
    TSchemeContent, TSchemeRainbow, TSchemeFruitSalad
  );
  NAMES: array[TDynamicColorVariant] of string = (
    'Monochrome', 'Neutral', 'Tonal Spot', 'Vibrant', 'Expressive', 'Fidelity',
    'Content', 'Rainbow', 'Fruit Salad'
  );

function ResFolder: string;
begin
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\..\res');
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  var ScaledMargin := MulDiv(5, Screen.PixelsPerInch, 96);

  for var V := Low(TDynamicColorVariant) to High(TDynamicColorVariant) do
  begin
    var SchemePanel := TPanel.Create(Self);
    SchemePanel.Name := StringReplace(NAMES[V], ' ', '', [rfReplaceAll]) + 'SchemePanel';
    SchemePanel.Parent := SchemesPanel;
    SchemePanel.Height := ((SchemesPanel.Height - ScaledMargin) div Length(NAMES)) - ScaledMargin;
    SchemePanel.Margins.SetBounds(ScaledMargin, ScaledMargin, ScaledMargin, 0);
    SchemePanel.AlignWithMargins := True;
    SchemePanel.Align := alTop;
    SchemePanel.BevelKind := bkNone;
    SchemePanel.BevelOuter := bvNone;
    SchemePanel.Caption := NAMES[V];
    SchemePanel.ParentBackground := False;
    SchemePanel.ParentFont := False;
    SchemePanel.Tag := Ord(V);
    SchemePanel.OnClick := SchemePanelClick;
    SchemePanel.Font.Size := MulDiv(8, Screen.PixelsPerInch, 96);

    FSchemePanels[V] := SchemePanel;
  end;

  FIsDark := False;
  FSchemeBuilder := TSchemeTonalSpot;
  ProcessImage;
end;

procedure TForm2.Image1Click(Sender: TObject);
begin
  ImageOpenDialog.DefaultFolder := ResFolder;
  if ImageOpenDialog.Execute then
  begin
    Image1.Picture.LoadFromFile(ImageOpenDialog.FileName);
    ProcessImage;
  end;
end;

procedure TForm2.ProcessImage;
begin
  FScoredColors := PictureToRankedColors(Image1.Picture);
  FSelectedColor := FScoredColors[0];

  UpdateSamples;
  UpdateTheme;
end;

procedure TForm2.UpdateSamples;

  function SamplePanels: TArray<TPanel>;
  begin
    Result := [ SamplePanel1, SamplePanel2, SamplePanel3, SamplePanel4,
                SamplePanel5, SamplePanel6, SamplePanel7, SamplePanel8 ];
  end;

  function SamplePanel(Index: Integer): TPanel;
  begin
    Result := SamplePanels[Index];
  end;

begin
  var SamplesCount := Length(FScoredColors);
  for var I := 0 to SamplesCount -1 do
    SamplePanel(I).Color := FScoredColors[I];

  for var I := SamplesCount to Length(SamplePanels) -1 do
    SamplePanel(I).Color := SamplesPanel.Color;
end;

procedure TForm2.UpdateSchemes(const Scheme: TDynamicScheme);
begin
  var Surface   := TMaterialDynamicColors.Surface.GetColor(Scheme);
  var OnSurface := TMaterialDynamicColors.OnSurface.GetColor(Scheme);
  var Primary   := TMaterialDynamicColors.Primary.GetColor(Scheme);
  var OnPrimary := TMaterialDynamicColors.OnPrimary.GetColor(Scheme);

  for var V := Low(TDynamicColorVariant) to High(TDynamicColorVariant) do
    if SCHEMES[V] = FSchemeBuilder then
    begin
      FSchemePanels[V].Color := Primary;
      FSchemePanels[V].Font.Color := OnPrimary;
    end
    else
    begin
      FSchemePanels[V].Color := Surface;
      FSchemePanels[V].Font.Color := OnSurface;
    end;
end;

type
  TColorSpeedButton = class(TSpeedButton)
  end;

procedure TForm2.UpdateTheme;
begin
  var Scheme := FSchemeBuilder.Construct(THCT.Create(ARGB(FSelectedColor)), FIsDark, 0.0);

  Self.Color := TMaterialDynamicColors.Surface.GetColor(Scheme);

  var SC_Color := TMaterialDynamicColors.SurfaceContainer.GetColor(Scheme);
  ImagePanel.Color       := SC_Color;
  LightOrDarkPanel.Color := SC_Color;
  SchemesPanel.Color     := SC_Color;
  SamplesPanel.Color     := SC_Color;
  PalettesPanel.Color    := SC_Color;

  var Primary      := TMaterialDynamicColors.Primary.GetColor(Scheme);
  var InvPrimary   := TMaterialDynamicColors.InversePrimary.GetColor(Scheme);
  var OnPrimary    := TMaterialDynamicColors.OnPrimary.GetColor(Scheme);
  var InvOnSurface := TMaterialDynamicColors.InverseOnSurface.GetColor(Scheme);

  if FIsDark then
  begin
    pDark.Color := Primary;
    pDark.Font.Color := OnPrimary;

    pLight.Color := InvPrimary;
    pLight.Font.Color := InvOnSurface;
  end
  else
  begin
    pLight.Color := Primary;
    pLight.Font.Color := OnPrimary;

    pDark.Color := InvPrimary;
    pDark.Font.Color := InvOnSurface;
  end;

  UpdateSchemes(Scheme);

  PrimaryPanel.Color        := Primary;
  PrimaryPanel.Font.Color   := OnPrimary;
  SecondaryPanel.Color      := TMaterialDynamicColors.Secondary.GetColor(Scheme);
  SecondaryPanel.Font.Color := TMaterialDynamicColors.OnSecondary.GetColor(Scheme);
  TertiaryPanel.Color       := TMaterialDynamicColors.Tertiary.GetColor(Scheme);
  TertiaryPanel.Font.Color  := TMaterialDynamicColors.OnTertiary.GetColor(Scheme);
  ErrorPanel.Color          := TMaterialDynamicColors.Error.GetColor(Scheme);
  ErrorPanel.Font.Color     := TMaterialDynamicColors.OnError.GetColor(Scheme);
end;

procedure TForm2.SamplePanelClick(Sender: TObject);
begin
  var Id := TPanel(Sender).Tag;

  if Id >= Length(FScoredColors) then
    Exit;

  FSelectedColor := FScoredColors[Id];
  UpdateTheme;
end;

procedure TForm2.LightOrDarkClick(Sender: TObject);
begin
  FIsDark := TPanel(Sender).Tag > 0;
  UpdateTheme;
end;

procedure TForm2.SchemePanelClick(Sender: TObject);
begin
  var Id := TPanel(Sender).Tag;

  if (Id < 0) or (Id > Ord(High(TDynamicColorVariant))) then
    Exit;

  FSchemeBuilder := SCHEMES[TDynamicColorVariant(Id)];
  UpdateTheme;
end;

end.
