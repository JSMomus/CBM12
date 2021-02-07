unit unMarketBase;

interface

uses
  System.Net.HttpClient, System.SysUtils, System.Generics.Collections,
  FMX.Dialogs,
  REST.Client,
  unGlobals, unDataMod, unMarketTypes, unRateFuncs, unHFuncs1, unGenFuncs;

type
  TMarketBase = class
  private
    FBaseCoins: TArray<string>;
    FCoinsCtrl: TCoins;
    FCoinsFirstLoad: boolean;
    FMinTrade: double;
    FMTCoin: string;
    FMaxTrade: double;
    FMaxTC: string;
    FCMR: double;
    FCMRExt: double;
    FFee: single;
    FCMRExcess: double;
    FTimedPart: boolean;
    FDeviation: single;
    FRun: boolean;
    FMaxExcess: double;
    FMEPair: string;
    FMERise: double;
    FMERPair: string;
    FMEFall: double;
    FMEFPair: string;
    FQuantToBTC: double;
    FQuantToUSD: double;
    FOrdUpdCount: integer;

    function PairInGlasses(APair: string): integer;
    function RateCTCDirect(ACName1, ACName2: string): double;
    function RateCTC(ACName1, ACName2: string): double;
    function AmountCTC(ACName1, ACName2: string): double;

    procedure LoadCoins; //loading coins from db
    procedure UpdCtrlCoins;
    procedure CheckCoinsCtrl;
    function TotalToCoin(ACName: string): double;
    function OrderBK(AOrder: TOrder): TBookKind;
    function OrderPart(AOrder: TOrder): single;
    function OrderDvt(AOrder: TOrder): single;
    procedure GetMaxExcess(meKind: TBookKind); overload;
    procedure GetMaxExcess; overload;
    function CommCMR(ACoins: TCoins): double;
    function NewCMR(AOrder: TOrder): double;
    function OrderCond(ARate: TRate): boolean; overload;
    function OrderCond(AOrder: TOrder): boolean; overload;
    function OrderCondFR(APair: string): boolean;
    procedure SaveOrder(AOrder: TOrder);
    procedure CheckSetOrders;
    procedure SortOrdersByExc(var AOrders: TList<TOrder>);
    procedure PickOrdersByBK(AOrders: TList<TOrder>;
              var OOrders: TList<TOrder>; bookKind: TBookKind);
    function CheckForSameOrder(AOrder: TOrder; AOrders: TList<TOrder>): boolean;
    procedure SetOrders(FallRise: boolean = False);
    procedure GetOTP(FallRise: boolean = False);      //OTP = orders to place
    procedure FitOrders;
    procedure UpdRates;
    procedure CulcCMR;

    procedure set_base_url(const Value: string);
    procedure set_limit(const Value: integer);
    procedure set_req_int(const Value: integer);
    procedure set_akey(const Value: string);
    procedure set_secret(const Value: string);
    procedure set_min_trade(const Value: double);
    procedure set_exp_time(const Value: integer);
    procedure set_minTC(const Value: string);
    procedure set_min_prt(const Value: single);
    procedure set_max_trade(const Value: double);
    procedure set_maxTC(const Value: string);
    procedure set_excess(const Value: double);
    procedure set_fee(const Value: single);
    procedure set_run(const Value: boolean);
    procedure set_fri(const Value: cardinal);
    procedure set_timed_part(const Value: boolean);
    procedure set_dvt(const Value: single);
    procedure set_cfl(const Value: boolean);
    procedure set_inf_str(const Value: string);
  protected
    FRESTClient: TRESTClient;
    FRESTRequest: TRESTRequest;
    FFRI: cardinal;     //Fast request interval

    FReqInt: integer;      //in seconds
    FLimit: integer;
    FApiKey: string;
    FApiSec: string;
    FExpTime: integer;    //in hours
    FExpTimeD: double;
    FMinPart: single;

    FCoins: TCoins;
    FCoinsExt: TCoins;
    FPairs: TArray<string>;
    FGlasses: TGlasses;
    FOrders: TList<TOrder>;
    FOrdersToPlace: TList<TOrder>;
    FRiseOrders: TList<TOrder>;
    FFallOrders: TList<TOrder>;
    FRates: TRates;
    FOrderCount: integer;
    FOrderChanged: boolean;

    FErrStr: string;
    FInfoStr: string;
    FRunIndic: cardinal;

    FBugStr: string;    //tmp

    function IncIndic: string;
    procedure WaitAfterRequest;

    function InCoins(AName: string; ACoins: TArray<string>): integer; overload;
    function InCoins(AName: string; ACoins: TCoins): integer; overload;

    procedure CombPairs; virtual; abstract;
    procedure GetGlasses; virtual; abstract;
    function GetPair(AName1, AName2: string; AForw: boolean = True): string;
                                            virtual; abstract;
    procedure GetFunds; virtual; abstract;
    procedure SetOrder(var AOrder: TOrder); virtual; abstract;
    procedure ActiveOrder(var AOrder: TOrder); virtual; abstract;
    procedure CancelOrder(AOrdID: string); virtual; abstract;
    function PairCoin(APair: string; AFirst: boolean = True): string;
                                            virtual; abstract;
    procedure ConvertOrder(AOrder: TOrder; var OOrderID: TOrderID);
                                            virtual; abstract;
  public
    constructor Create; overload;
    constructor Create(ABaseURL: string); overload;
    destructor Destroy; override;

    procedure UpdCoins;
    procedure UpdCG;      //Coins and glasses
    procedure EqualMaxes;
    procedure UpdSetOrders;
    procedure OrdersCircle;
    function OrdersByPeriod(ATime: double): integer;

    property BaseURL: string write set_base_url;
    property MinTrade: double read FMinTrade write set_min_trade;
    property MinTradeCoin: string read FMTCoin write set_minTC;
    property MaxTrade: double read FMaxTrade write set_max_trade;
    property MaxTradeCoin: string read FMaxTC write set_maxTC;
    property Limit: integer read FLimit write set_limit;
    property ExpireTime: integer read FExpTime write set_exp_time;
    property MinPart: single read FMinPart write set_min_prt;
    property RequestInterval: integer read FReqInt write set_req_int;
    property TimedPart: boolean read FTimedPart write set_timed_part;
    property Deviation: single read FDeviation write set_dvt;
    property ApiKey: string read FApiKey write set_akey;
    property ApiSecret: string read FApiSec write set_secret;
    property CoinsFirstLoad: boolean write set_cfl;
    property CMRelation: double read FCMR;
    property ErrorString: string read FErrStr;
    property InfoString: string read FInfoStr write set_inf_str;
    property OrderCount: integer read FOrderCount;
    property Fee: single read FFee write set_fee;
    property CMRExcess: double read FCMRExcess write set_excess;
    property Run: boolean read FRun write set_run;
    property MaxExcess: double read FMaxExcess;
    property MEPair: string read FMEPair;
    property MERise: double read FMERise;
    property MERPair: string read FMERPair;
    property MEFall: double read FMEFall;
    property MEFPair: string read FMEFPair;
    property QuantToBTC: double read FQuantToBTC;
    property QuantToUSD: double read FQuantToUSD;
    property FastRequestInterval: cardinal read FFRI write set_fri;
    property BugString: string read FBugStr;
  end;

