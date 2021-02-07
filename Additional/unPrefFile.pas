unit unPrefFile;

interface

uses
  System.IOUtils, System.SysUtils,
  unGlobals, unHFuncs1, unMYobit;

type
  TCommParams = record
    baseUrls: TArray<string>;
    buIndex: integer;
    depthLimit: integer;
    reqInt: integer;
    apiKey, apiSecret: string;
    tradeCoin: string;
    tradeMin: double;
    maxCoin: string;
    tradeMax: double;
    minPart: single;
    timedPart: boolean;
    dvt: single;
    expTime: integer;
    fee: double;
    cmre: double;
  end;

var
  CPG: TCommParams;

function ComposeParams(ACP: TCommParams): string;
procedure ParsParams(APrmString: string; var OCP: TCommParams);
procedure RewriteParams(AFileName: string; ACP:TCommParams);
function ReadParams(AFileName: string; var OCP:TCommParams): string;
procedure UpdateMarkParams(var AMarket: TYobit; AParams: TCommParams);

implementation

function ComposeParams(ACP: TCommParams): string;
var
  i1: integer;
begin
  for i1 := 0 to Length(ACP.baseUrls)-1 do
    Result := Result + ACP.baseUrls[i1] + ';';
  Result := Copy(Result, 1, Length(Result)-1);
  Result := Result + '*';
  Result := Result + ACP.buIndex.ToString + '*';
  Result := Result + ACP.depthLimit.ToString + '*';
  Result := Result + ACP.reqInt.ToString + '*';
  Result := Result + ACP.apiKey + '*';
  Result := Result + ACP.apiSecret + '*';
  Result := Result + ACP.tradeCoin + '*';
  Result := Result + ACP.tradeMin.ToString(ffFixed, 20, 8) + '*';
  Result := Result + ACP.maxCoin + '*';
  Result := Result + ACP.tradeMax.ToString(ffFixed, 20, 8) + '*';
  Result := Result + ACP.minPart.ToString(ffFixed, 20, 8) + '*';
  if ACP.timedPart then
    Result := Result + 't' + '*'
  else
    Result := Result + 'f' + '*';
  Result := Result + ACP.dvt.ToString(ffFixed, 20, 8) + '*';
  Result := Result + ACP.expTime.ToString + '*';
  Result := Result + ACP.fee.ToString(ffFixed, 10, 5) + '*';
  Result := Result + ACP.cmre.ToString(ffFixed, 10, 5);
end;

procedure ParsParams(APrmString: string; var OCP: TCommParams);
var
  pos1: integer;
  buStr, uStr, hStr: string;
