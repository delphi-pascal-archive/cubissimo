unit Cubi02;
                                                                                {
                 CubeEngine   PAR CARIBENSILA
                              février 2007
                         légèrement modifié par DEBIARS
                              avril 2007
                                                                                }
INTERFACE

  uses
    Windows, ExtCtrls, Controls, Classes, jpeg, SysUtils, Graphics, Forms,
    StdCtrls, math, Dialogs;

  type
    TCube = class(TImage)
    private
      fTabloBtm   : array[0..5] of TBitmap;
      fIndexFace : Integer;
      fTailleCube : Integer;
      fVitesse    : Integer;
      fVirtuel    : Boolean;
      fDecale     : Integer;                        // Ajout
      procedure SetVirtuel(Valeur : Boolean);
      procedure SetTailleCube(Valeur : Integer);
      procedure SetVitesse(Valeur : Integer);
      procedure SetDecale(Valeur : Integer);
      procedure CubeDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
      procedure CubeDragDrop(Sender, Source: TObject; X, Y: Integer);   // Ajout
      procedure CubeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    public
      constructor Create(AOwner:TComponent); override;
      destructor  Destroy; override;
      procedure ChargerGraphic(Index: Integer; UneImage: TGraphic);
      procedure AfficheUneFace(Index : integer);
      procedure PivoteUneFace(nb : byte);                       // Ajout
      function  GetIndexFace : integer;                           // Ajout
      property  Taille  : Integer read fTailleCube write SetTailleCube;
      property  Vitesse : Integer read fVitesse write SetVitesse;
      property  Virtuel : Boolean read fVirtuel write SetVirtuel;
      property  Decale  : Integer read fDecale write SetDecale;   // Ajout
      property  IndexFace : integer read GetIndexFace;
  end;

  var
    modjeu : byte = 0;
    
IMPLEMENTATION


  type
      TTab = array[0..23,1..4] of byte;

  const                                    //Ce tableau permet de connaître les photos présentes sur chaque face du cube.
     TabloRotation: TTab= ((13, 5, 9,17),  //Chaque ligne représente le N° de la face visible..
                           (18,14, 6,10),  //..et chaque colonne les faces mitoyennes dans..
                           (11,19,15, 7),  //..l'ordre: "Haut,Droite,Bas,Gauche".
                           ( 8,12,20,16),  //Bon... Je sais, c'est pas clair...
                           (14,21,12, 1),  //Mais pour faire ce tableau, j'ai fabriqué un petit cube en papier.
                           ( 2,15,22, 9),  //Et je l'envoie au plus offrant. lol
                           (10, 3,16,23),
                           (24,11, 4,13),
                           ( 1, 6,23,20),
                           (17, 2, 7,24),
                           (21,18, 3, 8),
                           ( 5,22,19, 4),
                           (23, 8, 1,18),
                           (19,24, 5, 2),
                           ( 3,20,21, 6),
                           ( 7, 4,17,22),
                           (16, 1,10,21),
                           (22,13, 2,11),
                           (12,23,14, 3),
                           ( 4, 9,24,15),
                           (15,17,11, 5),
                           ( 6,16,18,12),
                           ( 9, 7,13,19),
                           (20,10, 8,14));

    NbreImages : Integer = 30; //Nombre d'images calculées pour une animation.

  var
    MousePoint: TPoint; // Pour le drag'n drop.

  
procedure Trace(n : integer);
begin
  SHowMessage(IntToStr(n));
end;

constructor TCube.Create(AOwner:TComponent);
  begin
  inherited;
  fTailleCube      := 0;    // Valeur par défaut.
  fIndexFace       := 0;    //         "
  fVirtuel         := true; //         "
  fDecale          := 0;    //         "             // Ajout
  self.AutoSize    := true;
  self.OnMouseDown := CubeMouseDown;
  self.OnDragOver  := CubeDragOver;
  self.OnDragDrop  := CubeDragDrop;
end;



destructor TCube.Destroy;
  var
      i : integer;
  begin
  for i := 0 to 5 do FreeAndNil(fTabloBtm[i]);
  Inherited;
end;



procedure TCube.SetVirtuel(Valeur : Boolean);
  begin
  fVirtuel := Valeur;
end;



