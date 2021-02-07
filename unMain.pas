unit unMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Hash,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls,
  unHFuncs1, unGlobals, unDataMod, unCoins, unPrefs, unPrefFile,
  unYobitRun, unYobitInfo, unMYobit;

type
  TfmMain = class(TForm)
    btStart: TButton;
    btCoins: TButton;
    btPrefs: TButton;
    Memo1: TMemo;
    procedure btStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btCoinsClick(Sender: TObject);
    procedure btPrefsClick(Sender: TObject);
  private
    procedure CompPos;
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.fmx}

procedure TfmMain.btCoinsClick(Sender: TObject);
begin
  Application.CreateForm(TfmCoins, fmCoins);
  fmCoins.Show;
end;

procedure TfmMain.btPrefsClick(Sender: TObject);
begin
  Application.CreateForm(TfmPrefs, fmPrefs);
  fmPrefs.Show;
end;

procedure TfmMain.btStartClick(Sender: TObject);
begin
  if btStart.Text = 'START' then
  begin
    yobitRun := TThrYobitRun.Create(False);
    btStart.Text := 'STOP';
  end
  else
  begin
    mrkYobit.Run := False;
    btStart.Enabled := False;
  end;
end;

procedure TfmMain.CompPos;
const
  COMP_HEIGHT: single = 55;
var
  cw: single;
begin
  cw := (FormFactor.Width div 2) - 10;
  Memo1.Height := fmMain.ClientHeight * 5 / 8;

  btStart.Width := cw;
  btStart.Height := COMP_HEIGHT;
  btStart.Position.X := 5;
  btStart.Position.Y := Memo1.Position.Y + Memo1.Height + 20;

  btCoins.Width := cw;
  btCoins.Height := COMP_HEIGHT - 5;
  btCoins.Position.X := cw + 15;
  btCoins.Position.Y := btStart.Position.Y;

  btPrefs.Width := cw;
  btPrefs.Height := COMP_HEIGHT - 5;
  btPrefs.Position.X := cw + 15;
  btPrefs.Position.Y := btCoins.Height + btCoins.Position.Y + 30;
end;

procedure TfmMain.FormActivate(Sender: TObject);
begin
  if firstActivate then
  begin
    while not Assigned(dmMain) do
      Sleep(100);

    ReadParams(PARAM_FILE, CPG);

    mrkYobit := TYobit.Create;
    UpdateMarkParams(mrkYobit, CPG);
    try
      mrkYobit.UpdCG;
    except
      on E: Exception do ShowMessage(E.Message);
    end;

    thrInfo := TThrInfo.Create(False);

    firstActivate := False;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
   firstActivate := True;

   CompPos;
end;

end.
