unit unPrefs;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.Layouts,
  FMX.Edit, FMX.DialogService.Async,
  unHFuncs1, unGlobals, unDataMod, unPrefFile, unMYobit, unAddish, unMarketBase;

type
  TfmPrefs = class(TForm)
    tbClose: TToolBar;
    btClose: TButton;
    Memo1: TMemo;
    loutParams: TLayout;
    cbBaseURLs: TComboBox;
    lbBaseURL: TLabel;
    lbDepthLimit: TLabel;
    lbReqInt: TLabel;
    edDepthLimit: TEdit;
    edReqInt: TEdit;
    btAddish: TButton;
    btAddS: TButton;
    btDelS: TButton;
    btEqMaxes: TButton;
    chbEqualMaxes: TCheckBox;
    procedure btCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btAddishClick(Sender: TObject);
    procedure btDelSClick(Sender: TObject);
    procedure btAddSClick(Sender: TObject);
    procedure btEqMaxesClick(Sender: TObject);
    procedure chbEqualMaxesChange(Sender: TObject);
  private
    procedure PlaceComps;
    procedure ReadFillData;
    function SaveData: byte;
    procedure UpdMarket;

    procedure DelServer(const AResult: TModalResult);
    procedure ECMQuery(const AResult: TModalResult);
    procedure AddServer(const AResult: TModalResult;
          const AValues: array of string);
  public
    { Public declarations }
  end;

var
  fmPrefs: TfmPrefs;

implementation

{$R *.fmx}

procedure TfmPrefs.AddServer(const AResult: TModalResult;
  const AValues: array of string);
begin
  if AResult = mrOk then
    if Trim(AValues[0]) <> '' then
    begin
      cbBaseURLs.Items.Add(AValues[0]);
      cbBaseURLs.ItemIndex := cbBaseURLs.Items.Count - 1;
    end;
end;

procedure TfmPrefs.btAddSClick(Sender: TObject);
var
  quest: string;
begin
  quest := 'New api-server.';
  TDialogServiceAsync.InputQuery(quest, ['API server'],
      ['https://'], AddServer);
end;

procedure TfmPrefs.btAddishClick(Sender: TObject);
begin
  Application.CreateForm(TfmAddish, fmAddish);
  FmAddish.Show;
end;

procedure TfmPrefs.btCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfmPrefs.btDelSClick(Sender: TObject);
var
  quest: string;
begin
  if (cbBaseURLs.Items.Count > 0) and (cbBaseURLs.ItemIndex >= 0) then
  begin
    quest := 'Delete spi-server ' + cbBaseURLs.Items[cbBaseURLs.ItemIndex] + '?';
    TDialogServiceAsync.MessageDialog(quest, TMsgDlgType.mtWarning,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0, DelServer);
  end;
end;

procedure TfmPrefs.btEqMaxesClick(Sender: TObject);
var
  quest: string;
begin
  quest := 'Equal maxes of coins?';
  TDialogServiceAsync.MessageDialog(quest, TMsgDlgType.mtWarning,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0, ECMQuery);
end;

procedure TfmPrefs.chbEqualMaxesChange(Sender: TObject);
begin
  if chbEqualMaxes.IsChecked then
    btEqMaxes.Enabled := True
  else
    btEqMaxes.Enabled := False;
end;

procedure TfmPrefs.DelServer(const AResult: TModalResult);
begin
  if AResult = mrYes then
  begin
    cbBaseURLs.Items.Delete(cbBaseURLs.ItemIndex);

    if cbBaseURLs.Items.Count > 0 then
      cbBaseURLs.ItemIndex := 0;
  end;
end;

procedure TfmPrefs.ECMQuery(const AResult: TModalResult);
begin
  if AResult = mrYes then
    mrkYobit.EqualMaxes;
end;

