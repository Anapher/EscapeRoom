unit GameComposition;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, BGRABitmap, LevelDesign, Controls, Storyboard, Math,
  LevelUtils, BGRABitmapTypes, BGRAGradients, LCLType, DateUtils,
  HeadUpDisplay, GameEffectUtils, SpecialExits, LockPickComposition;

const
  CharacterMoveOutTime = 500;
  CharacterMoveInTime = 500;
  TimeToEscapeFromMonster = 1000;

type
  {$PACKENUM 1}
  CharacterMode = (Normal, RunningToDoor, RunningFromDoor, Scared, RunAway);

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
        _currentCharacterProcessStartTime, _monsterRunningWithoutActions : TDateTime;
        _targetedRoom : IRoom;
        _targetedLocation : Direction;
        _currentMouseX, _currentMouseY : integer;
        _targetRoomContainsMonster, _isInEscapingMode : boolean;
        _hud : THeadUpDisplay;
        _currentRoomWithMonster : TPoint;
        _isRunningAway : boolean;
        _roomImageLocation : TRectangle;
        _defaultRoomSize : TSize;
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
        procedure RedrawWall(wallDirection : Direction; mapLocation : TRectangle; roomBitmap, bitmap : TBGRACustomBitmap);
        procedure SetTargetRoom(newRoom : IRoom; roomDirection : Direction);
        function GetDoorLocation(location : Direction; roomBitmapLocation : TRectangle) : TPoint;
        procedure AttemptToWalk(targetDirection : Direction);

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

type
  {$PACKENUM 1}
  MonsterChasingStage = (DisplayWarning, Running, Escaped);

type
  TMonsterChasingInfo = class
     private
         var _currentStage : MonsterChasingStage;
             _startTime : Int64;
     public
        constructor Create(startTime : Int64);
        property CurrentStage: MonsterChasingStage read _currentStage;
  end;

implementation

constructor TGameComposition.Create();
begin
    _requestedSwitchInfo := nil;
    _hud:= THeadUpDisplay.create;
end;

procedure TGameComposition.Initialize(parameter : TObject);
var compositionInfo : TGameCompositionInfo;
    startRoom : TPoint;
    lockPickCompositionInfo : TGameCompositionLockPickInfo;
    lockPickExit : TLockPickExit;
    specialExit : ISpecialExit;
begin
    if(parameter.ClassType = TGameCompositionLockPickInfo) then begin
       lockPickCompositionInfo := parameter as TGameCompositionLockPickInfo;
       if(lockPickCompositionInfo.Succeeded) then begin
          for specialExit in _currentRoom.GetExtendedExits() do begin
             if(Supports(specialExit, TLockPickExit, lockPickExit) and (not lockPickExit.GetExitPassed())) then begin
                lockPickExit.SetExitPassed();
                break;
             end;
          end;

          AttemptToWalk(lockPickCompositionInfo.DoorDirection);
       end;
       exit;
    end;

    compositionInfo := parameter as TGameCompositionInfo;
    _currentLevel := compositionInfo.Level;
    _character := compositionInfo.Character;

    _rooms := _currentLevel.GetRooms();
    _secureArea := _currentLevel.GetSecureArea();

    startRoom := _currentLevel.GetStartLocation();
    _currentX := startRoom.X;
    _currentY := startRoom.Y;

    _lastCharacterUpdate := Now;
    _currentCharacterState := CharacterState.DefaultSouth;
    _currentCharacterMode := CharacterMode.Normal;
    _isRunningAway := false;

    _currentRoom := GetRoomByCoordinates(_currentX, _currentY);
    _hud.InitializeRooms(_rooms);
    _hud.CurrentRoomChanged(_currentRoom);
    _hud.CurrentStatus := CurrentHeadUpDisplayStatus.Normal;
    _hud.SecureRoomLocation := _currentLevel.GetSecureArea();
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
   _hud.CurrentRoomChanged(room);
   room.EnterRoom();
end;

