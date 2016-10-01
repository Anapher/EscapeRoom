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
        constructor Create(x, y : integer); overload;
        function GetX() : integer;
        function GetY() : integer;
  end;

type
  TRectangle = class(TPoint)
       private
         _width, _height : integer;
       public
         constructor Create(x, y, width, height : integer); overload;
         function GetWidth() : integer;
         function GetHeight() : integer;
  end;

implementation

constructor TPoint.Create(x, y : integer);
begin
  _x := x;
  _y := y;
end;

function TPoint.GetX() : integer;
begin
  result := _x;
end;

function TPoint.GetY() : integer;
begin
  result := _y;
end;

constructor TRectangle.Create(x, y, width, height : integer);
begin
  _x := x;
  _y := y;
  _width := width;
  _height := height;
end;

function TRectangle.GetWidth() : integer;
begin
  result := _width;
end;

function TRectangle.GetHeight() : integer;
begin
  result := _height;
end;

end.

