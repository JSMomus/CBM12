unit unMYobit;

interface

uses
  System.SysUtils, System.Hash,
  REST.Client, REST.Types,
  unMarketBase, unMarketTypes, unMYobitPars, unHFuncs1, unGlobals;

type
  TYobit = class(TMarketBase)
  private
    procedure CombPairs;  override;
    procedure GetGlasses; override;
    function GetPair(AName1, AName2: string; AForw: boolean = True): string;  override;
    procedure GetFunds; override;
    procedure SetOrder(var AOrder: TOrder); override;
    procedure ActiveOrder(var AOrder: TOrder); override;
    procedure CancelOrder(AOrdID: string); override;
    function PairCoin(APair: string; AFirst: boolean = True): string; override;
    procedure ConvertOrder(AOrder: TOrder; var OOrderID: TOrderID); override;

    procedure ReqDepth(APairs: string);
  public
    //
  end;

var
  mrkYobit: TYobit;

implementation

{ TYobit }

procedure TYobit.ActiveOrder(var AOrder: TOrder);
var
  sign, resp: string;
  sucs: boolean;
  pos1: integer;
begin
  FRESTRequest.Resource := 'tapi/';

  FRESTRequest.Method := TRESTRequestMethod.rmPOST;

  try
    sucs := False;
    repeat
      try
        FRESTRequest.Params.Clear;
        FRESTRequest.AddParameter('method', 'ActiveOrders');
        FRESTRequest.AddParameter('pair', AOrder.pair);
        FRESTRequest.AddParameter('nonce', Nonce);

        FRESTRequest.Params.AddHeader('Key', FApiKey);
        sign := 'method=ActiveOrders&pair=' + AOrder.pair + '&nonce=' + Nonce;
        sign := THashSHA2.GetHMAC(sign, FApiSec, THashSHA2.TSHA2Version.SHA512);
        FRESTRequest.Params.AddHeader('Sign', sign);

        FRESTRequest.Execute;
        sucs := True;
      except
        on E: Exception do
        begin
          FErrStr := E.Message;
          WaitAfterRequest;
        end;
      end;
    until sucs;
  finally
    resp :=  FRESTRequest.Response.Content;
    AOrder.info.typ := resp;

    pos1 := Pos('error', resp);
    if pos1 > 0 then
    begin
      resp := Copy(resp, pos1 + 8, Length(resp) - pos1 - 7);
      pos1 := Pos('"}', resp);
      FErrStr := Copy(resp, 1, pos1 - 1);
    end
    else
    begin
      FErrStr := '';

      ActOrdsPars(resp, AOrder);
    end;
  end;
end;

procedure TYobit.CancelOrder(AOrdID: string);
var
  sign, resp: string;
  sucs: boolean;
  pos1: integer;
begin
  FBugStr := 'In cancel order';

  FRESTRequest.Resource := 'tapi/';

  try
    sucs := False;
    repeat
      try
        FRESTRequest.Params.Clear;
        FRESTRequest.AddParameter('method', 'CancelOrder');
        FRESTRequest.AddParameter('order_id', AOrdID);
        FRESTRequest.AddParameter('nonce', Nonce);

        FRESTRequest.Params.AddHeader('Key', FApiKey);
        sign := 'method=CancelOrder&order_id=' + AOrdID + '&nonce=' + Nonce;
        sign := THashSHA2.GetHMAC(sign, FApiSec, THashSHA2.TSHA2Version.SHA512);
        FRESTRequest.Params.AddHeader('Sign', sign);

        FRESTRequest.Method := TRESTRequestMethod.rmPOST;

        FRESTRequest.Execute;
        sucs := True;
      except
        on E: Exception do
        begin
          FErrStr := E.Message;
          WaitAfterRequest;
        end;
      end;
    until sucs;
  finally
    resp :=  FRESTRequest.Response.Content;
    pos1 := Pos('error', resp);
    if pos1 > 0 then
    begin
      resp := Copy(resp, pos1 + 8, Length(resp) - pos1 - 7);
      pos1 := Pos('"}', resp);
      FErrStr := Copy(resp, 1, pos1 - 1);
    end
    else
    begin
      CnclOrdPars(resp);
      FErrStr := '';
    end;
  end;

  FBugStr := '';
