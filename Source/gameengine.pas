unit GameEngine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, LevelDesign, MenuComposition, GameComposition,
  IntroComposition, Controls, Forms, Graphics, BGRABitmap, BGRABitmapTypes,
  BGRAGradients, DateUtils, DeadComposition, LockPickComposition, LevelCompletedComposition;

const
  FramesPerSecond = 25;

type
  TGameEngine = class
    private
      _compositionCache : array of IComposition;
      _currentComposition : IComposition;
      _renderLoopTimer : TTimer;
      _ownerForm : TForm;
      _isGameStarted : boolean;
      _renderImage : TBGRABitmap;
      _beginTime : TDateTime;

      function GetComposition(composition : CompositionType) : IComposition;
      procedure RenderLoopTimer(sender : TObject);
      procedure FormPaint(Sender: TObject);
    public
      constructor Create(form : TForm); overload;
      procedure StartGame();

      procedure KeyDown(var Key: Word; Shift: TShiftState);
      procedure MouseMove(Shift: TShiftState; X, Y: Integer);
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

implementation

constructor TGameEngine.Create(form : TForm);
begin
     _ownerForm := form;
     _isGameStarted := false;
     form.OnPaint := @FormPaint;

     SetLength(_compositionCache, 3);
     _renderLoopTimer := TTimer.Create(form);
     _renderLoopTimer.Interval := round(1000 / FramesPerSecond);
     _renderLoopTimer.Enabled := false;
     _renderLoopTimer.OnTimer := @RenderLoopTimer;
end;

procedure TGameEngine.FormPaint(Sender: TObject);
begin
     if((not _isGameStarted) or (_renderImage = nil)) then begin
        _ownerForm.Canvas.Brush.Color := clSkyBlue;
        _ownerForm.Canvas.Rectangle(0, 0, _ownerForm.Width, _ownerForm.Height);
        exit;
     end;

     _renderImage.Draw(_ownerForm.Canvas, 0, 0);
end;

procedure TGameEngine.StartGame();
begin
     if(_isGameStarted) then
        raise Exception.Create('Cant start a game which is already started');

     _currentComposition := GetComposition(CompositionType.Intro);
     _beginTime := Now;
     _renderLoopTimer.Enabled := true;
     _isGameStarted := true;
end;

function TGameEngine.GetComposition(composition : CompositionType) : IComposition;
var i, arrayLength : integer;
  newComposition : IComposition;
begin
     arrayLength := Length(_compositionCache);

     for i := 0 to arrayLength - 1 do
       if((_compositionCache[i] <> nil) and (_compositionCache[i].GetCompositionType() = composition)) then begin
          exit(_compositionCache[i]);
       end;

     case composition of
         CompositionType.Intro:
           newComposition := TIntroComposition.Create();
         CompositionType.Menu:
           newComposition := TMenuComposition.Create();
         CompositionType.Game:
           newComposition := TGameComposition.Create();
         CompositionType.Dead:
           newComposition := TDeadComposition.Create();
         CompositionType.LockPick:
           newComposition := TLockPickComposition.Create();
         CompositionType.LevelCompleted:
           newComposition := TLevelCompletedComposition.Create();
     end;

     //search free space
     for i := 0 to arrayLength - 1 do
       if(_compositionCache[i] = nil) then begin
          _compositionCache[i] := newComposition;
          exit(newComposition);
       end;

     //array too small
     SetLength(_compositionCache, arrayLength * 2);
     _compositionCache[arrayLength] := newComposition;
     exit(newComposition);
end;

procedure TGameEngine.RenderLoopTimer(sender : TObject);
var deltaTime : Int64;
    requiredSwitch : TSwitchInfo;
begin
    deltaTime := MilliSecondsBetween(_beginTime, Now);

    if(_renderImage <> nil) then
       _renderImage.Free();

    _renderImage := TBGRABitmap.Create(_ownerForm.ClientWidth, _ownerForm.ClientHeight, BGRABlack);
    _currentComposition.Render(_renderImage, deltaTime);
    _ownerForm.Invalidate();

    requiredSwitch := _currentComposition.RequireSwitch();
    if (requiredSwitch <> nil) then begin
       _currentComposition := GetComposition(requiredSwitch.Composition);
       _currentComposition.Initialize(requiredSwitch.Parameter);
       _beginTime := Now;
    end;
end;

procedure TGameEngine.KeyDown(var Key: Word; Shift: TShiftState);
begin
    if(_currentComposition <> nil) then
       _currentComposition.KeyDown(Key, Shift);
end;

procedure TGameEngine.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    if(_currentComposition <> nil) then
       _currentComposition.MouseMove(Shift, X, Y);
end;

procedure TGameEngine.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if(_currentComposition <> nil) then
       _currentComposition.MouseDown(Button, Shift, X, Y);
end;


end.