implementation

{ TMarketBase }

function TMarketBase.AmountCTC(ACName1, ACName2: string): double;
var
  cInd1, cInd2: integer;
begin
  cInd1 := InCoins(ACName1, FCoinsExt);
  cInd2 := InCoins(ACName2, FCoinsExt);
  if (cInd1 <> -1) and (cInd2 <> -1) then
    Result := FCoinsExt[cInd1].quant * RateCTC(FCoinsExt[cInd1].name, ACName2)
  else
    Result := 0;
end;

constructor TMarketBase.Create;
begin
  FRESTClient := TRESTClient.Create(nil);
  FRESTRequest := TRESTRequest.Create(FRESTClient);
  FRESTClient.SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12];
  FRESTRequest.Client := FRESTClient;

  SetLength(FBaseCoins, 2);
  FBaseCoins[0] := 'btc';
  FBaseCoins[1] := 'usd';

  FOrders := TList<TOrder>.Create;
  FOrderCount := 0;
  FOrdersToPlace := TList<TOrder>.Create;
  FRiseOrders := TList<TOrder>.Create;
  FFallOrders := TList<TOrder>.Create;

  FCoinsFirstLoad := True;
  FOrderChanged := True;
  FMinTrade := 0.0001;
  FMTCoin := 'btc';
  FMaxTrade := 1000;
  FMaxTC := 'usd';
  FFee := 0.002;
  FCMRExcess := 1.005;
  FReqInt := 10;      //in seconds
  FLimit := 1;
  FExpTime := 72;    //in hours
  FMinPart := 0.06;
  FFRI := 1000;
  FTimedPart := False;
  FDeviation := 0.2;

  FMaxExcess := 0;
  FMEPair := 'N/P';
  FMERise := 0;
  FMERPair := 'N/P';
  FMEFall := 0;
  FMEFPair := 'N/P';
  FRun := False;
  FRunIndic := 0;
  FOrdUpdCount := 0;

  FErrStr := '';
  FInfoStr := '';
  FBugStr := '';
