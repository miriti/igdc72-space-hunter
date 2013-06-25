unit g_hud;

interface
uses
  OpenGL, Windows, u_winapi, u_math, g_class_gameobject, g_game_objects, Textures, u_consts, u_opengl, u_utils;
type
  THudCursor = class (TGameObject)
    procedure Move; override;
    procedure Render; override;
    procedure DoCollision(Vector : TGamePos; CoObject : TObject); override;
    constructor Create;
  end;

  TCompas = class (TGameObject)
    procedure Render; override;
    procedure Move; override;
  end;

  THUD = class
    Bg : GLuint;

    Cursor : THudCursor;
    Compas : TCompas;

    Font_FixeSys,
    Font_Courier_new : GLuint;
    Fade_Trans  : Single;
    Fade_Status : (fsNone, fsFadeIn, fsFadeOut);

    MainLabel : String;
    MainLabelTime : Integer;
    procedure ReInit;
    procedure WriteLn(Font:GLuint; tx,ty:integer; Text: String; r, g, b: Single);
    procedure Render;
    procedure Move;
    procedure SetOrtho;
    procedure FadeIn;
    procedure FadeOut;
    constructor Create;
  end;

var
  HUD : THUD;

implementation
uses
  g_player, g_world;

{ THUD }

constructor THUD.Create;
var
  font : HFONT;
begin
  ReInit;

  Compas := TCompas.Create;
  Compas.Pos.x := WINDOW_WIDTH - 60;
  Compas.Pos.y := WINDOW_HEIGHT - 60;
  
  LoadTexture('i/space.jpg', Bg, False);


  Font_FixeSys := glGenLists(256);
  font := CreateFont(23, 12, 0, 0, FW_NORMAL, 0, 0, 0, ANSI_CHARSET, OUT_TT_PRECIS,
    CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY	, FF_DONTCARE or DEFAULT_PITCH, 'Fixedsys');
  SelectObject(DC, font);
  wglUseFontBitmaps(DC, 0, 256, Font_FixeSys);
  DeleteObject(font);

  Font_Courier_new := glGenLists(256);
  font := CreateFont(12, 12, 0, 0, FW_NORMAL, 0, 0, 0, ANSI_CHARSET, OUT_TT_PRECIS,
    CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY	, FF_DONTCARE or DEFAULT_PITCH, 'Courier New');
  SelectObject(DC, font);
  wglUseFontBitmaps(DC, 0, 256, Font_Courier_new);
  DeleteObject(font);

  FadeOut;
end;

procedure THUD.FadeIn;
begin
  Fade_Status := fsFadeIn;
  Fade_Trans := 0.0;
end;

procedure THUD.FadeOut;
begin
  Fade_Status := fsFadeOut;
  Fade_Trans := 1.0;
end;

procedure THUD.Move;
begin
  if Fade_Status = fsFadeIn then
  begin
    Fade_Trans := Fade_Trans + 0.005;
    if Fade_Trans >= 1 then Fade_Status := fsNone;
  end else if Fade_Status = fsFadeOut then
  begin
    Fade_Trans := Fade_Trans - 0.005;
    if Fade_Trans <= 0 then Fade_Status := fsNone;
  end;

  if MainLabelTime > 0 then
    dec(MainLabelTime);

  Compas.Move;
end;

procedure THUD.ReInit;
begin
  Cursor := THudCursor.Create;
  ObjectsEngine.AddObject(Cursor);
end;

procedure THUD.Render;
var
  i,j:Integer;
