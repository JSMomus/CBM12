unit unRateFuncs;

interface

uses
  System.IOUtils, System.SysUtils, System.Classes,
  unMarketTypes, unHFuncs1;

type

TRateProps = record
  kind: TBookKind;
  part: single;
  dvt: single;    //deviation
end;

TTimedRate = record
  rat: double;
  tim: TDateTime;
end;

function FBRateToString(AFBRate: TFBRate): string;
procedure StringToFBRates(ADest: string; var OFBRate: TFBRate);
procedure ReadRates(AFileName: string; var AFBRates: TFBRates; AExpTime: double);
procedure WriteRates(AFileName: string; AGlasses: TGlasses;
          var AFBRates: TFBRates);
procedure RatesAnal(AFBRates: TFBRates; AGlasses: TGlasses; var ORates: TRates;
                    Timed: boolean = False);

implementation

function FBRateToString(AFBRate: TFBRate): string;
var
  i1: integer;
  hStr: string;
begin
  hStr := AFBRate.pair + '{';
  for i1 := 0 to Length(AFBRate.fbRates) - 1 do
  begin
    hStr := hStr + AFBRate.fbRates[i1].fRate.ToString(ffFixed, 20, 8) + ';';
    hStr := hStr + AFBRate.fbRates[i1].bRate.ToString(ffFixed, 20, 8) + ';';
    hStr := hStr + DateTimeToStr(AFBRate.fbRates[i1].time);
    if i1 = Length(AFBRate.fbRates) - 1 then
      hStr := hStr +'}'
    else
      hStr := hStr + '/';
  end;

  Result := hStr;
end;

procedure StringToFBRI(ADest: string; var OFBRI: TFBRateItem);
var
  pos1: integer;
  hStr: string;
begin
  pos1 := Pos(';', ADest);
  hStr := Copy(ADest, 1, pos1 - 1);
  OFBRI.fRate := DCStrToDouble(hStr);
  ADest := Copy(ADest, pos1 + 1, Length(ADest) - pos1);

  pos1 := Pos(';', ADest);
  hStr := Copy(ADest, 1, pos1 - 1);
  OFBRI.bRate := DCStrToDouble(hStr);
  ADest := Copy(ADest, pos1 + 1, Length(ADest) - pos1);

  OFBRI.time := StrToDateTime(ADest);
end;

procedure StringToFBRates(ADest: string; var OFBRate: TFBRate);
var
  pos1: integer;
  hStr: string;
  fbri: TFBRateItem;
begin
  pos1 := Pos('{', ADest);

  if pos1 > 0 then
  begin
    OFBRate.pair := Copy(ADest, 1, pos1 - 1);
    SetLength(OFBRate.fbRates, 0);

    ADest := Copy(ADest, pos1 + 2, Length(ADest) - pos1 - 2);
    if Length(ADest) > 0 then
      repeat
        pos1 := Pos('/', ADest);
        if pos1 > 0 then
        begin
          hStr := Copy(ADest, 1, pos1 - 1);
          ADest := Copy(ADest, pos1 + 1, Length(ADest) - pos1);
          StringToFBRI(hStr,  fbri);
          Insert(fbri, OFBRate.fbRates, Length(OFBRate.fbRates));
        end
        else
          if Length(ADest) > 0 then
          begin
            StringToFBRI(ADest,  fbri);
            Insert(fbri, OFBRate.fbRates, Length(OFBRate.fbRates));
            ADest := '';
          end;
      until ADest = '';
  end
  else
    OFBRate.pair := 'empty';
end;

procedure CutFBRates(var AFBRates: TFBRates; AExpTime: double);
var
  i1, i2: integer;
  timeMatch: boolean;
begin
  for i1 := 0 to Length(AFBRates) - 1 do
  begin
    i2 := 0;
    timeMatch := False;
    repeat
      if i2 > Length(AFBRates[i1].fbRates) - 1 then
        timeMatch := True
      else
        if (Now - AFBRates[i1].fbRates[i2].time < AExpTime) then
          timeMatch := True
        else
          i2 := i2 + 1;
    until timeMatch;

    if i2 < Length(AFBRates[i1].fbRates) then
      AFBRates[i1].fbRates := Copy(AFBRates[i1].fbRates, i2,
              Length(AFBRates[i1].fbRates) - i2 + 1);

  end;
end;

procedure ReadRates(AFileName: string; var AFBRates: TFBRates; AExpTime: double);
var
  hSL: TStringList;
  hStr: string;
  i1: integer;
  fbRate: TFBRate;
begin
  AFileName := TPath.Combine(TPath.GetHomePath, AFileName);

  hSL := TStringList.Create;
  SetLength(AFBRates, 0);

  if TFile.Exists(AFileName) then
  begin
    hSL.LoadFromFile(AFileName);
    for i1 := 0 to hSL.Count - 1 do
    begin
      hStr := hSL.Strings[i1];
      StringToFBRates(hStr, fbRate);
      Insert(fbRate, AFBRates, Length(AFBRates));
    end;
  end;

  hSL.Free;

  CutFBRates(AFBRates, AExpTime);
end;

procedure WriteRates(AFileName: string; AGlasses: TGlasses;
          var AFBRates: TFBRates);
var
  i1, i2, pInd: integer;
  hSL: TStringList;
  hStr: string;
  fbRate: TFBRate;
  fbri: TFBRateItem;
