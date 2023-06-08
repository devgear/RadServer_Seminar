program VCL_LDB;

uses
  Vcl.Forms,
  VCL_Main in 'VCL_Main.pas' {Form4},
  DB_VModule in 'DB_VModule.pas' {DataModule1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
