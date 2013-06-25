unit g_rockets;

interface
uses
  OpenGL, g_class_gameobject, g_game_objects, u_math, u_sound, g_sounds;

type
  TTrail = class (TGameObject)
    Scale : Single;
    procedure Move; override;
    procedure Render; override;
    procedure Death; override;
    constructor Create;
  end;

  TSimpleRocket = class (TGameObject)
    LockOn : TGameObject;
    FiredBy : TGameObject;
    TrailTime : Integer;
    procedure Move; override;
    procedure Render; Override;
    procedure Death; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    constructor Create;
  end;

  TExtraRocket = class (TSimpleRocket)
    procedure Move; override;
    procedure Render; Override;
    procedure Death; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    constructor Create;
  end;

  TStraightRocket = class (TSimpleRocket)
    procedure Move; override;
    procedure Render; Override;
    procedure Death; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
  end;

  TBullet = class (TGameObject)
    FiredBy : TGameObject;
    procedure Move; override;
    procedure Render; override;
    procedure Death; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    constructor Create;
  end;

  TAIMBullet = class (TBullet)
    LockOn : TGameObject;
    procedure Move; override;
    procedure Render; override;
    procedure Death; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    constructor Create;
  end;

  TWeb = class (TGameObject)
    LockOn : TGameObject;
    procedure Move; override;
    procedure Render; override;
    procedure Death; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    constructor Create(Target : TGameObject);
  end;

  TWebRocket = class (TSimpleRocket)
    procedure Move; override;
    procedure Render; Override;
    procedure Death; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    constructor Create;
  end;

  TExplosion = class (TGameObject)
    procedure Move; override;
    procedure Render; override;
    procedure Death; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    constructor Create;
  end;

implementation

{ TSimpleRocket }

constructor TSimpleRocket.Create;
begin
  Health := 100;
  Radius := 0.25;
  Collision := True;
  TrailTime := 5;
  Speed := 0.16;
  Sound_PlayStream(Rocket_Sound);
end;

procedure TSimpleRocket.Death;
begin
  inherited;
//
end;

procedure TSimpleRocket.DoCollision(Vector: TGamePos; CoObject: TObject);
var
  Expl : TExplosion;
begin
  inherited;
  if not (CoObject is TSimpleRocket) and not (CoObject is TTrail) and not (CoObject = FiredBy)  then
  begin
    (CoObject as TGameObject).Health := (CoObject as TGameObject).Health - 10; 
    Health := 0;
    Expl := TExplosion.Create;
    Expl.Pos := Pos;
    ObjectsEngine.AddObject(Expl);
  end;
end;

procedure TSimpleRocket.Move;
var
  Trail : TTrail;
  DVector : TGamePos;
  ToAng : Single;
begin
  inherited;

  ToAng := AngleTo(Pos.x, Pos.z, LockOn.Pos.x, LockOn.Pos.z);

  if Angle <  ToAng then
    Angle := Angle + 5 else
      Angle := Angle - 5;

  if TrailTime <= 0 then
  begin
    Trail := TTrail.Create;
    Trail.Pos := Pos;
    ObjectsEngine.AddObject(Trail);
    TrailTime := 5;
  end;

  dec(TrailTime);

  if TrailTime < 0 then TrailTime := 0;

  DVector := MakeNormalVector(Cosinus(Angle), 0.0, Sinus(Angle));

  Pos := AddVector(Pos, MultiplyVectorScalar(DVector, Speed));

  Health := Health - 0.01;

end;

procedure TSimpleRocket.Render;
begin
  inherited;

  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);
  glRotatef(90-Angle, 0.0, 1.0, 0.0);

  glColor3f(1.0, 0.0, 0.0);
  glBegin(GL_LINE_LOOP);
    glVertex3f(0, 0, 0.25);
    glVertex3f(0.1, 0, -0.25);
    glVertex3f(-0.1, 0, -0.25);
  glEnd;

  glPopMatrix;

end;

{ TTrail }

constructor TTrail.Create;
begin
  Collision := False;
  Health := 100;
  Scale := 1;
end;

procedure TTrail.Death;
begin
  inherited;
//
end;

procedure TTrail.Move;
begin
  Health := Health - 0.5;
end;

procedure TTrail.Render;
begin
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);
  glColor3f(0.5, 0.5, 0.5);

  glRotatef(Random(360), 0.0, 1.0, 0.0);
  glScalef(Scale, Scale, Scale);

  glBegin(GL_QUADS);
    glVertex3f(-0.1, 0.0, -0.1);
    glVertex3f( 0.1, 0.0, -0.1);
    glVertex3f( 0.1, 0.0,  0.1);
    glVertex3f(-0.1, 0.0,  0.1);
  glEnd;

  glPopMatrix;
