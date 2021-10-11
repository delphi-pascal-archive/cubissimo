object FBao: TFBao
  Left = 291
  Top = 184
  Width = 811
  Height = 639
  Caption = 'Boite a outils'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Vimage: TImage
    Left = 9
    Top = 6
    Width = 615
    Height = 492
  end
  object Image1: TImage
    Left = 6
    Top = 505
    Width = 123
    Height = 98
  end
  object Image2: TImage
    Left = 139
    Top = 505
    Width = 123
    Height = 98
  end
  object Image3: TImage
    Left = 272
    Top = 505
    Width = 123
    Height = 98
  end
  object Image4: TImage
    Left = 405
    Top = 505
    Width = 123
    Height = 98
  end
  object Image5: TImage
    Left = 538
    Top = 505
    Width = 123
    Height = 98
  end
  object Image6: TImage
    Left = 671
    Top = 505
    Width = 123
    Height = 98
  end
  object GroupBox1: TGroupBox
    Left = 634
    Top = 6
    Width = 161
    Height = 112
    Caption = ' Image '
    TabOrder = 0
    object Bt_Oui: TButton
      Left = 14
      Top = 64
      Width = 61
      Height = 31
      Caption = 'OUI'
      TabOrder = 0
      OnClick = Bt_OuiClick
    end
    object Bt_Non: TButton
      Left = 87
      Top = 64
      Width = 62
      Height = 31
      Caption = 'NON'
      TabOrder = 1
      OnClick = Bt_NonClick
    end
    object Bt_Charger: TButton
      Left = 12
      Top = 25
      Width = 137
      Height = 30
      Caption = 'CHARGER'
      TabOrder = 2
      OnClick = Bt_ChargerClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 634
    Top = 388
    Width = 161
    Height = 112
    Caption = ' Groupe d'#39'images '
    TabOrder = 1
    object Bt_Enregistrer: TButton
      Left = 12
      Top = 25
      Width = 137
      Height = 30
      Caption = 'ENREGISTRER'
      ModalResult = 1
      TabOrder = 0
      OnClick = Bt_EnregistrerClick
    end
    object Bt_Abandon: TButton
      Left = 12
      Top = 68
      Width = 137
      Height = 30
      Caption = 'ABANDONNER'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object OPDlg: TOpenPictureDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 15
    Top = 10
  end
  object SDlg: TSaveDialog
    Filter = 'Images|*.flx'
    Left = 50
    Top = 10
  end
end
