unit unYobitInfo;

interface

uses
  System.Classes, System.SysUtils,
  unGlobals, unMYobit;

const
  ORDER_UPD_ROUNDS = 5;

type
  TThrInfo = class(TThread)
  private
    procedure ShowInfo;
  protected
    procedure Execute; override;
  end;

var
  thrInfo: TThrInfo;
  cntrRound1: integer;
  ordCountH, ordCountD: integer;

implementation

uses unMain;

{ TThrInfo }

procedure TThrInfo.Execute;
begin
  cntrRound1 := 5;
  while True do
  begin
    Synchronize(ShowInfo);
    Sleep(INFO_UPDATE_INTERVAL * 1000);
  end;
end;

procedure TThrInfo.ShowInfo;
var
  hStr: string;
  updOC: boolean;
begin
  infoStr.Clear;
  if mrkYobit.ErrorString <> '' then
  begin
    hStr := '!ERROR: ' + mrkYobit.ErrorString;
    infoStr.Add(hStr);
  end;

  if mrkYobit.InfoString <> '' then
  begin
    hStr := mrkYobit.InfoString;
    infoStr.Add(hStr);
  end;

  hStr := 'Current CMR: ' + mrkYobit.CMRelation.ToString(ffFixed, 10, 5);
  infoStr.Add(hStr);

  if mrkYobit.OrderCount > 0 then
  begin
    hStr := 'Orders set: ' + mrkYobit.OrderCount.ToString;
    infoStr.Add(hStr);
  end;

  cntrRound1 := cntrRound1 + 1;
  if cntrRound1 >= ORDER_UPD_ROUNDS then
  begin
    cntrRound1 := 1;
    updOC := True;
  end
  else
    updOC := False;
  if updOC then
  begin
    ordCountH := mrkYobit.OrdersByPeriod(1/24);
    ordCountD := mrkYobit.OrdersByPeriod(1);
  end;
  hStr := 'Orders last hour: ' + ordCountH.ToString;
  infoStr.Add(hStr);
  hStr := 'Orders last day: ' + ordCountD.ToString;
  infoStr.Add(hStr);
  hStr := '-----------';
  infoStr.Add(hStr);

  hStr := 'RISE' + #13#10;
  hStr := hStr + 'Max excess is ' + mrkYobit.MERise.ToString(ffFixed, 10, 5) +
          ' at pair ' + mrkYobit.MERPair;
  infoStr.Add(hStr);

  hStr := 'FALL' + #13#10;
  hStr := hStr + 'Max excess is ' + mrkYobit.MEFall.ToString(ffFixed, 10, 5) +
          ' at pair ' + mrkYobit.MEFPair;
  hStr := hStr + #13#10 + '-----------';
  infoStr.Add(hStr);

  hStr := 'Total to btc: ' + mrkYobit.QuantToBTC.ToString(ffFixed, 20, 6);
  infoStr.Add(hStr);

  hStr := 'Total to usd: ' + mrkYobit.QuantToUSD.ToString(ffFixed, 20, 6);
  infoStr.Add(hStr);

  if mrkYobit.BugString <> '' then
  begin
    hStr := '-----------';
    infoStr.Add(hStr);
    hStr := mrkYobit.BugString;
    infoStr.Add(hStr);
  end;

  fmMain.Memo1.Lines.Clear;
  fmMain.Memo1.Lines.AddStrings(infoStr);
end;

end.
