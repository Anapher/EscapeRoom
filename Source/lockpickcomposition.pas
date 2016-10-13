unit LockPickComposition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelDesign, BGRABitmap, BGRABitmapTypes, BGRAGradients, DateUtils, Controls, LevelUtils, GameEffectUtils,
  LCLType;

const
  BoltWidth = 30;
  BoltHeight = 30;

type
  TLockPickComposition = class(IComposition)
    private
       _requestedSwitchInfo : TSwitchInfo;
       _triesLeft : integer;
       _totalBolts, _currentPosition : integer;
       _wallpaper, _arrowLeft, _arrowRight, _lockImage : TBGRABitmap;
       //false = left, true = right
       _boltCorrectState : array of boolean;
       _lastFailed : boolean;
       _failedTime : TDateTime;
    public
       constructor Create();
       function RequireSwitch() : TSwitchInfo;
       function GetCompositionType() : CompositionType;
       procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
       procedure Initialize(parameter : TObject);
       procedure ProcessInput(value : boolean);
       function GetMinimumSize(imageSize : TSize; maxWidth, maxHeight : integer) : TSize;

       procedure KeyDown(var Key: Word; Shift: TShiftState);
       procedure MouseMove(Shift: TShiftState; X, Y: Integer);
       procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

type
  TLockPickInfo = class
     private
        _tries, _bolts : integer;
     public
        constructor Create(triesVal, boltsVal : integer);
        property Tries: integer read _tries write _tries;
        property Bolts: integer read _bolts write _bolts;
  end;

implementation

constructor TLockPickComposition.Create();
begin
   _wallpaper := TBGRABitmap.Create('resources\lockpick\background.jpg');
   _arrowLeft := TBGRABitmap.Create('resources\lockpick\arrowLeft.png');
   _arrowRight := TBGRABitmap.Create('resources\lockpick\arrowRight.png');
   _lockImage := TBGRABitmap.Create('resources\lockpick\lock.png');
end;

function TLockPickComposition.RequireSwitch() : TSwitchInfo;
begin
    result := _requestedSwitchInfo;
    _requestedSwitchInfo := nil;
end;

function TLockPickComposition.GetCompositionType() : CompositionType;
begin
   exit(CompositionType.LockPick);
end;

function TLockPickComposition.GetMinimumSize(imageSize : TSize; maxWidth, maxHeight : integer) : TSize;
var widthIsHigher : boolean;
    ratio : double;
    newWidth, newHeight : double;
begin
   widthIsHigher := imageSize.Width > imageSize.Height;
   ratio := imageSize.Width / imageSize.Height;

   if(widthIsHigher) then begin
       newWidth := maxHeight * ratio;
       if(newWidth >= maxWidth) then
          newHeight := maxHeight
       else begin
           newWidth := maxWidth;
           newHeight := maxWidth / ratio;
       end;
   end
   else begin
       newHeight := maxWidth / ratio;
       if(newHeight >= maxHeight) then
          newWidth := maxWidth
       else begin
          newWidth := maxHeight * ratio;
          newHeight := maxHeight;
       end;
   end;

   exit(TSize.Create(round(newWidth), round(newHeight)));
end;

procedure TLockPickComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
var imageSize : TSize;
    barWidth, barX, barY : integer;
    i : integer;
    barX1 : integer;
    arrowX, arrowY : integer;
    centerPoint : TPoint;
