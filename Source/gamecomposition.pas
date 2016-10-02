unit GameComposition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, LevelDesign, Controls, TutorialLevel, Storyboard,
  LevelUtils;

type
  TGameComposition = class(IComposition)
     private
        _requestedComposition : CompositionType;
        _currentLevel : ILevel;
        _rooms : TRoomArray;
        _secureArea : TPoint;
        _currentRoom : IRoom;
        _currentX, _currentY : integer;
     public
        constructor Create(); overload;
        function RequireSwitch() : CompositionType;
        function GetCompositionType() : CompositionType;
        procedure InitializeLevel(level : ILevel);
        function GetRoomByCoordinates(x, y : integer) : IRoom;
        procedure EnterRoom(room : IRoom);


        procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);

        procedure KeyDown(var Key: Word; Shift: TShiftState);
        procedure MouseMove(Shift: TShiftState; X, Y: Integer);
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

implementation

constructor TGameComposition.Create();
begin
    _requestedComposition := CompositionType.None;
    _currentLevel := TTutorialLevel.Create();
    InitializeLevel(_currentLevel);
end;

procedure TGameComposition.InitializeLevel(level : ILevel);
var startRoom : TPoint;
begin
    _rooms := level.GetRooms();
    _secureArea := level.GetSecureArea();

    startRoom := level.GetStartLocation();
    _currentX := startRoom.X;
    _currentY := startRoom.Y;

    _currentRoom := GetRoomByCoordinates(_currentX, _currentY);
end;

function TGameComposition.GetRoomByCoordinates(x, y : integer) : IRoom;
var i : integer;
    roomLocation : TPoint;
begin
    for i := 0 to Length(_rooms) - 1 do begin
      roomLocation := _rooms[i].GetLocation();
      if((roomLocation.X = x) and (roomLocation.Y = y)) then
         exit(_rooms[i]);
    end;

    result := nil;
end;

procedure TGameComposition.EnterRoom(room : IRoom);
begin
   _currentRoom := room;
   room.EnterRoom();
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
var customDrawingRoom : ICustomDrawingRoom;
begin
    if(Supports(_currentRoom, ICustomDrawingRoom, customDrawingRoom)) then
       customDrawingRoom.Draw(bitmap)
    else
       _currentLevel.DrawDefaultRoom(_currentRoom, bitmap);
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

