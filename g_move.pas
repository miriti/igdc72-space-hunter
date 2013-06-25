unit g_move;
interface

uses
  Windows, OpenGL;

procedure MovingInitialize;
procedure MovingExecute;

var
  wTime, wTime_Delta, wTime_Old,
  ups_delta, ups_time_old, ups_time : DWORD;

implementation
uses
  g_game_objects, g_player, u_math, g_hud, u_winapi, g_world;

function GetTimer: integer;
var
  T : LARGE_INTEGER;
  F : LARGE_INTEGER;
begin
  QueryPerformanceFrequency(Int64(F));
  QueryPerformanceCounter(Int64(T));
  result := round(1000 * T.QuadPart / F.QuadPart);
end;

procedure MovingInitialize;
begin
  ups_delta := 10;
  ups_time_old := GetTimer - ups_delta;
  ups_time     := GetTimer;
end;

procedure MovingExecute;
begin
  wTime       := GetTimer;
  wTime_Delta := wTime - ups_time_old;
  while wTime_Delta >= ups_delta do
  begin

    Windows_Tick;
    ObjectsEngine.Move;
    ObjectsEngine.CollisionObjects;
    Hud.Move;
    World.OnMove;

    dec(wTime_Delta, ups_delta);  
  end;
  ups_time_old := wTime - wTime_Delta;
end;

end.
