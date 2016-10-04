unit Objectives;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelUtils, BGRABitmap, BGRABitmapTypes;

type
  TObjective = class
    private
      _location : TRectangle;
      _objectiveId, _normalImagePath, _hoveredImagePath : string;
      _cachedNormalImage, _cachedHoveredImage : TBGRABitmap;
    public
      constructor Create(objectiveIdVal : string; locationVal : TRectangle; normalImagePath, hoveredImagePath : string);
      property Location: TRectangle read _location;
      property ObjectiveId: string read _objectiveId;

      function GetObjectiveImage(mouseOver : boolean) : TBGRABitmap;
  end;

implementation

constructor TObjective.Create(objectiveIdVal : string; locationVal : TRectangle; normalImagePath, hoveredImagePath : string);
begin
    _objectiveId := objectiveIdVal;
    _location := locationVal;
    _normalImagePath := normalImagePath;
    _hoveredImagePath := hoveredImagePath;
end;

function TObjective.GetObjectiveImage(mouseOver : boolean) : TBGRABitmap;
begin
   if(not mouseOver) then begin
      if(_cachedNormalImage = nil) then
         _cachedNormalImage := TBGRABitmap.Create(_normalImagePath);
      exit(_cachedNormalImage);
   end
   else begin
     if(_cachedHoveredImage = nil) then
        _cachedHoveredImage := TBGRABitmap.Create(_hoveredImagePath);

     exit(_cachedHoveredImage);
   end;

end;

end.

