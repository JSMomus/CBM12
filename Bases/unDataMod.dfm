object dmMain: TdmMain
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 485
  Width = 365
  object FDConnection1: TFDConnection
    Params.Strings = (
      'POOL_MaximumItems=1000')
    Left = 40
    Top = 32
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 152
    Top = 32
  end
  object fdqAllCoins: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM tblCoins')
    Left = 48
    Top = 128
  end
  object fdqAddCoin: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'INSERT INTO tblCoins'
      '(cnInd, cnName, cnQuant, cnMax, cnActive)'
      'VALUES'
      '(:ind, :name, :quant, :max, :act)')
    Left = 48
    Top = 200
    ParamData = <
      item
        Name = 'IND'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'NAME'
        DataType = ftString
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'QUANT'
        DataType = ftFloat
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'MAX'
        DataType = ftFloat
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'ACT'
        DataType = ftBoolean
        ParamType = ptInput
        Value = Null
      end>
  end
  object fdqDelCoin: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'DELETE FROM tblCoins'
      'WHERE cnInd=:ind')
    Left = 48
    Top = 272
    ParamData = <
      item
        Name = 'IND'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object fdqModCoin: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'UPDATE tblCoins SET'
      'cnName=:name, '
      'cnQuant=:quant, '
      'cnMax=:max, '
      'cnActive=:act'
      'WHERE'
      'cnInd=:ind')
    Left = 48
    Top = 344
    ParamData = <
      item
        Name = 'NAME'
        DataType = ftString
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'QUANT'
        DataType = ftFloat
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'MAX'
        DataType = ftFloat
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'ACT'
        DataType = ftBoolean
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'IND'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object fdqAddOrd: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'INSERT INTO tblOrders'
      
        '(ordID, coinFrom, coinTo, ordAmount, ordRate, ordDir, ordType, o' +
        'rdTime)'
      'VALUES'
      '(:id, :cFrom, :cTo, :amnt, :rat, :dir, :typ, :time)')
    Left = 160
    Top = 200
    ParamData = <
      item
        Name = 'ID'
        DataType = ftString
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'CFROM'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'CTO'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'AMNT'
        DataType = ftFloat
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'RAT'
        DataType = ftFloat
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'DIR'
        DataType = ftBoolean
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'TYP'
        DataType = ftString
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'TIME'
        DataType = ftDateTime
        ParamType = ptInput
        Value = Null
      end>
  end
  object fdqDelOrd: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'DELETE FROM tblOrders'
      'WHERE ordID=:id')
    Left = 160
    Top = 272
    ParamData = <
      item
        Name = 'ID'
        DataType = ftString
        ParamType = ptInput
        Value = Null
      end>
  end
  object fdqAllOrders: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM tblOrders')
    Left = 160
    Top = 136
  end
  object fdqOrdInfo: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM tblOrders'
      'WHERE ordID=:id')
    Left = 232
    Top = 136
    ParamData = <
      item
        Name = 'ID'
        DataType = ftString
        ParamType = ptInput
        Value = Null
      end>
  end
end
