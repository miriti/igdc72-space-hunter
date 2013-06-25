unit u_math;

interface
type
  TGamePos = record
    x,y,z:Single;
  end;

function Sinus(x:Single):Single;
function Cosinus(x:Single):Single;
function Distance(Pos1, Pos2 : TGamePos) : Single;
function MakeNormalVector(x,y,z:Single):TGamePos;
function MakeVector(x,y,z:Single):TGamePos;
function AddVector(P1, P2 : TGamePos):TGamePos;
function MinusVctors(P1, P2 : TGamePos): TGamePos;
function MultiplyVectorScalar(Vector: TGamePos; Scalar : Single) : TGamePos;
function NormalAngle(a:Single):Single;
function VectorLength(Vector : TGamePos) : Single;
function NormalizeVector(Vector : TGamePos) : TGamePos;
function VectorAddScalar(Vector : TGamePos; Scalar : Single) : TGamePos;
function AngleTo(x0,z0,x1,z1:Single):Single;
function TurnToAngle(AngleTo, Angle : Single) : Integer;

implementation

function TurnToAngle;
var
  f_c, t_c : Byte;
begin

end;

function MinusVctors;
begin
  Result.x := P1.x - P2.x;
  Result.y := P1.y - P2.y;
  Result.z := P1.z - P2.z;
end;

function AngleTo(x0,z0,x1,z1:Single):Single;
var
  a:Single;
begin
  x1 := x1-x0;
  z1 := z1-z0;

  if(x1=0)then
  begin
    if z1>0 then a:=90;
    if z1<0 then a:=270;
  end else
  begin
    a := (z1/x1);
    a := abs(arctan(a))*(180/pi);
  end;

  if (x1<0)and(z1>0)then a:=180-a;
  if (x1<0)and(z1<0)then a:=180+a;
  if (x1>0)and(z1<0)then a:=360-a;

  Result := a;

end;

function VectorAddScalar;
begin
  Result.x := Vector.x + Scalar;
  Result.y := Vector.y + Scalar;
  Result.z := Vector.z + Scalar;
end;

function NormalizeVector;
begin
  Result := MakeNormalVector(Vector.x, Vector.y, Vector.z);
end;

function VectorLength;
begin
  Result := abs(sqrt(sqr(Vector.x) + sqr(Vector.y) + sqr(Vector.z)));
end;

function NormalAngle;
begin
  if a > 360 then Result := a - 360;
  if a < 0 then Result := 360 + a;

//  if (Result > 360) or (Result < 0) then Result := NormalAngle(Result);
end;

function MultiplyVectorScalar;
begin
  Result.x := Vector.x * Scalar;
  Result.y := Vector.y * Scalar;
  Result.z := Vector.z * Scalar;
end;

function MakeVector;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function AddVector;
begin
  Result.x := P1.x + P2.x;
  Result.y := P1.y + P2.y;
  Result.z := P1.z + P2.z;
end;

function MakeNormalVector;
var
  d:Single;
begin
  d:=sqrt(sqr(x)+sqr(y)+sqr(z));
  if d = 0 then d :=1;
  Result.x:=x/d;
  Result.y:=y/d;
  Result.z:=z/d;
end;

function Distance;
begin
Result := sqrt(sqr(Pos2.x-Pos1.x)+sqr(Pos2.y-Pos1.y)+sqr(Pos2.z-Pos1.z));
end;

function Cosinus;
begin
  Result := Cos(x/(180/pi));
end;

function Sinus;
begin
  Result := Sin(x/(180/pi));
end;

end.
