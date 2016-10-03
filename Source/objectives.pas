unit Objectives;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelUtils, BGRABitmap;

type
  TObjective = class
    private
      _location : TRectangle;
      _objectiveId, _folder : string;
    public
      constructor Create(objectiveIdVal : string; locationVal : TRectangle; folder : string);
      property Location: TRectangle read _location;
      property ObjectiveId: string read _objectiveId;

      function GetObjectiveImage(mouseOver : boolean) : TBGRABitmap;
  end;

implementation

constructor TObjective.Create(objectiveIdVal : string; locationVal : TRectangle; folder : string);
begin
    _objectiveId := objectiveIdVal;
    _location := locationVal;
    _folder := folder;
end;

function TObjective.GetObjectiveImage(mouseOver : boolean) : TBGRABitmap;
begin

end;

end.