function TGameComposition.RequireSwitch() : TSwitchInfo;
begin
    result := _requestedSwitchInfo;
    _requestedSwitchInfo := nil;
end;

function TGameComposition.GetCompositionType() : CompositionType;
begin
    result := CompositionType.Game;
end;

procedure TGameComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
var customDrawingRoom : ICustomDrawingRoom;
    characterImage : TBGRABitmap;
    deltaCharacterMovement, deltaMonsterEscapingTime, shortestSide : integer;
    doorLocation, centeredLocation, characterLocation : TPoint;
    roomBitmapLocation : TRectangle;
    characterSize : TSize;
    objectiveRoom : IObjectiveRoom;
    freeRoomImage : boolean;
    roomImage : TBGRACustomBitmap;
    monsterRoom : IMonsterRoom;
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
            _hud.CurrentRoomChanged(_currentRoom);
         end
         else begin
            doorLocation := GetDoorLocation(_targetedLocation, roomBitmapLocation);
            characterLocation := ComputeCharacterPositionLinear(centeredLocation, doorLocation,
                                                                deltaCharacterMovement, CharacterMoveOutTime);
         end;
    end;

    //NO ELSE IF!!!!
    if(_currentCharacterMode = CharacterMode.RunningFromDoor) then begin
         deltaCharacterMovement := MilliSecondsBetween(_currentCharacterProcessStartTime, Now);
         if((deltaCharacterMovement > CharacterMoveOutTime + CharacterMoveInTime) or (_targetRoomContainsMonster and (deltaCharacterMovement > CharacterMoveOutTime + round(CharacterMoveInTime / 2)))) then begin
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

              if(_targetRoomContainsMonster) then begin
                   _currentCharacterMode := CharacterMode.Scared;
                   _isInEscapingMode := true;
              end
              else begin
                   _currentCharacterMode := CharacterMode.Normal;
                   if(_isRunningAway) then
                      _monsterRunningWithoutActions := Now;
              end;
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
           doorLocation := GetDoorLocation(GetOppositeDirection(_targetedLocation), roomBitmapLocation);
           characterLocation := ComputeCharacterPositionLinear(doorLocation, centeredLocation,
                                                               deltaCharacterMovement - CharacterMoveOutTime, CharacterMoveInTime);
         end;
    end;

    //First, we check if the room is a monster room
    if(Supports(_currentRoom, IMonsterRoom, monsterRoom)) then begin
       if(monsterRoom.ContainsMonster()) then
          roomImage := monsterRoom.DrawWithMonster()
       else
          roomImage := monsterRoom.Draw();
    end
    else if(Supports(_currentRoom, ICustomDrawingRoom, customDrawingRoom)) then //then we check if it wants to draw itself
       roomImage := customDrawingRoom.Draw() as TBGRACustomBitmap
    else
       roomImage := _currentLevel.DrawDefaultRoom(_currentRoom) as TBGRACustomBitmap; //if no, the level should draw it

    if (Supports(_currentRoom, IObjectiveRoom, objectiveRoom)) then begin
        roomImage := roomImage.Duplicate(); //we must duplicate the image because DrawObjectives draws on it and the room always returns the same bitmap
        freeRoomImage := true;
        DrawObjectives(objectiveRoom, roomImage, roomBitmapLocation);
        _roomImageLocation := roomBitmapLocation;
        _defaultRoomSize := TSize.Create(roomImage.Width, roomImage.Height);
    end;

    bitmap.StretchPutImage(RectWithSize(roomBitmapLocation.X,
                                     roomBitmapLocation.Y, roomBitmapLocation.Width, roomBitmapLocation.Height), roomImage, TDrawMode.dmDrawWithTransparency);

    if((_currentCharacterMode = CharacterMode.Scared) or (_currentCharacterMode = CharacterMode.RunAway)) then begin
         deltaCharacterMovement := MilliSecondsBetween(_currentCharacterProcessStartTime, Now);
         if(deltaCharacterMovement > (round(CharacterMoveInTime / 2) + CharacterMoveOutTime)) then begin
              if((_currentCharacterMode = CharacterMode.Scared) and (deltaCharacterMovement > CharacterMoveInTime + CharacterMoveOutTime + 500)) then begin //we give some time to run
                  _hud.CurrentStatus := CurrentHeadUpDisplayStatus.MonsterIsChasing;
                  _hud.MonsterTimeLeft := TimeToEscapeFromMonster;
                  _currentRoomWithMonster := _currentRoom.GetLocation();
                  _isRunningAway := true;
                  _currentCharacterMode := CharacterMode.RunAway;
                  _monsterRunningWithoutActions := Now;
              end
              else if (_currentCharacterMode = CharacterMode.Scared) then
                  DrawCenteredText('RENN ZUM STARTPUNKT !!!', bitmap, BGRA(255,255,255, 170 - round(deltaCharacterMovement / ((CharacterMoveInTime + CharacterMoveOutTime + 500)) * 170)));
              deltaCharacterMovement := round(CharacterMoveInTime / 2) + CharacterMoveOutTime; //we stop at half
         end;
         characterLocation := ComputeCharacterPositionLinear(GetDoorLocation(GetOppositeDirection(_targetedLocation), roomBitmapLocation), centeredLocation, deltaCharacterMovement - CharacterMoveOutTime, CharacterMoveInTime);
    end;

    if(_isRunningAway) then begin
        if((_currentRoom.GetLocation().X = _currentLevel.GetSecureArea().X) and (_currentRoom.GetLocation().Y = _currentLevel.GetSecureArea().Y)) then begin
           _isRunningAway := false;
           _hud.CurrentStatus := CurrentHeadUpDisplayStatus.Normal;
        end;
        deltaMonsterEscapingTime := MilliSecondsBetween(_monsterRunningWithoutActions, Now);
        _hud.MonsterTimeLeft := deltaMonsterEscapingTime;
        if(((_currentCharacterMode = CharacterMode.Normal) or (_currentCharacterMode = CharacterMode.RunAway)) and (deltaMonsterEscapingTime > TimeToEscapeFromMonster)) then begin
           _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.Dead, nil);
        end;
    end;

    if(_currentCharacterMode = CharacterMode.Normal) then begin
         //we just draw the character centered
         characterLocation := centeredLocation;
    end;

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
    if(_currentCharacterMode = CharacterMode.RunningToDoor) then
       RedrawWall(_targetedLocation, roomBitmapLocation, roomImage, bitmap);

    if(_currentCharacterMode = CharacterMode.RunningFromDoor) then
       RedrawWall(GetOppositeDirection(_targetedLocation), roomBitmapLocation, roomImage, bitmap);

    _hud.Render(bitmap, deltaTime);

    if(freeRoomImage) then
       roomImage.Free();

    if(deltaTime < 1000) then
       bitmap.Rectangle(0, 0, bitmap.Width, bitmap.Height, BGRA(0, 0, 0,
       round(255 - (deltaTime / 1000 * 255))), BGRA(0, 0, 0,
       round(255 - (deltaTime / 1000 * 255))), dmDrawWithTransparency);
