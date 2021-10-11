unit Cubi04;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtDlgs, ExtCtrls, Jpeg;

type
  TPima = record               // Paramètres image
            posima : integer;      // position de l'image dans le stream
            taille : integer;      // taille de l'image
          end;
  TFBao = class(TForm)
    OPDlg: TOpenPictureDialog;
    SDlg: TSaveDialog;
    Vimage: TImage;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Bt_Oui: TButton;
    Bt_Non: TButton;
    GroupBox1: TGroupBox;
    Bt_Charger: TButton;
    GroupBox2: TGroupBox;
    Bt_Enregistrer: TButton;
    Bt_Abandon: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure Bt_OuiClick(Sender: TObject);
    procedure Bt_NonClick(Sender: TObject);
    procedure Bt_ChargerClick(Sender: TObject);
    procedure Bt_EnregistrerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FBao: TFBao;
  chemin : string;
  nbf : integer = -1;
  noima   : integer;
  tbfic : array[0..5] of string;

procedure Trace(n : integer);
procedure BitmapRedim(ImgSrc,ImgDest : TBitmap; dx,dy : integer;
                      RefreshBmp: Boolean);

implementation

{$R *.dfm}

var
  MemStrm,
  ImaStrm : TMemoryStream;
  tbPima : array[0..6] of TPima;
  ima1,ima2 : TBitmap;
  temp : string = 'Temp.jpg';

  
procedure Trace(n : integer);
begin
  SHowMessage(IntToStr(n));
end;

procedure BitmapRedim(ImgSrc,ImgDest : TBitmap; dx,dy : integer;
                      RefreshBmp: Boolean);
type
  TRGBArray = ARRAY[0..0] OF TRGBTriple; // élément de bitmap (API windows)
  pRGBArray = ^TRGBArray; // type pointeur vers tableau 3 octets 24 bits
var
  nbpix, R, G, B: Int64;
  x, y: Integer;
  posY1, posY2, posX1, posX2: Integer;
  Tmp, IntervalX, IntervalY: Double;
  SauvPixelFormatSrc : TPixelFormat;
  Row                : PRGBArray;  // pointeur scanline
//-----------------------------------------------------------------------------
      procedure Calcul;
      var _Row : PRGBArray;  // pointeur scanline ...
          _x,_y: Integer;
      begin
        R := 0;
        G := 0;
        B := 0;
        nbpix := 0;
        for _y := posY1 to posY2 do
        begin
          _Row := ImgSrc.scanline[_y];      // scanline
          for _x := posX1 to posX2 do
          begin
            R := R + _Row[_x].rgbtRed;
            G := G + _Row[_x].rgbtGreen;
            B := B + _Row[_x].rgbtBlue;
            nbpix := nbpix + 1;
          end;
        end;
        R := R Div nbpix;
        G := G Div nbpix;
        B := B Div nbpix;
      end;
//-----------------------------------------------------------------------------
begin
  SauvPixelFormatSrc := ImgSrc.PixelFormat;
  if ImgSrc.PixelFormat <> pf24Bit then ImgSrc.PixelFormat := pf24Bit;
  if ImgDest.PixelFormat <> pf24Bit then ImgDest.PixelFormat := pf24Bit;
  x := dx;
  y := dy;
  if x < 1 then x := 1;
  if y < 1 then y := 1;
  ImgDest.Width  := x;
  ImgDest.Height := y;
  IntervalX := ImgSrc.Width / ImgDest.Width;
  IntervalY := ImgSrc.Height / ImgDest.Height;
  for y := 0 to ImgDest.height-1 do
  begin
    row := ImgDest.scanline[y];
    Tmp := y * IntervalY;                    // pos 1er pixel ...
    posY1 := Round(Tmp);
    if posY1 > ImgSrc.Height - 1
    then posY1 := ImgSrc.Height - 1;
    Tmp := Tmp + IntervalY;                  // pos dernier pixel ...
    posY2 := Round(Tmp);
    if posY2 > ImgSrc.Height - 1
    then posY2 := ImgSrc.Height - 1;
    for x := 0 to ImgDest.width-1 do
    begin
      Tmp := x * IntervalX;                  // pos 1er pixel ...
      posX1 := Round(tmp);
      if posX1 > ImgSrc.Width - 1
      then posX1 := ImgSrc.Width - 1;
      Tmp := Tmp + IntervalX;                // pos dernier pixel ...
      posX2 := Round(Tmp);
      if posX2 > ImgSrc.Width - 1
      then posX2 := ImgSrc.Width - 1;
      Calcul; // Calcul des pixels entre posX1, posY1, posX2 et posY2
      if R < 0 then R := 0; if R > 255 then R := 255;
      if G < 0 then G := 0; if G > 255 then G := 255;
      if B < 0 then B := 0; if B > 255 then B := 255;
      row[x].rgbtred   := R;
      row[x].rgbtgreen := G;
      row[x].rgbtblue  := B;
    end;
  end;
  if SauvPixelFormatSrc <> pf24Bit
  then ImgSrc.PixelFormat := SauvPixelFormatSrc;
  if RefreshBmp then ImgDest.Modified := True;