end;

function TMarketBase.CheckForSameOrder(AOrder: TOrder;
  AOrders: TList<TOrder>): boolean;
var
  i1: integer;
begin
  Result := False;

  for i1 := 0 to AOrders.Count - 1 do
    if  (AOrder.pair = AOrders.Items[i1].pair) and
        (AOrder.info.amount = AOrders.Items[i1].info.amount) and
        (AOrder.info.rate = AOrders.Items[i1].info.rate) and
        (AOrder.info.dir = AOrders.Items[i1].info.dir) then
    begin
      Result := True;
      Break
    end;
end;

procedure TMarketBase.CheckSetOrders;
var
  i1: integer;
  order: TOrder;
begin
  for i1 := 0 to FOrders.Count - 1 do
  begin
    order.info.id := '';
    order.pair := FOrders.Items[i1].pair;
    FInfoStr := 'Checking orders for ' +
                FOrders.Items[i1].pair + ' ' + IncIndic;

    repeat
      ActiveOrder(order);

      if order.info.id = '' then
        SaveOrder(FOrders.Items[i1])
      else
      begin
        if order.info.amount <> FOrders.Items[i1].info.amount then
        begin
          order.info.amount := FOrders.Items[i1].info.amount - order.info.amount;
          SaveOrder(order);
        end;

        CancelOrder(order.info.id);
      end;

      FBugStr := 'Order id: ' + order.info.id;
    until order.info.id = '';
    FBugStr := '';

    Sleep(FFRI);
  end;

  FOrders.Clear;
  FOrderCount := 0;
end;

procedure TMarketBase.CheckCoinsCtrl;
var
  i1: integer;
begin
  if Length(FCoinsExt) = Length(FCoinsCtrl) then
  begin
    for i1 := 0 to Length(FCoinsExt) - 1  do
      if FCoinsExt[i1].name <> FCoinsCtrl[i1].name then
      begin
        FCoinsExt[i1].name := FCoinsCtrl[i1].name;
        dmMain.ModCoin(FCoinsExt[i1]);
      end;
  end
  else
    FErrStr := 'Control coins corrupted.';
end;

function TMarketBase.CommCMR(ACoins: TCoins): double;
var
  i1: integer;
begin
  Result := 0;
  for i1 := 0 to Length(ACoins)-1 do
    if ACoins[i1].max = 0 then
    begin
      ACoins[i1].max := ACoins[i1].quant;
      Result := Result + 1;
    end
    else
      Result := Result + ACoins[i1].quant/ACoins[i1].max;
end;

procedure TMarketBase.UpdSetOrders;
var
  i1: integer;
  order: TOrder;
begin
  FOrders.Clear;
  GetGlasses;

  for i1 := 0 to Length(FGlasses)-1 do
  begin
    order.pair := FGlasses[i1].pair;
    FInfoStr := 'Checking orders for ' + order.pair + ' ' + IncIndic;
    order.info.id := '';
    ActiveOrder(order);

    if order.info.id <> '' then
    begin
      order.info.excess := 0;
      order.info.placed := True;
      FOrders.Insert(FOrders.Count, order);
      FOrderCount := FOrders.Count;
    end;

    Sleep(FFRI);
  end;
end;

constructor TMarketBase.Create(ABaseURL: string);
begin
  Create;

  set_base_url(ABaseURL);
end;

procedure TMarketBase.CulcCMR;
begin
  FCMR := CommCMR(FCoins);
  FCMRExt := CommCMR(FCoinsExt);
end;

destructor TMarketBase.Destroy;
begin
  FRESTClient.Free;

  FOrders.Free;
  FOrdersToPlace.Free;
  FRiseOrders.Free;
  FFallOrders.Free;

  inherited;
end;

procedure TMarketBase.EqualMaxes;
var
  i1, mInd: integer;
  maxBTC, hBTC: double;
begin
  UpdCoins;
  GetGlasses;

  mInd := 0;
  maxBTC := 0;
  for i1 := 0 to Length(FCoinsExt)-1 do
  begin
    if FCoinsExt[i1].name = 'btc' then
      hBTC := FCoinsExt[i1].quant
    else
      hBTC := FCoinsExt[i1].quant*RateCTC(FCoinsExt[i1].name, 'btc');

    if maxBTC < hBTC then
    begin
      maxBTC := hBTC;
      mInd := i1;
    end;
  end;

  FCoinsExt[mInd].max := FCoinsExt[mInd].quant;
  for i1 := 0 to Length(FCoinsExt)-1 do
  begin
    if i1 <> mInd then
      FCoinsExt[i1].max := FCoinsExt[mInd].quant*
      RateCTC(FCoinsExt[mInd].name, FCoinsExt[i1].name);

    dmMain.ModCoin(FCoinsExt[i1]);
  end;

  CulcCMR;