begin
   //calculate background size to fill it uniformly
   imageSize := GetMinimumSize(TSize.Create(_wallpaper.Width, _wallpaper.Height), bitmap.Width, bitmap.Height);

   //draw background
   bitmap.StretchPutImage(RectWithSize(0, 0, imageSize.Width, imageSize.Height), _wallpaper, TDrawMode.dmSet);

   barWidth := _totalBolts * 10 + _totalBolts * BoltWidth - 10;
   barX := round((bitmap.Width - barWidth) / 2);
   barY := round((bitmap.Height - BoltHeight) / 2);
   arrowY := round((BoltHeight - _arrowLeft.Height) / 2);
   arrowX := round((BoltWidth - _arrowLeft.Width) / 2);

   for i := 0 to _totalBolts - 1 do begin
       barX1 := barX + i * BoltWidth + (10 *  i);

       if((i = _currentPosition) and _lastFailed) then begin
           bitmap.FillEllipseAntialias(barX1, barY, round(BoltWidth / 2), round(BoltHeight / 2), BGRA(231, 76, 60, 240));
           if(not _boltCorrectState[i]) then
              bitmap.PutImage(barX1 - round(BoltWidth / 2) + arrowX + 2, barY + arrowY - round(BoltHeight / 2), _arrowRight, TDrawMode.dmDrawWithTransparency)
           else
              bitmap.PutImage(barX1 - round(BoltWidth / 2) + arrowX - 2, barY + arrowY - round(BoltHeight / 2), _arrowLeft, TDrawMode.dmDrawWithTransparency);
       end
       else if(i >= _currentPosition) then begin
           bitmap.FillEllipseAntialias(barX1, barY, round(BoltWidth / 2) + 1, round(BoltHeight / 2), BGRA(149, 165, 166, 240));
           bitmap.PutImage(barX1 - round(BoltWidth / 2) + arrowX, barY + arrowY - round(BoltHeight / 2), _lockImage, TDrawMode.dmDrawWithTransparency);
       end
       else begin
           bitmap.FillEllipseAntialias(barX1, barY, round(BoltWidth / 2), round(BoltHeight / 2), BGRA(46, 204, 113, 240));
           if(_boltCorrectState[i]) then
              bitmap.PutImage(barX1 - round(BoltWidth / 2) + arrowX + 2, barY + arrowY - round(BoltHeight / 2), _arrowRight, TDrawMode.dmDrawWithTransparency)
           else
              bitmap.PutImage(barX1 - round(BoltWidth / 2) + arrowX - 2, barY + arrowY - round(BoltHeight / 2), _arrowLeft, TDrawMode.dmDrawWithTransparency);
       end;
   end;

   if(_lastFailed and (MilliSecondsBetween(_failedTime, Now) > 1000)) then begin
       _lastFailed := false;
       _currentPosition := 0;
   end;

   //bitmap.FontAntialias := true;
   bitmap.FontHeight := round(bitmap.Height / 15);
   centerPoint := GetTextCenterPoint('Schloss Knacken', bitmap);
   bitmap.TextOut(centerPoint.X, bitmap.Height / 5, 'Schloss Knacken', BGRA(255, 255, 255, 250));
   bitmap.FontHeight := round(bitmap.Height / 30);
   centerPoint := GetTextCenterPoint('Um das Schloss zu knacken, bewegen Sie den Bolzen mit den Pfeiltasten (Links / Rechts).', bitmap);
   bitmap.TextOut(centerPoint.X, bitmap.Height / 5 + bitmap.Height / 15 + 10, 'Um das Schloss zu knacken, bewegen Sie den Bolzen mit den Pfeiltasten (Links / Rechts).', BGRA(255, 255, 255, 250));
   centerPoint := GetTextCenterPoint('Sie haben noch ' + IntToStr(_triesLeft) + ' Versuche.', bitmap);
   bitmap.TextOut(centerPoint.X, bitmap.Height / 5 + bitmap.Height / 15 + 20 + bitmap.FontHeight, 'Sie haben noch ' + IntToStr(_triesLeft) + ' Versuche.', BGRA(255, 255, 255, 250));

   //small fade
   if(deltaTime < 1000) then
      bitmap.Rectangle(0, 0, bitmap.Width, bitmap.Height, BGRA(0, 0, 0,
      round(255 - (deltaTime / 1000 * 255))), BGRA(0, 0, 0,
      round(255 - (deltaTime / 1000 * 255))), dmDrawWithTransparency);
end;

procedure TLockPickComposition.Initialize(parameter : TObject);
var lockPickInfo : TLockPickInfo;
    i : integer;
begin
   lockPickInfo := parameter as TLockPickInfo;
   _triesLeft := lockPickInfo.Tries;
   _totalBolts := lockPickInfo.Bolts;

   SetLength(_boltCorrectState, _totalBolts);
   for i := 0 to _totalBolts - 1 do
       _boltCorrectState[i] := random(2) = 1;

   _lastFailed := false;
end;

procedure TLockPickComposition.KeyDown(var Key: Word; Shift: TShiftState);
begin
   if(_lastFailed) then
      exit;

   //move character right
   if((Key = VK_Right) or (Key = VK_D)) then begin
        ProcessInput(true);
        exit;
   end;

   //move left
   if((Key = VK_Left) or (Key = VK_A)) then begin
      ProcessInput(false);
      exit;
   end;
end;

procedure TLockPickComposition.ProcessInput(value : boolean);
begin
   if(_boltCorrectState[_currentPosition] = value) then begin
      _currentPosition := _currentPosition + 1;
      if(_currentPosition > _totalBolts) then begin
         //Succeeded
      end;
   end
   else begin
       _triesLeft := _triesLeft - 1;
       if(_triesLeft = 0) then begin
         //Failed
       end;
       _failedTime := Now;
       _lastFailed := true;
   end;
end;

procedure TLockPickComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TLockPickComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

constructor TLockPickInfo.Create(triesVal, boltsVal : integer);
begin
   _tries := triesVal;
   _bolts := boltsVal;
end;

end.

