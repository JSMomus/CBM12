unit unGlobals;

interface

uses
  System.Classes;

const
  API_KEY: string = '5AEE0B726B3E0B837263EF89136252C5';
  API_SECRET: string = 'b8e96b5bedc7bcfb3c95121f109b18dc';
  BASE_URL: string = 'https://yobit.io/';
  PARAM_FILE: string = 'prm.txt';
  RATES_FILE: string = 'rts.txt';
  INFO_UPDATE_INTERVAL: integer = 1;

type
  TCoin = record
    index: integer;
    name: string;
    quant, max: double;
    active: boolean;
  end;

  TCoins = TArray<TCoin>;

  TOrdInfo = record
    id: string;
    amount, rate: double;
    dir: boolean;
    typ: string;
    time: TDateTime;
    excess: double;
    placed: boolean;
  end;

  TOrder = record
    pair: string;
    info: TOrdInfo;
  end;

  TOrderID = record
    coin1ID, coin2ID: integer;
    info: TOrdInfo;
  end;

var
  Cntr: integer;    //temp

  firstActivate: boolean;
  infoStr: TStringList;

implementation

initialization

  infoStr := TStringList.Create;

finalization

  infoStr.Free;

end.
