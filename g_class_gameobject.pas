unit g_class_gameobject;

interface
uses
  OpenGL, u_math;

type
  TGameObject = class (TObject)
    // Сдужебное
    Index     : Integer; // Индекс в массиве объектов
    Parent    : TObject; // Родительский объект

    // Все что требуется для физики объекта
    Pos       : TGamePos; // Позиция в игровом мире
    MVector   : TGamePos; // Вектор движения (не нормализован)
    Angle     : Single; // Угол поворота объекта
    Acceler   : Single; // Ускорение объекта
    Mass      : Single; // Масса объекта
    Speed     : Single; // Скорость
    Speen     : Single; // Вращение (O_O ?!)

    // Игровое
    Health    : Single;
    Radius    : Single;
    Collision : Boolean;
    Fake      : TObject;
    Freeze    : Boolean;
    Hide      : Boolean;
    Unkill    : Boolean;

    procedure Move; virtual; abstract;
    procedure _render_bcircle;
    procedure Render; virtual; abstract;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); virtual; abstract;
    procedure Death; virtual; abstract;
  end;

implementation

{ TGameObject }

procedure TGameObject._render_bcircle;
var
  i : Integer;
begin
glPushMatrix;

  glTranslatef(Pos.x, Pos.y, Pos.z);

  glColor3f(1.0, 0.0, 0.0);
  glBegin(GL_LINE_LOOP);
  for i := 0 to 17 do
  begin
    glVertex3f(Cosinus(i)*Radius, Pos.y+1, Sinus(i)*Radius);
  end;
  glEnd;

  glPopMatrix;
end;

end.
