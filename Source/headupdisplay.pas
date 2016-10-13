unit  HeadUpDisplay;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelUtils, LevelDesign;

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
        _secureRoomLocation : TPoint;
        _LocationCurrentRoom: IRoom;
        _visitedRooms: Array of boolean;
    public
       procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
       procedure InitializeRooms(rooms : TRoomArray);
       procedure CurrentRoomChanged(currentRoom : IRoom);
       procedure ItemPickedUp(item : TObjective);

       property CurrentStatus: CurrentHeadUpDisplayStatus read _currentStatus write _currentStatus;
       property MonsterTimeLeft: integer read _monsterTimeLeft write _monsterTimeLeft;
       property SecureRoomLocation: TPoint read _secureRoomLocation write _secureRoomLocation;
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

      if _rooms[i].GetLocation.y > maxY then
        maxY:= _rooms[i].GetLocation.y;

   end;

  mapLocation:= Trectangle.create(round(0.02*bitmap.width) ,
                bitmap.height - (round(0.32 * bitmap.height)),
                round(0.25 * bitmap.width),
                round(0.3 * bitmap.height));

//   bitmap.FillRect(mapLocation.x, mapLocation.y,
//                mapLocation.x+mapLocation.width,
//                mapLocation.y+mapLocation.height,BGRA(255,255,255,125),
//                TDrawMode.dmDrawWithTransparency);

  numberRoomsX:= abs(max(maxX,minX)) + abs(min(maxX,minX))+1;
  numberRoomsY:= abs(max(maxY,minY)) + abs(min(maxY,minY))+1;

  roomWidth:= round(mapLocation.width / numberRoomsX);
  roomHeight:= round(mapLocation.height / numberRoomsY);


  for i:= 0 to length(_rooms)-1 do begin


     if _visitedRooms[i]=true then begin

           newX:= maplocation.x+(_rooms[i].GetLocation.x-minX) * roomWidth;
           newY:= mapLocation.y-roomHeight+(mapLocation.Height - (_rooms[i].Getlocation.y-minY) * roomHeight);

           if _CurrentStatus <> CurrentHeadUpDisplayStatus.MonsterIsChasing then begin

           if ((_rooms[i].GetLocation().X = _LocationCurrentRoom.GetLocation().X) and (_rooms[i].GetLocation().Y = _LocationCurrentRoom.GetLocation.Y)) then begin
              bitmap.FillRect(newX,newY, newX+roomWidth,newY+roomHeight,BGRA(0,0,200,255),
                TDrawMode.dmSet);
           end
           else if((_rooms[i].GetLocation().X = SecureRoomLocation.X) and (_rooms[i].GetLocation().Y = SecureRoomLocation.Y)) then begin
              bitmap.FillRect(newX,newY,newX+roomWidth,newY+roomHeight,BGRA(0,200,0,255),
                TDrawMode.dmSet);
           end
           else begin
              bitmap.FillRect(newX,newY,newX+roomWidth,newY+roomHeight,BGRA(100,0,0,255),
                TDrawMode.dmSet);
           end;

            bitmap.Rectangle(newX,newY,newX+roomWidth,newY+roomHeight,BGRA(125,125,125,255),
                TDrawMode.dmSet);
     end;

     end;

  end;




end;

procedure THeadUpDisplay.InitializeRooms(rooms : TRoomArray);
begin
   _rooms:= rooms;
   setlength(_visitedRooms, length(_rooms));


  end;

procedure THeadUpDisplay.CurrentRoomChanged(currentRoom : IRoom);
var
  i: integer;
begin
     _LocationCurrentRoom:= currentRoom;

     for i:=0 to length(_rooms)-1 do begin
              if (_rooms[i] = currentRoom) then
                 _visitedRooms[i]:= true;

     end;
end;

procedure THeadUpDisplay.ItemPickedUp(item : TObjective);
begin

end;


end.