end;

procedure TMarketBase.FitOrders;
var
  tmpOrds, coinOrds: TList<TOrder>;
  i1, i2, lastInd: integer;
  coinTot: double;
  coinExp: boolean;
  curCoin, coin1, coin2: string;
begin
  tmpOrds := TList<TOrder>.Create;
  for i1 := 0 to FFallOrders.Count - 1 do
    tmpOrds.Insert(tmpOrds.Count, FFallOrders.Items[i1]);
  FOrdersToPlace.Clear;

  coinOrds := TList<TOrder>.Create;
  for i1 := 0 to Length(FCoins) - 1 do
  begin
    coinOrds.Clear;
    curCoin := FCoins[i1].name;

    for i2 := 0 to tmpOrds.Count - 1 do
    begin
      coin1 := PairCoin(tmpOrds[i2].pair);
      coin2 := PairCoin(tmpOrds[i2].pair, False);
      if  ((coin1 = curCoin) and tmpOrds[i2].info.dir) or
          ((coin2 = curCoin) and (not tmpOrds[i2].info.dir))
      then
        if not CheckForSameOrder(tmpOrds[i2], coinOrds) then
          coinOrds.Insert(0, tmpOrds.Items[i2]);
    end;
    SortOrdersByExc(coinOrds);

    i2 := 0;
    coinTot := 0;
    coinExp := False;
    repeat
      if i2 >= coinOrds.Count - 1 then
        coinExp := True
      else
      begin
        if coinOrds.Items[i2].info.dir then
          coinTot := coinTot + coinOrds.Items[i2].info.amount
        else
          coinTot := coinTot + DblRoundUp(
              coinOrds.Items[i2].info.amount * coinOrds[i2].info.rate, 7);

        if coinTot <= FCoins[i1].quant then
          i2 := i2 + 1
        else
          coinExp := True;
      end;
    until coinExp;
    lastInd := i2;

    for i2 := 0 to lastInd - 1 do
      FOrdersToPlace.Insert(FOrdersToPlace.Count, coinOrds.Items[i2]);

  end;
  coinOrds.Free;

  tmpOrds.Free;
end;

procedure TMarketBase.GetMaxExcess(meKind: TBookKind);
var
  i1, ordInd: integer;
  prm, maxExc: double;
  mxePair: string;
  tmpOrders: TList<TOrder>;
begin
  tmpOrders := TList<TOrder>.Create;
  case meKind of
    bkRise:
      begin
        for i1 := 0 to FRiseOrders.Count - 1 do
          tmpOrders.Insert(tmpOrders.Count, FRiseOrders.Items[i1]);
      end;
    bkFall:
      begin
        for i1 := 0 to FFallOrders.Count - 1 do
          tmpOrders.Insert(tmpOrders.Count, FFallOrders.Items[i1]);
      end;
    bkLine:
      begin
        for i1 := 0 to FOrdersToPlace.Count - 1 do
          tmpOrders.Insert(tmpOrders.Count, FOrdersToPlace.Items[i1]);
      end;
  end;

  if tmpOrders.Count = 0 then
  begin
    maxExc := 0;
    mxePair := 'N/P';
  end
  else
  begin
    maxExc := tmpOrders.Items[0].info.excess;
    mxePair := tmpOrders.Items[0].pair;
    ordInd := 0;
    for i1 := 1 to tmpOrders.Count - 1 do
      if maxExc < tmpOrders.Items[i1].info.excess then
        ordInd := i1;

    maxExc := tmpOrders.Items[ordInd].info.excess;
    mxePair := tmpOrders.Items[ordInd].pair + '/';
    if tmpOrders.Items[ordInd].info.dir then
      mxePair := mxePair + 'f'
    else
      mxePair := mxePair + 'b';
    mxePair := mxePair + #13#10;

    prm := OrderPart(tmpOrders.Items[ordInd]);
    mxePair := mxePair + 'prt_' + prm.ToString(ffFixed, 10, 4);
    if FTimedPart then
      mxePair := mxePair + 't';
    mxePair := mxePair + #13#10;

    prm := OrderDvt(tmpOrders.Items[ordInd]);
    mxePair := mxePair + 'dvt_' + prm.ToString(ffFixed, 10, 4);
    mxePair := mxePair + #13#10;

    prm := tmpOrders.Items[ordInd].info.rate;
    mxePair := mxePair + 'rate_' + prm.ToString(ffFixed, 20, 8);
  end;

  case meKind of
    bkRise:
      begin
        FMERise := maxExc;
        FMERPair := mxePair;
      end;
    bkFall:
      begin
        FMEFall := maxExc;
        FMEFPair := mxePair;
      end;
    bkLine:
      begin
        FMaxExcess := maxExc;
        FMEPair := mxePair;
      end;
  end;

  tmpOrders.Free;
