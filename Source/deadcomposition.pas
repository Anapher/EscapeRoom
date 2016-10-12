unit DeadComposition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelDesign,
  Controls, GameEffectUtils, Storyboard, LCLType;

type
  TDeadComposition = class(IComposition)
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

constructor TDeadComposition.Create();
begin
    _requestedSwitchInfo := nil;
end;

procedure TDeadComposition.Initialize(parameter : TObject);
begin

end;

function TDeadComposition.RequireSwitch() : TSwitchInfo;
begin
    result := _requestedSwitchInfo;
    _requestedSwitchInfo := nil;
end;

function TDeadComposition.GetCompositionType() : CompositionType;
begin
    exit(CompositionType.Dead);
end;

procedure TDeadComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
begin
    bitmap.FontAntialias := true;
    bitmap.FontHeight := Round(bitmap.Height / 5);
    DrawCenteredText('Dead', bitmap, BGRA(231, 76, 60, 170));

    if(deltaTime > 5000) then
       _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.Menu, nil);
end;

procedure TDeadComposition.KeyDown(var Key: Word; Shift: TShiftState);
begin
   if((Key = VK_Space) or (Key = VK_Return)) then
      _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.Menu, nil);
end;

procedure TDeadComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TDeadComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;
end.

