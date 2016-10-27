unit LevelDesign;

{$mode objfpc}{$H+}
{$interfaces corba}

interface

uses
  Classes, SysUtils, LevelUtils, BGRABitmap, Controls;

const
  InjectionGuid = '229c7657-a84e-4a27-8345-52f1f2ca04df';

type
  {$PACKENUM 1}
  RoomType = (Normal, ContainsObjective, MonsterRoom, EscapeRoom);

type
  {$PACKENUM 1}
  Direction = (Left, Top, Right, Bottom);

type
  {$PACKENUM 1}
  CompositionType = (None, Intro, Menu, Game, DoorUnlocking, OffScreen, Dead, LevelCompleted, LockPick);

type
  {$PACKENUM 1}
  CharacterState = (DefaultNorth, DefaultEast, DefaultSouth, DefaultWest, RunningNorth, RunningEast, RunningSouth, RunningWest);

type
  ISpecialExit = interface(IInterface)
  ['{b45dfaed-56f0-4746-b7e0-7b4938af9522}']
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
  TObjective = class
    private
      var
         _location : TRectangle;
         _objectiveId, _normalImagePath, _hoveredImagePath, _itemImagePath : string;
         _cachedNormalImage, _cachedHoveredImage, _cachedItemImage : TBGRABitmap;
      function GetItemImage() : TBGRABitmap;
    public
      constructor Create(objectiveIdVal : string; locationVal : TRectangle; normalImagePath, hoveredImagePath, itemImagePath : string);
      property Location: TRectangle read _location;
      property ObjectiveId: string read _objectiveId;
      property ItemImage: TBGRABitmap read GetItemImage;

      function GetObjectiveImage(mouseOver : boolean) : TBGRABitmap;
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

type
  TObjectiveRoom = class abstract(TInterfacedObject, IObjectiveRoom, IRoom)
     public
        constructor Create();
        function GetObjectives() : TObjectiveArray;
        procedure ObjectiveCollected(objective : TObjective);
        procedure EnterRoom(); virtual; abstract;
        function GetExtendedExits() : TSpecialExitArray; virtual; abstract;
        function GetLocation() : TPoint; virtual; abstract;
     protected
        procedure AddObjective(objective : TObjective);
     private
        _objectivesArray : array of TObjective;
        _collectedArray : array of boolean;
  end;

type
  TStandardRoom = class(TInterfacedObject, IRoom, ICustomDrawingRoom)
     public
        constructor Create(location : TPoint; roomImagePath : string); virtual;
        procedure EnterRoom(); virtual;
        function GetExtendedExits() : TSpecialExitArray; virtual;
        function GetLocation() : TPoint; virtual;
        function Draw() : TBGRABitmap; virtual;
     private
        _location : TPoint;
        _roomImage : TBGRABitmap;
  end;

type
  TStandardMonsterRoom = class(TInterfacedObject, ICustomDrawingRoom, IRoom, IMonsterRoom)
     public
        constructor Create(location : TPoint; roomImagePath, roomWithMonsterImagePath : string);
        procedure EnterRoom();
        function GetExtendedExits() : TSpecialExitArray;
        function GetLocation() : TPoint;
        function Draw() : TBGRABitmap;
        function DrawWithMonster() : TBGRABitmap;
        function ContainsMonster() : boolean;
     private
        var _normalBitmap, _monsterBitmap : TBGRABitmap;
            _location : TPoint;
  end;

implementation

constructor TStandardMonsterRoom.Create(location : TPoint; roomImagePath, roomWithMonsterImagePath : string);
begin
   _normalBitmap := TBGRABitmap.Create(roomImagePath);
   _monsterBitmap := TBGRABitmap.Create(roomWithMonsterImagePath);
   _location := location;
end;

procedure TStandardMonsterRoom.EnterRoom();
begin

end;

function TStandardMonsterRoom.GetExtendedExits() : TSpecialExitArray;
begin
   exit(nil);
