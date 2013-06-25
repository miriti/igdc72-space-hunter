unit u_winapi;

interface
uses
  Windows, Messages;

var
  Keys : array [0..255] of Boolean;
  Quit_Hit : Boolean = False;
  Capture_Mouse  : Boolean = False;
  Mouse_x, Mouse_y, Mouse_Dx, Mouse_Dy : Integer;
  Mouse_lbutton, Mouse_rbutton : Boolean;
  Window_Handle : HWND;
  
  Wndow_Width,
  Wndow_Height,
  Screen_Width,
  Screen_Height : Integer;

function Windows_Create(ClientW, ClientH, Left, Top : Integer; ScreenCenter : Boolean = True; ClassName : String = 'SomeCoolWindowClass'; WindowTitle : String = 'Window Title'):Boolean;
procedure Windows_Tick;

implementation
uses
  g_world;

procedure Windows_Tick;
var
  Cur : TPoint;
begin
  if Capture_Mouse then
  begin
    GetCursorPos(Cur);

    Mouse_Dx := Cur.X - (Screen_Width div 2);
    Mouse_Dy := Cur.Y - (Screen_Height div 2);

    SetCursorPos(Screen_Width div 2, Screen_Height div 2);
  end;
end;

function WndProc(h_Wnd : HWND; msg : UINT; w_param : LPARAM; l_param : WPARAM):LRESULT;stdcall; // ������� �������.
begin
  Result := DefWindowProc(h_Wnd, msg, w_param, l_param); // ���������������� ��������� ����� ���������� �������.
  case msg of
    WM_DESTROY  : Quit_Hit := True; // Alt+F4 ��� X
    WM_KEYDOWN  : Keys[w_param] := True; // ����� ������
    WM_KEYUP    : keys[w_param] := False;   // ��������� ������
    WM_MOUSEMOVE: begin
                    Mouse_x := LoWord(l_param);
                    Mouse_y := HiWord(l_param);
                  end;
    WM_LBUTTONDOWN : Mouse_lbutton := True;
    WM_LBUTTONUP   : Mouse_lbutton := False;
    WM_RBUTTONDOWN : Mouse_rbutton := True;
    WM_RBUTTONUP   : Mouse_rbutton := False;
    WM_MOUSEWHEEL  : begin
                      //World.Zoom := World.Zoom +  ShortInt( HiWord(w_param) ) / 100;
                     end;
  end;
end;

function Windows_Create;
var
  wc : TWndClass;
  aLeft, aTop : Integer;
begin

  wc.style         := 0;
  wc.lpfnWndProc   := @WndProc;
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := HInstance;
  wc.hIcon         := LoadIcon(0, IDI_APPLICATION); // ������ - ���������
  wc.hCursor       := LoadCursor(0, IDC_ARROW); // ������ - �������
  wc.hbrBackground := COLOR_WINDOW; // ���� ���� ���� - �� ���������
  wc.lpszMenuName  := PChar(ClassName);
  wc.lpszClassName := PChar(ClassName); // ��� ������ ����

  if RegisterClass(wc) = 0 then
  begin
    Result := False;
    Exit;
  end;

  if ScreenCenter then
  begin
    aLeft := (GetSystemMetrics(SM_CXSCREEN)-ClientW) div 2;
    aTop := (GetSystemMetrics(SM_CYSCREEN)-ClientH) div 2;
  end else
  begin
    aLeft := Left;
    aTop := Top;
  end;

  Window_Handle := CreateWindow(PChar(ClassName),   // ������� ���� ��� ����� ������
                         PChar(WindowTitle), // � ����������
                         WS_CLIPSIBLINGS or WS_CLIPCHILDREN or WS_CAPTION or WS_VISIBLE, // ����� ����. WS_CLIPSIBLINGS or WS_CLIPCHILDREN - ������������ ������������� ��� OpenGL
                         aLeft, // ����������� X �� ������
                         aTop, // ����������� Y �� ������
                         ClientW+(GetSystemMetrics(SM_CXBORDER)*2), // ������ ����
                         ClientH+GetSystemMetrics(SM_CYCAPTION)+(GetSystemMetrics(SM_CYBORDER)*2), // ������ ����
                         0,
                         0,
                         HInstance,
                         nil);

  if Window_Handle <> 0 then
  begin
    ShowWindow(Window_Handle, CmdShow);
    UpdateWindow(Window_Handle);
  end;


  ZeroMemory(@Keys, Length(Keys));

  Result := True;

  Wndow_Width := ClientW;
  Wndow_Height := ClientH;

  Screen_Width := GetSystemMetrics(SM_CXSCREEN);
  Screen_Height := GetSystemMetrics(SM_CYSCREEN);

  if Capture_Mouse then
  begin
    SetCursorPos(Screen_Width div 2, Screen_Height div 2);
  end;
end;

end.
