unit IntroComposition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelDesign,
  Controls, GameEffectUtils, Storyboard, LCLType;

type
  TIntroComposition = class(IComposition)
    private
       _requestedSwitchInfo : TSwitchInfo;
       _storyboard : TStoryboard;
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

constructor TIntroComposition.Create();
begin
    _requestedSwitchInfo := nil;
    _storyboard := TStoryboard.Create();

    _storyboard.AddAnimation(TTextFadeAnimation.Create('Escape Room', BGRA(255,255,255, 255), 1000, 500, 1000));
    _storyboard.AddAnimation(TTextFadeAnimation.Create('Erstellt von Charlotte und Vincent', BGRA(255,255,255, 255), 3500, 500, 1000));
end;

procedure TIntroComposition.Initialize(parameter : TObject);
begin

end;

function TIntroComposition.RequireSwitch() : TSwitchInfo;
begin
    exit(_requestedSwitchInfo);
end;

function TIntroComposition.GetCompositionType() : CompositionType;
begin
    exit(CompositionType.Intro);
end;

procedure TIntroComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
begin
    bitmap.FontAntialias := true;
    bitmap.FontHeight := Round(bitmap.Height / 20);
    _storyboard.Render(bitmap, deltaTime);

    if(_storyboard.IsFinished) then
       _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.Menu, nil);
end;

procedure TIntroComposition.KeyDown(var Key: Word; Shift: TShiftState);
begin
   if((Key = VK_Space) or (Key = VK_Return)) then
      _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.Menu, nil);
end;

procedure TIntroComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TIntroComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

end.

