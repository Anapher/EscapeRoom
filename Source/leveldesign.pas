unit LevelDesign;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelUtils;
type
  {$PACKENUM 1}
  RoomType = (Normal, ContainsObjective, MonsterRoom, EscapeRoom);

type
  IRoom = interface
     procedure EnterRoom();
     procedure EnterRoomForTheFirstTime();
     function GetExtendedDoors();
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

implementation

end.