procedure TfmPrefs.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  excPos: byte;
begin
  excPos := SaveData;
  if excPos > 0 then
  begin
    CanClose := False;

    case excPos of
      1:
        ShowMessage('Incorrect Base URLs or URL index');
      2:
        ShowMessage('Incorrect Depth limit');
      3:
        ShowMessage('Incorrect Request interval');
    end;
  end
  else
  begin
    RewriteParams(PARAM_FILE, CPG);

    if Assigned(mrkYobit) then
      UpdMarket;
  end;
end;

procedure TfmPrefs.FormCreate(Sender: TObject);
begin
  PlaceComps;
  ReadFillData;
end;

procedure TfmPrefs.PlaceComps;
var
  cw, ew: single;  //column width, element (component) width
begin
  Memo1.Height := ClientHeight/3;

  btEqMaxes.Position.Y := Memo1.Height + 5;
  chbEqualMaxes.Position.Y := Memo1.Height + 5;

  loutParams.Height := ClientHeight/2;
  cw := loutParams.Width/2;
  ew := (loutParams.Width - 20)/2;

//Left column
  lbBaseURL.Position.Y := 5;
  lbBaseURL.Position.X := 5;
  lbBaseURL.Width := ew;

  cbBaseURLs.Position.Y := lbBaseURL.Height + 10;
  cbBaseURLs.Position.X := 5;
  cbBaseURLs.Width := ew;

  btAddS.Position.Y := lbBaseURL.Height + cbBaseURLs.Height + 15;
  btAddS.Position.X := 5;

  btDelS.Position.Y := lbBaseURL.Height + cbBaseURLs.Height + 15;
  btDelS.Position.X := cbBaseURLs.Width + 5 - btDelS.Width;

  btAddish.Position.Y := (loutParams.Height + lbBaseURL.Height +
              cbBaseURLs.Height + btAddS.Height - btAddish.Height + 10)/2;
  btAddish.Position.X := 5;

//Right column
  lbDepthLimit.Position.Y := 5;
  lbDepthLimit.Position.X := cw + 5;
  lbDepthLimit.Width := ew;

  edDepthLimit.Position.Y := lbDepthLimit.Height + 10;
  edDepthLimit.Position.X := cw + 5;
  edDepthLimit.Width := ew;

  lbReqInt.Position.Y := lbDepthLimit.Height + edDepthLimit.Height + 15;
  lbReqInt.Position.X := cw + 5;
  lbReqInt.Width := ew;

  edReqInt.Position.Y := lbDepthLimit.Height + edDepthLimit.Height +
                          lbReqInt.Height + 20;
  edReqInt.Position.X := cw + 5;
  edReqInt.Width := ew;
end;

procedure TfmPrefs.ReadFillData;
var
  i1: integer;
begin
  ReadParams(PARAM_FILE, CPG);

  cbBaseURLs.Items.Clear;
  for i1 := 0 to Length(CPG.baseUrls)-1 do
    cbBaseURLs.Items.Add(CPG.baseUrls[i1]);
  try
    cbBaseURLs.ItemIndex := CPG.buIndex;
  except
    cbBaseURLs.ItemIndex := -1;
  end;

  edDepthLimit.Text := CPG.depthLimit.ToString;
  edReqInt.Text := CPG.reqInt.ToString;
end;

function TfmPrefs.SaveData: byte;
var
  i1: integer;
begin
  Result := 0;

  if cbBaseURLs.Items.Count > 0 then
  begin
    SetLength(CPG.baseUrls, 0);
    for i1 := 0 to cbBaseURLs.Items.Count-1 do
      Insert(cbBaseURLs.Items[i1], CPG.baseUrls, Length(CPG.baseUrls));
    CPG.buIndex := cbBaseURLs.ItemIndex;
  end
  else
    Result := 1;

  try
    CPG.depthLimit := edDepthLimit.Text.ToInteger();
  except
    Result := 2;
  end;

  try
    CPG.reqInt := edReqInt.Text.ToInteger();
  except
    Result := 3;
  end;
end;

procedure TfmPrefs.UpdMarket;
begin
  UpdateMarkParams(mrkYobit, CPG);
end;

end.
