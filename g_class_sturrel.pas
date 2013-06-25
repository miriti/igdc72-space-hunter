unit g_class_sturrel;

interface
uses
  OpenGL, g_class_gameobject, g_game_objects, g_rockets, g_player, u_math, u_sound, g_sounds;

type
  TSimpleTurrel = class (TGameObject)
    FireTime : Integer;
    procedure Render; override;
    procedure Move; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    procedure Death; override;
    constructor Create;
  end;

  TMiniTurrel = class (TSimpleTurrel)
    procedure Render; override;
    procedure Move; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    procedure Death; override;
    constructor Create;
  end;

  TWebTurrel = class (TSimpleTurrel)
    procedure Render; override;
    procedure Move; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    procedure Death; override;
    constructor Create;
  end;

implementation
uses
  g_world;

{ TSimpleTurrel }

constructor TSimpleTurrel.Create;
begin
  Health := 100;
  Radius := 0.5;
  Collision := True;
  FireTime := 500;
end;

procedure TSimpleTurrel.Death;
var
  Expl : TExplosion;
begin
  Expl := TExplosion.Create;
  Expl.Pos := Pos;
  ObjectsEngine.AddObject(Expl);

  inc(World.Score, 100);
end;

procedure TSimpleTurrel.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;
//
end;

procedure TSimpleTurrel.Move;
var
  Rocket : TExtraRocket;
begin
  if Distance(Pos, Player.Pos) <= 20 then
  begin
    Angle := 90-AngleTo(Pos.x, Pos.z, Player.Pos.x, Player.Pos.z);
    if FireTime = 0 then
    begin
      Rocket := TExtraRocket.Create;
      Rocket.Pos := AddVector(Pos, MakeNormalVector(Cosinus(90-Angle), 0.0, Sinus(90-Angle)));
      Rocket.LockOn := Player;
      Rocket.FiredBy := Self;
      ObjectsEngine.AddObject(Rocket);
      FireTime := 500;
    end;
  end;

  Dec(FireTime);

  if FireTime < 0 then FireTime := 0;
end;

procedure TSimpleTurrel.Render;
begin
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glColor3f(1 - Health / 100, Health/100, 0.2);
  glBegin(GL_LINE_LOOP);
    glVertex3f(-0.5, 0.0, -0.5);
    glVertex3f( 0.5, 0.0, -0.5);
    glVertex3f( 0.5, 0.0,  0.5);
    glVertex3f(-0.5, 0.0,  0.5);
  glEnd;

  glRotatef(Angle, 0.0, 1.0, 0.0);

  glColor3f(1.0 - (FireTime / 500), (FireTime / 500), 0.0);
  glBegin(GL_LINE_LOOP);
    glVertex3f(-0.1, 0.0, 0.0);
    glVertex3f( 0.1, 0.0, 0.0);
    glVertex3f( 0.1, 0.0, 1);
    glVertex3f(-0.1, 0.0, 1);
  glEnd;

  glPopMatrix;
end;

{ TMiniTurrel }

constructor TMiniTurrel.Create;
begin
  Health := 50;
  Collision := True;
  Radius := 0.25;
  FireTime := 50;
end;

procedure TMiniTurrel.Death;
begin
  inherited;
  inc(World.Score, 50);
end;

procedure TMiniTurrel.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;

end;

procedure TMiniTurrel.Move;
var
  Bullet : TAIMBullet;
begin
  if Distance(Pos, Player.Pos) <= 30 then
  begin
    Angle := AngleTo(Pos.x, Pos.z, Player.Pos.x, Player.Pos.z);
    if FireTime = 0 then
    begin
      Bullet := TAIMBullet.Create;
      Bullet.Pos := AddVector(Pos, MakeVector(Cosinus(Angle), 0, Sinus(Angle)));
      Bullet.LockOn := Player;
      Bullet.FiredBy := Self;
      ObjectsEngine.AddObject(Bullet);
      FireTime := 50;
    end;
  end;

  Dec(FireTime);

  if FireTime < 0 then FireTime := 0;

end;

procedure TMiniTurrel.Render;
begin
  glPushMatrix;
  glTranslatef(Pos.x, Pos.y, Pos.z);

  glColor3f(1 - (Health / 50), Health / 50, 0.0);
  glBegin(GL_LINE_LOOP);
    glVertex3f(-0.25, 0, -0.25);
    glVertex3f( 0.25, 0, -0.25);
    glVertex3f( 0.25, 0,  0.25);
    glVertex3f(-0.25, 0,  0.25);
  glEnd;

  glRotatef(90-Angle, 0.0, 1.0, 0.0);

  glColor3f(1.0, 0.0, 0.0);
  glBegin(GL_LINE_LOOP);
    glVertex3f(   0, 0,  0);
    glVertex3f(-0.1, 0,  1);
    glVertex3f( 0.1, 0,  1);
  glEnd;

  glPopMatrix;
end;

{ TWebTurrel }

constructor TWebTurrel.Create;
begin
  Health := 100;
  Collision := True;
  Radius := 0.5;
  FireTime := 500;
end;

procedure TWebTurrel.Death;
var
  Expl : TExplosion;
begin
  Expl := TExplosion.Create;
  Expl.Pos := Pos;
  ObjectsEngine.AddObject(Expl);

inc(World.Score, 150);
end;

procedure TWebTurrel.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;

end;

procedure TWebTurrel.Move;
var
  WebRocket : TWebRocket;
begin
  if Distance(Pos, Player.Pos) < 30 then
  begin
    Angle := AngleTo(Pos.x, Pos.z, Player.Pos.x, Player.Pos.z);

    if (FireTime = 0) and not (Player.Freeze) then
    begin
      WebRocket := TWebRocket.Create;
      WebRocket.Pos := AddVector(Pos, MakeNormalVector(Cosinus(90-Angle)*2, 0.0, Sinus(90-Angle)*2));
      WebRocket.LockOn := Player;
      WebRocket.FiredBy := Self;
      ObjectsEngine.AddObject(WebRocket);
      FireTime := 500;

      Sound_PlayStream(Shot_2);
    end;
  end;
  Dec(FireTime);

  if FireTime < 0 then FireTime := 0;
end;

procedure TWebTurrel.Render;
var
  a : Integer;
begin
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glColor3f(1 - (Health / 100), Health / 100, 0);
  glBegin(GL_LINE_LOOP);
  for a := 0 to 18 do
  begin
    glVertex3f(Cosinus(a * 20), 0, Sinus(a * 20));
  end;
  glEnd;

  glRotatef(90-Angle, 0, 1, 0);
  glColor3f(1.0, 0.0, 0.0);
  glBegin(GL_LINE_LOOP);
    glVertex3f(   0, 0,  0);
    glVertex3f(-0.5, 0,  2);
    glVertex3f( 0.5, 0,  2);
  glEnd;

  glPopMatrix;
end;

end.
