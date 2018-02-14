program Snake_game;

uses
  Vcl.Forms,
  MainFm in 'MainFm.pas' {MainForm},
  Sound.Globals in 'Sound.Globals.pas',
  AboutFm in 'AboutFm.pas' {AboutForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.
