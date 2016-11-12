unit  HeadUpDisplay;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelUtils, LevelDesign, FGL, GameEffectUtils;

type
  {$PACKENUM 1}
  CurrentHeadUpDisplayStatus = (Normal, MonsterIsChasing);

TObjectiveList = specialize TFPGObjectList<TObjective>;

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
        _inventoryItems : TObjectiveList;
    public
       constructor Create();
       procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
       procedure InitializeRooms(rooms : TRoomArray);
       procedure CurrentRoomChanged(currentRoom : IRoom);
       procedure ItemPickedUp(item : TObjective);
       function GetInventoryItemWithId(id : string) : boolean;

       property CurrentStatus: CurrentHeadUpDisplayStatus read _currentStatus write _currentStatus;
       property MonsterTimeLeft: integer read _monsterTimeLeft write _monsterTimeLeft;
       property SecureRoomLocation: TPoint read _secureRoomLocation write _secureRoomLocation;
  end;

implementation

constructor THeadUpDisplay.Create();
begin
   _inventoryItems := TObjectiveList.Create(true);
end;

procedure THeadUpDisplay.Render(bitmap : TBGRABitmap; deltaTime : Int64);
var
  i, maxX, minX, maxY, minY: integer;
  mapLocation: TRectangle;
  roomWidth,roomHeight: integer;
  numberRoomsX, numberRoomsY: integer;
  sortedRoomsX, sortedRoomsY : TRoomArray;
  newX, newY: integer;
  inventoryPlaceSize, inventoryStartX : integer;
  objectiveToDraw : TObjective;
  textLocation : TRectangle;
begin

if _CurrentStatus <> CurrentHeadUpDisplayStatus.MonsterIsChasing then begin
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

           //Current Room
           if ((_rooms[i].GetLocation().X = _LocationCurrentRoom.GetLocation().X) and (_rooms[i].GetLocation().Y = _LocationCurrentRoom.GetLocation.Y)) then begin
              bitmap.FillRect(newX,newY, newX+roomWidth,newY+roomHeight,BGRA(52, 152, 219,100),
                TDrawMode.dmDrawWithTransparency);
           end
           //Secure Room
           else if((_rooms[i].GetLocation().X = SecureRoomLocation.X) and (_rooms[i].GetLocation().Y = SecureRoomLocation.Y)) then begin
              bitmap.FillRect(newX,newY,newX+roomWidth,newY+roomHeight,BGRA(46, 204, 113,100),
                TDrawMode.dmDrawWithTransparency);
           end
           //Normal Room
           else begin
              bitmap.FillRect(newX,newY,newX+roomWidth,newY+roomHeight,BGRA(149, 165, 166,100),
                TDrawMode.dmDrawWithTransparency);
           end;

            bitmap.Rectangle(newX,newY,newX+roomWidth,newY+roomHeight,BGRA(125,125,125,255),
                TDrawMode.dmSet);
     end;
  end;

  inventoryPlaceSize := round(bitmap.Height / 14);
  inventoryStartX := bitmap.Width - (inventoryPlaceSize * 4 + 3 * 10 + 20);
  bitmap.FontHeight := 10;
  bitmap.TextOut(inventoryStartX, bitmap.Height - 20 - inventoryPlaceSize - 20, 'Inventar', BGRA(255, 255, 255, 200));
  for i := 0 to 3 do begin //draw 4 inventory places
      bitmap.FillRect(inventoryStartX + i * 10 + i * inventoryPlaceSize, bitmap.Height - 20 - inventoryPlaceSize,
                      inventoryStartX + i * 10 + i * inventoryPlaceSize + inventoryPlaceSize, bitmap.Height - 20,
                      BGRA(155, 89, 182, 100), TDrawMode.dmDrawWithTransparency);
      if(_inventoryItems.Count > i) then begin
         objectiveToDraw := _inventoryItems[i];
         bitmap.StretchPutImage(RectWithSize(inventoryStartX + i * 10 + i * inventoryPlaceSize + 4, bitmap.Height - 20 - inventoryPlaceSize + 4,
                                inventoryPlaceSize - 8, inventoryPlaceSize - 8), objectiveToDraw.ItemImage, TDrawMode.dmDrawWithTransparency);
      end;
  end;
 end
else begin
    bitmap.Rectangle(round(bitmap.Width / 3), bitmap.Height - 60, round(bitmap.Width / 3 * 2), bitmap.Height - 40, BGRA(231, 76, 60), TDrawMode.dmSet);
    bitmap.FontHeight := 20;
    textLocation := GetTextCenterPoint('RENN ZUM STARTPUNKT !!!', bitmap);
    bitmap.TextOut(textLocation.X, bitmap.Height - 90, 'RENN ZUM STARTPUNKT !!!', BGRA(255,255,255));
    if(MonsterTimeLeft < 1000) then begin
      bitmap.FillRect(round(bitmap.Width / 3), bitmap.Height - 60, round(bitmap.Width / 3 + (bitmap.Width / 3) * MonsterTimeLeft / 1000), bitmap.Height - 40, BGRA(231, 76, 60, 180), TDrawMode.dmDrawWithTransparency);
    end;

    bitmap.FillRect(0, 0, bitmap.Width, bitmap.Height, BGRA(231, 76, 60, round(10 * (MonsterTimeLeft / 1000))),
                    TDrawMode.dmDrawWithTransparency);
end;
end;
procedure THeadUpDisplay.InitializeRooms(rooms : TRoomArray);
begin
   _rooms:= rooms;
   SetLength(_visitedRooms, 0); //reset
   _LocationCurrentRoom := nil;
   _inventoryItems.Clear();
   Setlength(_visitedRooms, length(_rooms));
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
   _inventoryItems.Add(item);
end;

function THeadUpDisplay.GetInventoryItemWithId(id : string) : boolean;
var objective : TObjective;
begin
   //Check if the item exits in the current inventory, if yes, remove it and return true, else return false
   for objective in _inventoryItems do begin
      if(objective.ObjectiveId = id) then begin
         _inventoryItems.Remove(objective);
         exit(true);
      end;
   end;

   exit(false);
end;
end.

