unit Cubi01;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Jpeg, Buttons, ImgList, StdCtrls, ExtDlgs,
  Cubi02, Cubi03, Cubi04, Cubi05;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    SBt_Ouvrir: TSpeedButton;
    SBt_Melange: TSpeedButton;
    SBt_Quitter: TSpeedButton;
    SBt_Voir: TSpeedButton;
    SBt_Images: TSpeedButton;
    Listima1: TImageList;
    Imodele: TImage;
    SB0: TSpeedButton;
    SB2: TSpeedButton;
    Img_Papillon: TImage;
    SB1: TSpeedButton;
    EdEvent: TEdit;
    Listima2: TImageList;
    PBox: TPaintBox;
    Listima3: TImageList;
    SBt_NoVol: TSpeedButton;
    SBt_Aide: TSpeedButton;
    procedure CreerCube(cb,lg,cl : byte);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChargeFaces;
    procedure SBt_OuvrirClick(Sender: TObject);
    procedure SBt_MelangeClick(Sender: TObject);
    procedure SBt_QuitterClick(Sender: TObject);
    procedure DeplaceCube(lg,cl : byte);
    procedure SBt_VoirClick(Sender: TObject);
    procedure Filtre;
    procedure SBt_ImagesClick(Sender: TObject);
    procedure SB0Click(Sender: TObject);
    procedure AfficheImage(fc : byte);
    procedure EdEventChange(Sender: TObject);
    procedure Voler;
    procedure PBoxPaint(Sender: TObject);
    procedure Bravo;
    procedure SBt_NoVolClick(Sender: TObject);
    procedure Ajuster;
    procedure SBt_AideClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var
  tbCube : array[1..4,1..5] of TCube;         // table des objets cube
  tbIma  : array[0..5,1..4,1..5] of TBitmap;  // table des images de faces
  bopen  : boolean = false;      // la boîte de cubes est ouverte
  bgo    : boolean = false;      // autorise le vol du papillon
  bind   : boolean = false;      // autorise le choix d'un cube par le papillon
  nocube : byte;
  px,ctr,
  aface  : integer;               // image affichée
  tbdes  : array[1..20] of byte;   // destination des cubes mélangés
  tbori  : array[1..20] of TPoint; // position d'origine des cubes en fonction de leur numéro
  bmp    : TBitmap;
  bunny  : TBitmap;
  unite  : integer;
  kxy : array[0..5] of integer;  // position cubes en place
  kx  : array[1..20] of integer; // position des cubes en bordure
  ky  : array[1..20] of integer;

procedure TForm1.FormCreate(Sender: TObject);
var  bm : TBitmap;
     i : byte;
begin
  DoubleBuffered := true;
  Randomize;
  chemin := ExtractFilePath(Application.ExeName);
  ImaStrm := TMemoryStream.Create;
  Jpgim := TJPEGImage.Create;
  bmp := TBitmap.Create;
  Image := TBitmap.Create;
  Ajuster;
  bm := TBitmap.Create;
  for i := 0 to 1 do
  begin
    bm.LoadFromFile(chemin+'Cubima\bte'+IntToStr(i)+'.bmp');
    Listima1.Add(bm,nil);
  end;
  for i := 0 to 8 do
  begin
    bm.LoadFromFile(chemin+'Cubima\pap'+IntToStr(i)+'.bmp');
    Listima2.Add(bm,nil);
  end;
  for i := 0 to 7 do
  begin
    bm.LoadFromFile(chemin+'Cubima\bun'+IntToStr(i)+'.bmp');
    Listima3.Add(bm,nil);
  end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  FChoix.ClientHeight := 485;
  FBao.ClientHeight   := 495;
end;

