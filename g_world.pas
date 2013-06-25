unit g_world;

interface
uses
  g_player, g_class_sturrel, u_math, g_game_objects, g_asteroids, g_flyers, g_bonuses, u_utils, u_sound, g_sounds;

type
  TGameWorld = class
    Lifes : Integer;
    Coins_Total, Coins_coll : Integer;
    Zoom : Single;
    Stasrt : TGamePos;
    NextLevel : Integer;
    Score : Integer;
    WhaidToLoadNextLevel : Boolean;
    constructor Create;
    procedure OnMove;
    procedure Load(FileName :String);
    procedure ReCreatePlayer;
    procedure GoNextLevel;
  end;


var
  World : TGameWorld;

implementation
uses
  g_hud;

{ TGameWorld }

constructor TGameWorld.Create;
begin
  Lifes := 3;
  Stasrt := MakeVector(0, 0, 0);
end;

procedure TGameWorld.GoNextLevel;
begin
  Hud.FadeIn;


  if NextLevel > 0 then
    WhaidToLoadNextLevel := True else
    begin
      Hud.MainLabel := 'Fin.';
      Hud.MainLabelTime := 100000;
      Player.Stop;
    end;

end;

procedure TGameWorld.Load(FileName: String);
var
  f : TextFile;
  i,
  Cnt : Integer;
  S, S2   : String;

  T : TSimpleTurrel;
  A : TAsteroid;
  Fl : TEnemyFlyer;
  M : TMiniTurrel;
  W : TWebTurrel;
  C : TCoin;
begin
  ObjectsEngine.Clear;

  ReCreatePlayer;

  Coins_Total := 0;
  Coins_coll := 0;

  AssignFile(f, FileName);
  Reset(f);

  while not eof(f) do
  begin
    Readln(f, Cnt, S);

    if S = ' Start' then
    begin
      Readln(f, Stasrt.x, Stasrt.z);
      Player.Pos := Stasrt;
    end else
    if S = ' Turrels' then
    begin
      for i := 0 to Cnt - 1 do
      begin
        T := TSimpleTurrel.Create;
        ReadLn(f, T.Pos.x, T.Pos.z);
        ObjectsEngine.AddObject(T);
      end;
    end else
    if S = ' Asteroids' then
    begin
      for i := 0 to Cnt - 1 do
      begin
        A := TAsteroid.Create;
        Readln(f, A.Radius, A.Pos.x, A.Pos.z);
        A.Init;
        ObjectsEngine.AddObject(A);
      end;
    end else
    if S = ' Flyers' then
    begin
      for i := 0 to Cnt - 1 do
      begin
        Fl := TEnemyFlyer.Create;
        Fl.Target := Player;
        Readln(f, Fl.Pos.x, Fl.Pos.Z);
        ObjectsEngine.AddObject(Fl);
      end;
    end else
    if S = ' Mini' then
    begin
      for i := 0 to Cnt - 1 do
      begin
        M := TMiniTurrel.Create;
        Readln(f, M.Pos.x, M.Pos.z);
        ObjectsEngine.AddObject(M);
      end;
    end else
    if S = ' Webs' then
    begin
      for i := 0 to Cnt - 1 do
      begin
        W := TWebTurrel.Create;
        Readln(f, W.Pos.x, W.Pos.z);
        ObjectsEngine.AddObject(W);
      end;
    end else
    if S = ' Coins' then
    begin
      for i := 0 to Cnt - 1 do
      begin
        C := TCoin.Create;
        Readln(f, C.Pos.x, C.Pos.z);
        C.Unkill := True;
        ObjectsEngine.AddObject(C);
        inc(Coins_Total);
      end;
    end else
    if S = ' Next' then
    begin
      NextLevel := Cnt;
    end;

  end;

  CloseFile(f);
end;



procedure TGameWorld.OnMove;
begin
  if WhaidToLoadNextLevel and (Hud.Fade_Status = fsNone) then
  begin
    WhaidToLoadNextLevel := False;
    Hud.FadeOut;
    Hud.MainLabel := 'Level ' + Inttostr(NextLevel);
    Load('m\level' + IntToStr(NextLevel) + '.map');
    HUD.ReInit;
    HUD.MainLabelTime := 200;
  end;

  If World.Score >= 10000 then
  begin
    inc(Lifes);
    World.Score := World.Score - 10000;
    Sound_PlayStream(Bonus);
  end;
end;

procedure TGameWorld.ReCreatePlayer;
begin
  if Lifes <= 0 then
  begin
    Hud.FadeIn;
    Hud.MainLabel := 'Game Over';
    Hud.MainLabelTime := 100000;
  end else
  begin
    Player := TPlayer.Create;
    Player.Pos := Stasrt;
    Player.MVector := MakeVector(0, 0, 0);
    Player.Angle := 0;
    Player.Acceler := 0;
    Player.Mass := 1;
    Player.Health := 100;
    Player.Collision := True;
    Player.Blinking := True;
    Player.Collision := False;
    Player.RespawnTime := 300;

    ObjectsEngine.AddObject(Player);
  end;
end;

end.