procedure TCube.SetTailleCube(Valeur : Integer);
  begin
  fTailleCube := Valeur;
end;


procedure TCube.SetVitesse(Valeur : Integer);
  begin
  fVitesse := Valeur;
end;


procedure TCube.SetDecale(Valeur : Integer);   // Ajout pour positionnement du cube
  begin
  fDecale := Valeur;
end;


function TCube.GetIndexFace : integer;         // Ajout pour récupération de la face
begin
  Result := fIndexFace;
end;


// Remplace ChargerJpg : accepte jpg et bmp
procedure TCube.ChargerGraphic(Index: Integer; UneImage: TGraphic);
  begin
  if fTailleCube = 0 then exit;//La taille du cube doit être initialisée avant de charger les images.
  if (Index>=0) and (Index<=5) then begin
     fTabloBtm[Index] := TBitmap.Create;
     fTabloBtm[Index].PixelFormat := pf24bit;
     fTabloBtm[Index].Height      := fTailleCube;
     fTabloBtm[Index].Width       := fTailleCube;
     fTabloBtm[Index].Canvas.StretchDraw(fTabloBtm[Index].Canvas.ClipRect,UneImage);
  end;
  if assigned(fTabloBtm[5]) then Picture.Assign(fTabloBtm[fIndexFace]);
end;


// Pour afficher une face avec mise à jour de fIndexFace (private) 
procedure TCube.AfficheUneFace(Index : integer);
  begin
    Picture.Assign(fTabloBtm[Index]);  
    fIndexFace := Index * 4;
  end;


procedure TCube.CubeDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
  var
      tempPoint : TPoint;
  Begin
  getcursorpos(tempPoint);
  with (Source as TControl) do begin
    Top :=Round((Parent as TControl).screentoclient(tempPoint).Y)-MousePoint.Y;
    Left:=Round((Parent as TControl).screentoclient(tempPoint).X)-MousePoint.X;
  end;
end;


procedure TCube.CubeDragDrop(Sender, Source: TObject; X, Y: Integer);  // Ajout
  var
      tempPoint : TPoint;
  Begin
  getcursorpos(tempPoint);
  with (Source as TControl) do begin
    Top :=Round((Parent as TControl).screentoclient(tempPoint).Y) div fTailleCube * fTailleCube + fDecale;
    Left:=Round((Parent as TControl).screentoclient(tempPoint).X) div fTailleCube * fTailleCube + fDecale;
    TEdit(Parent.FindComponent('EdEvent')).Text := IntToStr(Tag);  // déclenche un évènement dans Cubi01
  end;
end;


procedure TCube.PivoteUneFace(nb : byte);  // Ajout
  var
      nbr : byte;
      eta : TShiftState;
      x : integer;
  Begin
    x := 5;
    nbr := nb;
    if nbr > 2 then           // rotation à droite
    begin
      dec(nbr,2);
      x := fTailleCube-5;
    end;
    while nbr > 0 do
    begin
      CubeMouseDown(self, mbLeft, eta, x,5);
      dec(nbr);
    end;
end;


