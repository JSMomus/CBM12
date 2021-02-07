unit unAddish;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation,
  unPrefFile, unHFuncs1, unMYobit;

type
  TfmAddish = class(TForm)
    lbKey: TLabel;
    lbSecret: TLabel;
    edKey: TEdit;
    edSecret: TEdit;
    tbClose: TToolBar;
    btClose: TButton;
    chbADGuard: TCheckBox;
    edMTC: TEdit;
    edMTQ: TEdit;
    lbMTC: TLabel;
    lbMTQ: TLabel;
    lbMinPart: TLabel;
    lbExpTime: TLabel;
    edMinPart: TEdit;
    edExpTime: TEdit;
    lbMaxTQ: TLabel;
    lbMaxTC: TLabel;
    edMaxTQ: TEdit;
    edMaxTC: TEdit;
    edCMRE: TEdit;
    edFee: TEdit;
    lbFee: TLabel;
    lbCMRE: TLabel;
    edDvt: TEdit;
    lbDvt: TLabel;
    chbTimedPart: TCheckBox;
    procedure btCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chbADGuardChange(Sender: TObject);
  private
    procedure PlaceComps;
    procedure FillData;
    procedure SetPrefs;
  public
    { Public declarations }
  end;

var
  fmAddish: TfmAddish;

implementation

{$R *.fmx}

procedure TfmAddish.btCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfmAddish.chbADGuardChange(Sender: TObject);
begin
  if chbADGuard.IsChecked then
  begin
    edKey.Enabled := True;
    edSecret.Enabled := True;
  end
  else
  begin
    edKey.Enabled := False;
    edSecret.Enabled := False;
  end;
end;

procedure TfmAddish.FillData;
begin
  edKey.Text := CPG.apiKey;
  edSecret.Text := CPG.apiSecret;
  edMTC.Text := CPG.tradeCoin;
  edMTQ.Text := CPG.tradeMin.ToString(ffFixed, 20, 8);
  edMaxTC.Text := CPG.maxCoin;
  edMaxTQ.Text := CPG.tradeMax.ToString(ffFixed, 20, 8);
  edMinPart.Text := CPG.minPart.ToString(ffFixed, 20, 8);
  if CPG.timedPart then
    chbTimedPart.IsChecked := True
  else
    chbTimedPart.IsChecked := False;
  edDvt.Text := CPG.dvt.ToString(ffFixed, 10, 4);
  edExpTime.Text := CPG.expTime.ToString;
  edFee.Text := CPG.fee.ToString(ffFixed, 10, 5);
  edCMRE.Text := CPG.cmre.ToString(ffFixed, 10, 5);
end;

procedure TfmAddish.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Trim(edKey.Text) = '' then
  begin
    ShowMessage('Key can not be empty');
    CanClose := False;
  end;

  if Trim(edSecret.Text) = '' then
  begin
    ShowMessage('Secret can not be empty');
    CanClose := False;
  end;

  if Trim(edMTC.Text) = '' then
  begin
    ShowMessage('Coin name can not be empty');
    CanClose := False;
  end;

  try
    DCStrToDouble(edMTQ.Text);
  except
    CanClose := False;
    ShowMessage('Trade quantity is not valid float');
  end;

  if Trim(edMaxTC.Text) = '' then
  begin
    ShowMessage('Coin name can not be empty');
    CanClose := False;
  end;

  try
    DCStrToDouble(edMaxTQ.Text);
  except
    CanClose := False;
    ShowMessage('Trade quantity is not valid float');
  end;

  try
    DCStrToDouble(edMinPart.Text);
  except
    CanClose := False;
    ShowMessage('Min. part is not valid float');
  end;

  try
    DCStrToDouble(edDvt.Text);
  except
    CanClose := False;
    ShowMessage('Deviation is not valid float');
  end;

  try
    edExpTime.Text.ToInteger();
  except
    CanClose := False;
    ShowMessage('Expire time is not valid integer');
  end;

  try
    DCStrToDouble(edFee.Text);
  except
    CanClose := False;
    ShowMessage('Fee is not valid float');
  end;

  try
    DCStrToDouble(edCMRE.Text);
  except
    CanClose := False;
    ShowMessage('CMR excess is not valid float');
  end;

  if CanClose then
    SetPrefs;
end;

procedure TfmAddish.FormCreate(Sender: TObject);
begin
  PlaceComps;
  FillData;
end;

procedure TfmAddish.PlaceComps;
var
  cwB, cwS: single; //component width
begin
  cwB := ClientWidth - 10;
  cwS := ClientWidth/2 - 10;

