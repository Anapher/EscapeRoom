unit GameComposition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, LevelDesign, Controls;

type
  TGameComposition = class(IComposition)
     private
        _requestedComposition : CompositionType;
     public
        constructor Create(); overload;
        function RequireSwitch() : CompositionType;
        function GetCompositionType() : CompositionType;
        procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);

        procedure KeyDown(var Key: Word; Shift: TShiftState);
        procedure MouseMove(Shift: TShiftState; X, Y: Integer);
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

implementation

constructor TGameComposition.Create();
begin
    _requestedComposition := CompositionType.None;
end;

function TGameComposition.RequireSwitch() : CompositionType;
begin
    exit(_requestedComposition);
end;

function TGameComposition.GetCompositionType() : CompositionType;
begin
    result := CompositionType.Game;
end;

procedure TGameComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
begin

end;

procedure TGameComposition.KeyDown(var Key: Word; Shift: TShiftState);
begin

end;

procedure TGameComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TGameComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

end.