procedure TForm1.Ajuster;    //... à la dimension de l'écran
var  i : integer;
begin
  unite := (Screen.Height) div 65;
  unite := unite * 10;
  ilg   := unite * 5;
  iht   := unite * 4;
  ClientWidth    := unite * 7 + 10 + 92;
  ClientHeight   := unite * 6 + 10;
  Imodele.Width  := ilg;
  Imodele.Height := iht;
  Imodele.Left   := unite + 5;
  Imodele.Top    := unite + 5;
  Image.Width    := ilg;
  Image.Height   := iht;
  kxy[0] := 5;
  for i := 1 to 5 do kxy[i] := kxy[i-1] + unite;
  kx[1] := 0;
  for i := 2 to 7 do kx[i] := kx[i-1] + unite + 2;
  kx[8] := 0; kx[9] := kx[7];
  kx[10] := 0; kx[11] := kx[7];
  kx[12] := 0; kx[13] := kx[7];
  kx[14] := 0; kx[15] := kx[7];
  for i := 16 to 20 do kx[i] := kx[i-14];
  for i := 1 to 7 do ky[i] := 0;
  ky[8] := kx[2];  ky[9] := kx[2];
  ky[10] := kx[3];  ky[11] := kx[3];
  ky[12] := kx[4];  ky[13] := kx[4];
  ky[14] := kx[5];  ky[15] := kx[5];
  for i := 16 to 20 do ky[i] := kx[6];
  PBox.Top := ClientHeight - 80;
  PBox.Width := Panel1.Left + 200;
end;

procedure TForm1.AfficheImage(fc : byte);
var  lg,cl : byte;
begin
  for lg := 1 to 4 do        // 4 lignes
    for cl := 1 to 5 do      // 5 colonnes
      imodele.Canvas.Draw(kxy[cl-1],kxy[lg-1],tbima[fc,lg,cl]);
  imodele.Repaint;
  imodele.BringToFront;
end;

procedure TForm1.ChargeFaces;   // Découpe des images en 20 morceaux
var  fc,lg,cl : byte;
     X,Y    : Integer;
     imaRect,
     RectSrc  : TRect;
begin
  imaRect := Rect(0,0,unite,unite);
  for fc := 0 to 5 do          // 6 faces
  begin
    y := 0;
    FChoix.LitUneImage(tbPima[fc]);
    Imodele.Picture.Bitmap := Image;
    for lg := 1 to 4 do        // 4 lignes
    begin
      x := 0;
      for cl := 1 to 5 do      // 5 colonnes
      begin
        tbima[fc,lg,cl] := TBitmap.Create;
        tbima[fc,lg,cl].Width := unite;
        tbima[fc,lg,cl].Height := unite;
        RectSrc := Rect(X,Y,X+unite,Y+unite);
        tbima[fc,lg,cl].Canvas.CopyRect(imaRect,Imodele.Canvas,RectSrc);
        Inc(x,unite);
      end;
      inc(y,unite);
    end;
  end;
end;

// Charge les images, photos et crée les cubes
procedure TForm1.SBt_OuvrirClick(Sender: TObject);
var  lg,cl,cb : byte;
begin
  if bopen then exit;
  FChoix.Left := Left+25;
  Fchoix.Top := Top+50;
  FChoix.ShowModal;
  if FChoix.ModalResult = mrOk then
  begin
    Listima1.GetBitmap(1,bmp);
    SBt_Ouvrir.Glyph.Canvas.Draw(0,0,bmp);   // Ouvre la boîte à cubes
    bopen := true;
    ChargeFaces;
    aface := Random(6);
    cb := 0;
    for lg := 1 to 4 do
      for cl := 1 to 5 do
      begin
        inc(cb);
        CreerCube(cb,lg,cl);
      end;
    FChoix.LitUneImage(tbPima[aface]);
    Imodele.Picture.Bitmap := Image;
    Imodele.Repaint;
    Imodele.BringToFront;
  end;  
end;

procedure TForm1.SBt_MelangeClick(Sender: TObject);
var  i,n,s,lg,cl : byte;
begin
  if not bopen then exit;
  FChoix.LitUneImage(tbPima[aface]);
  Imodele.Picture.Bitmap := Image;
  Imodele.Visible := false;
  for lg := 1 to 4 do
    for cl := 1 to 5 do
      tbCube[lg,cl].AfficheUneFace(aface);
  for i := 1 to 20 do tbdes[i] := i;
  for i := 1 to 20 do                // détermine l'emplacement de chaque cube
  begin                              // autour de l'image
    n := Random(20)+1;
    s := tbdes[n];
    tbdes[n] := tbdes[i];
    tbdes[i] := s;
  end;
  for lg := 1 to 4 do                // affiche une face aléatoire pour chaque
    for cl := 1 to 5 do              // cube et le déplace sur le bord
    begin
      if modjeu > 1 then
      begin
        tbCube[lg,cl].Virtuel := false;
      end
      else tbCube[lg,cl].Virtuel := true;
      if modjeu > 0 then
        tbCube[lg,cl].AfficheUneFace(Random(6));
      DeplaceCube(lg,cl);
      if modjeu = 2 then tbCube[lg,cl].PivoteUneFace(Random(4)+1);
   end;
  Filtre;
  ctr := 0;
  Img_Papillon.Visible := true;
  Img_Papillon.BringToFront;
  bgo := true;
  Voler;