end;

function TStandardMonsterRoom.GetLocation() : TPoint;
begin
   exit(_location);
end;

function TStandardMonsterRoom.Draw() : TBGRABitmap;
begin
   exit(_normalBitmap);
end;

function TStandardMonsterRoom.DrawWithMonster() : TBGRABitmap;
begin
   exit(_monsterBitmap);
end;

function TStandardMonsterRoom.ContainsMonster() : boolean;
begin
   exit(true);
end;

constructor TStandardRoom.Create(location : TPoint; roomImagePath : string);
begin
   _location := location;
   _roomImage := TBGRABitmap.Create(roomImagePath);
end;

procedure TStandardRoom.EnterRoom();
begin
end;

function TStandardRoom.GetExtendedExits() : TSpecialExitArray;
begin
   exit(nil);
end;

function TStandardRoom.GetLocation() : TPoint;
begin
   exit(_location);
end;

function TStandardRoom.Draw() : TBGRABitmap;
begin
   exit(_roomImage);
end;

constructor TSwitchInfo.Create(compositionVal : CompositionType; parameterVal : TObject);
begin
  _composition := compositionVal;
  _parameter := parameterVal;
end;

constructor TObjective.Create(objectiveIdVal : string; locationVal : TRectangle; normalImagePath, hoveredImagePath, itemImagePath : string);
begin
    _objectiveId := objectiveIdVal;
    _location := locationVal;
    _normalImagePath := normalImagePath;
    _hoveredImagePath := hoveredImagePath;
    _itemImagePath := itemImagePath;
end;

function TObjective.GetItemImage() : TBGRABitmap;
begin
   if(_cachedItemImage = nil) then
      _cachedItemImage := TBGRABitmap.Create(_itemImagePath);

   exit(_cachedItemImage);
end;

function TObjective.GetObjectiveImage(mouseOver : boolean) : TBGRABitmap;
begin
   if(not mouseOver) then begin
      if(_cachedNormalImage = nil) then
         _cachedNormalImage := TBGRABitmap.Create(_normalImagePath);
      exit(_cachedNormalImage);
   end
   else begin
     if(_cachedHoveredImage = nil) then
        _cachedHoveredImage := TBGRABitmap.Create(_hoveredImagePath);

     exit(_cachedHoveredImage);
   end;

end;

constructor TObjectiveRoom.Create();
begin
   SetLength(_objectivesArray, 0);
   SetLength(_collectedArray, 0);
end;

function TObjectiveRoom.GetObjectives() : TObjectiveArray;
var objectivesArray : array of TObjective;
    objective : TObjective;
    i, arrayLength : integer;
begin
   SetLength(objectivesArray, 0);

   if(Length(_objectivesArray) = 0) then
      exit(objectivesArray);

   //we only take objectives which aren't nil and which weren't taken
   for i := 0 to Length(_objectivesArray) - 1 do begin
       objective := _objectivesArray[i];

       if((objective <> nil) and not _collectedArray[i]) then begin
          arrayLength := Length(objectivesArray);
          SetLength(objectivesArray, arrayLength + 1);
          objectivesArray[arrayLength] := objective;
       end;
   end;

   exit(objectivesArray);
end;

procedure TObjectiveRoom.ObjectiveCollected(objective : TObjective);
var i : integer;
begin
   for i := 0 to Length(_objectivesArray) - 1 do begin
       if(_objectivesArray[i] = objective) then begin
          _collectedArray[i] := true; //this objective was taken
          exit;
       end;
   end;
end;

procedure TObjectiveRoom.AddObjective(objective : TObjective);
var arrayLength : integer;
begin
   arrayLength := Length(_objectivesArray);
   SetLength(_objectivesArray, arrayLength + 1);
   SetLength(_collectedArray, arrayLength + 1);

   _objectivesArray[arrayLength] := objective;
   _collectedArray[arrayLength] := false;
end;

end.

