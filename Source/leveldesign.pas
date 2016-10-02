unit LevelDesign;

{$mode objfpc}{$H+}
{$interfaces corba}

interface

uses
  Classes, SysUtils, LevelUtils, BGRABitmap, Controls;
type
  {$PACKENUM 1}
  RoomType = (Normal, ContainsObjective, MonsterRoom, EscapeRoom);

type
  {$PACKENUM 1}
  Direction = (Left, Top, Right, Bottom);

type
  {$PACKENUM 1}
  CompositionType = (None, Intro, Menu, Game, DoorUnlocking, OffScreen);

type
  ISpecialExit = interface
      function GetExitPosition() : Direction;
  end;

type
  TSpecialExitArray = array of ISpecialExit;

type
  IRoom = interface
     procedure EnterRoom();
     procedure EnterRoomForTheFirstTime();
     function GetExtendedExits() : TSpecialExitArray;
  end;

type
  ICustomDrawingRoom = interface(IRoom)
      procedure Draw();
  end;

type
  IObjectiveRoom = interface(IRoom)
      function GetObjectiveCount() : integer;
      procedure GetObjective(index : integer);
  end;

type
  IPortalRoom = interface(IRoom)
       function GetTargetRoom() : TPoint;
  end;

type
  TRoomArray = array of IRoom;

type
  ILevel = interface
     function GetRooms() : TRoomArray;
     function GetStartLocation() : TPoint;

     function GetLevelName() : string;
     function GetDifficulty() : integer;
  end;

type
  IComposition = interface
     function RequireSwitch() : CompositionType;
     function GetCompositionType() : CompositionType;
     procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);

     procedure KeyDown(var Key: Word; Shift: TShiftState);
     procedure MouseMove(Shift: TShiftState; X, Y: Integer);
     procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

implementation

end.