end;

procedure TMarketBase.GetMaxExcess;
var
  i1: integer;
begin
  GetMaxExcess(bkLine);
  GetMaxExcess(bkRise);
  GetMaxExcess(bkFall);
end;

procedure TMarketBase.GetOTP(FallRise: boolean = False);  //OTP = orders to place
var
  i1, cInd1, cInd2: integer;
  relAmnt1, relAmnt2, amnt1, amnt2, tmpCMR: double;
  coin1, coin2: string;
  order: TOrder;
  ordCnd: boolean;
begin
  UpdRates;

  FOrdersToPlace := TList<TOrder>.Create;
  for i1 := 0 to Length(FRates) - 1 do
  begin
    if FallRise then
      ordCnd := OrderCondFR(FRates[i1].pair)
    else
      ordCnd := OrderCond(FRates[i1]);

    if ordCnd then
    begin
      coin1 := PairCoin(FRates[i1].pair);
      coin2 := PairCoin(FRates[i1].pair, False);
      cInd1 := InCoins(coin1, FCoins);
      cInd2 := InCoins(coin2, FCoins);

      if (cInd1 <> -1) and (cInd2 <> -1) then
      begin
        relAmnt1 := AmountCTC(coin1, FMTCoin);
        relAmnt2 := AmountCTC(coin2, FMTCoin);

        order.pair := FRates[i1].pair;
        order.info.placed := False;

        if relAmnt1 > FMinTrade then
        begin
          amnt1 := AmountCTC(coin1, FMaxTC);
          if amnt1 > FMaxTrade then
            order.info.amount := FMaxTrade * RateCTC(FMaxTC, coin1)
          else
            order.info.amount := FCoins[cInd1].quant;

          order.info.rate := FRates[i1].fRate;
          order.info.dir := True;

          tmpCMR := NewCMR(order);
          order.info.excess := tmpCMR/FCMR;

          FOrdersToPlace.Insert(FOrdersToPlace.Count, order);
        end;

        if relAmnt2 > FMinTrade then
        begin
          amnt2 := AmountCTC(coin2, FMaxTC);
          if amnt2 > FMaxTrade then
            order.info.amount := FMaxTrade * RateCTC(FMaxTC, coin2)
          else
            order.info.amount := FCoins[cInd2].quant;

          order.info.rate := FRates[i1].bRate;
          order.info.amount := DblRoundDown(order.info.amount * (1 - FFee), 8);
          order.info.amount := DblRoundDown(order.info.amount / order.info.rate, 8);
          order.info.dir := False;

          tmpCMR := NewCMR(order);
          order.info.excess := tmpCMR/FCMR;

          FOrdersToPlace.Insert(FOrdersToPlace.Count, order);
        end;
      end;
    end;
  end;

  FRiseOrders.Clear;
  FFallOrders.Clear;
  for i1 := 0 to FOrdersToPlace.Count - 1 do
  begin
    if OrderBK(FOrdersToPlace.Items[i1]) = bkRise then
      FRiseOrders.Insert(FRiseOrders.Count, FOrdersToPlace.Items[i1]);
    if OrderBK(FOrdersToPlace[i1]) = bkFall then
      FFallOrders.Insert(FFallOrders.Count, FOrdersToPlace.Items[i1]);
  end;

  GetMaxExcess;
end;

function TMarketBase.IncIndic: string;
begin
  FRunIndic := FRunIndic + 1;
  Result := FRunIndic.ToString + '_' + TimeToStr(Now);
end;

function TMarketBase.InCoins(AName: string; ACoins: TCoins): integer;
var
  i1: integer;
begin
  Result := -1;

  for i1 := 0 to Length(ACoins)-1 do
    if ACoins[i1].name = AName then
    begin
      Result := i1;
      Break
    end;
end;

procedure TMarketBase.UpdRates;
var
  fbRates: TFBRates;
begin
  ReadRates(RATES_FILE, fbRates, FExpTimeD);
  WriteRates(RATES_FILE, FGlasses, fbRates);
  RatesAnal(fbRates, FGlasses, FRates, FTimedPart);

  FQuantToBTC := TotalToCoin('btc');
  FQuantToUSD := TotalToCoin('usd');
end;

procedure TMarketBase.SaveOrder(AOrder: TOrder);
var
  tmpOID: TOrderID;
