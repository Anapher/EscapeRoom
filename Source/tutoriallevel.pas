unit TutorialLevel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelDesign, LevelUtils, SpecialExits, BGRABitmap,
  BGRABitmapTypes, BGRAGradients;

type
  TTutorialLevel = class(ILevel)
     function GetRooms() : TRoomArray;
     function GetStartLocation() : TPoint;
     function GetSecureArea() : TPoint;
     procedure DrawDefaultRoom(room : IRoom; bitmap : TBGRABitmap);

     function GetLevelName() : string;
     function GetDifficulty() : integer;
  end;

type
  TStartRoom = class(TInterfacedObject, ICustomDrawingRoom, IRoom)
     constructor Create();
     procedure EnterRoom();
     function GetExtendedExits() : TSpecialExitArray;
     procedure Draw(bitmap : TBGRABitmap);
     function GetLocation() : TPoint;

     var _extendedExits : array of ISpecialExit;
         _normalBitmap, _doorOpenedBitmap : TBGRABitmap;
  end;

implementation

function TTutorialLevel.GetRooms() : TRoomArray;
   var roomArray : array[0..5] of IRoom;
begin
    roomArray[0] := TStartRoom.Create();
    exit(roomArray);
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

procedure TTutorialLevel.DrawDefaultRoom(room : IRoom; bitmap : TBGRABitmap);
begin

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

procedure TStartRoom.Draw(bitmap : TBGRABitmap);
var bitmapToDraw : TBGRABitmap;
var shortestSide, verticalSpace, horizontalSpace : integer;
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

   if(bitmap.Width > bitmap.Height) then
      shortestSide := bitmap.Height
   else
      shortestSide := bitmap.Width;

   horizontalSpace := round((bitmap.Width - shortestSide) / 2);
   verticalSpace := round((bitmap.Height - shortestSide) / 2);
   //bitmap.PutImage(0, 0, bitmapToDraw, dmDrawWithTransparency);
   bitmap.StretchPutImage(RectWithSize(horizontalSpace,verticalSpace,shortestSide,shortestSide), bitmapToDraw, dmDrawWithTransparency);
end;

function TStartRoom.GetLocation() : TPoint;
begin
   exit(TPoint.Create(0, 0));
end;

end.

