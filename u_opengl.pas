unit u_opengl;

interface
uses
  Windows,
  OpenGL;

var
  DC : HDC;
  RC : HGLRC;

function OpenGL_Init(H_Wnd: HWND):Boolean;
procedure OpenGL_OxysDebug;
procedure OpenGL_DepthGridDebug(side:Integer);

implementation

procedure OpenGL_DepthGridDebug;
var
  i,j:Integer;
begin
  glPushMatrix;
  glColor3f(0.0, 0.7, 0.58);

  for i := -(side div 2) to (side div 2) do
  begin
    for j := -(side div 2) to (side div 2) do
    begin
      glBegin(GL_LINE_LOOP);
        glVertex3f(i, 0, j);
        glVertex3f(i+1, 0, j);
        glVertex3f(i+1, 0, j+1);
        glVertex3f(i, 0, j+1);
      glEnd;
    end;
  end;
  glPopMatrix;

end;

procedure OpenGL_OxysDebug;
begin
  glPushMatrix;
  glBegin(GL_LINES);

    glColor3f(1.0, 0.0, 0.0);
    glVertex3f(0.0, 0.0, 0.0);
    glVertex3f(1.0, 0.0, 0.0);

    glColor3f(0.0, 1.0, 0.0);
    glVertex3f(0.0, 0.0, 0.0);
    glVertex3f(0.0, 1.0, 0.0);

    glColor3f(0.0, 0.0, 1.0);
    glVertex3f(0.0, 0.0, 0.0);
    glVertex3f(0.0, 0.0, 1.0);
  glEnd;
  glPopMatrix;
end;

function OpenGL_Init;
var
  pfd : TPixelFormatDescriptor; // �������� ������� �������
  n   : Integer;
begin
  DC := GetDC(H_Wnd);
  with pfd do // ��������� ����������
  begin
    nSize      := SizeOf(pfd);
    nVersion   := 1;
    dwFlags    := PFD_DOUBLEBUFFER or // ������� �����������
                  PFD_SUPPORT_OPENGL; // �������������� OpenGL
    iPixelType := PFD_TYPE_RGBA;      // ��� ������� ������� RGBA
    cColorBits := 24;               // ������� �����
    cDepthBits := 16;                  // ������� Depth ������ (aka Z-Bufer);
  end;

  n := ChoosePixelFormat(DC, @pfd);   // �������� ����������� ������� �������
  SetPixelFormat(DC, n, @pfd);        // ������������ ���� ������ �������
  DescribePixelFormat(DC, n, sizeof(pfd), pfd);

  RC := wglCreateContext(DC);         // ������� ������� ���������������
  Result := RC<>0;

  if Result then
    wglMakeCurrent(DC, RC);           // ������������� ���� �������� ������� ���
end;

end.