end;

procedure TGameComposition.RedrawWall(wallDirection : Direction; mapLocation : TRectangle; roomBitmap, bitmap : TBGRACustomBitmap);
var relativeLocation : TRectangle;
    wallLength, wallWidth : integer;
    factor : single;
    wallImage : TBGRACustomBitmap;
begin
    factor := mapLocation.Width / roomBitmap.Width;
    wallLength := 300;
    wallWidth := 110;

    case wallDirection of
         Direction.Top:
           relativeLocation := TRectangle.Create(round((roomBitmap.Width - wallLength) / 2), 0, wallLength, wallWidth);
         Direction.Bottom:
           relativeLocation := TRectangle.Create(round((roomBitmap.Width - wallLength) / 2), roomBitmap.Height - wallWidth, wallLength, wallWidth);
         Direction.Right:
           relativeLocation := TRectangle.Create(roomBitmap.Width - wallWidth, round((roomBitmap.Height - wallLength) / 2), wallWidth, wallLength);
         Direction.Left:
           relativeLocation := TRectangle.Create(0, round((roomBitmap.Height - wallLength) / 2), wallWidth, wallLength);
    end;

    wallImage := roomBitmap.GetPart(RectWithSize(relativeLocation.X, relativeLocation.Y, relativeLocation.Width, relativeLocation.Height));

    bitmap.StretchPutImage(RectWithSize(round(mapLocation.X + relativeLocation.X * factor), round(mapLocation.Y + relativeLocation.Y * factor),
                           round(relativeLocation.Width * factor), round(relativeLocation.Height * factor)), wallImage, TDrawMode.dmDrawWithTransparency);
    wallImage.Free();
    //bitmap.PutImagePart(round(mapLocation.X + relativeLocation.X * factor), round(mapLocation.Y + relativeLocation.Y * factor),
    //                    roomBitmap, RectWithSize(relativeLocation.X, relativeLocation.Y, relativeLocation.Width, relativeLocation.Height), TDrawMode.dmSet);
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

