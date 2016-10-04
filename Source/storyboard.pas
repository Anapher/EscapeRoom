unit Storyboard;

{$mode objfpc}{$H+}
{$interfaces corba}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, BGRAGradients, GameEffectUtils;

type
  IAnimation = interface
      function Render(bitmap : TBGRABitmap; deltaTime : Int64) : boolean;
  end;

type
  TFadeAnimationBase = class abstract(IAnimation)
    public
      constructor Create(startTime, fadeDuration, displayDuration : integer);
      function Render(bitmap : TBGRABitmap; deltaTime : Int64) : boolean;
      procedure RenderInternal(bitmap : TBGRABitmap; relativeTime, fadeDuration,
        displayDuration : Int64); virtual; abstract;
    private
      var _startTime, _fadeDuration, _displayDuration : integer;
  end;

type
  TTextFadeAnimation = class(TFadeAnimationBase)
    public
      constructor Create(text : string; color : TBGRAPixel; startTime, fadeDuration, displayDuration : integer); overload;
      procedure RenderInternal(bitmap : TBGRABitmap; relativeTime, fadeDuration,
        displayDuration : Int64); override;
    private
      _text : string;
      _color : TBGRAPixel;
  end;

type
  TStoryboard = class
    private
      function CheckIsFinished() : boolean;
      var _animations : array of IAnimation;
     _isFinished : boolean;
    public
      constructor Create();
      procedure AddAnimation(animation : IAnimation);
      procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
      procedure Clear();
      property IsFinished: boolean read _isFinished;
  end;


implementation

//TFadeAnimationBase
constructor TFadeAnimationBase.Create(startTime, fadeDuration, displayDuration : integer);
begin
   _startTime := startTime;
   _fadeDuration := fadeDuration;
   _displayDuration := displayDuration;
end;

function TFadeAnimationBase.Render(bitmap : TBGRABitmap; deltaTime : Int64) : boolean;
begin
   if (_startTime > deltaTime) then //we still have to wait
      exit(true);

   RenderInternal(bitmap, deltaTime - _startTime, _fadeDuration, _displayDuration);
   exit(deltaTime < _startTime + _fadeDuration * 2 + _displayDuration);
end;

//TTextFadeAnimation
constructor TTextFadeAnimation.Create(text : string; color : TBGRAPixel; startTime, fadeDuration, displayDuration : integer);
begin
   inherited Create(startTime, fadeDuration, displayDuration);
   _text := text;
   _color := color;
end;

procedure TTextFadeAnimation.RenderInternal(bitmap : TBGRABitmap; relativeTime, fadeDuration,
         displayDuration : Int64);
begin
    if (relativeTime < fadeDuration) then
        FadeText(_text, _color, fadeDuration, relativeTime, true, bitmap)
    else if((relativeTime > fadeDuration) and (relativeTime < fadeDuration + displayDuration)) then
        DrawCenteredText(_text, bitmap, _color)
    else if ((relativeTime > fadeDuration + displayDuration) and (relativeTime < fadeDuration * 2 + displayDuration)) then
        FadeText(_text, _color, fadeDuration, relativeTime - fadeDuration - displayDuration, false, bitmap);
end;

//Storyboard
constructor TStoryboard.Create();
var i : integer;
begin
   SetLength(_animations, 6);
   _isFinished := false;
end;

procedure TStoryboard.AddAnimation(animation : IAnimation);
var i, arrayLength : integer;
begin
   arrayLength := Length(_animations);

   for i := 0 to arrayLength - 1 do
       if (_animations[i] = nil) then begin
         _animations[i] := animation;
         exit;
       end;

   SetLength(_animations, arrayLength * 2);
   _animations[arrayLength] := animation;
   _isFinished := false;
end;

procedure TStoryboard.Render(bitmap : TBGRABitmap; deltaTime : Int64);
var i : integer;
var removedSmthg : boolean;
begin
   removedSmthg := false;

   for i := 0 to Length(_animations) - 1 do
     if(_animations[i] <> nil) then
        if (not _animations[i].Render(bitmap, deltaTime)) then begin
           _animations[i] := nil;
           removedSmthg := true;
        end;

   //only check if something was actually removed
   if(removedSmthg) then
      _isFinished := CheckIsFinished();
end;

function TStoryboard.CheckIsFinished() : boolean;
var i : integer;
begin
    for i := 0 to Length(_animations) - 1 do begin
      if(_animations[i] <> nil) then //if one is not nil, we are not done!
         exit(false);
    end;
end;

procedure TStoryboard.Clear();
var i : integer;
begin
   for i := 0 to Length(_animations) - 1 do
     _animations[i] := nil;

   _isFinished := true;
end;

end.

