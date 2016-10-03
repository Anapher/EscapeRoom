unit GameEffectUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelUtils, Types;

procedure FadeText(text : string; x, y : integer; color : TBGRAPixel; duration : integer;
         deltaTime : integer; fadeIn : boolean; bitmap : TBGRABitmap);
procedure FadeText(text : string; color : TBGRAPixel; duration : integer;
         deltaTime : integer; fadeIn : boolean; bitmap : TBGRABitmap); overload;
function GetTextCenterPoint(text : string; bitmap : TBGRABitmap) : TRectangle;
procedure DrawCenteredText(text : string; bitmap : TBGRABitmap; color : TBGRAPixel);

implementation

procedure FadeText(text : string; x, y : integer; color : TBGRAPixel; duration : integer;
  deltaTime : integer; fadeIn : boolean; bitmap : TBGRABitmap);
begin
  if(fadeIn) then
      color.alpha := round(deltaTime / duration * 255)
  else
      color.alpha := round(255 - (deltaTime / duration * 255));

  bitmap.TextOut(x, y, text, color);
end;

procedure FadeText(text : string; color : TBGRAPixel; duration : integer;
         deltaTime : integer; fadeIn : boolean; bitmap : TBGRABitmap);
var position : TRectangle;
begin
    position := GetTextCenterPoint(text, bitmap);
    FadeText(text, position.X, position.Y, color, duration, deltaTime, fadeIn, bitmap);
end;

function GetTextCenterPoint(text : string; bitmap : TBGRABitmap) : TRectangle;
var textSize : TSize;
begin
    textSize := bitmap.TextSize(text);

    exit(TRectangle.Create(round((bitmap.Width - textSize.cx) / 2),
         round((bitmap.Height - textSize.cy) / 2), textSize.cx, textSize.cy));
end;

procedure DrawCenteredText(text : string; bitmap : TBGRABitmap; color : TBGRAPixel);
var position : TRectangle;
begin
   position := GetTextCenterPoint(text, bitmap);
   bitmap.TextOut(position.X, position.Y, text, color);

end;

end.

