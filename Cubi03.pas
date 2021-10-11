unit Cubi03;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, Buttons, ExtCtrls, Jpeg,
  Cubi04;

type
  TFChoix = class(TForm)
    Pn01: TPanel;
    Image0: TImage;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Bt_Creation: TButton;
    FLBox: TFileListBox;
    Bt0: TButton;
    Bt1: TButton;
    Bt2: TButton;
    Bt3: TButton;
    Bt4: TButton;
    Bt_Abandon: TButton;
    PnPat: TPanel;
    ImPat: TImage;
    procedure FormActivate(Sender: TObject);
    procedure ChargeStream(nf : byte);
    procedure LitUneImage(pima : TPima);
    procedure AfficheImages(si : byte);
    procedure Bt0Click(Sender: TObject);
    procedure Bt_CreationClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FChoix: TFChoix;
  ImaFile : string;
  ImaStrm : TMemoryStream;
  FileStrm : TFileStream;
  Image : TBitmap;
  Jpgim  : TJPEGImage;
  tbPima : array[0..5] of TPima;
  ilg,iht : integer;
  pa : integer;

implementation

{$R *.dfm}

procedure TFChoix.FormActivate(Sender: TObject);
var  i : byte;
begin
  nbf := FLBox.Items.Count - 1;     // fichiers *.flx
  if nbf < 0 then exit;
  if nbf > 4 then nbf := 4;
  pa := 300 div ((nbf + 1) * 6);
  ImPat.Visible := true;
  PnPat.Visible := true;
  for i := 0 to nbf do
  begin
    tbfic[i] := FLBox.Items[i];
    ChargeStream(i);
    AfficheImages(i);
    TButton(FindComponent('Bt'+IntToStr(i))).Enabled := true;
  end;
  ImPat.Visible := false;
  PnPat.Visible := false;
  ImPat.Left := 1;
end;

procedure TFChoix.ChargeStream(nf : byte);
var  i,lg : integer;
begin                           
  FileStrm := TFileStream.Create(tbfic[nf],fmOpenRead);
  try
    for i := 0 to 5 do
      FileStrm.ReadBuffer(tbPima[i],SizeOf(TPima));
    FileStrm.ReadBuffer(lg,SizeOf(integer));
    ImaStrm.Clear;
    ImaStrm.CopyFrom(FileStrm,lg);
  finally
  end;
  FileStrm.Free;
end;

procedure TFChoix.LitUneImage(pima : TPima);
var  MemS : TMemoryStream;
     bima : TBitmap;
begin
  ImaStrm.Position := pima.posima;
  MemS := TMemoryStream.Create;
  bima := TBitmap.Create;
  try
    MemS.SetSize(pima.taille);
    MemS.CopyFrom(ImaStrm,pima.taille);
    MemS.Position := 0;
    Jpgim.LoadFromStream(Mems);
    bima.Assign(Jpgim);
    BitmapRedim(bima,Image,ilg,iht,true);
  finally
    MemS.Free;
    bima.Free;
  end;
end;

procedure TFChoix.AfficheImages(si : byte);
var  i,k : byte;
     bima : TBitmap;
begin
  if si > 4 then exit;
  for i := 0 to 5 do
  begin
//    n := si * 10 + i + 1;
    bima := TBitmap.Create;
    LitUneImage(tbPima[i]);
    BitmapRedim(Image,bima,100,80,true);
    with TImage(FindComponent('Image'+IntToStr(si))) do
    begin
//      Picture.Bitmap := bima;
      Canvas.Draw(105*i,0,bima);
      for k := 1 to pa do
      begin
       ImPat.Left := ImPat.Left + 1;
       ImPat.Repaint;
       Sleep(10);
      end;
    end;
    bima.Free
  end;
end;

procedure TFChoix.Bt0Click(Sender: TObject);  
var  tag : byte;
begin
  tag := (Sender as TButton).Tag;
  if tag > nbf-1 then exit;
  ChargeStream(tag);
end;

procedure TFChoix.Bt_CreationClick(Sender: TObject);
begin
  FBao.ShowModal;
  if FBao.ModalResult = mrOk then
  begin
    ChargeStream(nbf);
    AfficheImages(nbf);
    TButton(FindComponent('Bt'+IntToStr(nbf))).Enabled := true;
  end;
end;

end.
