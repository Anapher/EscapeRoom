unit PrisonLevel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelDesign, LevelUtils, SpecialExits, BGRABitmap,
  BGRABitmapTypes, BGRAGradients, Storyboard;

type
  TPrisonLevel = class(ILevel)
    constructor Create();
    function GetRooms() : TRoomArray;
    function GetStartLocation() : TPoint;
    function GetSecureArea() : TPoint;
    function DrawDefaultRoom(room : IRoom) : TBGRABitmap;
    function GetIsControlLocked() : boolean;
    procedure AfterProcessing(currentRoom : IRoom; bitmap : TBGRABitmap; deltaTime : Int64);

    function GetLevelName() : string;
    function GetDifficulty() : integer;

    function GetRoom1x0y() : IRoom;
    function GetRoom2x0y() : IRoom;
    function GetRoom3x0y() : IRoom;
    function GetRoom3xm1y() : IRoom;
    function GetRoom3xm3y() : IRoom;

    function GetCellRoom(x, y : integer; isAtTop : boolean) : IRoom;
    function GetCellMonsterRoom(x, y : integer; isAtTop : boolean) : IRoom;
  var _storyboard : TStoryboard;
      _isControlLocked : boolean;
      _currentRoom : IRoom;
      _enteredCorridorRoom : boolean;
  end;

implementation

constructor TPrisonLevel.Create();
begin
    _storyboard := TStoryboard.Create();
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Sie befinden sich in einem Gefägnis', BGRA(255, 255, 255, 200), 2000, 500, 2000));
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Finden Sie den Ausgang!', BGRA(255, 255, 255, 200), 5000, 500, 2000));
    _isControlLocked := true;

    _currentRoom := nil;
    _enteredCorridorRoom := false;
end;

function TPrisonLevel.DrawDefaultRoom(room : IRoom) : TBGRABitmap;
begin
   result := nil;
end;

procedure TPrisonLevel.AfterProcessing(currentRoom : IRoom; bitmap : TBGRABitmap; deltaTime : Int64);
begin
    bitmap.FontAntialias := true;
    bitmap.FontHeight := Round(bitmap.Height / 50);
    _storyboard.Render(bitmap, deltaTime);

    if(currentRoom <> _currentRoom) then begin
        _currentRoom := currentRoom;
    end;

    if(deltaTime > 8000) then
       _isControlLocked := false;
end;

function TPrisonLevel.GetRoom1x0y() : IRoom;
var standardRoom : TStandardRoom;
    extendedExits : array[0..1] of ISpecialExit;
    lockPickExit : TLockPickExit;
begin
    standardRoom := TStandardRoom.Create(TPoint.Create(1, 0), 'resources\levels\prison\corridorRoom.png');
    lockPickExit := TLockPickExit.Create(Direction.Bottom);
    lockPickExit.Bolts := 12;
    lockPickExit.Tries := 16;
    extendedExits[0] := lockPickExit;

    standardRoom.ExtendedExits := extendedExits;
    exit(standardRoom);
end;

function TPrisonLevel.GetRoom2x0y() : IRoom;
var standardRoom : TStandardRoom;
    extendedExits : array[0..1] of ISpecialExit;
    lockPickExit : TLockPickExit;
begin
   standardRoom := TStandardRoom.Create(TPoint.Create(2, 0), 'resources\levels\prison\corridorRoom.png');
   lockPickExit := TLockPickExit.Create(Direction.Top);
   lockPickExit.Bolts := 4;
   lockPickExit.Tries := 6;
   extendedExits[0] := lockPickExit;

   standardRoom.ExtendedExits := extendedExits;
   exit(standardRoom);
end;

function TPrisonLevel.GetRoom3x0y() : IRoom;
var standardRoom : TStandardRoom;
    extendedExits : array[0..2] of ISpecialExit;
    lockPickExit : TLockPickExit;
begin
   standardRoom := TStandardRoom.Create(TPoint.Create(3, 0), 'resources\levels\prison\corridorRoom.png');
   lockPickExit := TLockPickExit.Create(Direction.Top);
   lockPickExit.Bolts := 8;
   lockPickExit.Tries := 10;
   extendedExits[0] := lockPickExit;

   lockPickExit := TLockPickExit.Create(Direction.Bottom);
   lockPickExit.Bolts := 4;
   lockPickExit.Tries := 6;
   extendedExits[1] := lockPickExit;

   standardRoom.ExtendedExits := extendedExits;
   exit(standardRoom);
end;

function TPrisonLevel.GetCellRoom(x, y : integer; isAtTop : boolean) : IRoom;
var standardRoom : TStandardRoom;
    extendedExits : array[0..2] of ISpecialExit;
