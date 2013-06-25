unit u_sound;

interface
uses
  Windows, Bass;

var
  Samples : Array of HSAMPLE;
  Streams : Array of HSTREAM;

function Sound_Init(Wnd : HWND): Boolean;
function Sound_LoadSample(FileName : String; Looped : Boolean = False) : Integer;
function Sound_LoadStream(FileName : String; Looped : Boolean = False) : Integer;
function Sound_PlaySample(SampleID : Integer): Boolean;
function Sound_PlayStream(StreamID : Integer): Boolean;
function Sound_StopStream(StreamID : Integer): Boolean;
function Sound_StopSample(SampleID : Integer): Boolean;

implementation

function Sound_StopSample;
begin
  BASS_ChannelStop(Samples[SampleID]);
end;

function Sound_StopStream;
begin
  BASS_ChannelStop(Streams[StreamID]);
end;

function Sound_LoadSample;
var
  Flags : DWORD;
begin
  Flags := 0;
  if Looped then
    Flags := Flags or BASS_SAMPLE_LOOP;

  SetLength(Samples, Length(Samples)+1);
  Samples[High(Samples)] := BASS_SampleLoad(False, PChar(FileName), 0, 0, 10, Flags);

  Result := High(Samples);
end;

function Sound_LoadStream;
var
  Flags : DWORD;
begin
  Flags := 0;
  if Looped then
    Flags := Flags or BASS_SAMPLE_LOOP;
  SetLength(Streams, Length(Streams)+1);
  Streams[High(Streams)] := BASS_StreamCreateFile(False, PChar(FileName), 0, 0, Flags);

  Result := High(Streams);
end;

function Sound_PlaySample;
begin
  BASS_ChannelPlay(Samples[SampleID], False);
end;

function Sound_PlayStream;
begin
  BASS_ChannelPlay(Streams[StreamID], False);
end;

function Sound_Init;
begin
	if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
	begin
		MessageBox(Wnd,'An incorrect version of BASS.DLL was loaded',nil,MB_ICONERROR);
		Halt;
	end;

  if not BASS_Init(-1, 44100, 0, Wnd, nil) then
  begin
    MessageBox(Wnd, 'Can not init fucking sound!', 'Error', MB_ICONERROR);
    Halt;
  end;
end;

end.
