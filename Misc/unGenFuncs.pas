unit unGenFuncs;

interface

type

TArraysMisc = class
  class procedure ArrDelete<ArrItem>(var Mass: TArray<ArrItem>;
                  ind, count: integer);
end;

implementation

{ TArraysMisc }

class procedure TArraysMisc.ArrDelete<ArrItem>(var Mass: TArray<ArrItem>; ind,
  count: integer);
var
  tmpMass: TArray<ArrItem>;
begin
  SetLength(tmpMass, 0);

  tmpMass := Copy(Mass, 1, ind - 1);
  Mass := Copy(Mass, ind + count, Length(Mass) - ind - count + 1);
  Insert(tmpMass, Mass, 0);

  SetLength(tmpMass, 0);
end;

end.
