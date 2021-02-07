unit unHFuncs1;

interface

uses
  FMX.Memo, System.SysUtils, System.DateUtils,
  unGlobals;

procedure MemoAppendWidth(AMemo: TMemo; AString: string);
function Nonce: string;
function DCStrToDouble(ADest: string): double;
function DoubleToDStr(ANumber: double; digs, prec: integer): string;
function DblRoundDown(ANumber: double; digs: integer): double;
function DblRoundUp(ANumber: double; digs: integer): double;
function CoinStr(ACoins: TCoins): string;
function OrderStr(AOrder: TOrderID; ACoins: TCoins): string;
function CoinIDByName(ACName: string; ACoins: TCoins): integer;

implementation

procedure MemoAppendWidth(AMemo: TMemo; AString: string);
var
  hStr: string;
  fntSize: single;
  strLen, i1, iStart, iEnd: integer;
  textFinish: boolean;
begin
  fntSize := AMemo.Font.Size;
  strLen := Round(AMemo.Width*1.2/fntSize);

  iStart := 0;
  textFinish := False;
  if Length(AString) > 0 then
    repeat
      if iStart < Length(AString) then
      begin
        iEnd := iStart + strLen - 1;
        if iEnd > Length(AString) - 1 then
          iEnd := Length(AString) - 1;

        hStr := Copy(AString, iStart, iEnd - iStart + 1);
        iStart := iEnd + 1;
        AMemo.Lines.Append(hStr);
      end
      else
        textFinish := True;
    until textFinish;
end;

function Nonce: string;
begin
  Result := IntToStr(DateTimeToUnix(Now));
end;

function IsNumber(AChar: char): boolean;
const
  NUM_SET: string = '1234567890';
var
  i1: integer;
begin
  Result := False;
  for i1 := 0 to 9 do
    if AChar = NUM_SET[i1] then
    begin
      Result := True;
      Break
    end;
end;

function DCStrToDouble(ADest: string): double;
var
  cntr, i1, pos1: integer;
  isNum: boolean;
  intPart, fracPart: string;
begin
  cntr := 0;
  isNum := True;
  for i1 := 0 to Length(ADest)-1 do
  begin
    if not IsNumber(ADest[i1]) then
    begin
      if (ADest[i1] = '.') or (ADest[i1] = ',') then
        cntr := cntr + 1
      else
        isNum := False;

      if cntr > 1 then
        isNum := False;
    end;

    if not isNum then
      Break
  end;

  if isNum then
  begin
    pos1 := Pos(',', ADest);
    if pos1 = 0 then
      pos1 := Pos('.', ADest);

    if pos1 = 0 then
      Result := ADest.ToDouble()
    else
    begin
      intPart := Copy(ADest, 1, pos1 - 1);
      if intPart = '' then
        intPart := '0';
      fracPart := Copy(ADest, pos1+1, Length(ADest) - pos1);
      if fracPart = '' then
        fracPart := '0';
      cntr := 1;
      for i1 := 1 to Length(fracPart) do
        cntr := cntr*10;

      Result := intPart.ToDouble() + fracPart.ToDouble()/cntr;
    end;
  end
  else
    raise Exception.Create('Not valid number');
end;

function DoubleToDStr(ANumber: double; digs, prec: integer): string;
var
  hStr1, hStr2: string;
  pos1: integer;
begin
  hStr1 := ANumber.ToString(ffFixed, digs, prec);
  pos1 := Pos(',', hStr1);
  if pos1 > 0 then
  begin
    hStr2 := Copy(hStr1, pos1+1, Length(hStr1) - pos1);
    hStr1 := Copy(hStr1, 1, pos1-1);

    Result := hStr1 + '.' + hStr2;
  end
  else
    Result := hStr1;
end;

function DblRoundDown(ANumber: double; digs: integer): double;
var
  digPower: Int64;
  i1: integer;
begin
  digPower := 1;
  for i1 := 1 to digs do
    digPower := digPower * 10;
  Result := Int(ANumber * digPower);
  Result := Result/digPower;
end;

function DblRoundUp(ANumber: double; digs: integer): double;
var
  digPower: Int64;
  i1: integer;
begin
  digPower := 1;
  for i1 := 1 to digs do
    digPower := digPower * 10;
  Result := Int(ANumber * digPower) + 1;
  Result := Result/digPower;
end;

function CoinStr(ACoins: TCoins): string;
var
  i1: integer;
begin
  Result := 'c';

  for i1 := 0 to Length(ACoins)-1 do
  begin
    Result := Result + ACoins[i1].index.ToString + ';';
    Result := Result + ACoins[i1].name + ';';
    Result := Result + ACoins[i1].quant.ToString(ffFixed, 20, 8) + ';';
    Result := Result + ACoins[i1].max.ToString(ffFixed, 20, 8) + ';';
    if ACoins[i1].active then
      Result := Result + '1'
    else
      Result := Result + '1';
    if i1 <> Length(ACoins) - 1 then
      Result := Result + ';;';
  end;
end;

function FindCoin(AIndex: integer; ACoins: TCoins): string;
var
  i1: integer;
begin
  Result := '___';

  for i1 := 0 to Length(ACoins)-1 do
    if ACoins[i1].index = AIndex then
      Result := ACoins[i1].name;
end;

function OrderStr(AOrder: TOrderID; ACoins: TCoins): string;
begin
  Result := 'o' + AOrder.info.id + ';';
  Result := Result + FindCoin(AOrder.coin1ID, ACoins) + ';';
  Result := Result + FindCoin(AOrder.coin2ID, ACoins) + ';';
  Result := Result + AOrder.info.amount.ToString(ffFixed, 20, 8) + ';';
  Result := Result + AOrder.info.rate.ToString(ffFixed, 20, 8) + ';';
  if AOrder.info.dir then
    Result := Result + '1;'
  else
    Result := Result + '0;';
  Result := Result + DateTimeToStr(AOrder.info.time);
end;

function CoinIDByName(ACName: string; ACoins: TCoins): integer;
var
  i1: integer;
begin
  Result := 0;

  for i1 := 0 to Length(ACoins)-1 do
    if ACoins[i1].name = ACName then
    begin
      Result := ACoins[i1].index;
      Break
    end;
end;

end.
