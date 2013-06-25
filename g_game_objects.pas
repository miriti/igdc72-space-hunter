unit g_game_objects;

interface
uses
  g_class_gameobject, u_math, g_bonuses;

type
  TObjectsEngine = class (TGameObject)
    Objects : Array of TGameObject;
    Rendered : Integer;
    procedure Move; override;
    procedure Render; override;
    procedure AddObject(Obj : TGameObject);
    procedure DeleteObject(Index : Integer);
    procedure CollisionObjects;
    function GetNearest(Pos : TGamePos; Index : Integer; Collision : Boolean = true) : TGameObject;
    function GetNearestCoin : TGamePos;
    procedure Clear;
  private

  end;

var
  ObjectsEngine : TObjectsEngine;


implementation

uses Math, g_rockets, g_player;

{ TObjectsEngine }

procedure TObjectsEngine.AddObject(Obj: TGameObject);
begin
  SetLength(Objects, Length(Objects)+1);
  Obj.Index := High(Objects);
  Obj.Parent := Self;
  Objects[High(Objects)] := Obj;
end;

procedure TObjectsEngine.Clear;
var
  i:Integer;
begin
  for i := 0 to High(Objects) do
  begin
    Objects[i].Free;
  end;

  SetLength(Objects, 0);
end;

procedure TObjectsEngine.CollisionObjects;
var
  i,j:Integer;
begin
  for i := 0 to High(Objects) do
  begin
    for j := i+1 to High(Objects)-1 do
    begin
      if Objects[i].Collision and Objects[j].Collision then
      begin
        if Distance(Objects[i].Pos, Objects[j].Pos) <= (Objects[i].Radius + Objects[j].Radius) then
        begin
          Objects[i].DoCollision(MakeNormalVector(Objects[i].Pos.x - Objects[j].Pos.x, 0, Objects[i].Pos.z - Objects[j].Pos.z), Objects[j]);
          Objects[j].DoCollision(MakeNormalVector(Objects[j].Pos.x - Objects[i].Pos.x, 0, Objects[j].Pos.z - Objects[i].Pos.z), Objects[i]);
        end;
      end;
    end;
  end;
end;

procedure TObjectsEngine.DeleteObject(Index: Integer);
begin
  Objects[Index] := Objects[High(Objects)];
  SetLength(Objects, Length(Objects)-1);
end;

function TObjectsEngine.GetNearest(Pos: TGamePos; Index: Integer;
  Collision: Boolean): TGameObject;
var
  i : Integer;
  mind : Single;
begin
  Result := nil;
  mind := 1000000;
  for i := 0 to High(Objects) do
  begin
    if i <> Index then
    begin
      if (Objects[i].Collision) and not (Objects[i] is TSimpleRocket) then
      begin

      if Distance(Pos, Objects[i].Pos) < mind then
        Result := Objects[i];

      end;
    end;
  end;
end;

function TObjectsEngine.GetNearestCoin: TGamePos;
var
  i:Integer;
  mindis, dis : Single;
begin
  mindis := 10000000;

  for i := 0 to High(Objects) do
  begin
    if Objects[i] is TCoin then
    begin
      dis := Distance(Player.Pos, Objects[i].Pos);
      if dis < mindis then
      begin
        Result := Objects[i].Pos;
        mindis := dis;
      end;
    end;
  end;
end;

procedure TObjectsEngine.Move;
var
  i:Integer;
begin
  inherited;
  for i := 0 to High(Objects) do
    if not Objects[i].Freeze then
      Objects[i].Move;

  for i := High(Objects) downto 0 do
  begin
    if (Objects[i].Health <= 0) and not (Objects[i].Unkill) then
    begin
      Objects[i].Death;
      Objects[i].Free;
      DeleteObject(i);
    end;
  end;
end;

procedure TObjectsEngine.Render;
var
  i:Integer;
begin
  inherited;
  Rendered := 0;
  for i := 0 to High(Objects) do
  begin
    //if Distance(Player.Pos, Objects[i].Pos) < 30 then
    //begin
      if not Objects[i].Hide then
      begin
        Objects[i].Render;
        inc(Rendered);
      end;
    //end;
  end;
end;

initialization
  ObjectsEngine := TObjectsEngine.Create;

end.
