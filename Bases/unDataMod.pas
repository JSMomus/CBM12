unit unDataMod;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, unGlobals;

type
  TdmMain = class(TDataModule)
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    fdqAllCoins: TFDQuery;
    fdqAddCoin: TFDQuery;
    fdqDelCoin: TFDQuery;
    fdqModCoin: TFDQuery;
    fdqAddOrd: TFDQuery;
    fdqDelOrd: TFDQuery;
    fdqAllOrders: TFDQuery;
    fdqOrdInfo: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    function CoinByID(AID: integer; ACoins: TCoins): string;
  public
    procedure GetAllCoins(var ACoins: TCoins);
    procedure AddCoin(ACoin: TCoin);
    procedure DelCoin(ACoin: TCoin);
    procedure ModCoin(ANewCoin: TCoin);

    function LastOrders(ATime: double; var OOrdersID: TArray<TOrderID>): integer;
    procedure AddOrder(AOrder: TOrderID);
    procedure DelOrder(AOrdID: string);
    procedure OrdersIDs(var OrdID: TArray<string>);
    procedure GetOrder(AID: string; var AOrder: TOrderID);
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TdmMain.AddCoin(ACoin: TCoin);
begin
  fdqAddCoin.ParamByName('name').Asstring := ACoin.name;
  fdqAddCoin.ParamByName('quant').AsFloat := ACoin.quant;
  fdqAddCoin.ParamByName('max').AsFloat := ACoin.max;
  fdqAddCoin.ParamByName('act').AsBoolean := ACoin.active;
  fdqAddCoin.ExecSQL;
  fdqAddCoin.Close;
end;

procedure TdmMain.AddOrder(AOrder: TOrderID);
begin
  fdqAddOrd.ParamByName('id').Asstring := AOrder.info.id;
  fdqAddOrd.ParamByName('cFrom').AsInteger := AOrder.coin1ID;
  fdqAddOrd.ParamByName('cTo').AsInteger := AOrder.coin2ID;
  fdqAddOrd.ParamByName('amnt').AsFloat := AOrder.info.amount;
  fdqAddOrd.ParamByName('rat').AsFloat := AOrder.info.rate;
  fdqAddOrd.ParamByName('dir').AsBoolean := AOrder.info.dir;
  fdqAddOrd.ParamByName('typ').Asstring := AOrder.info.typ;
  fdqAddOrd.ParamByName('time').AsDateTime := AOrder.info.time;
  fdqAddOrd.ExecSQL;
  fdqAddOrd.Close;
end;

function TdmMain.CoinByID(AID: integer; ACoins: TCoins): string;
var
  i1: integer;
begin
  Result := 'n/c';

  for i1 := 0 to Length(ACoins) - 1 do
    if ACoins[i1].index = AID then
    begin
      Result := ACoins[i1].name;
      Break
    end;
end;

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  FDConnection1.DriverName := 'SQLite';
  FDConnection1.Params.Database := TPath.Combine(TPath.GetHomePath, 'YobitCBM.s3db');
  FDConnection1.Connected := True;
end;

procedure TdmMain.DelCoin(ACoin: TCoin);
begin
  fdqDelCoin.ParamByName('ind').AsInteger := ACoin.index;
  fdqDelCoin.ExecSQL;
  fdqDelCoin.Close;
end;

procedure TdmMain.DelOrder(AOrdID: string);
begin
  fdqDelOrd.ParamByName('id').Asstring := AOrdID;
  fdqDelOrd.ExecSQL;
  fdqDelOrd.Close;
end;

procedure TdmMain.GetAllCoins(var ACoins: TCoins);
var
  i1: integer;
  coin: TCoin;