function TGameComposition.GetDoorLocation(location : Direction; roomBitmapLocation : TRectangle) : TPoint;
begin
    case location of
      Direction.Right:
         exit(TPoint.Create(roomBitmapLocation.X + roomBitmapLocation.Width, round(roomBitmapLocation.Y + roomBitmapLocation.Height / 2)));
      Direction.Left:
         exit(TPoint.Create(roomBitmapLocation.X, round(roomBitmapLocation.Y + roomBitmapLocation.Height / 2)));
      Direction.Top:
         exit(TPoint.Create(round(roomBitmapLocation.X + roomBitmapLocation.Width / 2), roomBitmapLocation.Y));
      Direction.Bottom:
         exit(TPoint.Create(round(roomBitmapLocation.X + roomBitmapLocation.Width / 2), roomBitmapLocation.Y + roomBitmapLocation.Height));
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
begin
    //if the level wants the control locked or the character is currently moving, we deny to handle this key
    if(_currentLevel.GetIsControlLocked() or ((_currentCharacterMode <> CharacterMode.Normal) and (_currentCharacterMode <> CharacterMode.RunAway))) then
       exit;

    //move character right
    if((Key = VK_Right) or (Key = VK_D)) then begin
         AttemptToWalk(Direction.Right);
         exit;
    end;

    //move left
    if((Key = VK_Left) or (Key = VK_A)) then begin
       AttemptToWalk(Direction.Left);
       exit;
    end;

    //move up
    if((Key = VK_Up) or (Key = VK_S)) then begin
       AttemptToWalk(Direction.Top);
       exit;
    end;

    //move down
    if((Key = VK_Down) or (Key = VK_W)) then begin
       AttemptToWalk(Direction.Bottom);
       exit;
    end;
end;

procedure TGameComposition.AttemptToWalk(targetDirection : Direction);
var newRoom : IRoom;
    currentRoomLocation : TPoint;
    specialExits : TSpecialExitArray;
    specialExit : ISpecialExit;
    lockedExit : TLockedExit;
    lockPickExit : TLockPickExit;
