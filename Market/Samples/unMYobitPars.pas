unit unMYobitPars;

interface

uses
  System.SysUtils, System.StrUtils, System.DateUtils,
  unMarketTypes, unHFuncs1, unGlobals, unDataMod;

function CnclOrdPars(AResp: string): boolean;
procedure ActOrdsPars(AResp: string; var OOrder: TOrder);
procedure TradePars(AResp: string; var OOrder: TOrder);
procedure DepthPars(AResp: string; var OGlasses: TGlasses);
function InCoinSet(AName: string; ACoinSet: TCoins): integer;
procedure WalletsPars(AResp: string; var OCoins: TCoins);

implementation

function CnclOrdPars(AResp: string): boolean;
begin
  Result := True;

  if Pos('error', AResp) > 0 then
    Result := False;
end;

procedure ActOrdsPars(AResp: string; var OOrder: TOrder);
var
  pos1: integer;
  iTime: Int64;
  hStr: string;
begin
  if Pos('return', AResp) > 0 then
  begin
    pos1 := Pos('":{"', AResp);
    AResp := Copy(AResp, pos1 + 4, Length(AResp) - pos1 - 3);
    pos1 := Pos('"', AResp);
    OOrder.info.id := Copy(AResp, 1, pos1 - 1);

    pos1 := Pos('"type"', AResp);
    AResp := Copy(AResp, pos1 + 8, Length(AResp) - pos1 - 7);
    pos1 := Pos('"', AResp);
    hStr := Copy(AResp, 1, pos1 - 1);
    if hStr = 'sell' then
      OOrder.info.dir := True
    else
      OOrder.info.dir := False;

    pos1 := Pos('"amount"', AResp);
    AResp := Copy(AResp, pos1 + 9, Length(AResp) - pos1 - 8);
    pos1 := Pos(',"', AResp);
    hStr := Copy(AResp, 1, pos1 - 1);
    OOrder.info.amount := DCStrToDouble(hStr);

    pos1 := Pos('"rate"', AResp);
    AResp := Copy(AResp, pos1 + 7, Length(AResp) - pos1 - 6);
    pos1 := Pos(',"', AResp);
    hStr := Copy(AResp, 1, pos1 - 1);
    OOrder.info.rate := DCStrToDouble(hStr);

    pos1 := Pos('"timestamp_created"', AResp);
    AResp := Copy(AResp, pos1 + 21, Length(AResp) - pos1 - 20);
    pos1 := Pos('"', AResp);
    hStr := Copy(AResp, 1, pos1 - 1);
    iTime := hStr.ToInt64();
    OOrder.info.time := UnixToDateTime(iTime);
  end
  else
  begin
    OOrder.info.id := '';
    OOrder.info.amount := 0;
  end;
end;

procedure TradePars(AResp: string; var OOrder: TOrder);
var
  pos1: integer;
begin
  if Pos('return', AResp) > 0 then
  begin
    pos1 := Pos('_id', AResp);
    AResp := Copy(AResp, pos1+5, Length(AResp) - pos1 - 4);
    pos1 := Pos(',"', AResp);
    OOrder.info.id := Copy(AResp, 1, pos1-1);

    OOrder.info.time := Now;
  end
  else
    OOrder.info.id := 'wrong';
end;

procedure GlassArray(ADest: string; var OGlass: TGlass);
var
  rStr, qStr: string;
  pos1: integer;
  glsItem: TGlassItem;
begin
  SetLength(OGlass, 0);

  repeat
    pos1 := Pos('[', ADest);

    if pos1 > 0 then
    begin
      ADest := Copy(ADest, pos1+1, Length(ADest) - pos1);

      pos1 := Pos(']', ADest);
      rStr := Copy(ADest, 1, pos1 - 1);
      pos1 := Pos(',', rStr);
      qStr := Copy(rStr, pos1+1, Length(rStr) - pos1);
      rStr := Copy(rStr, 1, pos1 - 1);

      glsItem.rate := DCStrToDouble(rStr);
      glsItem.quant := DCStrToDouble(qStr);
      Insert(glsItem, OGlass, Length(OGlass));
    end;

  until pos1 = 0;

end;

procedure DepthPars(AResp: string; var OGlasses: TGlasses);
var
  pairGlasses: TPairGlasses;
  pos1: integer;
  gStr: string;
begin
  repeat
    pos1 := Pos('"', AResp);

    if pos1 > 0 then
    begin
      AResp := Copy(AResp, pos1 + 1, Length(AResp) - pos1);

      gStr := AResp[0];
      gStr := AResp[1];


      pos1 := Pos('"', AResp);
      pairGlasses.pair := Copy(AResp, 1, pos1 - 1);

      AResp := Copy(AResp, pos1+11, Length(AResp) - pos1 - 10);
      pos1 := Pos(']]', AResp);
      gStr := Copy(AResp, 1, pos1);
      GlassArray(gStr, pairGlasses.asks);

      AResp := Copy(AResp, pos1+11, Length(AResp) - pos1 - 10);
      pos1 := Pos(']]', AResp);
      gStr := Copy(AResp, 1, pos1);
      GlassArray(gStr, pairGlasses.bids);

      AResp := Copy(AResp, pos1, Length(AResp) - pos1 + 1);

      Insert(pairGlasses, OGlasses, Length(OGlasses));
    end;
  until pos1 = 0;
end;

function InCoinSet(AName: string; ACoinSet: TCoins): integer;
var
  i1: integer;
begin
  Result := -1;

  for i1 := 0 to Length(ACoinSet)-1 do
    if ACoinSet[i1].name = AName then
    begin
      Result := i1;
      Break
    end;
end;

procedure WalletsPars(AResp: string; var OCoins: TCoins);
var
  pos1, ind: integer;
  coin: TCoin;
  cName, qStr: string;
  cQuant: double;
begin
  pos1 := Pos('return', AResp);
  if pos1 > 0 then
  begin
    pos1 := Pos('funds_incl_orders', AResp);
    AResp := Copy(AResp, pos1+1, Length(AResp) - pos1);

    pos1 := Pos('{', AResp);
    AResp := Copy(AResp, pos1+1, Length(AResp) - pos1);

    pos1 := Pos('}', AResp);
    AResp := Copy(AResp, 1, pos1 - 1);

    repeat
      AResp := Copy(AResp, 2, Length(AResp) - 1);
      pos1 := Pos('"', AResp);
      if pos1 > 0 then
      begin
        cName := Copy(AResp, 1, pos1-1);
        AResp := Copy(AResp, pos1+2, Length(AResp) - pos1 - 1);

        pos1 := Pos(',"', AResp);
        if pos1 > 0 then
        begin
          qStr := Copy(AResp, 1, pos1-1);
          AResp := Copy(AResp, pos1+1, Length(AResp) - pos1);
        end
        else
          qStr := AResp;
        cQuant := DCStrToDouble(qStr);

        ind := InCoinSet(cName, OCoins);
        if ind > -1 then
          if OCoins[ind].quant <> cQuant then
          begin
            OCoins[ind].quant := cQuant;
            if OCoins[ind].max < OCoins[ind].quant then
              OCoins[ind].max := OCoins[ind].quant;

            dmMain.ModCoin(OCoins[ind]);
          end;
      end;
    until pos1 = 0;
  end;
end;

end.
