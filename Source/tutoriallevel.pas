unit TutorialLevel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelDesign, LevelUtils, SpecialExits, BGRABitmap,
  BGRABitmapTypes, BGRAGradients, Storyboard, Objectives;

type
  TTutorialLevel = class(ILevel)
     constructor Create();

     function GetRooms() : TRoomArray;
     function GetStartLocation() : TPoint;
     function GetSecureArea() : TPoint;
     function DrawDefaultRoom(room : IRoom) : TBGRABitmap;
     function GetIsControlLocked() : boolean;
     procedure AfterProcessing(currentRoom : IRoom; bitmap : TBGRABitmap; deltaTime : Int64);

     function GetLevelName() : string;
     function GetDifficulty() : integer;

     var _storyboard : TStoryboard;
         _isControlLocked : boolean;
         _currentRoom : IRoom;
         _enteredCorridorRoom : boolean;
  end;

type
  TStartRoom = class(TInterfacedObject, ICustomDrawingRoom, IRoom)
     constructor Create();
     procedure EnterRoom();
     function GetExtendedExits() : TSpecialExitArray;
     function Draw() : TBGRABitmap;
     function GetLocation() : TPoint;

     var _extendedExits : array of ISpecialExit;
         _normalBitmap, _doorOpenedBitmap : TBGRABitmap;
  end;

type
  TStandardRoom = class(TInterfacedObject, IRoom)
     public
        constructor Create(location : TPoint);
        procedure EnterRoom();
        function GetExtendedExits() : TSpecialExitArray;
        function GetLocation() : TPoint;
     private
        _location : TPoint;
  end;

type
  TCorridorRoom = class(TInterfacedObject, ICustomDrawingRoom, IObjectiveRoom, IRoom)
     public
        constructor Create();
        procedure EnterRoom();
        function GetExtendedExits() : TSpecialExitArray;
        function Draw() : TBGRABitmap;
        function GetLocation() : TPoint;
        function GetObjectives() : TObjectiveArray;
        procedure ObjectiveCollected(objective : TObjective);
     private
        var _normalBitmap : TBGRABitmap;
  end;

implementation

constructor TTutorialLevel.Create();
begin
    _storyboard := TStoryboard.Create();
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Hallo und Willkommen zu Escape Room', BGRA(255, 255, 255, 200), 2000, 500, 2000));
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Dies ist das Tutorial Level, in welchem Sie die Spielweise erlernen sollen', BGRA(255, 255, 255, 200), 5000, 500, 2000));
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Sie befinden sich in einem mysteriösen Haus, aus welchem Sie entkommen wollen', BGRA(255, 255, 255, 200), 8000, 500, 2000));
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Finden Sie den Schlüssel, um die Tür zu öffnen, aber passen Sie auf!', BGRA(255, 255, 255, 200), 11000, 500, 2000));
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Laut unbestätigten Berichten sind Sie nicht alleine.', BGRA(255, 255, 255, 200), 14000, 500, 2000));
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Kommen Sie hierher zurück, sollten Sie irgendetwas bemerken.', BGRA(255, 255, 255, 200), 17000, 500, 2000));
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Sie können sich jetzt mit den Pfeiltasten bewegen. Viel Glück!', BGRA(255, 255, 255, 200), 20000, 500, 3500));
    _isControlLocked := true;

    _currentRoom := nil;
    _enteredCorridorRoom := false;
end;

function TTutorialLevel.GetRooms() : TRoomArray;
   var roomArray : array[0..5] of IRoom;
begin
    roomArray[0] := TStartRoom.Create();
    roomArray[1] := TCorridorRoom.Create();
    exit(roomArray);
end;

function TTutorialLevel.DrawDefaultRoom(room : IRoom) : TBGRABitmap;
begin
   result := nil;
end;

procedure TTutorialLevel.AfterProcessing(currentRoom : IRoom; bitmap : TBGRABitmap; deltaTime : Int64);
begin
    bitmap.FontAntialias := true;
    bitmap.FontHeight := Round(bitmap.Height / 50);
    _storyboard.Render(bitmap, deltaTime);

    if(currentRoom <> _currentRoom) then begin
        _currentRoom := currentRoom;
        if((currentRoom is TCorridorRoom) and (not _enteredCorridorRoom)) then begin
            _enteredCorridorRoom := true;
            _storyboard.AddAnimation(TTextFadeAnimation.Create('Oh, hier liegen Spritzen, sehr gut. Sammel Sie mit der Maus ein.', BGRA(255, 255, 255, 200), deltaTime, 500, 3000));
        end;
    end;
    //if(deltaTime > 23500) then
       _isControlLocked := false;
end;

function TTutorialLevel.GetIsControlLocked() : boolean;
begin
   exit(_isControlLocked);
end;

function TTutorialLevel.GetStartLocation() : TPoint;
begin
   exit(TPoint.Create(0, 0));
end;

function TTutorialLevel.GetSecureArea() : TPoint;
begin
   exit(TPoint.Create(0, 0));
end;

function TTutorialLevel.GetLevelName() : string;
begin
    exit('Tutorial');
end;

function TTutorialLevel.GetDifficulty() : integer;
begin
   exit(2);
end;

//Start Room
constructor TStartRoom.Create();
begin
   SetLength(_extendedExits, 2);
   _extendedExits[0] := TLockedExit.Create(Direction.Bottom, '9376646c-d9ad-4d35-9688-c0db48b9c52f');
   _extendedExits[1] := TLevelCompletedExit.Create(Direction.Bottom);
end;

procedure TStartRoom.EnterRoom();
begin

end;

function TStartRoom.GetExtendedExits() : TSpecialExitArray;
begin
    exit(_extendedExits);
end;

function TStartRoom.Draw() : TBGRABitmap;
var bitmapToDraw : TBGRABitmap;
begin
   if(not _extendedExits[0].GetExitPassed()) then begin
       if(_normalBitmap = nil) then
          _normalBitmap := TBGRABitmap.Create('resources\levels\tutorial\startRoom.png', false);
       bitmapToDraw := _normalBitmap;
   end
   else
   begin
       if(_doorOpenedBitmap = nil) then
          _doorOpenedBitmap := TBGRABitmap.Create('resources\levels\tutorial\startRoom_open.png', false, [TBGRALoadingOption.loKeepTransparentRGB]);
   end;

   exit(bitmapToDraw);
end;

function TStartRoom.GetLocation() : TPoint;
begin
   exit(TPoint.Create(0, 0));
end;

//StandardRoom
constructor TStandardRoom.Create(location : TPoint);
begin
    _location := location;
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

//Corridor
constructor TCorridorRoom.Create();
begin
    _normalBitmap := TBGRABitmap.Create('resources\levels\tutorial\corridorRoom.png', false);
end;

procedure TCorridorRoom.EnterRoom();
begin
end;

function TCorridorRoom.GetExtendedExits() : TSpecialExitArray;
begin
    exit(nil);
end;

function TCorridorRoom.Draw() : TBGRABitmap;
begin
   exit(_normalBitmap);
end;

function TCorridorRoom.GetLocation() : TPoint;
begin
   exit(TPoint.Create(1, 0));
end;

function TCorridorRoom.GetObjectives() : TObjectiveArray;
begin
   exit(nil);
end;

procedure TCorridorRoom.ObjectiveCollected(objective : TObjective);
begin

end;

end.