begin
   specialExits := _currentRoom.GetExtendedExits();
   if (specialExits <> nil) then
      for specialExit in specialExits do begin
         if((specialExit <> nil) and (specialExit.GetExitPosition() = targetDirection)) then begin
            if((specialExit as TObject).ClassType = TNoExit) then
               exit;
            if((specialExit as TObject).ClassType = TLevelCompletedExit) then begin
               _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.LevelCompleted, nil);
               exit;
            end;
            if(Supports(specialExit, TLockedExit, lockedExit) and (not lockedExit.GetExitPassed())) then begin
               if(not _hud.GetInventoryItemWithId(lockedExit.ObjectiveId)) then
                  exit;
            end;
            if(Supports(specialExit, TLockPickExit, lockPickExit) and (not lockPickExit.GetExitPassed())) then begin
               _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.LockPick, TLockPickInfo.Create(lockPickExit.Tries, lockPickExit.Bolts, lockPickExit.GetExitPosition()));
               exit;
            end;
         end;
      end;

   currentRoomLocation := _currentRoom.GetLocation();
   case targetDirection of
     Direction.Top:
        newRoom := GetRoomByCoordinates(currentRoomLocation.X, currentRoomLocation.Y + 1);
     Direction.Right:
        newRoom := GetRoomByCoordinates(currentRoomLocation.X + 1, currentRoomLocation.Y);
     Direction.Bottom:
        newRoom := GetRoomByCoordinates(currentRoomLocation.X, currentRoomLocation.Y - 1);
     Direction.Left:
        newRoom := GetRoomByCoordinates(currentRoomLocation.X - 1, currentRoomLocation.Y);
   end;

   //if there isn't a room, we just return
   if(newRoom = nil) then
      exit;

   SetTargetRoom(newRoom, targetDirection);
end;

procedure TGameComposition.SetTargetRoom(newRoom : IRoom; roomDirection : Direction);
var monsterRoom : IMonsterRoom;
begin
   if(_currentCharacterMode = CharacterMode.RunAway) then begin
      if((newRoom.GetLocation().X = _currentRoomWithMonster.X) and (newRoom.GetLocation().Y = _currentRoomWithMonster.Y)) then begin
         _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.Dead, nil);
         exit(); //if the player wants to go back to the room with the monster, he's dead
      end;

      _currentRoomWithMonster := newRoom.GetLocation();
   end;

    _currentCharacterMode := CharacterMode.RunningToDoor;
    _targetedLocation := roomDirection;
    _targetedRoom := newRoom;

    case roomDirection of
         Direction.Top:
           _currentCharacterState := CharacterState.RunningNorth;
         Direction.Bottom:
           _currentCharacterState := CharacterState.RunningSouth;
         Direction.Left:
           _currentCharacterState := CharacterState.RunningWest;
         Direction.Right:
           _currentCharacterState := CharacterState.RunningEast;
    end;

    _targetRoomContainsMonster := Supports(newRoom, IMonsterRoom, monsterRoom) and (monsterRoom.ContainsMonster());

    _currentCharacterProcessStartTime := Now;
    _lastCharacterUpdate := Now;

end;

procedure TGameComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    _currentMouseX := X;
    _currentMouseY := Y;
end;

procedure TGameComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var relativeMouseX, relativeMouseY : Integer;
    room : IObjectiveRoom;
    objective : TObjective;
    xa, ya : integer;
begin
   if(not Supports(_currentRoom, IObjectiveRoom, room)) then
      exit;

   relativeMouseX := round((X - _roomImageLocation.X) * (_defaultRoomSize.Width / _roomImageLocation.Width));
   relativeMouseY := round((Y - _roomImageLocation.Y) * (_defaultRoomSize.Height / _roomImageLocation.Height));

   for objective in room.GetObjectives() do begin
      xa := objective.Location.X;
      ya := objective.Location.Y;
      if((relativeMouseX > objective.Location.X) and (relativeMouseX < objective.Location.X + objective.Location.Width) and
         (relativeMouseY > objective.Location.Y) and (relativeMouseY < objective.Location.Y + objective.Location.Height)) then begin
             room.ObjectiveCollected(objective);
             _hud.ItemPickedUp(objective);
             exit;
      end;
   end;
end;

//TGameCompositionInfo
constructor TGameCompositionInfo.Create(levelVal : ILevel; characterVal : ICharacter);
begin
   _level := levelVal;
   _character := characterVal;
end;

//TMonsterChasingInfo
constructor TMonsterChasingInfo.Create(startTime : Int64);
begin
   _startTime := startTime;
   _currentStage := MonsterChasingStage.DisplayWarning;
end;

end.

