unit IntroComposition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelDesign,
  Controls, GameEffectUtils, Storyboard, LCLType;

type
  TIntroComposition = class(IComposition)
    private
       _requestedComposition : CompositionType;
       _storyboard : TStoryboard;
    public
       constructor Create(); overload;
       function RequireSwitch() : CompositionType;
       function GetCompositionType() : CompositionType;
       procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);

       procedure KeyDown(var Key: Word; Shift: TShiftState);
       procedure MouseMove(Shift: TShiftState; X, Y: Integer);
       procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

implementation

constructor TIntroComposition.Create();
begin
    _requestedComposition := CompositionType.None;
    _storyboard := TStoryboard.Create();

    _storyboard.AddAnimation(TTextFadeAnimation.Create('Escape Room', BGRA(255,255,255, 255), 1000, 500, 1000));
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Erstellt von Charlotte und Vincent', BGRA(255,255,255, 255), 3500, 500, 1000));
end;

function TIntroComposition.RequireSwitch() : CompositionType;
begin
    result := _requestedComposition;
end;

function TIntroComposition.GetCompositionType() : CompositionType;
begin
    result := CompositionType.Intro;
end;

procedure TIntroComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
begin
    bitmap.FontAntialias := true;
    bitmap.FontHeight := Round(bitmap.Height / 20);
    _storyboard.Render(bitmap, deltaTime);

    if(_storyboard.IsFinished) then
       _requestedComposition := CompositionType.Menu;
end;

procedure TIntroComposition.KeyDown(var Key: Word; Shift: TShiftState);
begin
   if((Key = VK_Space) or (Key = VK_Return)) then
      _requestedComposition := CompositionType.Menu;
end;

procedure TIntroComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TIntroComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

end.

