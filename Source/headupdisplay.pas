unit  HeadUpDisplay;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelDesign;

type
  THeadUpDisplay= class
     private
        _rooms: TRoomArray;
    public
       procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
       procedure InitializeRooms(rooms : TRoomArray);
       procedure CurrentRoomChanged(currentRoom : IRoom);
  end;

implementation

procedure THeadUpDisplay.Render(bitmap : TBGRABitmap; deltaTime : Int64);
var
  i, maxX, minX, maxY, minY: integer;

begin
   minX:= _rooms[0].GetLocation.x;
   minY:= _rooms[0].GetLocation.y;
   maxX:= _rooms[0].GetLocation.x;
   maxY:= _rooms[0].GetLocation.y;

   for i:= 0 to length(_rooms)-1 do begin

     if _rooms[i].GetLocation.x < minX then
        minX:= _rooms[i].GetLocation.x;

      if _rooms[i].GetLocation.y < minY then
        minX:= _rooms[i].GetLocation.y;

      if _rooms[i].GetLocation.x > maxX then
        minX:= _rooms[i].GetLocation.x;

      if _rooms[i].GetLocation.x > maxY then
        minX:= _rooms[i].GetLocation.y;

   end;


end;

procedure THeadUpDisplay.InitializeRooms(rooms : TRoomArray);
begin
   _rooms:= rooms;

  end;

procedure THeadUpDisplay.CurrentRoomChanged(currentRoom : IRoom);
begin

end;

end.