begin
  AFileName := TPath.Combine(TPath.GetHomePath, AFileName);

  hSL := TStringList.Create;

  for i1 := 0 to Length(AGlasses) - 1 do
  begin
    pInd := -1;
    for i2 := 0 to Length(AFBRates) - 1 do
      if AGlasses[i1].pair = AFBRates[i2].pair then
      begin
        pInd := i2;
        Break
      end;

    fbri.fRate := AGlasses[i1].bids[0].rate;
    fbri.bRate := AGlasses[i1].asks[0].rate;
    fbri.time := Now;
    if pInd <> -1 then
      Insert(fbri, AFBRates[i2].fbRates, Length(AFBRates[i2].fbRates))
    else
    begin
      fbRate.pair := AGlasses[i1].pair;
      SetLength(fbRate.fbRates, 0);
      Insert(fbri, fbRate.fbRates, Length(fbRate.fbRates));
      Insert(fbRate, AFBRates, Length(AFBRates));
    end;
  end;

  for i1 := 0 to Length(AFBRates) - 1 do
  begin
    hStr := FBRateToString(AFBRAtes[i1]);
    hSL.Add(hStr);
  end;

  if TFile.Exists(AFileName) then
    TFile.Delete(AFileName);

  TFile.Create(AFileName);
  hSL.SaveToFile(AFileName);

  hSL.Free;
end;

function RateAnal(ARate: TArray<TTimedRate>; Timed: boolean = False): TRateProps;
var
  minInd, maxInd, i1: integer;
  minRate, maxRate: double;
begin
  minInd := 0; maxInd := 0;
  minRate := ARate[0].rat; maxRate := ARate[0].rat;

  for i1 := 0 to Length(ARate)-1 do
  begin
    if minRate > ARate[i1].rat then
    begin
      minInd := i1;
      minRate := ARate[i1].rat;
    end;

    if maxRate < ARate[i1].rat then
    begin
      maxInd := i1;
      maxRate := ARate[i1].rat;
    end;
  end;

  if Length(ARate) < 3 then
  begin
    Result.kind := bkRise;
    Result.part := 0;
    Result.dvt := 0;
  end
  else
    if minInd = maxInd then
    begin
      Result.kind := bkLine;
      Result.part := 0;
      Result.dvt := 0;
    end
    else
      if minInd = Length(ARate) - 1 then
      begin
        Result.kind := bkFall;
        if Timed then
          Result.part :=  (ARate[minInd].tim - ARate[maxInd].tim) / Length(ARate)
        else
          Result.part :=  (Length(ARate) - maxInd - 1) / Length(ARate);
        Result.dvt := (ARate[maxInd].rat - ARate[minInd].rat) /
                      ARate[maxInd].rat;
      end
      else
      begin
        if minInd > 0 then
          ARate := Copy(ARate, minInd - 1, Length(ARate) - minInd);

        maxInd := 0; maxRate := ARate[0].rat;
        for i1 := 0 to Length(ARate)-1 do
          if maxRate < ARate[i1].rat then
          begin
            maxInd := i1;
            maxRate := ARate[i1].rat;
          end;

        if maxInd = Length(ARate) - 1 then
        begin
          Result.kind := bkRise;
          Result.part := 1;
          Result.dvt := (ARate[maxInd].rat - ARate[0].rat)/ARate[0].rat;
        end
        else
        begin
          Result.kind := bkFall;
          if Timed then
            Result.part :=  (ARate[Length(ARate) - 1].tim - ARate[maxInd].tim) /
                            (ARate[Length(ARate) - 1].tim - ARate[0].tim)
          else
            Result.part :=  (Length(ARate) - 1 - maxInd)/Length(ARate);
          Result.dvt := (ARate[maxInd].rat - ARate[Length(ARate) - 1].rat) /
                        ARate[maxInd].rat;
        end;
      end;
end;


procedure RatesAnal(AFBRates: TFBRates; AGlasses: TGlasses; var ORates: TRates;
                    Timed: boolean = False);
var
  hRate: TArray<TTimedRate>;
  tmpRate: TRate;
  i1, i2, pInd: integer;
begin
  SetLength(ORates, 0);

  for i1 := 0 to Length(AGlasses) - 1 do
  begin
    tmpRate.pair := AGlasses[i1].pair;
    tmpRate.fRate := AGlasses[i1].bids[0].rate;
    tmpRate.bRate := AGlasses[i1].asks[0].rate;

    pInd := -1;
    for i2 := 0 to Length(AFBRates) - 1 do
    if AGlasses[i1].pair = AFBRates[i2].pair then
    begin
      pInd := i2;
      Break
    end;

    if pInd = -1 then
    begin
      tmpRate.fKind := bkLine;
      tmpRate.fPart := 0;
      tmpRate.fDvt := 0;
      tmpRate.bKind := bkLine;
      tmpRate.bPart := 0;
      tmpRate.bDvt := 0;
    end
    else
    begin
      SetLength(hRate, Length(AFBRates[pInd].fbRates));
      for i2 := 0 to Length(hRate) - 1 do
      begin
        hRate[i2].rat := AFBRates[pInd].fbRates[i2].fRate;
        hRate[i2].tim := AFBRates[pInd].fbRates[i2].time;
      end;
      tmpRate.fKind := RateAnal(hRate, Timed).kind;
      tmpRate.fPart := RateAnal(hrate, Timed).part;
      tmpRate.fDvt := RateAnal(hrate, Timed).dvt;

      for i2 := 0 to Length(hRate) - 1 do
      begin
        hRate[i2].rat := 1/AFBRates[pInd].fbRates[i2].bRate;
        hRate[i2].tim := AFBRates[pInd].fbRates[i2].time;
      end;
      tmpRate.bKind := RateAnal(hRate, Timed).kind;
      tmpRate.bPart := RateAnal(hrate, Timed).part;
      tmpRate.bDvt := RateAnal(hrate, Timed).dvt;
    end;

    Insert(tmpRate, ORates, Length(ORates));
  end;

  SetLength(hRate, 0);
end;

end.