//left column
  lbKey.Position.X := 5;
  lbKey.Position.Y := 5;
  lbKey.Width := cwB;

  edKey.Position.X := 5;
  edKey.Position.Y := lbKey.Height + 10;
  edKey.Width := cwB;

  lbSecret.Position.X := 5;
  lbSecret.Position.Y := lbKey.Height + edKey.Height + 15;
  lbSecret.Width := cwB;

  edSecret.Position.X := 5;
  edSecret.Position.Y := lbKey.Height + edKey.Height + lbSecret.Height + 20;
  edSecret.Width := cwB;

  chbADGuard.Position.X := 5;
  chbADGuard.Position.Y := edSecret.Position.Y + edSecret.Height + 5;
  chbADGuard.Width := cwS;

  lbMTC.Position.X := 5;
  lbMTC.Position.Y := chbADGuard.Position.Y + chbADGuard.Height + 8;
  lbMTC.Width := cwS;

  edMTC.Position.X := 5;
  edMTC.Position.Y := lbMTC.Position.Y + lbMTC.Height + 5;
  edMTC.Width := cwS;

  lbMaxTC.Position.X := 5;
  lbMaxTC.Position.Y := edMTC.Position.Y + edMTC.Height + 5;
  lbMaxTC.Width := cwS;

  edMaxTC.Position.X := 5;
  edMaxTC.Position.Y := lbMaxTC.Position.Y + lbMaxTC.Height + 5;
  edMaxTC.Width := cwS;

  lbMinPart.Position.X := 5;
  lbMinPart.Position.Y := edMaxTC.Position.Y + edMaxTC.Height + 5;
  lbMinPart.Width := cwS;

  edMinPart.Position.X := 5;
  edMinPart.Position.Y := lbMinPart.Position.Y + lbMinPart.Height + 5;
  edMinPart.Width := cwS;

  lbDvt.Position.X := 5;
  lbDvt.Position.Y := edMinPart.Position.Y + edMinPart.Height + 5;
  lbDvt.Width := cwS;

  edDvt.Position.X := 5;
  edDvt.Position.Y := lbDvt.Position.Y + lbDvt.Height + 5;
  edDvt.Width := cwS;

  lbFee.Position.X := 5;
  lbFee.Position.Y := edDvt.Position.Y + edDvt.Height + 5;
  lbFee.Width := cwS;

  edFee.Position.X := 5;
  edFee.Position.Y := lbFee.Position.Y + lbFee.Height + 5;
  edFee.Width := cwS;

//right column

  lbMTQ.Position.X := 15 + cwS;
  lbMTQ.Position.Y := lbMTC.Position.Y;
  lbMTQ.Width := cwS;

  edMTQ.Position.X := 15 + cwS;
  edMTQ.Position.Y := edMTC.Position.Y;
  edMTQ.Width := cwS;

  lbMaxTQ.Position.X := 15 + cwS;
  lbMaxTQ.Position.Y := lbMaxTC.Position.Y;
  lbMaxTQ.Width := cwS;

  edMaxTQ.Position.X := 15 + cwS;
  edMaxTQ.Position.Y := edMaxTC.Position.Y;
  edMaxTQ.Width := cwS;

  chbTimedPart.Position.X := 15 + cwS;
  chbTimedPart.Position.Y := lbMinPart.Position.Y;
  chbTimedPart.Width := cwS;

  lbExpTime.Position.X := 15 + cwS;
  lbExpTime.Position.Y := lbDvt.Position.Y;
  lbExpTime.Width := cwS;

  edExpTime.Position.X := 15 + cwS;
  edExpTime.Position.Y := edDvt.Position.Y;
  edExpTime.Width := cwS;

  lbCMRE.Position.X := 15 + cwS;
  lbCMRE.Position.Y := lbFee.Position.Y;
  lbCMRE.Width := cwS;

  edCMRE.Position.X := 15 + cwS;
  edCMRE.Position.Y := edFee.Position.Y;
  edCMRE.Width := cwS;

end;

procedure TfmAddish.SetPrefs;
begin
  CPG.apiKey := Trim(edKey.Text);
  CPG.apiSecret := Trim(edSecret.Text);
  CPG.tradeCoin :=  Trim(edMTC.Text);
  CPG.tradeMin := DCStrToDouble(edMTQ.Text);
  CPG.maxCoin :=  Trim(edMaxTC.Text);
  CPG.tradeMax := DCStrToDouble(edMaxTQ.Text);
  CPG.minPart := Single(DCStrToDouble(edMinPart.Text));
  if chbTimedPart.IsChecked then
    CPG.timedPart := True
  else
    CPG.timedPart := False;
  CPG.dvt := Single(DCStrToDouble(edDvt.Text));
  CPG.expTime := edExpTime.Text.ToInteger();
  CPG.fee := DCStrToDouble(edFee.Text);
  CPG.cmre := DCStrToDouble(edCMRE.Text);
end;

end.
