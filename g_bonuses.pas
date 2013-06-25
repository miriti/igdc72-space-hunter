unit g_bonuses;

interface
uses
  OpenGL, u_math, g_class_gameobject, u_sound, g_sounds;

type
  TCoin = class (TGameObject)
    procedure Move; override;
    procedure Render; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    procedure Death; override;
    constructor Create;
  end;

implementation
uses
  g_player, g_world;

{ TCoin }

constructor TCoin.Create;
begin
  Collision := True;
  Health := 100;
  Radius := 1;
end;

procedure TCoin.Death;
begin
  //
end;

procedure TCoin.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  if CoObject = Player then
  begin
    Player.Health := Player.Health + 30;

    if Player.Health > 100 then Player.Health := 100;
    Health := 0;
    Unkill := False;
    inc(World.Coins_coll);
    inc(World.Score, 200);
    Sound_PlayStream(Bonus);
    if World.Coins_Total = World.Coins_coll then
      World.GoNextLevel;
  end;
end;

procedure TCoin.Move;
begin
  Angle := Angle + 1;
end;

procedure TCoin.Render;
var
  a : Integer;
begin
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);
  glRotatef(Angle, 1.0, 0.0, 0.0);

  glColor3f(1.0, 1.0, 0);

  glBegin(GL_POLYGON);
  for a := 0 to 18 do
  begin
    glVertex3f(Cosinus(a * 20) * 0.5, 0, Sinus(a * 20) * 0.5);
  end;
  glEnd;

  glPopMatrix;
end;

end.