begin
  ConvertOrder(AOrder, tmpOID);
  if tmpOID.info.id <> 'wrong' then
    dmMain.AddOrder(tmpOID);
end;

procedure TMarketBase.SetOrders(FallRise: boolean = False);
var
  i1: integer;
  ordMatch, cnd, cndF, cndB: boolean;
  order: TOrder;
begin
  for i1 := 0 to FOrdersToPlace.Count - 1 do
  begin
    if FallRise then
    begin
      cnd :=  ((OrderPart(FOrdersToPlace.Items[i1]) > FMinPart) or
               (OrderDvt(FOrdersToPlace.Items[i1]) > FDeviation));
      cndF := FOrdersToPlace.Items[i1].info.dir and cnd;
      cndB := (not FOrdersToPlace.Items[i1].info.dir) and cnd;

      ordMatch := (FOrdersToPlace.Items[i1].info.excess >= FCMRExcess);
      ordMatch := ordMatch and (cndF or cndB);
    end
    else
      ordMatch := (FOrdersToPlace.Items[i1].info.excess >= FCMRExcess);
    if ordMatch then
    begin
      order := FOrdersToPlace.Items[i1];
      SetOrder(order);
      if Trim(FErrStr) = '' then
      begin
        order.info.placed := True;
        FOrders.Insert(FOrders.Count, order);
        FOrderCount := FOrders.Count;
      end;

      Sleep(FFRI);
    end;
  end;

  FOrdersToPlace.Clear;
end;

function TMarketBase.InCoins(AName: string;
  ACoins: TArray<string>): integer;
var
  i1: integer;
begin
  Result := -1;

  for i1 := 0 to Length(ACoins)-1 do
    if ACoins[i1] = AName then
    begin
      Result := i1;
      Break
    end;
end;

function TMarketBase.PairInGlasses(APair: string): integer;
var
  i1: integer;
begin
  Result := -1;

  for i1 := 0 to Length(FGlasses)-1 do
    if FGlasses[i1].pair = APair then
    begin
      Result := i1;
      Break
    end;
end;

procedure TMarketBase.PickOrdersByBK(AOrders: TList<TOrder>;
          var OOrders: TList<TOrder>; bookKind: TBookKind);
var
  i1: integer;
begin
  OOrders := TList<TOrder>.Create;
  for i1 := 0 to AOrders.Count - 1 do
    if OrderBK(AOrders.Items[i1]) = bookKind then
      OOrders.Insert(0, AOrders.Items[i1]);
  SortOrdersByExc(OOrders);
end;

function TMarketBase.RateCTC(ACName1, ACName2: string): double;
var
  i1: integer;
  midRes, midRes1, midRes2: double;
begin
  midRes := RateCTCDirect(ACName1, ACName2);

  if midRes = -1 then
    for i1 := 0 to Length(FCoinsExt)-1 do
    begin
      midRes1 := RateCTCDirect(ACName1, FCoinsExt[i1].name);
      midRes2 := RateCTCDirect(FCoinsExt[i1].name, ACName2);

      if (midRes1 <> -1) and (midRes2 <> -1) then
      begin
        midRes1 := midRes1*midRes2;
        if midRes < midRes1 then
          midRes := midRes1;
      end;
    end;

  Result := midRes;
end;

function TMarketBase.RateCTCDirect(ACName1, ACName2: string): double;
var
  index: integer;
  pair: string;
begin
  Result := -1;

  pair := GetPair(ACName1, ACName2);
  index := PairInGlasses(pair);
  if index <> -1 then
    Result := FGlasses[index].bids[0].rate
  else
  begin
    pair := GetPair(ACName1, ACName2, False);
    index := PairInGlasses(pair);
    if index <> -1 then
      Result := 1/FGlasses[index].asks[0].rate
  end;
end;


procedure TMarketBase.set_akey(const Value: string);
begin
  FApiKey := Value;
end;

procedure TMarketBase.set_base_url(const Value: string);
begin
  FRestClient.BaseURL := Value;
end;

procedure TMarketBase.set_cfl(const Value: boolean);
begin
  FCoinsFirstLoad := Value;
end;

procedure TMarketBase.set_dvt(const Value: single);
begin
  FDeviation := Value;
end;

procedure TMarketBase.set_excess(const Value: double);
begin
  FCMRExcess := Value;
end;

procedure TMarketBase.set_exp_time(const Value: integer);
begin
  FExpTime := Value;

  FExpTimeD := FExpTime/24;
end;

procedure TMarketBase.set_fee(const Value: single);
begin
  FFee := Value;
end;

procedure TMarketBase.set_fri(const Value: cardinal);
begin
  FFRI := Value;
