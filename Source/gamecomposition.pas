unit GameComposition;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, BGRABitmap, LevelDesign, Controls, Storyboard, Math,
  LevelUtils, BGRABitmapTypes, BGRAGradients, LCLType, DateUtils, Objectives;

const
  CharacterMoveOutTime = 500;
  CharacterMoveInTime = 500;

type
  {$PACKENUM 1}
  CharacterMode = (Normal, RunningToDoor, RunningFromDoor);

type
  TGameComposition = class(IComposition)
     private
        _requestedSwitchInfo : TSwitchInfo;
        _currentLevel : ILevel;
        _rooms : TRoomArray;
        _secureArea : TPoint;
        _currentRoom : IRoom;
        _currentX, _currentY : integer;
        _character : ICharacter;
        _lastCharacterUpdate : TDateTime;
        _currentCharacterState : CharacterState;
        _currentCharacterMode : CharacterMode;
        _currentCharacterProcessStartTime : TDateTime;
        _targetedRoom : IRoom;
        _targetedLocation : Direction;
        _currentMouseX, _currentMouseY : integer;
     public
        constructor Create(); overload;
        function RequireSwitch() : TSwitchInfo;
        function GetCompositionType() : CompositionType;
        procedure Initialize(parameter : TObject);
        function GetRoomByCoordinates(x, y : integer) : IRoom;
        procedure EnterRoom(room : IRoom);
        function ComputeCharacterPositionLinear(originPoint, targetPoint : TPoint; currentProgress, maximumProgress : integer) : TPoint;
        procedure DrawObjectives(room : IObjectiveRoom; bitmap : TBGRACustomBitmap; finalRoomRectangle : TRectangle);
        procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
        function GetOppositeDirection(direction : Direction) : Direction;

        procedure KeyDown(var Key: Word; Shift: TShiftState);
        procedure MouseMove(Shift: TShiftState; X, Y: Integer);
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

type
  TGameCompositionInfo = class
     private
        _level : ILevel;
        _character : ICharacter;
     public
        constructor Create(levelVal : ILevel; characterVal : ICharacter);
        property Level: ILevel read _level;
        property Character: ICharacter read _character;
  end;

implementation

constructor TGameComposition.Create();
begin
    _requestedSwitchInfo := nil;
    _lastCharacterUpdate := Now;
    _currentCharacterState := CharacterState.DefaultSouth;
    _currentCharacterMode := CharacterMode.Normal;
end;

procedure TGameComposition.Initialize(parameter : TObject);
var compositionInfo : TGameCompositionInfo;
    startRoom : TPoint;
begin
    compositionInfo := parameter as TGameCompositionInfo;
    _currentLevel := compositionInfo.Level;
    _character := compositionInfo.Character;

    _rooms := _currentLevel.GetRooms();
    _secureArea := _currentLevel.GetSecureArea();

    startRoom := _currentLevel.GetStartLocation();
    _currentX := startRoom.X;
    _currentY := startRoom.Y;

    _currentRoom := GetRoomByCoordinates(_currentX, _currentY);
end;

function TGameComposition.GetRoomByCoordinates(x, y : integer) : IRoom;
var i : integer;
    roomLocation : TPoint;
begin
    for i := 0 to Length(_rooms) - 1 do begin
      roomLocation := _rooms[i].GetLocation();
      if((roomLocation.X = x) and (roomLocation.Y = y)) then
         exit(_rooms[i]);
    end;

    result := nil;
end;

procedure TGameComposition.EnterRoom(room : IRoom);
begin
   _currentRoom := room;
   room.EnterRoom();
end;

function TGameComposition.RequireSwitch() : TSwitchInfo;
begin
    exit(_requestedSwitchInfo);
end;

function TGameComposition.GetCompositionType() : CompositionType;
begin
    result := CompositionType.Game;
end;