end;

procedure TFBao.FormCreate(Sender: TObject);
begin
  with tbPima[0] do
  begin
    posima := 0;
    taille := 0;
  end;
end;

procedure TFBao.FormActivate(Sender: TObject);
begin
  ImaStrm := TMemoryStream.Create;
  MemStrm := TMemoryStream.Create;
  ima1 := TBitmap.Create;
  ima2 := TBitmap.Create;
  noima := 0;
end;

procedure TFBao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ImaStrm.Free;
  MemStrm.Free;
  ima1.Free;
  ima2.Free;
end;

procedure LitImage(fic : string);
var
  ImageJPEG : TJPEGImage;
  ex : string;
begin
  ex := Uppercase(ExtractFileExt(fic));
  if ex = '.BMP' then
  begin
    Ima1.LoadFromFile(fic);
    exit;
  end;
  if (ex = '.JPG') or (ex = '.JPE') then
  begin
    ImageJPEG := TJPEGImage.Create;
    try
      ImageJPEG.LoadFromFile(fic);
      Ima1.Assign(ImageJPEG);
    finally
      ImageJPEG.Free;
    end;
  end;
end;
        
procedure EcritTempFile;
var
  ImageJPEG : TJPEGImage;
begin
  ImageJPEG := TJPEGImage.Create;
  try
    ImageJPEG.Assign(Ima2);
    ImageJPEG.SaveToFile(temp);
  finally
    ImageJPEG.Free;
  end;
end;

// Chargement d'une image
procedure TFBao.Bt_ChargerClick(Sender: TObject);
begin
  if OPDlg.Execute then
  begin
    if noima >= 6 then exit;
    LitImage(OPDlg.FileName);
    BitmapRedim(Ima1,Ima2,500,400,true); // Redimensionne l'image
    Vimage.Picture.Bitmap := ima2;
    Vimage.Repaint;
    Bt_Charger.Enabled := false;
  end;
end;

// Acceptation de l'image
procedure TFBao.Bt_OuiClick(Sender: TObject);
var  bmp : TBitmap;
     f : file;
begin
  bmp := TBitmap.Create;
  inc(noima);
  BitmapRedim(Ima2,bmp,100,80,true);
  TImage(FindComponent('image'+IntToStr(noima))).Picture.Bitmap := bmp;
  bmp.Free;
  EcritTempFile;
  tbPima[noima] := tbPima[0];  // initialisation à l'aide de l'élément 0
  ImaStrm.Position := ImaStrm.Size;
  tbPima[noima].posima := ImaStrm.Position; // position dans le stream
  VImage.Picture.LoadFromFile(temp);
  VImage.Picture.Graphic.SaveToStream(ImaStrm); // copie de l'image
  tbPima[noima].taille := ImaStrm.Position - tbPima[noima].posima;
        // la taille de l'image est calculée par différence entre sa position
        // et la taille du stream après ajout de l'image.
  Bt_Charger.Enabled := true;
  AssignFile(f,temp);
  Erase(f);
end;

// Refus de l'image
procedure TFBao.Bt_NonClick(Sender: TObject);
begin
  Bt_Charger.Enabled := true;
end;

procedure TFBao.Bt_EnregistrerClick(Sender: TObject);
// Enregistrement des images. Les éléments sont rassemblés dans un
// MemoryStream qui est ensuite copié dans un fichier.
var  i,lg : integer;
begin
  if nbf > 3 then
  begin
    Showmessage('Plus de 5 groupes d''images!');
    FBao.ModalResult := mrCancel;
    exit;
  end;
  if noima <> 6 then
  begin
    Showmessage('Le nombre d''images ('+IntToStr(noima)+') n''est pas correct!');
    FBao.ModalResult := mrCancel;
    exit;
  end;
  SDlg.InitialDir := chemin;
  if SDlg.Execute then
  begin
    MemStrm.Clear;
    try
      for i := 1 to 6 do
        MemStrm.WriteBuffer(tbPima[i],SizeOf(TPima)); // paramètres images
      lg := ImaStrm.Size;
      MemStrm.WriteBuffer(lg,SizeOf(integer));        // taille du stream images
      ImaStrm.Position := 0;
      MemStrm.CopyFrom(ImaStrm,lg);                   // stream images
      MemStrm.SaveToFile(SDlg.FileName);
      inc(nbf);
      tbfic[nbf] := SDlg.FileName;
    finally
    end;
  end;
end;

end.
