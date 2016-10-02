unit Objectives;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelUtils, BGRABitmap;

type
  {$PACKENUM 1}
  ObjectiveType = (Key, Note);

type
  TObjective = class
    private
      _location : TRectangle;
      _objectiveId : string;
    public
      constructor Create(objectiveId : string);
      function GetLocation() : TRectangle;
      function GetObjectiveImage(mouseOver : boolean) : TBGRABitmap;
      function GetId() : string;
  end;

implementation

constructor TObjective.Create(objectiveId : string);
begin
    _objectiveId := objectiveId;
end;

function TObjective.GetLocation() : TRectangle;
begin
   result := _location;
end;

function TObjective.GetId() : string;
begin
   result := _objectiveId;
end;

end.