procedure TGameComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
var customDrawingRoom : ICustomDrawingRoom;
    characterImage : TBGRABitmap;
    deltaCharacterMovement, shortestSide : integer;
    doorLocation, centeredLocation, characterLocation : TPoint;
    roomBitmapLocation, redrawArea : TRectangle;
    characterSize : TSize;
    objectiveRoom : IObjectiveRoom;
    freeRoomImage : boolean;
    roomImage : TBGRACustomBitmap;
begin
    freeRoomImage := false;

    if(bitmap.Width > bitmap.Height) then
       shortestSide := bitmap.Height
    else
       shortestSide := bitmap.Width;

    roomBitmapLocation := TRectangle.Create(round((bitmap.Width - shortestSide) / 2),
                                       round((bitmap.Height - shortestSide) / 2),
                                       shortestSide, shortestSide);

    centeredLocation := TPoint.Create(round(roomBitmapLocation.X + roomBitmapLocation.Width / 2),
                                      round(roomBitmapLocation.Y + roomBitmapLocation.Height / 2));

    //First of all, we make the character computing
    if(_currentCharacterMode = CharacterMode.RunningToDoor) then begin
         deltaCharacterMovement := MilliSecondsBetween(_currentCharacterProcessStartTime, Now);
         //if the character is already running about CharacterMoveOutTime to the door,
         //he will run through the door of the other room
         if(deltaCharacterMovement > CharacterMoveOutTime) then begin
            _currentCharacterMode := CharacterMode.RunningFromDoor;
            _currentRoom := _targetedRoom;
            _targetedRoom := nil;
         end
         else begin
            case _targetedLocation of
                 Direction.Right:
                   doorLocation := TPoint.Create(roomBitmapLocation.X + roomBitmapLocation.Width, round((roomBitmapLocation.Y + roomBitmapLocation.Height) / 2));
                 Direction.Left:
                   doorLocation := TPoint.Create(roomBitmapLocation.X, round((roomBitmapLocation.Y + roomBitmapLocation.Height) / 2));
                 Direction.Top:
                   doorLocation := TPoint.Create(round((roomBitmapLocation.X + roomBitmapLocation.Width) / 2), roomBitmapLocation.Y);
                 Direction.Bottom:
                   doorLocation := TPoint.Create(round((roomBitmapLocation.X + roomBitmapLocation.Width) / 2), roomBitmapLocation.Y + roomBitmapLocation.Height);
            end;

            characterLocation := ComputeCharacterPositionLinear(centeredLocation, doorLocation,
                                                                deltaCharacterMovement, CharacterMoveOutTime);
         end;
    end;

    //NO ELSE IF!!!!
    if(_currentCharacterMode = CharacterMode.RunningFromDoor) then begin
         deltaCharacterMovement := MilliSecondsBetween(_currentCharacterProcessStartTime, Now);
         if(deltaCharacterMovement > CharacterMoveOutTime + CharacterMoveInTime) then begin
              case _currentCharacterState of
                   CharacterState.RunningEast:
                     _currentCharacterState := CharacterState.DefaultEast;
                   CharacterState.RunningNorth:
                     _currentCharacterState := CharacterState.DefaultNorth;
                   CharacterState.RunningWest:
                     _currentCharacterState := CharacterState.DefaultWest;
                   CharacterState.RunningSouth:
                     _currentCharacterState := CharacterState.DefaultSouth;
              end;

              _lastCharacterUpdate := Now;
              _currentCharacterMode := CharacterMode.Normal;
         end
         else begin
            case GetOppositeDirection(_targetedLocation) of
                 Direction.Right:
                   doorLocation := TPoint.Create(roomBitmapLocation.X + roomBitmapLocation.Width, round((roomBitmapLocation.Y + roomBitmapLocation.Height) / 2));
                 Direction.Left:
                   doorLocation := TPoint.Create(roomBitmapLocation.X, round((roomBitmapLocation.Y + roomBitmapLocation.Height) / 2));
                 Direction.Top:
                   doorLocation := TPoint.Create(round((roomBitmapLocation.X + roomBitmapLocation.Width) / 2), roomBitmapLocation.Y);
                 Direction.Bottom:
                   doorLocation := TPoint.Create(round((roomBitmapLocation.X + roomBitmapLocation.Width) / 2), roomBitmapLocation.Y + roomBitmapLocation.Height);
            end;
            characterLocation := ComputeCharacterPositionLinear(doorLocation, centeredLocation,
                                                                deltaCharacterMovement - CharacterMoveOutTime, CharacterMoveInTime);
         end;
    end;

    if(_currentCharacterMode = CharacterMode.Normal) then begin
         //we just draw the character centered
         characterLocation := centeredLocation;
    end;

    //First, we check if the room wants to draw itself
    if(Supports(_currentRoom, ICustomDrawingRoom, customDrawingRoom)) then //if yes, then we let it
       roomImage := customDrawingRoom.Draw() as TBGRACustomBitmap
    else
       roomImage := _currentLevel.DrawDefaultRoom(_currentRoom) as TBGRACustomBitmap; //if no, the level should draw it

    if (Supports(_currentRoom, IObjectiveRoom, objectiveRoom)) then begin
        roomImage := roomImage.Duplicate(); //we must duplicate the image because DrawObjectives draws on it and the room always returns the same bitmap
        freeRoomImage := true;
        DrawObjectives(objectiveRoom, roomImage, roomBitmapLocation);
    end;

    bitmap.StretchPutImage(RectWithSize(roomBitmapLocation.X,
                                     roomBitmapLocation.Y, roomBitmapLocation.Width, roomBitmapLocation.Height), roomImage, TDrawMode.dmDrawWithTransparency);

    //we draw the character
    characterImage := _character.Render(_currentCharacterState, MilliSecondsBetween(_lastCharacterUpdate, Now));
    characterSize := _character.GetDesiredSize(roomBitmapLocation.ToSize());
    //the character image should be drawn to the point. because we give PutImage the top/left corner, we have to adjust these values
   // bitmap.PutImage(round(characterLocation.X - (characterImage.Width / 2)), round(characterLocation.Y - (characterImage.Height / 2)),
    //                characterImage, TDrawMode.dmDrawWithTransparency, 255);

    bitmap.StretchPutImage(RectWithSize(round(characterLocation.X - (characterSize.Width / 2)),
                                        round(characterLocation.Y - (characterSize.Height / 2)),
                                        characterSize.Width, characterSize.Height),
                                        characterImage, dmDrawWithTransparency);
    //bitmap.Rectangle(characterLocation.X - 5, characterLocation.Y - 5, characterLocation.X + 5, characterLocation.Y + 5, BGRA(255, 255, 255), TDrawMode.dmSet);

    _currentLevel.AfterProcessing(_currentRoom, bitmap, deltaTime);
    if(_currentCharacterMode <> CharacterMode.Normal) then begin
       // case _targetedLocation of
      //      Right:
      //        redrawArea := TRectangle.Create(roomBitmapLocation.X + roomBitmapLocation.Width - 100);
      //  end;
    end;

    //bitmap.PutImagePart();

    if(freeRoomImage) then
       roomImage.Free();
    if(deltaTime < 1000) then
       bitmap.Rectangle(0, 0, bitmap.Width, bitmap.Height, BGRA(0, 0, 0,
       round(255 - (deltaTime / 1000 * 255))), BGRA(0, 0, 0,
       round(255 - (deltaTime / 1000 * 255))), dmDrawWithTransparency);