PROCEDURE TCube.CubeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  VAR
      Largeur    : Integer;
      Decalage   : Integer;
      Arete      : Integer;
      BorneBasse : Integer;
      BorneHaute : Integer;
      i          : Integer;
      L, T       : Integer;
      BtmImage   : TBitmap;
      BtmFace    : TBitmap;
      BtmSuivant : TBitmap;
      Angle      : extended;
      Pas        : Extended;

                  {Quelques procédures imbriquées pour éviter des variables globales.}

                    {1ère procédure imbriquée.}
                  procedure Calculer;
                    begin
                    Angle   := Angle - 3.1415926536 / (NbreImages shl 1);
                    Largeur := round((fTailleCube * 1.4142135623731) * Cos(abs(Angle))); // 1,4142135623731 := Sqrt(2)
                    Arete   := round(cos(0.7853981634 - Angle) * fTailleCube); //round(cos(Pi/4-Angle)...
                  end;


                    {2ème procédure imbriquée.}
                  procedure Afficher;
                    begin
                    self.Picture.Bitmap.Assign(BtmImage);
                    (self.Owner as TForm).Refresh;
                    Sleep(fVitesse);
                  end;


                    {3ème procédure imbriquée.}
                  procedure BmpRotation(BmpSourc: TBitmap; Angle: Extended);
                    {Rotation selon l'axe Z.}
                    var
                        ScanCible, ScanSourc : array of pointer;
                        CoinX, CoinY, X, Y, X2, Y2, T1 : integer;
                        Xcosr,Xsinr,Ysinr,Ycosr,Sinr,Cosr: integer;
                        Sinus, Cosin : Extended;
                    begin
                    while Angle > 360 do Angle := Angle-360; //Il faut 0 <= Angle <= 360
                    Angle := Angle*0.0174532925199433; // De degrés en radians.
                    SinCos(Angle ,Sinus, Cosin);
                    BtmSuivant.Height := round(BmpSourc.Height * abs(Sinus) + BmpSourc.Height * abs(Cosin));
                    BtmSuivant.Width  := BtmSuivant.Height;  //La taille de BmpDest est calculée pour contenir exactement  la nouvelle image.
                    BtmSuivant.Canvas.Brush.Color := clBlue; //65535;//Couleur de transparence.
                    BtmSuivant.Canvas.FillRect(BtmSuivant.Canvas.ClipRect);
                    BtmSuivant.TransparentColor := clBlue;   //65535;
                    {CoinX et CoinY sont les coordonnées du coin supérieur gauche de la photo dans l'image finale.}
                    CoinX := 0;
                    CoinY := 0;
                    if (Angle>=0)and(Angle<=1.5707963267949)then CoinX := round(BmpSourc.Height * abs(Sinus));
                    if (Angle >1.5707963267949)and(Angle<=3.14159265358979)then begin
                        CoinX := BtmSuivant.Width-1;
                        CoinY := round(BmpSourc.Height * abs(Cosin));  end;
                    if (Angle>3.14159265358979)and(Angle<=4.71238898038469)then begin
                        CoinX := round(BmpSourc.Height * abs(Cosin));
                        CoinY := BtmSuivant.Height-1;  end;
                    if (Angle>4.71238898038469)and(Angle<=6.28318530717959)then CoinY := round(BmpSourc.Height * abs(Sinus))-1;
                    {Decalage servira à replacer le TImage de façon à ce que l'image semble tourner sur elle-même.}
                    Decalage := (BtmSuivant.Height - BmpSourc.Height) shr 1;
                    SetLength(ScanCible,BtmSuivant.Height);
                    SetLength(ScanSourc,BmpSourc.Height);
                    for Y:=BtmSuivant.Height-1 downto 0 do ScanCible[Y] := BtmSuivant.scanline[Y];
                    for Y:=BmpSourc.Height  -1 downto 0 do ScanSourc[Y] := BmpSourc.scanline[Y];
                    Sinr := round(Sinus * $10000);//Les valeurs sinus et cosinus en Integer pour les décalages.
                    Cosr := round(Cosin * $10000);
                    for X:=BmpSourc.Width-1 downto 0 do begin
                      Xcosr:=X*Cosr;
                      Xsinr:=X*Sinr;
                      Y:=BmpSourc.Height-1;
                      Ysinr:=Y*Sinr;
                      Ycosr:=Y*Cosr;
                      for Y:=BmpSourc.Height-1 downto 0 do begin
                        T1 := Xcosr-Ysinr;
                        if T1>=0 then X2 := CoinX + T1 shr 16 else X2 := CoinX - (-T1) shr 16; //Evite de décaler les valeurs négatives.
                        T1 := Ycosr+Xsinr;
                        if T1>=0 then Y2 := CoinY + T1 shr 16 else Y2 := CoinY - (-T1) shr 16;
                        {X2 et Y2 sont maintenant les coordonnées du pixel de destination.}
                        dec(Ysinr,Sinr);
                        dec(Ycosr,Cosr);
                        if X2>-1 then
                        if X2<BtmSuivant.Width then
                        if Y2>-1 then
                        if Y2<BtmSuivant.Height then begin //Si X2 et Y2 sont bien dans le Bitmap de destination...
                          asm //Le code ASM original commenté en anglais est visible à : http://www.Planet-Source-Code.com/vb/scripts/ShowCode.asp?txtCodeId=853&lngWId=7
                            mov edx,ScanSourc;
                            mov eax,Y;
                            mov ecx,[edx+eax*4];
                            mov edx,X;
                            lea edx,[edx*2+edx];
                            mov ax,[edx+ecx];
                            push ebx;
                            mov bl,byte [edx+ecx+2];
                            mov ecx,ScanCible;
                            mov edx,Y2;
                            mov ecx,[edx*4+ecx];
                            mov edx,X2;
                            lea edx,[edx*2+edx];
                            mov word [ecx+edx],ax;
                            mov byte [ecx+edx+2],bl;
                            or edx,edx;
                            jz @end;
                            mov word [ecx+edx-3],ax;
                            mov byte [ecx+edx-1],bl;
                            @end:
                            pop ebx;
                          end;
                        end;
                      end;
                    end;
                  end;


                  {4ème procédure imbriquée.}
                  procedure OrienterFaceSuivante;
                  {Détermine la rotation à appliquer au bitmap de l'image suivante.
                   C'est cette procédure qui rend réaliste le comportement du cube.}
                    begin
                    case fIndexFace mod 4 of
                      0: BtmSuivant.Assign(fTabloBtm[fIndexFace shr 2]     );
                      1: BmpRotation      (fTabloBtm[fIndexFace shr 2],  90);
                      2: BmpRotation      (fTabloBtm[fIndexFace shr 2], 180);
                      3: BmpRotation      (fTabloBtm[fIndexFace shr 2], 270);
                    end;
                  end;


                  {5ème procédure imbriquée.}
                  procedure RotZ;
                    begin
                    BmpRotation(BtmFace, Pas);
                    self.Left := L-Decalage; //On repositionne le TImage.
                    self.Top  := T-Decalage;
                    self.Picture.Bitmap.Assign(BtmSuivant);
                    self.Refresh;
       //             Sleep(fVitesse);
                  end;



  BEGIN //PROCEDURE TCube.CubeMouseDown
  Self.BringToFront; //Pour survoler les autres cubes.
  BorneBasse := Self.Height div 5;
  BorneHaute := BorneBasse * 4;

  {Si clic au milieu du compo, c'est un Drag'n Drop.}
  if (modjeu = 0)                                          // Ajout
  or ((X>=BorneBasse) and (X<=BorneHaute) and (Y>=BorneBasse) and (Y<=BorneHaute)) then
  begin
    begindrag(false,3);//Le Drag commence après un mouvement de 3 pixels.
    MousePoint.X := X;
    MousePoint.Y := Y;
    Exit;
  end;

  BtmImage   := TBitmap.Create; //Sevira à recueillir les 2 images suivantes.
  BtmFace    := TBitmap.Create; // L'image de la face en train de disparaître.
  BtmSuivant := TBitmap.Create; // L'image de la face en train d'apparaître.
  try
    BtmImage.pixelformat   := pf24bit;
    BtmFace.pixelformat    := pf24bit;
    BtmSuivant.pixelformat := pf24bit;
    BtmImage.Height   := fTailleCube;       BtmImage.Width   := fTailleCube;
    BtmFace.Height    := fTailleCube;       BtmFace.Width    := fTailleCube;
    BtmSuivant.Height := fTailleCube;       BtmSuivant.Width := fTailleCube;
    BtmFace.Assign(self.Picture.Bitmap);
    Angle := 0.7853981634; // Pi/4
    
    {Si click dans un des coins.}
    L:= self.Left;
    T:= self.Top;
    if (X<=BorneBasse) and ((Y<=BorneBasse) or (Y>=BorneHaute)) then  //coins gauches.
    if (fVirtuel) then exit
    else begin
      if (fIndexFace div 4 > (fIndexFace-1) div 4) or (fIndexFace = 0) then fIndexFace := fIndexFace+3
      else fIndexFace := fIndexFace-1;
      self.Transparent := true;
      for i := NbreImages downto 1 do begin
        Pas := i*(90/NbreImages) + (270-90/NbreImages);
        RotZ;
      end;
      self.Transparent := false;
      Exit;
    end;
    if (X>=BorneHaute) and ((Y<=BorneBasse) or (Y>=BorneHaute)) then  //coins droits.
    if (fVirtuel) then exit
    else begin
      if fIndexFace div 4 < (fIndexFace+1) div 4  then fIndexFace := fIndexFace-3
      else fIndexFace := fIndexFace + 1;
      self.Transparent := true;
      for i := 1 to NbreImages do begin
        Pas := i*(90/NbreImages);
        RotZ;
      end;
      self.Transparent := false;
      Exit;
    end;

    {Si clic côté droit.}
    if (X>BorneHaute) and ((Y>BorneBasse) and (Y<BorneHaute)) then  begin //Tourne vers la droite => Face à apparaître = TabloRotation[fIndexFace,4].
      fIndexFace := TabloRotation[fIndexFace,4] - 1;
      if (fVirtuel = true) then BtmSuivant.Assign(fTabloBtm[fIndexFace shr 2])
      else OrienterFaceSuivante;
      for i := 1 to NbreImages do begin
        Calculer;
        Decalage := (self.Width - Largeur) div 2;
        BtmImage.Width := Largeur;
        BtmImage.Canvas.StretchDraw(rect(0,0,Largeur-Arete+1,fTailleCube+1),BtmSuivant);
        BtmImage.Canvas.StretchDraw(rect(Largeur-Arete+1,0,Largeur+1,fTailleCube+1),BtmFace);
        self.Left := self.Left + Decalage;
        Afficher;
      end;
    end;

    {Si clic côté gauche.}
    if (X<BorneBasse) and ((Y>BorneBasse) and (Y<BorneHaute)) then  begin
      fIndexFace := TabloRotation[fIndexFace,2] - 1;
      if (fVirtuel = true) then BtmSuivant.Assign(fTabloBtm[fIndexFace shr 2])
      else OrienterFaceSuivante; //On prépare la face qui va apparaître.
      for i := 1 to NbreImages do begin
        Calculer;
        Decalage := (self.Width - Largeur) div 2;
        BtmImage.Width := Largeur;
        BtmImage.Canvas.StretchDraw(rect(0,0,Arete+1,fTailleCube+1),BtmFace);
        BtmImage.Canvas.StretchDraw(rect(Arete+1,0,Largeur+1,fTailleCube+1),BtmSuivant);
        self.Left := self.Left + Decalage;
        Afficher;
      end;
    end;

    {Si clic côté bas.}
    if (Y>BorneHaute) and ((X>BorneBasse) and (X<BorneHaute)) then  begin
      fIndexFace := TabloRotation[fIndexFace,1] - 1;
      if (fVirtuel = true) then BtmSuivant.Assign(fTabloBtm[fIndexFace shr 2])
      else OrienterFaceSuivante; //On prépare la face qui va apparaître.
      for i := 1 to NbreImages do begin
        Calculer;
        Decalage := (self.Height - Largeur) div 2;
        BtmImage.Height := Largeur;
        BtmImage.Canvas.StretchDraw(rect(0,0,fTailleCube+1,Largeur-Arete+1),BtmSuivant);
        BtmImage.Canvas.StretchDraw(rect(0,Largeur-Arete+1,fTailleCube+1,Largeur+1),BtmFace);
        self.Top := self.Top + Decalage;
        Afficher;
      end;
    end;

    {Si clic côté haut.}
    if (Y<BorneBasse) and ((X>BorneBasse) and (X<BorneHaute)) then  begin
      {Tourne vers le haut => Face à apparaître = TabloRotation[fIndexFace,3].}
      fIndexFace := TabloRotation[fIndexFace,3] - 1;
      if (fVirtuel = true) then BtmSuivant.Assign(fTabloBtm[fIndexFace shr 2])
      else OrienterFaceSuivante; //On prépare la face qui va apparaître.
      for i := 1 to NbreImages do begin
        Calculer;
        Decalage := (self.Height - Largeur) div 2;
        BtmImage.Height := Largeur;
        BtmImage.Canvas.StretchDraw(rect(0,0,fTailleCube+1,Arete+1),BtmFace);
        BtmImage.Canvas.StretchDraw(rect(0,Arete+1,fTailleCube+1,Largeur+1),BtmSuivant);
        self.Top := self.Top + Decalage;
        Afficher;
      end;
    end;
    self.Picture.Bitmap.Assign(BtmSuivant);
  finally
    BtmImage.Free;
    BtmFace.Free;
    BtmSuivant.Free;
  end;
END;//PROCEDURE TSimpleCube.CubeMouseDown


END.