end;

procedure TMarketBase.set_inf_str(const Value: string);
begin
  FInfoStr := Value;
end;

procedure TMarketBase.set_limit(const Value: integer);
begin
  FLimit := Value;
end;

procedure TMarketBase.set_maxTC(const Value: string);
begin
  FMaxTC := Value;
end;

procedure TMarketBase.set_max_trade(const Value: double);
begin
  FMaxTrade := Value;
end;

procedure TMarketBase.set_minTC(const Value: string);
begin
  FMTCoin := Value;
end;

procedure TMarketBase.set_min_prt(const Value: single);
begin
  FMinPart := Value;
end;

procedure TMarketBase.set_min_trade(const Value: double);
begin
  FMinTrade := Value;
end;

procedure TMarketBase.set_req_int(const Value: integer);
begin
  FReqInt := Value;
end;

procedure TMarketBase.set_run(const Value: boolean);
begin
  FRun := Value;
end;

procedure TMarketBase.set_secret(const Value: string);
begin
  FApiSec := Value;
end;

procedure TMarketBase.set_timed_part(const Value: boolean);
begin
  FTimedPart := Value;
end;

procedure TMarketBase.SortOrdersByExc(var AOrders: TList<TOrder>);
var
  i1: integer;
  sorted: boolean;
begin
  repeat
    sorted := True;

    for i1 := 0 to AOrders.Count - 2 do
      if  AOrders.Items[i1].info.excess <
          AOrders.Items[i1 + 1].info.excess then
      begin
        AOrders.Exchange(i1, i1 + 1);
        sorted := False;
      end;
  until sorted;

end;

function TMarketBase.TotalToCoin(ACName: string): double;
var
  i1: integer;
begin
  Result := 0;
  for i1 := 0 to Length(FCoinsExt) - 1 do
    if FCoinsExt[i1].name = ACName then
      Result := Result + FCoinsExt[i1].quant
    else
      Result := Result + AmountCTC(FCoinsExt[i1].name, ACName);
end;

procedure TMarketBase.UpdCG;
begin
  UpdCoins;
  GetGlasses;
  UpdRates;
end;

procedure TMarketBase.UpdCtrlCoins;
begin
  SetLength(FCoinsCtrl, 0);
  Insert(FCoinsExt, FCoinsCtrl, 0);
end;

procedure TMarketBase.UpdCoins;
var
 i1: integer;
begin
  LoadCoins;
  GetFunds;

  for i1 := 0 to Length(FCoinsExt) - 1 do
  begin
    if FCoinsExt[i1].max < FCoinsExt[i1].quant then
      FCoinsExt[i1].max := FCoinsExt[i1].quant;

    dmMain.ModCoin(FCoinsExt[i1]);
  end;

  CulcCMR;
end;

procedure TMarketBase.WaitAfterRequest;
begin
  Sleep(FReqInt*1000);
end;

procedure TMarketBase.LoadCoins;
var
  i1: integer;
  coins: TCoins;
begin
  dmMain.GetAllCoins(coins);
  if FCoinsFirstLoad then
  begin
    UpdCtrlCoins;
    FCoinsFirstLoad := False;
  end
  else
    CheckCoinsCtrl;

  SetLength(FCoins, 0);
  SetLength(FCoinsExt, 0);

  for i1 := 0 to Length(coins)-1 do
    if coins[i1].active then
    begin
      Insert(coins[i1], FCoins, Length(FCoins));
      Insert(coins[i1], FCoinsExt, Length(FCoinsExt));
    end
    else
      if InCoins(coins[i1].name, FBaseCoins) > -1 then
        Insert(coins[i1], FCoinsExt, Length(FCoinsExt));

  CombPairs;

  SetLength(coins, 0);
end;

function TMarketBase.NewCMR(AOrder: TOrder): double;
var
  cInd: integer;
  tmpCoins: TCoins;
  coin1, coin2: string;
begin
  Result := -1;

  SetLength(tmpCoins, 0);
  Insert(FCoins, tmpCoins, 0);

  coin1 := PairCoin(AOrder.pair);
  coin2 := PairCoin(AOrder.pair, False);

  if (Trim(coin1) <> '') and (Trim(coin2) <> '') then
  begin
    if AOrder.info.dir then
    begin
      cInd := InCoins(coin1, tmpCoins);
      tmpCoins[cInd].quant := tmpCoins[cInd].quant - AOrder.info.amount;

      cInd := InCoins(coin2, tmpCoins);
      tmpCoins[cInd].quant := tmpCoins[cInd].quant + AOrder.info.amount *
              (1 - FFee) * AOrder.info.rate;
    end
    else
    begin
      cInd := InCoins(coin1, tmpCoins);
      tmpCoins[cInd].quant := tmpCoins[cInd].quant + AOrder.info.amount *
              (1-FFee);

      cInd := InCoins(coin2, tmpCoins);
      tmpCoins[cInd].quant := tmpCoins[cInd].quant - AOrder.info.amount *
              AOrder.info.rate;
    end;

    Result := CommCMR(tmpCoins);
  end;

  SetLength(tmpCoins, 0);