end;

procedure TYobit.CombPairs;
var
  i1, i2: integer;
  pair: string;
begin
  SetLength(FPairs, 0);

  for i1 := 0 to Length(FCoinsExt)-1 do
    for i2 := 0 to Length(FCoinsExt)-1 do
    if i1 <> i2 then
      begin
        pair := FCoinsExt[i1].name + '_' + FCoinsExt[i2].name;
        Insert(pair, FPairs, Length(FPairs));
      end;
end;

procedure TYobit.GetGlasses;
var
  i1, iStart, iEnd: integer;
  pairEnd: boolean;
  pairStr: string;
begin
  SetLength(FGlasses, 0);

  iStart := 0;
  pairEnd := False;
  if Length(FPairs) > 0 then
    repeat
      if iStart < Length(FPairs) then
      begin
        iEnd := iStart + 9;
        if iEnd > Length(FPairs)-1 then
          iEnd := Length(FPairs)-1;

        pairStr := FPairs[iStart];
        for i1 := iStart+1 to iEnd do
          pairStr := pairStr + '-' + FPairs[i1];

        ReqDepth(pairStr);

        iStart := iEnd + 1;
      end
      else
        pairEnd := True;
    until pairEnd;
end;

function TYobit.GetPair(AName1, AName2: string; AForw: boolean): string;
begin
  if AForw then
    Result := AName1 + '_' + AName2
  else
    Result := AName2 + '_' + AName1;
end;

procedure TYobit.GetFunds;
var
  resp, sign: string;
  sucs: boolean;
  pos1: integer;
begin
  FRESTRequest.Resource := 'tapi/';

  try
    sucs := False;
    repeat
      try
        FRESTRequest.Params.Clear;
        FRESTRequest.AddParameter('method', 'getInfo');
        FRESTRequest.AddParameter('nonce', Nonce);

        FRESTRequest.Params.AddHeader('Key', FApiKey);
        sign := 'method=getInfo&nonce=' + Nonce;
        sign := THashSHA2.GetHMAC(sign, FApiSec, THashSHA2.TSHA2Version.SHA512);
        FRESTRequest.Params.AddHeader('Sign', sign);

        FRESTRequest.Method := TRESTRequestMethod.rmPOST;

        FRESTRequest.Execute;
        sucs := True;
      except
        on E: Exception do
        begin
          FErrStr := E.Message;
          WaitAfterRequest;
        end;
      end;
    until sucs;
  finally
    resp :=  FRESTRequest.Response.Content;
    pos1 := Pos('error', resp);
    if pos1 > 0 then
    begin
      resp := Copy(resp, pos1 + 8, Length(resp) - pos1 - 7);
      pos1 := Pos('"}', resp);
      FErrStr := Copy(resp, 1, pos1 - 1);
    end
    else
    begin
      FErrStr := '';

      WalletsPars(resp, FCoins);
      WalletsPars(resp, FCoinsExt);
    end;
  end;
end;

function TYobit.PairCoin(APair: string; AFirst: boolean): string;
var
  dlmPos: integer;
begin
  dlmPos := Pos('_', APair);

  if dlmPos <= 0 then
    Result := ''
  else
    if AFirst then
      Result := Copy(APair, 1, dlmPos - 1)
    else
      Result := Copy(APair, dlmPos + 1, Length(APair) - dlmPos);
end;

procedure TYobit.ReqDepth(APairs: string);
var
  resp: string;
  sucs: boolean;
  pos1: integer;
