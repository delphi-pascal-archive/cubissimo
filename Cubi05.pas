unit Cubi05;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TFAide = class(TForm)
    ImAide: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FAide: TFAide;

implementation

{$R *.dfm}

procedure TFAide.FormCreate(Sender: TObject);
begin
  ImAide.Picture.LoadFromFile('Aide.jpg');
end;

end.
