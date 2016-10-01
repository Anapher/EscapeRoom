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
    public
      function GetLocation() : TRectangle;
      function GetObjectiveImage(mouseOver : boolean) : TBGRABitmap;
  end;

implementation

function TObjective.GetLocation() : TRectangle;
begin
   result := _location;
end;

end.

