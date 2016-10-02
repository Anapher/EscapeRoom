unit SpecialExits;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelDesign;

type
  TPortalExit = class(ISpecialExit)
    private
      _exitPosition : Direction;
      _targetRoom : TPoint;
    public
      constructor Create(exitPosition : Direction; targetX, targetY : integer); overload;
      function GetExitPosition() : Direction;
      function GetTargetRoom() : TPoint;
  end;

type
  TLockedExit = class(ISpecialExit)
    private
      _exitPosition : Direction;
      _objectiveId : string;
    public
      constructor Create(exitPosition : Direction; objectiveId : string); overload;
      function GetExitPosition() : Direction;
      function GetObjectiveId() : string;
  end;

type
  TLockPickExit = class(ISpecialExit)
    private
      _exitPosition : Direction;
    public
      constructor Create(exitPosition : Direction); overload;
      function GetExitPosition() : Direction;
  end;

implementation

//Portal
constructor TPortalExit.Create(exitPosition : Direction; targetRoom : TPoint);
begin
    _exitPosition := exitPosition;
    _targetRoom := targetRoom;
end;

function TPortalExit.GetExitPosition() : Direction;
begin
    result := _exitPosition;
end;

function TPortalExit.GetTargetRoom() : TPoint;
begin
    result := _targetRoom;
end;

//Lock
constructor TLockedExit.Create(exitPosition : Direction; objectiveId : string);
begin
    _exitPosition := exitPosition;
    _objectiveId := objectiveId;
end;

function TLockedExit.GetExitPosition() : Direction;
begin
    result := _exitPosition;
end;

function TLockedExit.GetObjectiveId() : string;
begin
   result := _objectiveId;
end;

//LockPickExit
constructor TLockPickExit.Create(exitPosition : Direction; objectiveId : string); overload;
begin
   _exitPosition := exitPosition;
end;

function TLockPickExit.GetExitPosition() : Direction;
begin
   result := _exitPosition;
end;

end.

