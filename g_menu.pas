unit g_menu;

interface
uses
  OpenGL, g_Hud;

type
  TMenu = class
    procedure Render;
    procedure KeyDown(Key : Word);
  end;

var
  Menu : TMenu;

{ TMenu }

implementation

procedure TMenu.KeyDown(Key: Word);
begin

end;

procedure TMenu.Render;
begin

end;

initialization
  Menu := TMenu.Create;

end.
