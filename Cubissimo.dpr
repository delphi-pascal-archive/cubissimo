program Cubissimo;

uses
  Forms,
  Cubi01 in 'Cubi01.pas' {Form1},
  Cubi04 in 'Cubi04.pas' {FBao},
  Cubi03 in 'Cubi03.pas' {FChoix},
  Cubi02 in 'Cubi02.pas',
  Cubi05 in 'Cubi05.pas' {FAide};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFBao, FBao);
  Application.CreateForm(TFChoix, FChoix);
  Application.CreateForm(TFAide, FAide);
  Application.Run;
end.
