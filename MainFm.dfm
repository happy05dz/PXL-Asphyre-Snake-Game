object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Snake Game'
  ClientHeight = 356
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object MainMenu1: TMainMenu
    Left = 24
    Top = 8
    object FileBtn: TMenuItem
      Caption = 'File'
      object NewBtn: TMenuItem
        Caption = 'New'
        Enabled = False
        OnClick = NewBtnClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object SoundBtn: TMenuItem
        Caption = 'Sound'
        object EnableSndBtn: TMenuItem
          Caption = 'Enable sound'
          OnClick = EnableSndBtnClick
        end
        object DisableSndBtn: TMenuItem
          Caption = 'Disable sound'
          OnClick = DisableSndBtnClick
        end
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object ExitBtn: TMenuItem
        Caption = 'Exit'
        OnClick = ExitBtnClick
      end
    end
    object LevelBtn: TMenuItem
      Caption = 'Level'
      object NewBtn1: TMenuItem
        Caption = 'New'
        Enabled = False
        OnClick = NewBtn1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object ImportBtn: TMenuItem
        Caption = 'Import'
        OnClick = ImportBtnClick
      end
      object ExportBtn: TMenuItem
        Caption = 'Export'
        Enabled = False
        OnClick = ExportBtnClick
      end
    end
    object HelpBtn: TMenuItem
      Caption = 'Help'
      object AboutBtn: TMenuItem
        Caption = 'About'
        ShortCut = 112
        OnClick = AboutBtnClick
      end
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'level'
    FileName = 'PXLSnake'
    Left = 24
    Top = 104
  end
  object OpenDialog1: TOpenDialog
    Left = 24
    Top = 56
  end
end