begin
  SetLength(ACoins, 0);

  fdqAllCoins.Open();
  for i1 := 1 to fdqAllCoins.RecordCount do
  begin
    fdqAllCoins.RecNo := i1;
    coin.index := fdqAllCoins.FieldByName('cnInd').AsInteger;
    coin.name := fdqAllCoins.FieldByName('cnName').Asstring;
    coin.quant := fdqAllCoins.FieldByName('cnQuant').AsFloat;
    coin.max := fdqAllCoins.FieldByName('cnMax').AsFloat;
    coin.active := fdqAllCoins.FieldByName('cnActive').AsBoolean;

    Insert(coin, ACoins, Length(ACoins));
  end;

  fdqAllCoins.Close;
end;

procedure TdmMain.GetOrder(AID: string; var AOrder: TOrderID);
begin
  fdqOrdInfo.ParamByName('id').Asstring := AID;
  AOrder.info.id := AID;
  fdqOrdInfo.Open();

  if fdqOrdInfo.RecordCount > 0 then
  begin
    AOrder.coin1ID := fdqOrdInfo.FieldByName('coinFrom').AsInteger;
    AOrder.coin2ID := fdqOrdInfo.FieldByName('coinTo').AsInteger;
    AOrder.info.amount := fdqOrdInfo.FieldByName('ordAmount').AsFloat;
    AOrder.info.rate := fdqOrdInfo.FieldByName('ordRate').AsFloat;
    AOrder.info.dir := fdqOrdInfo.FieldByName('ordDir').AsBoolean;
    AOrder.info.typ := fdqOrdInfo.FieldByName('ordType').Asstring;
    AOrder.info.time := fdqOrdInfo.FieldByName('ordTime').AsDateTime;
  end;

  fdqOrdInfo.Close;
end;

function TdmMain.LastOrders(ATime: double; var OOrdersID: TArray<TOrderID>): integer;
var
  i1: integer;
  ordID: TOrderID;
begin
  Result := 0;
  SetLength(OOrdersID, 0);
  fdqAllOrders.Open();

  for i1 := 1 to fdqAllOrders.RecordCount do
  begin
    try
      fdqAllOrders.RecNo := i1;
      ordID.info.id := fdqAllOrders.FieldByName('ordID').Asstring;
      ordID.coin1ID := fdqAllOrders.FieldByName('coinFrom').AsInteger;
      ordID.coin2ID := fdqAllOrders.FieldByName('coinTo').AsInteger;
      ordID.info.amount := fdqAllOrders.FieldByName('ordAmount').AsFloat;
      ordID.info.rate := fdqAllOrders.FieldByName('ordRate').AsFloat;
      ordID.info.dir := fdqAllOrders.FieldByName('ordDir').AsBoolean;
      ordID.info.typ := fdqAllOrders.FieldByName('ordType').Asstring;
      ordID.info.time := fdqAllOrders.FieldByName('ordTime').AsDateTime;

      if (Now - ordID.info.time) < ATime then
      begin
        Insert(ordID, OOrdersID, Length(OOrdersID));
        Result := Result + 1;
      end;
    finally

    end;
  end;

  fdqAllOrders.Close;
end;

procedure TdmMain.ModCoin(ANewCoin: TCoin);
begin
  fdqModCoin.ParamByName('name').Asstring := ANewCoin.name;
  fdqModCoin.ParamByName('quant').AsFloat := ANewCoin.quant;
  fdqModCoin.ParamByName('max').AsFloat := ANewCoin.max;
  fdqModCoin.ParamByName('act').AsBoolean := ANewCoin.active;
  fdqModCoin.ParamByName('ind').AsInteger := ANewCoin.index;
  fdqModCoin.ExecSQL;
  fdqModCoin.Close;
end;

procedure TdmMain.OrdersIDs(var OrdID: TArray<string>);
var
  i1: integer;
begin
  SetLength(OrdID, 0);

  fdqAllOrders.Open();
  for i1 := 1 to fdqAllOrders.RecordCount do
  begin
    fdqAllOrders.RecNo := i1;
    Insert(fdqAllOrders.FieldByName('ordID').Asstring, OrdID, 0);
  end;

  fdqAllOrders.Close;
end;

end.