end;

{ TBullet }

constructor TBullet.Create;
begin
  Health := 100;
  Collision := True;
  Radius := 0.1;
end;

procedure TBullet.Death;
begin
  inherited;

end;

procedure TBullet.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;
  if CoObject <> FiredBy then
  begin
    Health := 0;
    (CoObject as TGameObject).Health := (CoObject as TGameObject).Health - 25;

  end;
end;

procedure TBullet.Move;
begin
  inherited;
  Pos := AddVector(Pos, MultiplyVectorScalar(MVector, 2));
  Health := Health - 0.5;
end;

procedure TBullet.Render;
begin
  inherited;
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glColor3f(1.0, 1.0, 0.0);

  glPointSize(3);

  glBegin(GL_POINTS);
    glVertex3f(0.0, 0.0, 0.0);
  glEnd;

  glPointSize(1);

  glPopMatrix;
end;

{ TExplosion }

constructor TExplosion.Create;
begin
  Health := 10;
  Collision := False;
  Sound_PlayStream(Explod_Sound);
end;

procedure TExplosion.Death;
begin
  inherited;

end;

procedure TExplosion.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;

end;

procedure TExplosion.Move;
begin
  inherited;
  Health := Health - 0.5;
end;

procedure TExplosion.Render;
var
  a:Integer;
begin
  inherited;

  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glRotatef(Random(360), 0.0, 1.0, 0.0);

  glColor3f(1-(Health / 10), 1, 0);

  glBegin(GL_POLYGON);
    for a := 0 to 5 do
    begin
      glVertex3f(Cosinus(a * 72), 0, Sinus(a * 72));
    end;
  glEnd;

  glPopMatrix;

end;

{ TExtraRocket }

constructor TExtraRocket.Create;
begin
  Health := 100;
  Collision := False;
end;

procedure TExtraRocket.Death;
begin
  inherited;
  //
end;

procedure TExtraRocket.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  //inherited;

end;

procedure TExtraRocket.Move;
var
  Rock : TSimpleRocket;
  Expl : TExplosion;
  i:Integer;
  Trail : TTrail;
  DVector : TGamePos;
begin

  {if LockOn = nil then Health := 0;
  if LockOn.Fake <> nil then LockOn := LockOn.Fake as TGameObject;}

  Angle := AngleTo(Pos.x, Pos.z, LockOn.Pos.x, LockOn.Pos.z);

  if Distance(Pos, LockOn.Pos) < 5 then
  begin
    Health := 0;
    for i := 1 to 3 do
    begin
      Rock := TSimpleRocket.Create;
      Rock.Pos := AddVector(Pos, MakeVector(Cosinus(Angle + (i * 90 - 180)), 0, Sinus(Angle + (i * 90 - 180))));
      Rock.LockOn := LockOn;
      Rock.Angle := Angle + (i * 90 - 180);
      Rock.FiredBy := FiredBy;

      ObjectsEngine.AddObject(Rock);
    end;

    Expl := TExplosion.Create;
    Expl.Pos := Pos;
    ObjectsEngine.AddObject(Expl);
  end else
  begin

    if TrailTime <= 0 then
    begin
      Trail := TTrail.Create;
      Trail.Pos := Pos;
      ObjectsEngine.AddObject(Trail);
      TrailTime := 5;
    end;

    dec(TrailTime);

    if TrailTime < 0 then TrailTime := 0;

    DVector := MakeNormalVector(Cosinus(Angle), 0.0, Sinus(Angle));

    Pos := AddVector(Pos, MultiplyVectorScalar(DVector, 0.2));

    Health := Health - 0.01;
  end;
end;

procedure TExtraRocket.Render;
var
  a : Integer;
begin
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glColor3f(1.0, 1.0, 0.0);

  glBegin(GL_LINE_LOOP);
  for a := 0 to 5 do
  begin
    glVertex3f(Cosinus(a * 72) * 0.3, 0, Sinus(a * 72) * 0.3);
  end;
  glEnd;

  glPopMatrix;
end;

{ TAIMBullet }

constructor TAIMBullet.Create;
begin
  Health := 100;
  Collision := True;
  Radius := 0.1;

  Sound_PlayStream(Shot_2);
end;

procedure TAIMBullet.Death;
begin
  inherited;

end;

procedure TAIMBullet.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  if CoObject <> FiredBy then
  begin
    (CoObject as TGameObject).Health := (CoObject as TGameObject).Health - 5;
    Health := 0;
  end;
end;

