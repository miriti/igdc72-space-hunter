unit g_asteroids;

interface
uses
  OpenGL, g_class_gameobject, g_game_objects, u_math, u_sound, g_sounds;

type
  TAsteroid = class (TGameObject)
    Verts : array[0..18] of array[0..2] of GLfloat;
    procedure Init;
    procedure Move; override;
    procedure Render; override;
    procedure Death; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    constructor Create;
  end;

implementation

uses g_world;

{ TAsteroid }

constructor TAsteroid.Create;
begin
  Health := 100;

  Collision := True;
end;

procedure TAsteroid.Death;
var
  Child : TAsteroid;
  i : Integer;
begin
  inherited;

  for i := 0 to 2 do
  begin
    Child := TAsteroid.Create;
    Child.Radius := Radius / 3;
    Child.Init;
    Child.Pos := AddVector(Pos, MultiplyVectorScalar(MakeVector(Cosinus(Random(360)), 0, Sinus(Random(360))), Radius));
    Child.MVector := MultiplyVectorScalar(MakeVector(Cosinus(Random(360)), 0, Sinus(Random(360))), 0.01);
    Child.Mass := Mass / 3;

    ObjectsEngine.AddObject(Child);
    Sound_PlayStream(Explod_Sound);
  end;

  inc(World.Score, 10);

end;

procedure TAsteroid.DoCollision(Vector: TGamePos; CoObject: TObject);
begin
  inherited;
  //MVector := AddVector(MVector, MultiplyVectorScalar(Vector, (VectorLength((CoObject as TGameObject).MVector) * (CoObject as TGameObject).Mass) / Mass));
end;

procedure TAsteroid.Init;
var
  a : Integer;
  R : Single;
begin
  for a := 0 to 18 do
  begin
    R := Random(100)/100;

    Verts[a][0] := Cosinus(a * 20) * (Radius + R);
    Verts[a][1] := 0;
    Verts[a][2] := Sinus(a * 20) * (Radius + R);
  end;
end;

procedure TAsteroid.Move;
begin
  inherited;
  Angle := Angle + 0.5;

  Pos := AddVector(Pos, MVector);
end;

procedure TAsteroid.Render;
var
  a: Integer;
begin
  inherited;
  glPushMatrix;

  glTranslatef(Pos.x, Pos.y+0.1, Pos.z);
  glRotatef(Angle, 0.0, 1.0, 0.0);

  glColor3f(1.0, 1.0, 1.0);

  glBegin(GL_LINE_LOOP);
    for a := 0 to 18 do
    begin
      glVertex3fv(@Verts[a]);
    end;
  glEnd;

  glPopMatrix;
end;

end.
