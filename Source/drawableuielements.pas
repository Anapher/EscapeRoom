unit DrawableUiElements;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  {$PACKENUM 1}
  ElementState = (Normal, Hovered, Selected);

type
  TDrawableButton = class
    private
      _state : ElementState;
      _x, _y, _width, _height : integer;
      _text : string;
      _id : integer;
    public
      constructor Create(textVal : string; idVal, xVal, yVal, widthVal, heightVal : integer);
      constructor Create(textVal : string; idVal : integer); overload;
      property State: ElementState read _state write _state;
      property X: integer read _x write _x;
      property Y: integer read _y write _y;
      property Width: integer read _width write _width;
      property Height: integer read _height write _height;
      property Text: string read _text;
      property Id: integer read _id;
  end;

implementation

constructor TDrawableButton.Create(textVal : string; idVal, xVal, yVal, widthVal, heightVal : integer);
begin
   _x := xVal;
   _y := yVal;
   _width := widthVal;
   _height := heightVal;
   _id := idVal;
   _text := textVal;
   _state := ElementState.Normal;
end;

constructor TDrawableButton.Create(textVal : string; idVal : integer);
begin
    Create(textVal, idVal, 0, 0, 0, 0);
end;

end.