procedure TAIMBullet.Move;
begin

  Angle := AngleTo(Pos.x, Pos.z, LockOn.Pos.x, LockOn.Pos.z);

  MVector := MultiplyVectorScalar(MakeVector(Cosinus(Angle), 0, Sinus(Angle)), 0.12);
  Pos := AddVector(Pos, MVector);

  Health := Health - 0.3;

end;

procedure TAIMBullet.Render;
begin
  inherited;
end;

{ TWeb }

constructor TWeb.Create;
begin
  Collision := False;
  Health := 100;
  LockOn := Target;
  LockOn.Freeze := True;
end;

procedure TWeb.Death;
begin
  inherited;
  LockOn.Freeze := False;

end;

procedure TWeb.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;

end;

procedure TWeb.Move;
begin
  Health := Health - 0.25;
end;

procedure TWeb.Render;
var
  a : Integer;
begin
  glPushMatrix;

  glTranslatef(LockOn.Pos.x, LockOn.Pos.y, LockOn.Pos.z);
  glColor3f(0.8, 0.8, 0.8);

  glBegin(GL_LINE_LOOP);
  for a := 0 to 5 do
  begin
    glVertex3f(Cosinus(a * 60), 0, Sinus(a * 60));
  end;
  glEnd;

  glBegin(GL_LINE_LOOP);
  for a := 0 to 5 do
  begin
    glVertex3f(Cosinus(a * 60) * 2, 0, Sinus(a * 60) * 2);
  end;
  glEnd;

  glBegin(GL_LINES);
  for a := 0 to 5 do
  begin
    glVertex3f(Cosinus(a * 60), 0, Sinus(a * 60));
    glVertex3f(Cosinus(a * 60)*3, 0, Sinus(a * 60)*3);
  end;
  glEnd;

  glPopMatrix;
end;

{ TWebRocket }

constructor TWebRocket.Create;
begin
  Health := 100;
  Radius := 0.25;
  Collision := True;
end;

procedure TWebRocket.Death;
var
  Expl : TExplosion;
begin

  Expl := TExplosion.Create;
  Expl.Pos := Pos;
  ObjectsEngine.AddObject(Expl);

end;

procedure TWebRocket.DoCollision(Vector: TGamePos; CoObject: TObject);
var
  Web : TWeb;
begin
  if CoObject = LockOn then
  begin
    Web := TWeb.Create(LockOn);
    ObjectsEngine.AddObject(Web);
    Health := 0;
  end;
end;

procedure TWebRocket.Move;
var
  Trail : TTrail;
begin

  Angle := AngleTo(Pos.x, Pos.z, LockOn.Pos.x, LockOn.Pos.z);
  MVector := MultiplyVectorScalar(MakeVector(Cosinus(Angle), 0, Sinus(Angle)), 0.13);

  Pos := AddVector(Pos, MVector) ;

    if (TrailTime <= 0) then
    begin
      Trail := TTrail.Create;
      Trail.Pos := Pos;
      ObjectsEngine.AddObject(Trail);
      TrailTime := 5;
    end;

    dec(TrailTime);

    if TrailTime < 0 then TrailTime := 0;

  Health := Health - 0.1;
end;

procedure TWebRocket.Render;
var
  a : Integer;
begin
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glColor3f(1.0, 1.0, 1.0);

  glBegin(GL_LINE_LOOP);
  for a := 0 to 5 do
  begin
    glVertex3f(Cosinus(a * 72) * 0.3, 0, Sinus(a * 72) * 0.3);
  end;
  glEnd;

  glPopMatrix;
end;

{ TStraightRocket }

procedure TStraightRocket.Death;
begin
  inherited;

end;

procedure TStraightRocket.DoCollision(Vector: TGamePos; CoObject: TObject);
var
  Expl : TExplosion;
begin
  inherited;
  if not (CoObject is TSimpleRocket) and not (CoObject is TTrail) and not (CoObject = FiredBy)  then
  begin
    (CoObject as TGameObject).Health := (CoObject as TGameObject).Health - 50; 
    Health := 0;
    Expl := TExplosion.Create;
    Expl.Pos := Pos;
    ObjectsEngine.AddObject(Expl);
  end;
end;

procedure TStraightRocket.Move;
var
  Trail : TTrail;
begin

  if TrailTime <= 0 then
  begin
    Trail := TTrail.Create;
    Trail.Pos := Pos;
    ObjectsEngine.AddObject(Trail);
    TrailTime := 5;
  end;

  dec(TrailTime);

  if TrailTime < 0 then TrailTime := 0;

  Pos := AddVector(Pos, MultiplyVectorScalar(MVector, Speed));
end;

procedure TStraightRocket.Render;
begin
  inherited;
end;

end.
