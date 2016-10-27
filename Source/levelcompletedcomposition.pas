unit LevelCompletedComposition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelDesign,
  Controls, GameEffectUtils, Storyboard, LCLType;

type
  TLevelCompletedComposition = class(IComposition)
    private
       _requestedSwitchInfo : TSwitchInfo;
    public
       constructor Create(); overload;
       function RequireSwitch() : TSwitchInfo;
       function GetCompositionType() : CompositionType;
       procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
       procedure Initialize(parameter : TObject);

       procedure KeyDown(var Key: Word; Shift: TShiftState);
       procedure MouseMove(Shift: TShiftState; X, Y: Integer);
       procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;
implementation

constructor TLevelCompletedComposition.Create();
begin
    _requestedSwitchInfo := nil;
end;

procedure TLevelCompletedComposition.Initialize(parameter : TObject);
begin

end;

function TLevelCompletedComposition.RequireSwitch() : TSwitchInfo;
begin
    result := _requestedSwitchInfo;
    _requestedSwitchInfo := nil;
end;

function TLevelCompletedComposition.GetCompositionType() : CompositionType;
begin
    exit(CompositionType.LevelCompleted);
end;

procedure TLevelCompletedComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
begin
    bitmap.FontAntialias := true;
    bitmap.FontHeight := Round(bitmap.Height / 10);
    DrawCenteredText('Level erfolgreich abgeschlossen!', bitmap, BGRA(39, 174, 96, 170));

    if(deltaTime > 5000) then
       _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.Menu, nil);
end;

procedure TLevelCompletedComposition.KeyDown(var Key: Word; Shift: TShiftState);
begin
   if((Key = VK_Space) or (Key = VK_Return)) then
      _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.Menu, nil);
end;

procedure TLevelCompletedComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TLevelCompletedComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

end.

