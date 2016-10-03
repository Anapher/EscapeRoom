unit LevelUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TPoint = class
      private
        _x, _y : integer;
      public
        constructor Create(xPos, yPos : integer); overload;
        property X: Integer read _x;
        property Y: Integer read _y;
  end;

type
  TSize = class
       private
         _width, _height : integer;
       public
         constructor Create(widthVal, heightVal : integer); overload;
         property Width: Integer read _width;
         property Height: Integer read _height;
  end;

type
  TRectangle = class(TPoint)
       private
         _width, _height : integer;
       public
         constructor Create(xPos, yPos, widthVal, heightVal : integer); overload;
         function ToSize() : TSize;
         property Width: Integer read _width;
         property Height: Integer read _height;
  end;

implementation

constructor TPoint.Create(xPos, yPos : integer);
begin
  _x := xPos;
  _y := yPos;
end;

constructor TRectangle.Create(xPos, yPos, widthVal, heightVal : integer);
begin
  _x := xPos;
  _y := yPos;
  _width := widthVal;
  _height := heightVal;
end;

function TRectangle.ToSize() : TSize;
begin
    exit(TSize.Create(_width, _height));
end;

constructor TSize.Create(widthVal, heightVal : integer);
begin
  _width := widthVal;
  _height := heightVal;
end;

end.