end;

function TGameComposition.GetOppositeDirection(direction : Direction) : Direction;
begin
    case direction of
         Bottom:
           exit(Top);
         Top:
           exit(Bottom);
         Right:
           exit(Left);
         Left:
           exit(Right);
    end;
end;

procedure TGameComposition.DrawObjectives(room : IObjectiveRoom; bitmap : TBGRACustomBitmap; finalRoomRectangle : TRectangle);
   var objective : TObjective;
       drawHovered, isElementHovered : boolean;
   var relativeMouseX, relativeMouseY : Integer;
begin
   //we have to calculate the relative cursor position
   relativeMouseX := round((_currentMouseX - finalRoomRectangle.X) * (bitmap.Width / finalRoomRectangle.Width));
   relativeMouseY := round((_currentMouseY - finalRoomRectangle.Y) * (bitmap.Height / finalRoomRectangle.Height));

   isElementHovered := false; //we don't want two hovered objectives
   for objective in room.GetObjectives() do begin
      drawHovered := (relativeMouseX > objective.Location.X) and (relativeMouseX < objective.Location.X + objective.Location.Width) and
                      (relativeMouseY > objective.Location.Y) and (relativeMouseY < objective.Location.Y + objective.Location.Height);
      bitmap.StretchPutImage(RectWithSize(objective.Location.X, objective.Location.Y, objective.Location.Width, objective.Location.Height),
                             objective.GetObjectiveImage((not isElementHovered) and drawHovered), TDrawMode.dmDrawWithTransparency);
      if(drawHovered) then
         isElementHovered := true;
   end;
