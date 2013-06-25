unit u_utils;

interface

function IntToStr(Int : Integer):String;
function FloatToStr(Float : Single; Digs : Integer = 3) : String;

implementation

function IntToStr;
begin
  Str(Int, Result);
end;

function FloatToStr;
begin
  Str(Float:3:Digs, Result);
end;

end.
