unit GameComposition;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, BGRABitmap, LevelDesign, Controls, TutorialLevel, Storyboard,
  LevelUtils, BGRABitmapTypes, BGRAGradients, CharacterSoldier, LCLType, DateUtils,
  Math;

const
  CharacterMoveOutTime = 500;
  CharacterMoveInTime = 500;

type
  {$PACKENUM 1}
  CharacterMode = (Normal, RunningToDoor, RunningFromDoor);

type
  TGameComposition = class(IComposition)
     private
        _requestedComposition : CompositionType;
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
     public
        constructor Create(); overload;
        function RequireSwitch() : CompositionType;
        function GetCompositionType() : CompositionType;
        procedure InitializeLevel(level : ILevel);
        function GetRoomByCoordinates(x, y : integer) : IRoom;
        procedure EnterRoom(room : IRoom);
        function ComputeCharacterPositionLinear(originPoint, targetPoint : TPoint; currentProgress, maximumProgress : integer) : TPoint;

        procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);

        procedure KeyDown(var Key: Word; Shift: TShiftState);
        procedure MouseMove(Shift: TShiftState; X, Y: Integer);
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

implementation

constructor TGameComposition.Create();
begin
    _requestedComposition := CompositionType.None;
    _currentLevel := TTutorialLevel.Create();
    _character := TCharacterSoldier.Create();
    _lastCharacterUpdate := Now;
    _currentCharacterState := CharacterState.DefaultSouth;
    _currentCharacterMode := CharacterMode.Normal;

    InitializeLevel(_currentLevel);
end;

procedure TGameComposition.InitializeLevel(level : ILevel);
var startRoom : TPoint;
begin
    _rooms := level.GetRooms();
    _secureArea := level.GetSecureArea();

    startRoom := level.GetStartLocation();
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

function TGameComposition.RequireSwitch() : CompositionType;
begin
    exit(_requestedComposition);
end;

function TGameComposition.GetCompositionType() : CompositionType;
begin
    result := CompositionType.Game;
end;

procedure TGameComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
var customDrawingRoom : ICustomDrawingRoom;
    characterImage : TBGRABitmap;
    deltaCharacterMovement, distanceX, distanceY, shortestSide : integer;
    doorLocation, centeredLocation, characterLocation : TPoint;
    roomBitmapLocation : TRectangle;
begin
    if(bitmap.Width > bitmap.Height) then
       shortestSide := bitmap.Height
    else
       shortestSide := bitmap.Width;

    roomBitmapLocation := TRectangle.Create(round((bitmap.Width - shortestSide) / 2),
                                       round((bitmap.Height - shortestSide) / 2),
                                       shortestSide, shortestSide);

    centeredLocation := TPoint.Create(round((roomBitmapLocation.X + roomBitmapLocation.Width) / 2),
                                      round((roomBitmapLocation.Y + roomBitmapLocation.Height) / 2));

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

         end;
    end;

    if(_currentCharacterMode = CharacterMode.Normal) then begin
         //we just draw the character centered
         characterLocation := centeredLocation;
    end;

    //First, we check if the room wants to draw itself
    if(Supports(_currentRoom, ICustomDrawingRoom, customDrawingRoom)) then //if yes, then we let it
       customDrawingRoom.Draw(bitmap, RectWithSize(roomBitmapLocation.X,
                              roomBitmapLocation.Y, roomBitmapLocation.Width, roomBitmapLocation.Height))
    else
       _currentLevel.DrawDefaultRoom(_currentRoom, bitmap, RectWithSize(roomBitmapLocation.X,
                                     roomBitmapLocation.Y, roomBitmapLocation.Width, roomBitmapLocation.Height)); //if no, the level should draw it

    //we draw the character
    characterImage := _character.Render(_currentCharacterState, MilliSecondsBetween(_lastCharacterUpdate, Now));



    bitmap.PutImage(characterLocation.X, characterLocation.Y, characterImage, TDrawMode.dmDrawWithTransparency, 255);
    _currentLevel.AfterProcessing(_currentRoom, bitmap, deltaTime);

    if(deltaTime < 1000) then
       bitmap.Rectangle(0, 0, bitmap.Width, bitmap.Height, BGRA(0, 0, 0,
       round(255 - (deltaTime / 1000 * 255))), BGRA(0, 0, 0,
       round(255 - (deltaTime / 1000 * 255))), dmDrawWithTransparency);
end;

function TGameComposition.ComputeCharacterPositionLinear(originPoint, targetPoint : TPoint; currentProgress, maximumProgress : integer) : TPoint;
var currentX, currentY : integer;
begin
//   lineLength := round(sqrt(power((targetPoint.X - originPoint.X), 2) + power((targetPoint.Y - originPoint.Y), 2)));
   currentX := round((targetPoint.X - originPoint.X) * (currentProgress / maximumProgress));
   currentY := round((targetPoint.Y - originPoint.Y) * (currentProgress / maximumProgress));

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
end;

procedure TGameComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TGameComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

end.

