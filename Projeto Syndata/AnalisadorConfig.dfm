object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Analisar Computador'
  ClientHeight = 645
  ClientWidth = 1085
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object pnlAnalisador: TPanel
    Left = 0
    Top = 0
    Width = 1085
    Height = 645
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 8
    object memResultado: TMemo
      Left = 168
      Top = 48
      Width = 665
      Height = 289
      Lines.Strings = (
        '')
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object btnAnalisadorIA: TButton
      Left = 408
      Top = 424
      Width = 153
      Height = 41
      Caption = 'Analisar com IA'
      TabOrder = 1
      OnClick = btnAnalisadorIAClick
    end
  end
  object RESTClient1: TRESTClient
    Params = <>
    SynchronizedEvents = False
    Left = 952
    Top = 48
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Params = <>
    Response = RESTResponse1
    SynchronizedEvents = False
    Left = 952
    Top = 104
  end
  object RESTResponse1: TRESTResponse
    Left = 960
    Top = 168
  end
end