end;

// Je sais..., j'aurais dû utiliser ScanLine, mais vu que la procedure n'est
// utilisée qu'une fois par jeu..., et puis, la flemme, vous connaissez ?   
procedure TForm1.Filtre;
var  x,y : integer;
begin
  for y := 0 to Imodele.Height-1 do
    for x := 0 to Imodele.Width-1 do
    begin
      if Odd(y) then
      begin
        if Odd(x) then Imodele.Canvas.Pixels[x,y] := clBlue;
      end
      else if not Odd(x) then Imodele.Canvas.Pixels[x,y] := clBlue;
    end;
end;

procedure TForm1.SBt_QuitterClick(Sender: TObject);
begin
  Img_Papillon.Visible := false;
  bgo := false;
  Listima1.GetBitmap(0,bmp);
  SBt_Ouvrir.Glyph.Canvas.Draw(0,0,bmp);   // referme la boîte à cubes
  SBt_Ouvrir.Repaint;
  Sleep(1000);
  Close;
end;

procedure TForm1.CreerCube(cb,lg,cl : byte);
var
  Index      : Integer;
begin
  tbori[cb].X := cl;
  tbori[cb].Y := lg;
  tbCube[lg,cl] := TCube.Create(self);
  tbCube[lg,cl].Parent  := Form1;
  tbCube[lg,cl].Taille  := unite;
  tbCube[lg,cl].Vitesse := 5;
  tbCube[lg,cl].Top     := kxy[lg];
  tbCube[lg,cl].Left    := kxy[cl];
  tbCube[lg,cl].Decale  := 5;
  tbCube[lg,cl].Tag := cb;
  try
    for Index := 0 to 5 do
    begin
      tbCube[lg,cl].ChargerGraphic(Index,tbima[Index,lg,cl]);
    end;
  finally
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var  fc,lg,cl : byte;
begin
  for fc := 0 to 5 do
  begin
    for lg := 1 to 4 do
      for cl := 1 to 5 do tbima[fc,lg,cl].Free;
  end;
  for lg := 1 to 4 do
    for cl := 1 to 5 do tbCube[lg,cl].Free;
  ImaStrm.Free;
  Jpgim.Free;
  Image.Free;
  bmp.Free;
end;

procedure TForm1.DeplaceCube(lg,cl : byte);
var  n : byte;
     ecx,ecy,
     xa,ya,xd,yd,p : integer;
     unCube : TCube;
begin
  unCube := tbCube[lg,cl];
  xd := unCube.Left;        // position initiale du cube
  yd := unCube.Top;
  n  := tbdes[tbCube[lg,cl].Tag];
  xa := kx[n];              // position finale
  ya := ky[n];
  p := 20;                  // nbre de pas à effectuer
  repeat
    ecx := (xa-xd) div p;   // longueur d'un pas
    ecy := (ya-yd) div p;   //         "
    xd := xd+ecx;
    yd := yd+ecy;
    dec(p);
    unCube.Left := xd;
    unCube.Top := yd;
    unCube.BringToFront;
    Repaint;
    Sleep(20);
  until p = 0;
  unCube.Left := kx[n];
  unCube.Top  := ky[n];
  EdEvent.Text := '';
end;

// Pendant la reconstitution, permet d'afficher et enlever le modèle
procedure TForm1.SBt_VoirClick(Sender: TObject);
begin
  iModele.Visible := not iModele.Visible;
end;

// Permet de faire défiler les images
procedure TForm1.SBt_ImagesClick(Sender: TObject);
begin
  if not bopen then exit;
  inc(aface);
  if aface > 5 then aface := 0;
  FChoix.LitUneImage(tbPima[aface]);
  Imodele.Picture.Bitmap := Image;
  Imodele.Visible := true;
  Imodele.BringToFront;
