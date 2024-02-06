program GUITest;

uses
  Vcl.Forms,
  GUITest.MainForm in 'GUITest.MainForm.pas' {Form2},
  MaterialColor.VCL in 'src\MaterialColor.VCL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
