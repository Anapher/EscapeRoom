unit GameEngine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TGameEngine = class
    private
      _positionX, _positionY : integer;

    public
      procedure MoveLeft();
      procedure MoveRight;
      procedure MoveTop;
      procedure MoveBottom;

      constructor Create; overload;
  end;

implementation

constructor TGameEngine.Create();
begin
     _positionX := 0;
     _positionY := 0;
end;

procedure TGameEngine.MoveLeft();
begin

end;

procedure TGameEngine.MoveRight();
begin

end;

procedure TGameEngine.MoveTop();
begin

end;

procedure TGameEngine.MoveBottom();
begin

end;

end.