begin
  try
    pos1 := Pos('*', APrmString);
    buStr := Copy(APrmString, 1, pos1-1);
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
    SetLength(OCP.baseUrls, 0);
    repeat
      pos1 := Pos(';', buStr);

      if pos1 > 0 then
      begin
        uStr := Copy(buStr, 1, pos1-1);
        buStr := Copy(buStr, pos1+1, Length(buStr) - pos1);
        Insert(uStr, OCP.baseUrls, Length(OCP.baseUrls));
      end
      else
      if Length(buStr) > 0 then
        Insert(buStr, OCP.baseUrls, Length(OCP.baseUrls));
    until pos1 = 0;

    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    OCP.buIndex := hStr.ToInteger();
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    SetLength(OCP.baseUrls, 0);
    Insert(BASE_URL, OCP.baseUrls, 0);

    OCP.buIndex := 0;
  end;

  try
    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    OCP.depthLimit := hStr.ToInteger();
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    OCP.depthLimit := 1;
  end;

  try
    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    OCP.reqInt := hStr.ToInteger();
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    OCP.reqInt := 20;
  end;

  try
    try
      pos1 := Pos('*', APrmString);
      OCP.apiKey := Copy(APrmString, 1, pos1-1);
      APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
    except
      OCP.apiKey := 'empty';
    end;
  finally
    if Trim(OCP.apiKey) = '' then
      OCP.apiKey := 'empty';
  end;

  try
    try
      pos1 := Pos('*', APrmString);
      OCP.apiSecret := Copy(APrmString, 1, pos1-1);
      APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
    except
      OCP.apiSecret := 'empty';
    end;
  finally
    if Trim(OCP.apiSecret) = '' then
      OCP.apiSecret := 'empty';
  end;

  try
    try
      pos1 := Pos('*', APrmString);
      OCP.tradeCoin := Copy(APrmString, 1, pos1-1);
      APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
    except
      OCP.tradeCoin := 'btc';
    end;
  finally
    if Trim(OCP.tradeCoin) = '' then
      OCP.tradeCoin := 'btc';
  end;

  try
    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    OCP.tradeMin := DCStrToDouble(hStr);
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    OCP.tradeMin := DCStrToDouble('0.0001');
  end;

  try
    try
      pos1 := Pos('*', APrmString);
      OCP.maxCoin := Copy(APrmString, 1, pos1-1);
      APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
    except
      OCP.maxCoin := 'usd';
    end;
  finally
    if Trim(OCP.maxCoin) = '' then
      OCP.tradeCoin := 'usd';
  end;

  try
    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    OCP.tradeMax := DCStrToDouble(hStr);
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    OCP.tradeMax := DCStrToDouble('1000');
  end;

  try
    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    OCP.minPart := DCStrToDouble(hStr);
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    OCP.minPart := DCStrToDouble('0.05');
  end;

  try
    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    if hStr = 't' then
      OCP.timedPart := True
    else
      OCP.timedPart := False;
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    OCP.timedPart := False;
  end;

  try
    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    OCP.dvt := DCStrToDouble(hStr);
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    OCP.dvt := DCStrToDouble('0.2');
  end;

  try
    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    OCP.expTime := hStr.ToInteger;
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    OCP.expTime := 72;
  end;

  try
    pos1 := Pos('*', APrmString);
    hStr := Copy(APrmString, 1, pos1-1);
    OCP.fee := DCStrToDouble(hStr);
    APrmString := Copy(APrmString, pos1+1, Length(APrmString) - pos1);
  except
    OCP.fee := DCStrToDouble('0.002');
  end;

  try
    OCP.cmre := DCStrToDouble(APrmString);
  except
    OCP.cmre := DCStrToDouble('1.0045');
  end;
end;

procedure RewriteParams(AFileName: string; ACP:TCommParams);
var
  prmStr: string;
begin
  prmStr := ComposeParams(ACP);
  TFile.WriteAllText(TPath.Combine(TPath.GetHomePath, AFileName), prmStr);
end;

function ReadParams(AFileName: string; var OCP:TCommParams): string;
var
  prmStr: string;
begin
  try
    if TFile.Exists(TPath.Combine(TPath.GetHomePath, AFileName)) then
      prmStr := TFile.ReadAllText(TPath.Combine(TPath.GetHomePath, AFileName));
  finally
    ParsParams(prmStr, OCP);
    Result := ComposeParams(OCP);
  end;
end;

procedure UpdateMarkParams(var AMarket: TYobit; AParams: TCommParams);
begin
  if Assigned(AMarket) then
  begin
    AMarket.BaseURL := AParams.baseUrls[AParams.buIndex];
    AMarket.Limit := AParams.depthLimit;
    AMarket.RequestInterval := AParams.reqInt;
    AMarket.ApiKey := AParams.apiKey;
    AMarket.ApiSecret := AParams.apiSecret;
    AMarket.MinTradeCoin := AParams.tradeCoin;
    AMarket.MinTrade := AParams.tradeMin;
    AMarket.MaxTradeCoin := AParams.maxCoin;
    AMarket.MaxTrade := AParams.tradeMax;
    AMarket.ExpireTime := AParams.expTime;
    AMarket.MinPart := AParams.minPart;
    AMarket.TimedPart := AParams.timedPart;
    AMarket.Deviation := AParams.dvt;
    AMarket.Fee := AParams.fee;
    AMarket.CMRExcess := AParams.cmre;
  end;
end;

end.
