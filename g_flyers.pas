unit g_flyers;

interface
uses
  OpenGL, u_math, g_class_gameobject, g_game_objects, g_player, g_rockets;

type
  TEnemyFlyer = class (TGameObject)
    Target : TGameObject;
    FireTime : Integer;
    procedure Move; override;
    procedure Render; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    procedure Death; override;
    constructor Create;
  end;

var
  TestEnemy : TEnemyFlyer;

implementation
uses
  g_world;

{ TEnemyFlyer }

constructor TEnemyFlyer.Create;
begin
  Radius := 0.5;
  Collision := True;
  Health := 100;
  FireTime := 100;
  Speed := 0;
end;

procedure TEnemyFlyer.Death;
var
  Expl : TExplosion;
begin
  Expl := TExplosion.Create;
  Expl.Pos := Pos;
  ObjectsEngine.AddObject(Expl);

  inc(World.Score, 500);
end;

procedure TEnemyFlyer.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;

end;

procedure TEnemyFlyer.Move;
var
  Rocket : TSimpleRocket;
begin
  inherited;

  if Distance(Pos, Target.Pos) < 30 then
  begin
    Angle := AngleTo(Pos.x, Pos.z, Target.Pos.x, Target.Pos.z);
    if Distance(Pos, Target.Pos) < 20 then
    begin
      if FireTime = 0 then
      begin
        Rocket := TSimpleRocket.Create;
        Rocket.Pos := AddVector(Pos, MakeNormalVector(Cosinus(Angle)*2, 0.0, Sinus(Angle)*2));
        Rocket.LockOn := Player;
        Rocket.FiredBy := Self;
        Rocket.Speed := 0.20;
        ObjectsEngine.AddObject(Rocket);
        FireTime := 100;
      end;
      Dec(FireTime);

      if Speed > 0 then
        Speed := Speed - 0.001;
    end else
    begin
    Speed := Speed + 0.002;
    end;
  end;

  if Speed > 0.15 then Speed := 0.14;

  MVector := MultiplyVectorScalar(MakeVector(Cosinus(Angle), 0, Sinus(Angle)), Speed);
  Pos := AddVector(Pos, MVector);

end;

procedure TEnemyFlyer.Render;
begin
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glRotatef(90-Angle, 0.0, 1.0, 0.0);

  glColor3f(1 - (Health / 100), Health / 100, 0.0);
  glBegin(GL_LINE_LOOP);
    glVertex3f(0.0, 0.0, 1.2);
    glVertex3f(0.5, 0.0, -1.2);
    glVertex3f(-0.5, 0.0, -1.2);
  glEnd;


    glColor3f(1.0, 1.0, 0.0);

    glBegin(GL_LINE_LOOP);
      glVertex3f(-0.5, 0.0, -1.2);
      glVertex3f(0.0, 0.0, -2 + (random(100)/100));
      glVertex3f(0.5, 0.0, -1.2);
    glEnd;

  glPopMatrix;
end;

end.
