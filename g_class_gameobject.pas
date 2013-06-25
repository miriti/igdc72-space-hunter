unit g_class_gameobject;

interface
uses
  OpenGL, u_math;

type
  TGameObject = class (TObject)
    // ���������
    Index     : Integer; // ������ � ������� ��������
    Parent    : TObject; // ������������ ������

    // ��� ��� ��������� ��� ������ �������
    Pos       : TGamePos; // ������� � ������� ����
    MVector   : TGamePos; // ������ �������� (�� ������������)
    Angle     : Single; // ���� �������� �������
    Acceler   : Single; // ��������� �������
    Mass      : Single; // ����� �������
    Speed     : Single; // ��������
    Speen     : Single; // �������� (O_O ?!)

    // �������
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
