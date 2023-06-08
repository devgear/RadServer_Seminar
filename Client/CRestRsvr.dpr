program CRestRsvr;

uses
  System.StartUpCopy,
  FMX.Forms,
  CMUnit in 'CMUnit.pas' {CForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCForm, CForm);
  Application.Run;
end.
