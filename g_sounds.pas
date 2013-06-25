unit g_sounds;

interface
uses
  u_Sound;

var
  Explod_Sound : Integer;
  Rocket_Sound : Integer;
  Lost_life    : Integer;
  Shot_2       : Integer;
  Bonus        : Integer;
  EngineSound  : Integer;
  ShotSound    : Integer;

procedure LoadSounds;

implementation

procedure LoadSounds;
begin
  Explod_Sound := Sound_LoadStream('s/expl1.wav');
  Rocket_Sound := Sound_LoadStream('s/rocket.wav');
  Lost_life    := Sound_LoadStream('s/lostlife.wav');
  Shot_2       := Sound_LoadStream('s/piu2.wav');
  Bonus        := Sound_LoadStream('s/bonus.wav');
  EngineSound   := Sound_LoadStream('s/engine1.wav', True);
  ShotSound     := Sound_LoadStream('s/piu1.wav');
end;

end.
