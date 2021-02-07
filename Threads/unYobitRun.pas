unit unYobitRun;

interface

uses
  System.Classes, System.SysUtils,
  unMYobit;

type
  TThrYobitRun = class(TThread)
  private
    procedure StartButton;
  protected
    procedure Execute; override;
  end;

var
  yobitRun: TThrYobitRun;

implementation

{ TThrYobitRun }

uses unMain;

procedure TThrYobitRun.Execute;
begin
  FreeOnTerminate := True;

  if Assigned(mrkYobit) then
  begin
    mrkYobit.Run := True;
    mrkYobit.CoinsFirstLoad := True;
    mrkYobit.UpdCoins;
    mrkYobit.UpdSetOrders;

    while mrkYobit.Run do
    begin
      mrkYobit.OrdersCircle;

      Sleep(10);
    end;
  end;

  Synchronize(StartButton);
end;

procedure TThrYobitRun.StartButton;
begin
  fmMain.btStart.Enabled := True;
  fmMain.btStart.Text := 'START';
end;

end.
