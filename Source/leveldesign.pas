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
      procedure SetExitPassed();
      function GetExitPassed() : boolean;
  end;

type
  TSpecialExitArray = array of ISpecialExit;

type
  IRoom = interface(IInterface)
  ['{60F37191-5B95-45BC-8C14-76633826889E}']
     procedure EnterRoom();
     function GetExtendedExits() : TSpecialExitArray;
     function GetLocation() : TPoint;
  end;

type
  ICustomDrawingRoom = interface(IRoom)
  ['{0b3a3d3d-af46-4afa-bc24-4f3a8610a7b8}']
      procedure Draw(bitmap : TBGRABitmap);
  end;

type
  IObjectiveRoom = interface(IRoom)
  ['{aa4bc91e-a9e1-4dea-a191-2f246900cff1}']
      function GetObjectiveCount() : integer;
      procedure GetObjective(index : integer);
  end;

type
  IMonsterRoom = interface(ICustomDrawingRoom)
  ['{fafdfac0-1312-4b55-a37e-5f594103de25}']
      procedure DrawWithMonster(bitmap : TBGRABitmap);
      function ContainsMonster() : boolean;
  end;

type
  TRoomArray = array of IRoom;

type
  ILevel = interface
     function GetRooms() : TRoomArray;
     function GetStartLocation() : TPoint;
     function GetSecureArea() : TPoint;
     procedure DrawDefaultRoom(room : IRoom; bitmap : TBGRABitmap);

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