begin
   if(isAtTop) then
      standardRoom := TStandardRoom.Create(TPoint.Create(x, y), 'resources\levels\prison\topCell.png')
   else
      standardRoom := TStandardRoom.Create(TPoint.Create(x, y), 'resources\levels\prison\bottomCell.png');

   extendedExits[0] := TNoExit.Create(Direction.Left);
   extendedExits[1] := TNoExit.Create(Direction.Right);
   if(isAtTop) then
      extendedExits[2] := TNoExit.Create(Direction.Top)
   else
      extendedExits[2] := TNoExit.Create(Direction.Bottom);

   standardRoom.ExtendedExits := extendedExits;
   exit(standardRoom);
end;

function TPrisonLevel.GetCellMonsterRoom(x, y : integer; isAtTop : boolean) : IRoom;
var standardRoom : TStandardMonsterRoom;
    extendedExits : array[0..2] of ISpecialExit;
begin
   if(isAtTop) then
      standardRoom := TStandardMonsterRoom.Create(TPoint.Create(x, y), 'resources\levels\prison\topCell.png', 'resources\levels\prison\topCell_Monster.png')
   else
      standardRoom := TStandardMonsterRoom.Create(TPoint.Create(x, y), 'resources\levels\prison\topCell_Monster.png', 'resources\levels\prison\bottomCell_Monster.png');

   extendedExits[0] := TNoExit.Create(Direction.Left);
   extendedExits[1] := TNoExit.Create(Direction.Right);
   if(isAtTop) then
      extendedExits[2] := TNoExit.Create(Direction.Top)
   else
      extendedExits[2] := TNoExit.Create(Direction.Bottom);

   standardRoom.ExtendedExits := extendedExits;
   exit(standardRoom);
end;

function TPrisonLevel.GetRoom3xm1y() : IRoom;
var standardRoom : TStandardRoom;
    extendedExits : array[0..1] of ISpecialExit;
    lockPickExit : TLockPickExit;
begin
   standardRoom := TStandardRoom.Create(TPoint.Create(3, -1), 'resources\levels\prison\Room3xm1y.png');
   extendedExits[0] := TNoExit.Create(Direction.Left);
   extendedExits[1] := TNoExit.Create(Direction.Right);

   standardRoom.ExtendedExits := extendedExits;
   exit(standardRoom);
end;

function TPrisonLevel.GetRoom3xm3y() : IRoom;
var standardRoom : TStandardRoom;
    extendedExits : array[0..1] of ISpecialExit;
    lockPickExit : TLockPickExit;
begin
   standardRoom := TStandardRoom.Create(TPoint.Create(3, -3), 'resources\levels\prison\EndRoom.png');

   lockPickExit := TLockPickExit.Create(Direction.Bottom);
   lockPickExit.Bolts := 8;
   lockPickExit.Tries := 10;

   extendedExits[0] := lockPickExit;
   extendedExits[1] := TLevelCompletedExit.Create(Direction.Bottom);

   standardRoom.ExtendedExits := extendedExits;
   exit(standardRoom);
end;

function TPrisonLevel.GetRooms() : TRoomArray;
   var roomArray : array[0..15] of IRoom;
begin
    roomArray[0] := TStandardRoom.Create(TPoint.Create(0, 0), 'resources\levels\prison\startRoom.png');
    roomArray[1] := GetRoom1x0y();
    roomArray[2] := GetCellRoom(1, 1, true);
    roomArray[3] := GetCellMonsterRoom(1, -1, false);
    roomArray[4] := GetRoom2x0y();
    roomArray[5] := GetCellMonsterRoom(2, 1, true);
    roomArray[6] := GetCellRoom(2, -1, false);
    roomArray[7] := GetRoom3x0y();
    roomArray[8] := GetCellRoom(3, 1, true);
    roomArray[9] := TStandardRoom.Create(TPoint.Create(4, 0), 'resources\levels\prison\endCorridorRoom.png');
    roomArray[10] := GetCellMonsterRoom(4, 1, true);
    roomArray[11] := GetCellMonsterRoom(4, -1, false);
    roomArray[12] := GetRoom3xm1y();
    roomArray[13] := TStandardRoom.Create(TPoint.Create(3, -2), 'resources\levels\prison\Room3xm2y.png');
    roomArray[14] := TStandardMonsterRoom.Create(TPoint.Create(4, -2), 'resources\levels\prison\Room4xm2y.png', 'resources\levels\prison\Room4xm2y_Monster.png');
    roomArray[15] := GetRoom3xm3y();

    exit(roomArray);
end;

function TPrisonLevel.GetIsControlLocked() : boolean;
begin
   exit(_isControlLocked);
end;

function TPrisonLevel.GetStartLocation() : TPoint;
begin
   exit(TPoint.Create(0, 0));
end;

function TPrisonLevel.GetSecureArea() : TPoint;
begin
   exit(TPoint.Create(0, 0));
end;

function TPrisonLevel.GetDifficulty() : integer;
begin
   exit(4);
end;

function TPrisonLevel.GetLevelName() : string;
begin
    exit('Das Gefängnis');
end;

end.

