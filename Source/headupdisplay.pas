unit  HeadUpDisplay;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelUtils, LevelDesign, Objectives;

type
  {$PACKENUM 1}
  CurrentHeadUpDisplayStatus = (Normal, MonsterIsChasing);

type
  THeadUpDisplay= class
     private
        var
        _rooms: TRoomArray;
        _currentStatus : CurrentHeadUpDisplayStatus;
        _monsterTimeLeft : integer;

    public
       procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
       procedure InitializeRooms(rooms : TRoomArray);
       procedure CurrentRoomChanged(currentRoom : IRoom);
       procedure ItemPickedUp(item : TObjective);

       property CurrentStatus: CurrentHeadUpDisplayStatus read _currentStatus write _currentStatus;
       property MonsterTimeLeft: integer read _monsterTimeLeft write _monsterTimeLeft;
  end;

implementation

procedure THeadUpDisplay.Render(bitmap : TBGRABitmap; deltaTime : Int64);
var
  i, maxX, minX, maxY, minY: integer;
  mapLocation: TRectangle;
  roomWidth,roomHeight: integer;
  numberRoomsX, numberRoomsY: integer;
  sortedRoomsX, sortedRoomsY : TRoomArray;
  newX, newY: integer;

begin
   minX:= _rooms[0].GetLocation.x;
   minY:= _rooms[0].GetLocation.y;
   maxX:= _rooms[0].GetLocation.x;
   maxY:= _rooms[0].GetLocation.y;

   for i:= 1 to length(_rooms)-1 do begin

     if _rooms[i].GetLocation.x < minX then
        minX:= _rooms[i].GetLocation.x;

      if _rooms[i].GetLocation.y < minY then
        minY:= _rooms[i].GetLocation.y;

      if _rooms[i].GetLocation.x > maxX then
        maxX:= _rooms[i].GetLocation.x;

      if _rooms[i].GetLocation.x > maxY then
        maxY:= _rooms[i].GetLocation.y;

   end;

  mapLocation:= Trectangle.create(round(0.02*bitmap.width) ,
                bitmap.height - (round(0.32 * bitmap.height)),
                round(0.25 * bitmap.width),
                round(0.3 * bitmap.height));

  bitmap.rectangle(mapLocation.x, mapLocation.y,
                mapLocation.x+mapLocation.width,
                mapLocation.y+mapLocation.height,BGRA(255,255,255,125),
                TDrawMode.dmDrawWithTransparency);

  numberRoomsX:= maxX - minX;
  numberRoomsY:= maxY - minY;

  roomWidth:= round(mapLocation.width / numberRoomsX);
  roomHeight:= round(mapLocation.height / numberRoomsY);

  for i:= 0 to length(_rooms)-1 do begin
           newX:= maplocation.x+(_rooms[i].GetLocation.x-minX) * roomWidth;
           newY:= mapLocation.y+(_rooms[i].Getlocation.y-minY) * roomHeight;
           bitmap.Rectangle(newX,newY,newX+roomWidth,newY+roomHeight,BGRA(0,0,0,200),
                TDrawMode.dmDrawWithTransparency);

  end;



end;

procedure THeadUpDisplay.InitializeRooms(rooms : TRoomArray);
begin
   _rooms:= rooms;

  end;

procedure THeadUpDisplay.CurrentRoomChanged(currentRoom : IRoom);
begin

end;

procedure THeadUpDisplay.ItemPickedUp(item : TObjective);
begin

end;


end.

