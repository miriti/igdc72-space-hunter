program rarena;
uses
  Windows,
  Messages,
  OpenGL,
  u_winapi in 'u_winapi.pas',
  u_opengl in 'u_opengl.pas',
  u_consts in 'u_consts.pas',
  g_class_gameobject in 'g_class_gameobject.pas',
  u_math in 'u_math.pas',
  g_game_objects in 'g_game_objects.pas',
  g_player in 'g_player.pas',
  g_move in 'g_move.pas',
  g_class_sturrel in 'g_class_sturrel.pas',
  g_hud in 'g_hud.pas',
  g_rockets in 'g_rockets.pas',
  g_world in 'g_world.pas',
  g_asteroids in 'g_asteroids.pas',
  u_sound in 'u_sound.pas',
  g_menu in 'g_menu.pas',
  g_flyers in 'g_flyers.pas',
  u_utils in 'u_utils.pas',
  g_sounds in 'g_sounds.pas',
  g_bonuses in 'g_bonuses.pas';

var
  Msg : TMsg;
  GameMode : (gmGame, gmMenu) = gmGame;

{**
 * Прорисовка всего
 *}
procedure Render;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  if GameMode = gmGame then
  begin
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    gluPerspective(50, 4/3, 0.1, 1000.0);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;

    gluLookAt(Player.Pos.x, 50 + World.Zoom, Player.Pos.z + 0.001,
              Player.Pos.x, 0, Player.Pos.z,
              0.0, 1.0, 0.0);


    ObjectsEngine.Render;
    Hud.Render;
  end else
  begin
    Menu.Render;
  end;

  SwapBuffers(DC);
end;

begin

if not Windows_Create(WINDOW_WIDTH, WINDOW_HEIGHT, 0, 0, True, 'blablabla', 'Space Hunter') then
begin
  MessageBox(0, 'Windows_Create error', FATAL_ERROR, MB_ICONERROR);
  Halt;
end;

ShowCursor(False);
Capture_Mouse := True;

Sound_Init(Window_Handle);


World := TGameWorld.Create;
World.Load('m\level1.map');

LoadSounds;

if not OpenGL_Init(Window_Handle) then
begin
  MessageBox(Window_Handle, 'OpenGL_Init error', FATAL_ERROR, MB_ICONERROR);
  Halt;
end;

glEnable(GL_DEPTH_TEST);
Hud := THUD.Create;

Hud.MainLabel := 'Level 1';
HUD.MainLabelTime := 200;

glClearColor(0.0, 0.0, 0.0, 1.0);
glLineWidth(2);

MovingInitialize;

while not Quit_Hit do
begin
  if PeekMessage(Msg, Window_Handle, 0, 0, PM_NOREMOVE) then
  begin
    if GetMessage(Msg, 0, 0, 0) then // Берем сообщение из очереди сообщений
    begin
      TranslateMessage(Msg); // Переводим сообщение
      DispatchMessage(Msg);  // Отправляем сообщение в WndProc
    end;
  end else
  begin
    if GameMode = gmGame then
      MovingExecute;
      
    Render;
  end;
end;

end.