end;

procedure TForm1.SB0Click(Sender: TObject);  // choix du mode de jeu
begin
  modjeu := (Sender as TSpeedButton).Tag;
end;

// Lors du "DragDrop" d'un cube, on transfère le numéro de cube (Tag) dans la
// propriété Texte de EdEvent, ce qui provoque un évènement onChange qui permet
// de savoir qu'un déplacement de cube a eu lieu...ouf!
procedure TForm1.EdEventChange(Sender: TObject);
var  lg,cl,sn,fc : byte;
     fno : integer;
begin
  if EdEvent.Text = '' then exit;
  nocube := StrToInt(EdEvent.Text);
  if nocube in[1..20] then         // un cube a été déplacé
  begin
    lg := tbori[nocube].Y;
    cl := tbori[nocube].X;
    sn := 0;
    fno := tbCube[lg,cl].GetIndexFace;
    fc := fno div 4;                      // calcul de n° de face
    if modjeu = 2 then sn := fno mod 4;   // orientation de la face
    if (tbCube[lg,cl].Left = kxy[cl]) and (tbCube[lg,cl].Top = kxy[lg])
       and (fc = aface) and (sn = 0) then
    begin
      inc(ctr);
      tbdes[nocube] := 0;         // supprime le n° de cube sur le bord
      bind := false;              // autorise le pointage par le papillon
    end
    else DeplaceCube(lg,cl);      // place incorrecte
  end;
  if ctr = 20 then Bravo;         // tous les cubes sont à leur place
end;

procedure TForm1.Voler;       // auteur : Caribensila et + pour affinités
var
  i, IndexIma, SensH ,SensV, IndexCoef, Vitesse,
  Frequence, NbreCycles,Min, Max,
  cx, cy, ox, oy, qc : Integer;

    procedure VolDirect(dx,dy,vx,vy : integer);
    var  ecx,ecy,
         xa,ya,xd,yd,p : integer;
    begin
      xd := dx;        // position initiale du papillon
      yd := dy;
      xa := vx;              // position finale
      ya := vy;
      p := 30;                  // nbre de pas à effectuer
      repeat
        ecx := (xa-xd) div p;   // longueur d'un pas
        ecy := (ya-yd) div p;   //         "
        xd := xd+ecx;
        yd := yd+ecy;
        dec(p);
        Img_Papillon.Picture.Bitmap := nil;
        Listima2.GetBitmap(IndexIma + IndexCoef,Img_Papillon.Picture.Bitmap);
        Img_Papillon.Left := xd;
        Img_Papillon.Top  := yd;
        Img_Papillon.Refresh;
        bind := true;
        Sleep(20);
        if IndexIma < 3 then inc(IndexIma) else IndexIma:=0;
        Application.ProcessMessages;
      until p = 0;
    end;

    procedure MontreCube;
    var  lg,cl : integer;
    begin
      qc := 0;
      for lg := 1 to 4 do
       for cl := 1 to 5 do
         if (tbcube[lg,cl].Left = ox) and (tbcube[lg,cl].Top = oy) then
           qc := tbcube[lg,cl].Tag;
      if qc = 0 then exit;
      if (ctr = 20) or (Random(10) > 1) then exit;
      Img_Papillon.Picture.Bitmap := nil;
      Img_Papillon.Left := ox;
      Img_Papillon.Top := oy;
      Listima2.GetBitmap(8,Form1.Img_Papillon.Picture.Bitmap);
      Img_Papillon.Refresh;
      Sleep(1000);
      for lg := 1 to 4 do
        for cl := 1 to 5 do
          if tbcube[lg, cl].Tag = qc then
          begin
            VolDirect(ox,oy,kxy[cl],kxy[lg]);
            Img_Papillon.Picture.Bitmap := nil;
            Img_Papillon.Left := kxy[cl];
            Img_Papillon.Top := kxy[lg];
            Listima2.GetBitmap(8,Form1.Img_Papillon.Picture.Bitmap);
            Img_Papillon.Refresh;
            Sleep(1000);
            Application.ProcessMessages;
          end;
    end;

