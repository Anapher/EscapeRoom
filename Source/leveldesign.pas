unit LevelDesign;

{$mode objfpc}{$H+}
{$interfaces corba}

interface

uses
  Classes, SysUtils, LevelUtils, BGRABitmap, Controls, Objectives;
type
  {$PACKENUM 1}
  RoomType = (Normal, ContainsObjective, MonsterRoom, EscapeRoom);

type
  {$PACKENUM 1}
  Direction = (Left, Top, Right, Bottom);

type
  {$PACKENUM 1}
  CompositionType = (None, Intro, Menu, Game, DoorUnlocking, OffScreen, Dead);

type
  {$PACKENUM 1}
  CharacterState = (DefaultNorth, DefaultEast, DefaultSouth, DefaultWest, RunningNorth, RunningEast, RunningSouth, RunningWest);

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
      function Draw() : TBGRABitmap;
  end;

type
  TObjectiveArray = array of TObjective;

type
  IObjectiveRoom = interface(IRoom)
  ['{aa4bc91e-a9e1-4dea-a191-2f246900cff1}']
      function GetObjectives() : TObjectiveArray;
      procedure ObjectiveCollected(objective : TObjective);
  end;

type
  IMonsterRoom = interface(ICustomDrawingRoom)
  ['{fafdfac0-1312-4b55-a37e-5f594103de25}']
      function DrawWithMonster() : TBGRABitmap;
      function ContainsMonster() : boolean;
  end;

type
  TRoomArray = array of IRoom;

type
  ILevel = interface
     function GetRooms() : TRoomArray;
     function GetStartLocation() : TPoint;
     function GetSecureArea() : TPoint;
     function DrawDefaultRoom(room : IRoom) : TBGRABitmap;
     function GetIsControlLocked() : boolean;
     procedure AfterProcessing(currentRoom : IRoom; bitmap : TBGRABitmap; deltaTime : Int64);

     function GetLevelName() : string;
     function GetDifficulty() : integer;

     property IsControlLocked: boolean read GetIsControlLocked;
  end;

type
  TSwitchInfo = class
     private
       _composition : CompositionType;
       _parameter : TObject;
     public
       constructor Create(compositionVal : CompositionType; parameterVal : TObject);

       property Composition: CompositionType read _composition write _composition;
       property Parameter: TObject read _parameter write _parameter;
  end;

type
  IComposition = interface
     function RequireSwitch() : TSwitchInfo;
     function GetCompositionType() : CompositionType;
     procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
     procedure Initialize(parameter : TObject);

     procedure KeyDown(var Key: Word; Shift: TShiftState);
     procedure MouseMove(Shift: TShiftState; X, Y: Integer);
     procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

type
  ICharacter = interface
    function Render(state : CharacterState; deltaTimeSinceLastStateChange : Int64) : TBGRABitmap;
    function GetThumbnail() : TBGRABitmap;
    function GetDesiredSize(roomSize : TSize) : TSize;
  end;

implementation

constructor TSwitchInfo.Create(compositionVal : CompositionType; parameterVal : TObject);
begin
  _composition := compositionVal;
  _parameter := parameterVal;
end;

end.