end;

function TMarketBase.OrderCond(ARate: TRate): boolean;
var
  coin1, coin2: string;
  relAmnt1, relAmnt2: double;
begin
  Result := False;

  coin1 := PairCoin(ARate.pair);
  coin2 := PairCoin(ARate.pair, False);
  relAmnt1 := AmountCTC(coin1, FMTCoin);
  relAmnt2 := AmountCTC(coin2, FMTCoin);

  Result := ( (ARate.fKind = bkFall) and (ARate.fPart > FMinPart) and
              (relAmnt1 > FMinTrade))
                or
            ( (ARate.bKind = bkFall) and (ARate.bPart > FMinPart) and
              (relAmnt2 > FMinTrade));
end;

function TMarketBase.OrderBK(AOrder: TOrder): TBookKind;
var
  rateInd, i1: integer;
begin
  Result := bkLine;

  rateInd := - 1;
  for i1 := 0 to Length(FRates) - 1 do
    if FRates[i1].pair = AOrder.pair then
    begin
      rateInd := i1;
      Break
    end;

  if rateInd > -1 then
    if AOrder.info.dir then
      Result := FRates[rateInd].fKind
    else
      Result := FRates[rateInd].bKind;
end;

function TMarketBase.OrderCond(AOrder: TOrder): boolean;
var
  i1, rateInd: integer;
begin
  rateInd := -1;
  for i1 := 0 to Length(FRates) - 1 do
    if AOrder.pair = FRates[i1].pair then
    begin
      rateInd := i1;
      Break
    end;

  if rateInd = -1 then
    Result := False
  else
    Result := OrderCond(FRates[rateInd]);
end;

function TMarketBase.OrderCondFR(APair: string): boolean;
var
  coin1, coin2: string;
  relAmnt1, relAmnt2: double;
begin
  Result := False;

  coin1 := PairCoin(APair);
  coin2 := PairCoin(APair, False);
  relAmnt1 := AmountCTC(coin1, FMTCoin);
  relAmnt2 := AmountCTC(coin2, FMTCoin);

  Result := (relAmnt1 > FMinTrade) or (relAmnt2 > FMinTrade);
end;

function TMarketBase.OrderDvt(AOrder: TOrder): single;
var
  rateInd, i1: integer;
begin
  Result := 0;

  rateInd := - 1;
  for i1 := 0 to Length(FRates) - 1 do
    if FRates[i1].pair = AOrder.pair then
    begin
      rateInd := i1;
      Break
    end;

  if rateInd > -1 then
    if AOrder.info.dir then
      Result := FRates[rateInd].fDvt
    else
      Result := FRates[rateInd].bDvt;
end;

function TMarketBase.OrderPart(AOrder: TOrder): single;
var
  rateInd, i1: integer;
begin
  Result := 0;

  rateInd := - 1;
  for i1 := 0 to Length(FRates) - 1 do
    if FRates[i1].pair = AOrder.pair then
    begin
      rateInd := i1;
      Break
    end;

  if rateInd > -1 then
    if AOrder.info.dir then
      Result := FRates[rateInd].fPart
    else
      Result := FRates[rateInd].bPart;
end;

function TMarketBase.OrdersByPeriod(ATime: double): integer;
var
  ordsID: TArray<TOrderID>;
begin
  SetLength(ordsID, 0);

  Result := dmMain.LastOrders(ATime, ordsID);

  SetLength(ordsID, 0);
end;

procedure TMarketBase.OrdersCircle;
begin
  FInfoStr := 'UPDATING FUNDS ' + IncIndic;
  UpdCoins;

  FInfoStr := 'GETTING GLASSES ' + IncIndic;
  GetGlasses;

  FInfoStr := 'GETTING ORDRERS LIST ' + IncIndic;
  GetOTP(True);

  CheckSetOrders;

  FInfoStr := 'FITTING ORDRERS ' + IncIndic;
  FitOrders;

  FInfoStr := 'PLACING ACTIVE ORDRERS (' +
              FOrdersToPlace.Count.ToString + ') ' + IncIndic;
  SetOrders(True);

  FInfoStr := 'WAITING...' + IncIndic;
  WaitAfterRequest;
end;

end.