begin
  sucs := False;
  repeat
    try
      FRESTRequest.Resource := 'api/3/depth/' + APairs +
          '?ignore_invalid=1&limit=' + FLimit.ToString;
      FRESTRequest.Method := TRESTRequestMethod.rmGET;
      FRESTRequest.Execute;
      resp :=  FRESTRequest.Response.Content;

      pos1 := Pos('error', resp);
      if pos1 > 0 then
      begin
        resp := Copy(resp, pos1 + 8, Length(resp) - pos1 - 7);
        pos1 := Pos('"}', resp);
        FErrStr := Copy(resp, 1, pos1 - 1);
      end
      else
      begin
        FErrStr := '';

        DepthPars(resp, FGlasses);
      end;

      sucs := True;
    except
      on E: Exception do
      begin
        FErrStr := E.Message;
        WaitAfterRequest;
      end;
    end;
  until sucs;
end;

procedure TYobit.ConvertOrder(AOrder: TOrder; var OOrderID: TOrderID);
var
  coin1, coin2: string;
  coinInd1, coinInd2: integer;
  rightOrd: boolean;
begin
  FBugStr := 'In order converting';

  coin1 := PairCoin(AOrder.pair);
  coin2 := PairCoin(AOrder.pair, False);

  coinInd1 := InCoins(coin1, FCoins);
  if coinInd1 > -1 then
    OOrderId.coin1ID := FCoins[coinInd1].index;

  coinInd2 := InCoins(coin2, FCoins);
  if coinInd2 > -1 then
    OOrderId.coin2ID := FCoins[coinInd2].index;

  rightOrd := True;
  if (coinInd1 = -1) or (coinInd2 = -1) then
    rightOrd := False;

  if rightOrd then
    OOrderID.info := AOrder.info
  else
    OOrderID.info.id := 'wrong';

  FBugStr := '';
end;

procedure TYobit.SetOrder(var AOrder: TOrder);
var
  ordType, sign, resp: string;
  sucs: boolean;
  pos1: integer;
begin
  FRESTRequest.Resource := 'tapi/';

  try
    sucs := False;
    repeat
      try
        FRESTRequest.Params.Clear;
        FRESTRequest.AddParameter('method', 'Trade');
        FRESTRequest.AddParameter('pair', AOrder.pair);
        if AOrder.info.dir then
          ordType := 'sell'
        else
          ordType := 'buy';
        FRESTRequest.AddParameter('type', ordType);
        FRESTRequest.AddParameter('rate', DoubleToDStr(AOrder.info.rate, 20, 8));
        FRESTRequest.AddParameter('amount', DoubleToDStr(AOrder.info.amount, 20, 8));
        FRESTRequest.AddParameter('nonce', Nonce);

        FRESTRequest.Params.AddHeader('Key', FApiKey);
        sign := 'method=Trade&pair=' + AOrder.pair +
            '&type=' + ordType +
            '&rate=' + DoubleToDStr(AOrder.info.rate, 20, 8) +
            '&amount=' + DoubleToDStr(AOrder.info.amount, 20, 8) +
            '&nonce=' + Nonce;
        sign := THashSHA2.GetHMAC(sign, FApiSec, THashSHA2.TSHA2Version.SHA512);
        FRESTRequest.Params.AddHeader('Sign', sign);

        FRESTRequest.Method := TRESTRequestMethod.rmPOST;

        FRESTRequest.Execute;
        sucs := True;
        FOrderChanged := True;
      except
        on E: Exception do
        begin
          FErrStr := E.Message;
          WaitAfterRequest;
        end;
      end;
    until sucs;
  finally
    resp :=  FRESTRequest.Response.Content;
    pos1 := Pos('error', resp);
    if pos1 > 0 then
    begin
      resp := Copy(resp, pos1 + 8, Length(resp) - pos1 - 7);
      pos1 := Pos('"}', resp);
      FErrStr := Copy(resp, 1, pos1 - 1);
    end
    else
    begin
      FErrStr := '';

      TradePars(resp, AOrder);
    end;
  end;
end;

end.