end;

function TGameComposition.ComputeCharacterPositionLinear(originPoint, targetPoint : TPoint; currentProgress, maximumProgress : integer) : TPoint;
var currentX, currentY : integer;
begin
//   lineLength := round(sqrt(power((targetPoint.X - originPoint.X), 2) + power((targetPoint.Y - originPoint.Y), 2)));
   currentX := round((targetPoint.X - originPoint.X) * (currentProgress / maximumProgress)) + originPoint.X;
   currentY := round((targetPoint.Y - originPoint.Y) * (currentProgress / maximumProgress)) + originPoint.Y;

   exit(TPoint.Create(currentX, currentY));
end;
procedure TGameComposition.KeyDown(var Key: Word; Shift: TShiftState);
var newRoom : IRoom;
    currentRoomLocation : TPoint;
begin
    //if the level wants the control locked or the character is currently moving, we deny to handle this key
    if(_currentLevel.GetIsControlLocked() or (_currentCharacterMode <> CharacterMode.Normal)) then
       exit;

    currentRoomLocation := _currentRoom.GetLocation();
    //move character right
    if((Key = VK_Right) or (Key = VK_D)) then begin
         //we get the room which is left to ours
         newRoom := GetRoomByCoordinates(currentRoomLocation.X + 1, currentRoomLocation.Y);
         //if there isn't a room, we just return
         if(newRoom = nil) then
            exit;

         _currentCharacterState := CharacterState.RunningEast;
         _currentCharacterMode := CharacterMode.RunningToDoor;
         _currentCharacterProcessStartTime := Now;
         _lastCharacterUpdate := Now;
         _targetedLocation := Direction.Right;
         _targetedRoom := newRoom;
         exit;
    end;

    //move left
    if((Key = VK_Left) or (Key = VK_A)) then begin
         //we get the room which is left to ours
         newRoom := GetRoomByCoordinates(currentRoomLocation.X - 1, currentRoomLocation.Y);
         //if there isn't a room, we just return
         if(newRoom = nil) then
            exit;

         _currentCharacterState := CharacterState.RunningWest;
         _currentCharacterMode := CharacterMode.RunningToDoor;
         _currentCharacterProcessStartTime := Now;
         _lastCharacterUpdate := Now;
         _targetedLocation := Direction.Left;
         _targetedRoom := newRoom;
         exit;
    end;
end;

procedure TGameComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    _currentMouseX := X;
    _currentMouseY := Y;
end;

procedure TGameComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

constructor TGameCompositionInfo.Create(levelVal : ILevel; characterVal : ICharacter);
begin
   _level := levelVal;
   _character := characterVal;
end;

end.

