object RTestResource1: TRTestResource1
  Height = 300
  Width = 600
  object FDQueryI: TFDQuery
    Connection = FDConnection1
    Left = 216
    Top = 88
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=D:\5sh_Delphi\Seminar2023\3.RadServer\Server\stest.db')
    LoginPrompt = False
    Left = 104
    Top = 89
  end
end