begin
  IndexIma := 0;
  SensH := 1;// SensH=1 => se déplace vers la droite, SensH=-1 => se déplace vers la gauche.
  SensV :=-1;// SensV=1 => se déplace vers le bas, SensV=-1 => se déplace vers le haut.
  IndexCoef := 0;//.
  while bgo do
  begin
    Vitesse := 15;
    Vitesse := (Random((1+Vitesse+Vitesse div 5)-(Vitesse-Vitesse div 5)))+Vitesse-Vitesse div 5; //La vitesse peut varier de + ou - 20%.
    Frequence := 1000 div 20;//Fréquence de battement des ailes.
    Min := 8;
    Max := 20;
    NbreCycles := Random(1+Max-Min)+Min;
    for i := 1 to NbreCycles do
    begin
      if ctr = 20 then exit;
      Img_Papillon.Picture.Bitmap := nil;
      Listima2.GetBitmap(IndexIma + IndexCoef,Img_Papillon.Picture.Bitmap);
      Img_Papillon.Left := Img_Papillon.Left + Vitesse * SensH;
      Img_Papillon.Top  := Img_Papillon.Top  + Vitesse * SensV;
      cx := Img_Papillon.Left + unite div 2;
      cy := Img_Papillon.Top + unite div 2;
    //Survol d'un cube ?
      if (cx > Width-150) and (SensH = 1) then          // à droite
      begin
        SensH:= -1 * SensH;
        if IndexCoef=0 then IndexCoef:=4 else IndexCoef:=0;
        if (modjeu > 0) and not bind then
        begin
          ox := kx[7];
          oy := kx[5];
          while oy > cy do dec(oy,unite+2);
          MontreCube;
        end;
      end;
      if (cx < 50) and (SensH = -1) then               // à gauche
      begin
        SensH:= -1 * SensH;
        if IndexCoef=0 then IndexCoef:=4 else IndexCoef:=0;
        if (modjeu > 0) and not bind then
        begin
          ox := 0;
          oy := kx[5];
          while oy > cy do dec(oy,unite+2);
          MontreCube;
        end;
      end;
      if (cy > Height-100) and (SensV = 1) then        // en bas
      begin
        SensV:= -1 * SensV;
        if (modjeu > 0) and not bind then
        begin
          ox := kx[6];
          oy := kx[6];
          while ox > cx do dec(ox,unite+2);
          MontreCube;
        end;
      end;
      if (cy < 50) and (SensV = -1) then               // en haut
      begin
        SensV:= -1 * SensV;
        if (modjeu > 0) and not bind then
        begin
          ox := kx[6];
          oy := 0;
          while ox > cx do dec(ox,unite+2);
          MontreCube;
        end;
      end;
      Img_Papillon.Refresh;
      Sleep(Frequence);
      if IndexIma < 3 then inc(IndexIma) else IndexIma:=0;
      Application.ProcessMessages;
    end;
    //Changement aléatoire de direction.
    if Random(2) = 0 then SensV:= -1 * SensV;
    if Random(5) = 0 then
    begin
      SensH:= -1 * SensH;
      if IndexCoef=0 then IndexCoef:=4 else IndexCoef:=0;
    end;
    if not bgo then exit;
    Img_Papillon.BringToFront;
  end;
end;

procedure TForm1.PBoxPaint(Sender: TObject);
begin
  PBox.Canvas.Draw(px,0,bunny);
end;

procedure TForm1.Bravo;   // Quand l'image est reconstituée...
var  i : byte;
begin
  i := 0;
  px := -185;
  repeat
    bunny := TBitmap.Create;
    bunny.Width := 186;
    bunny.Height := 56;
    bunny.Transparent := true;
    Listima3.GetBitmap(i,bunny);
    inc(px,5);
    PBox.Repaint;
    Sleep(50);
    inc(i);
    if i > 7 then i := 0;
  until px > Panel1.Left;
  bgo := false;
  Img_Papillon.Visible := false;
end;

// Arrêt du vol du papillon (des fois ça agace...)
procedure TForm1.SBt_NoVolClick(Sender: TObject);
begin
  bgo := false;
  Img_Papillon.Visible := false;
end;

procedure TForm1.SBt_AideClick(Sender: TObject);
begin
  FAide.ShowModal;
end;

end.