begin
  glPushMatrix;

  glEnable(GL_TEXTURE_2D);
  glColor3f(1, 1, 1);

  glBindTexture(GL_TEXTURE_2D, Bg);

  glBegin(GL_QUADS);

    for i := -10 to 10 do for j := -10 to 10 do
    begin
      glTexCoord2f(0, 0); glVertex3i(i * 30, -1, j * 30);
      glTexCoord2f(1, 0); glVertex3i(i * 30 + 30, -1, j * 30);
      glTexCoord2f(1, 1); glVertex3i(i * 30 + 30, -1, j*30 +30);
      glTexCoord2f(0, 1); glVertex3i(i * 30, -1, j*30 + 30);
    end;

  glEnd;

  glDisable(GL_TEXTURE_2D);
  glPopMatrix;

  SetOrtho;
  Compas.Render;
  //if Fade_Status <> fsNone then
  //begin
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glColor4f(0.0, 0.0, 0.0, Fade_Trans);

    glBegin(GL_QUADS);
      glVertex2i(0, 0);
      glVertex2i(WINDOW_WIDTH, 0);
      glVertex2i(WINDOW_WIDTH, WINDOW_HEIGHT);
      glVertex2i(0, WINDOW_HEIGHT);
    glEnd;

    glDisable(GL_BLEND);
 // end;



  {DEBUG}
  {WriteLn(Font_Courier_new, 5, 10, 'Objects Drawn : ' + IntToStr(ObjectsEngine.Rendered), 1, 1, 1);
  WriteLn(Font_Courier_new, 5, 20, 'PlayerX : ' + FloatToStr(Player.Pos.X), 1, 1, 1);
  WriteLn(Font_Courier_new, 5, 30, 'PlayerY : ' + FloatToStr(Player.Pos.Y), 1, 1, 1);
  WriteLn(Font_Courier_new, 5, 40, 'PlayerZ : ' + FloatToStr(Player.Pos.Z), 1, 1, 1);
  WriteLn(Font_Courier_new, 5, 50, 'Player Angle : ' + FloatToStr(Player.Angle), 1, 1, 1);
  WriteLn(Font_Courier_new, 5, 60, 'Player Speed : ' + FloatToStr(Player.Speed), 1, 1, 1);
  WriteLn(Font_Courier_new, 5, 70, 'Player.MVector.x : ' + FloatToStr(Player.MVector.x), 1, 1, 1);
  WriteLn(Font_Courier_new, 5, 80, 'Player.MVector.y : ' + FloatToStr(Player.MVector.y), 1, 1, 1);
  WriteLn(Font_Courier_new, 5, 90, 'Player.MVector.z : ' + FloatToStr(Player.MVector.z), 1, 1, 1);
  WriteLn(Font_Courier_new, 5, 100, 'Player.Health : ' + FloatToStr(Player.Health), 1, 1, 1);    }
  //WriteLn(Font_Courier_new, 5, 110, 'Trans : ' + FloatToStr(Fade_Trans), 1, 1, 1);    

  {Debug}

  if MainLabelTime > 0 then
  begin
    WriteLn(Font_FixeSys, WINDOW_WIDTH div 2 - (Length(MainLabel) div 2) * 20, WINDOW_HEIGHT div 2, MainLabel, 1, 1, 1);
  end;

  WriteLn(Font_FixeSys, 5, WINDOW_HEIGHT-60, 'Lifes x ' + IntToStr(World.Lifes) + ' (' + FloatToStr(Player.Health, 0) + '%)', 1, 0.7, 0);
  WriteLn(Font_FixeSys, 5, WINDOW_HEIGHT-40, 'Score : ' + IntToStr(World.Score), 1, 0.7, 0);
  Writeln(Font_FixeSys, 5, WINDOW_HEIGHT-20, 'Coins : ' + IntToStr(World.Coins_coll) + '/' + IntToStr(World.Coins_Total), 1, 0.7, 0);
end;

procedure THUD.SetOrtho;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;

  gluOrtho2D(0, WINDOW_WIDTH, WINDOW_HEIGHT, 0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure THUD.WriteLn;
  procedure glPutchar(text : PChar);
  begin
    if (text = '') then Exit;
    glListBase(Font);
    glCallLists(length(text), GL_UNSIGNED_BYTE, text);
  end;
begin
  glColor3f(r, g, b);
  glRasterPos3f(tx, ty, 1);
  glPutchar(PChar(text));
  glColor3f(1, 1, 1);
end;

{ THudCursor }

constructor THudCursor.Create;
begin
  Health := 100;
  Collision := False;
end;

procedure THudCursor.DoCollision(Vector: TGamePos; CoObject: TObject);
begin

end;

procedure THudCursor.Move;
var
  TmpV : TGamePos;
begin
  Pos.x := Pos.x + Mouse_Dx / 20;
  Pos.z := Pos.z + Mouse_Dy / 20;

{  if Distance(Pos, Player.Pos) > 20 then
  begin
    Pos := AddVector(Player.Pos, MultiplyVectorScalar( NormalizeVector(MinusVctors(Pos, Player.Pos)), 20));
  end;}
//  Pos := AddVector(Pos, Player.MVector);
end;

procedure THudCursor.Render;
begin
  glPushMatrix;

  glColor3f(0.0, 0.5, 1.0);

  glTranslatef(Player.Pos.x, Player.Pos.y, Player.Pos.z);

  glBegin(GL_LINES);
    glVertex3f(Pos.x-1, 0, Pos.z);
    glVertex3f(Pos.x+1, 0, Pos.z);

    glVertex3f(Pos.x, 0, Pos.z+1);
    glVertex3f(Pos.x, 0, Pos.z-1);
  glEnd;


  glPopMatrix;
end;

{ TCompas }

procedure TCompas.Move;
var
  CPos : TGamePos;
begin
  CPos := ObjectsEngine.GetNearestCoin;
  Angle := AngleTo(Player.Pos.x, Player.Pos.z, CPos.x, CPOs.z);
end;

procedure TCompas.Render;
var
  a : Integer;
begin

  glPushMatrix;
  glTranslatef(Pos.x, Pos.y, 0);

  glColor3f(1.0, 1.0, 1.0);

  glBegin(GL_LINE_LOOP);
  for a := 0 to 18 do
  begin
    glVertex2f(Cosinus(a * 20) * 50,  Sinus(a * 20) * 50);
  end;
  glEnd;

  glRotatef(Angle, 0, 0, 1);

  glColor3f(1.0, 1.0, 0.0);
  glBegin(GL_POLYGON);

    glVertex2f(50, 0);
    glVertex2f(0, -5);
    glVertex2f( 0, 5);
  glEnd;

  glColor3f(1.0, 1.0, 1.0);
  glBegin(GL_LINE_LOOP);
    glVertex2f(-50, 0);
    glVertex2f(0, -5);
    glVertex2f( 0, 5);
  glEnd;


  glPopMatrix;

end;

end.
