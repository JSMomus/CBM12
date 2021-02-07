unit unCoins;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox,
  FMX.DialogService.Async,
  unDataMod, unGlobals, unHFuncs1, unMYobit;

type
  TfmCoins = class(TForm)
    tbControl: TToolBar;
    tbClose: TToolBar;
    btClose: TButton;
    lbCoins: TListBox;
    btAdd: TButton;
    btDel: TButton;
    btMod: TButton;
    procedure btCloseClick(Sender: TObject);
    procedure btAddClick(Sender: TObject);
    procedure btModClick(Sender: TObject);
    procedure lbCoinsPainting(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure btDelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbCoinsChangeCheck(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure GetCoinFromLBI(lbi: TListBoxItem; var OCoin: TCoin);
    procedure FillList;

    procedure AddQuery(const AResult: TModalResult;
                      const AValues: array of string);
    procedure ModQuery(const AResult: TModalResult;
                      const AValues: array of string);
    procedure DelQuery(const AResult: TModalResult);
  public
    { Public declarations }
  end;

var
  fmCoins: TfmCoins;
  coinsVis: TCoins;

implementation

{$R *.fmx}

procedure TfmCoins.AddQuery(const AResult: TModalResult;
  const AValues: array of string);
var
  coin: TCoin;
  errPos: byte;
begin
  if AResult = mrOk then
  begin
    errPos := 0;
    coin.name := AValues[0];
    try
      errPos := 1;
      coin.quant := DCStrToDouble(AValues[1]);
      errPos := 2;
      coin.max := DCStrToDouble(AValues[2]);

      dmMain.AddCoin(coin);
      dmMain.GetAllCoins(coinsVis);
      FillList;
    except
      on E: EConvertError do
      begin
        if errPos = 1 then
          ShowMessage('Invalid quantity')
        else
          ShowMessage('Invalid max quantity');
      end;
    end;
  end;
end;

procedure TfmCoins.btAddClick(Sender: TObject);
var
  quest: string;
begin
  quest := 'Input new coin:';
  TDialogServiceAsync.InputQuery(quest, ['Coin name', 'Quantity', 'Max quant.'],
      ['new_coin', '0', '0.00000001'], AddQuery);
end;

procedure TfmCoins.btCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfmCoins.btDelClick(Sender: TObject);
var
  coin: TCoin;
  quest: string;
begin
  if lbCoins.Selected <> nil then
  begin
    coin := coinsVis[lbCoins.ItemIndex];
    quest := 'Delete coin ' + coin.name +'?';
    TDialogServiceAsync.MessageDialog(quest, TMsgDlgType.mtWarning,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0, DelQuery);
  end;
end;

procedure TfmCoins.btModClick(Sender: TObject);
var
  quest: string;
  coin: TCoin;
begin
  if lbCoins.Selected <> nil then
  begin
    GetCoinFromLBI(lbCoins.Selected, coin);
    quest := 'Changing coin ' + coin.name;
    TDialogServiceAsync.InputQuery(quest, ['Coin name', 'Quantity', 'Max quant.'],
        [coin.name, coin.quant.ToString(ffFixed, 20, 8),
        coin.max.ToString(ffFixed, 20, 8)], ModQuery);
  end;
end;

procedure TfmCoins.DelQuery(const AResult: TModalResult);
var
  coin: TCoin;
begin
  if AResult = mrYes then
  begin
    GetCoinFromLBI(lbCoins.Selected, coin);
    coin.index := coinsVis[lbCoins.ItemIndex].index;

    dmMain.DelCoin(coin);
    dmMain.GetAllCoins(coinsVis);
    FillList;
  end;
end;

procedure TfmCoins.FillList;
var
  i1: integer;
  lbi: TListBoxItem;
  det: string;
begin
  for i1 := lbCoins.ComponentCount-1 downto 0 do
    if (lbCoins.Components[i1] is TListBoxItem) then
    begin
      (lbCoins.Components[i1] as TListBoxItem).Parent := nil;
      (lbCoins.Components[i1] as TListBoxItem).Free;
    end;

  for i1 := 0 to Length(coinsVis)-1 do
  begin
    lbi := TListBoxItem.Create(lbCoins);
    lbi.ItemData.Text := coinsVis[i1].name;
    lbi.TextSettings.HorzAlign := TTextAlign.Leading;
    lbi.Height := 40;
    lbi.StyleLookup := 'listboxitembottomdetail';

    det := 'Q_' + coinsVis[i1].quant.ToString(ffFixed, 20, 8);
    det := det + ' /M_' + coinsVis[i1].max.ToString(ffFixed, 20, 8);
    lbi.ItemData.Detail := det;

    lbi.IsChecked := coinsVis[i1].active;

    lbi.Parent := lbCoins;
  end;
end;

procedure TfmCoins.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  mrkYobit.CoinsFirstLoad := True;
  mrkYobit.UpdCoins;
end;

procedure TfmCoins.FormCreate(Sender: TObject);
begin
  dmMain.GetAllCoins(coinsVis);

  FillList;
end;

procedure TfmCoins.GetCoinFromLBI(lbi: TListBoxItem; var OCoin: TCoin);
var
  hStr, qStr: string;
  pos1: integer;
begin
  OCoin.name := lbi.ItemData.Text;

  hStr := lbi.ItemData.Detail;
  hStr := Copy(hStr, 3, Length(hStr) - 2);
  pos1 := Pos('/', hStr);
  qStr := Copy(hStr, 0, pos1 - 2);
  hStr := Copy(hStr, pos1 + 3, Length(hStr) - pos1 - 2);

  OCoin.quant := DCStrToDouble(qStr);
  OCoin.max := DCStrToDouble(hStr);
  OCoin.active := lbi.IsChecked;
end;

procedure TfmCoins.lbCoinsChangeCheck(Sender: TObject);
begin
  if lbCoins.Selected.IsChecked <> coinsVis[lbCoins.ItemIndex].active then
  begin
    coinsVis[lbCoins.ItemIndex].active := lbCoins.Selected.IsChecked;

    dmMain.ModCoin(coinsVis[lbCoins.ItemIndex]);
    dmMain.GetAllCoins(coinsVis);
  end;
end;

procedure TfmCoins.lbCoinsPainting(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  btMod.Enabled := True;
  btDel.Enabled := True;

  if lbCoins.Selected = nil then
  begin
    btMod.Enabled := False;
    btDel.Enabled := False;
  end;
end;

procedure TfmCoins.ModQuery(const AResult: TModalResult;
  const AValues: array of string);
var
  errPos: byte;
  index: integer;
begin
  if AResult = mrOk then
  begin
    errPos := 0;
    index := lbCoins.ItemIndex;
    coinsVis[index].name := AValues[0];
    try
      errPos := 1;
      coinsVis[index].quant := DCStrToDouble(AValues[1]);
      errPos := 2;
      coinsVis[index].max := DCStrToDouble(AValues[2]);

      dmMain.ModCoin(coinsVis[index]);
      dmMain.GetAllCoins(coinsVis);
      FillList;
    except
      on E: EConvertError do
      begin
        if errPos = 1 then
          ShowMessage('Invalid quantity')
        else
          ShowMessage('Invalid max quantity');
      end;
    end;
  end;
end;

end.
