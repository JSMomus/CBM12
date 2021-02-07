unit unMarketTypes;

interface

type

TGlassItem = record
  rate, quant: double;
end;

TGlass = TArray<TGlassItem>;

TPairGlasses = record
  pair: string;
  asks, bids: TGlass;
end;

TGlasses = TArray<TPairGlasses>;

TBookKind = ( bkRise = 0,
              bkFall = 1,
              bkLine = 2);
//For object
TRate = record
  pair: string;
  fRate, bRate: double;
  fKind: TBookKind;
  fPart, fDvt: single;
  bKind: TBookKind;
  bPart, bDvt: single;
end;

TRates = TArray<TRate>;
//For files
TFBRateItem = record    //forward-back rate
  fRate, bRate: double;
  time: TDateTime;
end;

TFBRate = record
  pair: string;
  fbRates: TArray<TFBRateItem>;
end;

TFBRates = TArray<TFBRate>;
//===============================================

implementation

end.
