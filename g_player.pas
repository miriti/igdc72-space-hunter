unit g_player;

interface
uses
  OpenGL, Windows, u_winapi, u_math, g_class_gameobject, g_game_objects, g_rockets, g_hud, u_sound, g_sounds;

type
  TPlayer = class (TGameObject)
    FireTimer     : Integer;
    RocketTime    : Integer;
    FakeTimer     : Integer;
    TrailTime     : Integer;
    BlinkTime     : Integer;
    RespawnTime   : Integer;

    Blinking      : Boolean;

    SoundPlayed   : Boolean;
    LockOn        : TGameObject;

    Streif        : Single;
    procedure Move; override;
    procedure Render; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    procedure Death; override;
    procedure Stop;
  end;

  TFakePlayer = class (TGameObject)
    procedure Move; override;
    procedure Render; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    procedure Death; override;
  end;

const
  MAX_SPEED = 0.15;

var
  Player : TPlayer = nil;

implementation

uses g_world, SysUtils;

{ TPlayer }

procedure TPlayer.Death;
begin
  inherited;
  if SoundPlayed then Sound_StopStream(EngineSound);
  Sound_PlayStream(Lost_life);
  Dec(World.Lifes);
  World.ReCreatePlayer;
end;

procedure TPlayer.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;
end;

procedure TPlayer.Move;
var
  Bullet : TBullet;
  Rock : TSimpleRocket;
  Trail : TTrail;
  StrVec : TGamePos;
begin

  Angle := AngleTo(Pos.x, Pos.z, Pos.x + Hud.Cursor.Pos.x, Pos.z + Hud.Cursor.Pos.z);
  StrVec := MakeVector(0, 0, 0);

  if (Keys[Ord('W')] or Keys[VK_UP]) then
  begin
    if not SoundPlayed then
    begin
      Sound_PlayStream(EngineSound);
      SoundPlayed := True;
    end;

    Speed := Speed + 0.002;
    if Speed > MAX_SPEED then Speed := MAX_SPEED;
    MVector := MakeVector(Cosinus(Angle), 0, Sinus(Angle))
  end else if (Keys[Ord('S')] or Keys[VK_DOWN]) then
  begin
    if not SoundPlayed then
    begin
      Sound_PlayStream (EngineSound);
      SoundPlayed := True;
    end;
      
    Speed := Speed - 0.002;
    if Speed <  -MaX_SPEED then Speed := - MAX_SPEED;
    MVector := MakeVector(Cosinus(Angle), 0, Sinus(Angle))
  end else if (Keys[Ord('A')] or Keys[VK_LEFT]) then
  begin
    if not SoundPlayed then
    begin
      Sound_PlayStream (EngineSound);
      SoundPlayed := True;
    end;

    Streif := Streif - 0.002;
    if Streif < -Max_SPEED then Streif := -Max_SPEED;

    StrVec := MakeVector(Cosinus(Angle+90), 0, Sinus(Angle+90));
  end else if (Keys[Ord('D')] or Keys[VK_RIGHT]) then
  begin
    if not SoundPlayed then
    begin
      Sound_PlayStream (EngineSound);
      SoundPlayed := True;
    end;

    Streif := Streif + 0.002;
    if Streif > Max_SPEED then Streif := Max_SPEED;
    StrVec := MakeVector(Cosinus(Angle+90), 0, Sinus(Angle+90));
  end else
  begin
    if SoundPlayed then
    begin
      Sound_StopStream(EngineSound);
      SoundPlayed := False;
    end;
    if Speed > 0 then
      Speed := Speed - 0.0001 else
        Speed := Speed + 0.0001;
  end;

  if Keys[ord('W')] then
  begin
    if TrailTime = 0 then
    begin
      Trail := TTrail.Create;
      Trail.Scale := 1+Random(30)/10;
      Trail.Pos := MinusVctors(Pos, MultiplyVectorScalar(MakeVector(Cosinus(Angle), 0, Sinus(Angle)), 2));
      ObjectsEngine.AddObject(Trail);

      TrailTime := 5;
    end;

    Dec(TrailTime);
  end;

  if Keys[VK_SHIFT] or Mouse_lbutton then
  begin
    if FireTimer <= 0 then
    begin
      Bullet := TBullet.Create;
      Bullet.Pos := AddVector(Pos, MultiplyVectorScalar(MakeNormalVector(Cosinus(Angle), 0, Sinus(Angle)), 0.2));
      Bullet.MVector := MultiplyVectorScalar(MakeNormalVector(Cosinus(Angle), 0, Sinus(Angle)), 0.2);
      Bullet.FiredBy := Self;

      ObjectsEngine.AddObject(Bullet);
      Sound_PlayStream(ShotSound);
      FireTimer := 10;
    end else
      Dec(FireTimer);
  end else
    FireTimer := 0;

  if Keys[VK_SPACE] or Mouse_rbutton then
  begin
    if RocketTime <= 0 then
    begin
      Rock := TStraightRocket.Create;
      Rock.Pos := AddVector(Pos, MultiplyVectorScalar(MakeNormalVector(Cosinus(Angle), 0, Sinus(Angle)), 0.5));;
      Rock.MVector := MakeNormalVector(Cosinus(Angle), 0, Sinus(Angle));
      Rock.FiredBy := Self;
      Rock.Angle := Angle;
      ObjectsEngine.AddObject(Rock);
      RocketTime := 100;
    end;
  end;

  Dec(RocketTime);
  if RocketTime < 0 then RocketTime := 0;

  if Collision = False then
  begin
    dec(RespawnTime);
    if RespawnTime <= 0 then
    begin
      Collision := True;
      Hide := False;
    end else
      Hide := odd(RespawnTime div 10);
  end;

  Pos := AddVector(Pos, MultiplyVectorScalar(MVector, Speed));
  //Pos := AddVector(Pos, MultiplyVectorScalar(StrVec, Streif));

end;

procedure TPlayer.Render;
begin
  inherited;
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glRotatef(90-Angle, 0.0, 1.0, 0.0);

  glColor3f(1 - (Health / 100), Health / 100, 0.0);
  glBegin(GL_LINE_LOOP);
    glVertex3f(0.0, 0.0, 1);
    glVertex3f(0.5, 0.0, -1);
    glVertex3f(-0.5, 0.0, -1);
  glEnd;

  if Keys[Ord('W')] or Keys[ord('S')] then
  begin
    glColor3f(1.0, 1.0, 0.0);

    glBegin(GL_LINE_LOOP);
      glVertex3f(-0.5, 0.0, -1);
      glVertex3f(0.0, 0.0, -1.3 - (Random(100) / 100));
      glVertex3f(0.5, 0.0, -1);
    glEnd;
  end;

  glPopMatrix;
end;

procedure TPlayer.Stop;
begin
  Sound_StopStream(EngineSound);
  Freeze := True;
end;

{ TFakePlayer }

procedure TFakePlayer.Death;
begin
  inherited;
  //
end;

procedure TFakePlayer.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;

end;

procedure TFakePlayer.Move;
begin
  inherited;
  Health := Health - 0.5;
end;

procedure TFakePlayer.Render;
begin
  inherited;
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glRotatef(90-Angle, 0.0, 1.0, 0.0);

  glColor3f(0.5, 0.5, 0.5);
  glBegin(GL_POLYGON);
    glVertex3f(0.0, 0.0, 1);
    glVertex3f(0.5, 0.0, -1);
    glVertex3f(-0.5, 0.0, -1);
  glEnd;

  glPopMatrix;

end;

end.
