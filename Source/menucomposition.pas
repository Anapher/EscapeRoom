unit MenuComposition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, BGRAGradients, LevelDesign,
  Controls, DrawableUiElements, Types, Forms, LCLType, TutorialLevel, GameComposition,
  CharacterSoldier;

const
  MenuButtonRelWidth = 0.4; //rel = relative
  MenuButtonHeight = 40;
  MenuButtonSpace = 20;

type
  TMenuComposition = class(IComposition)
     private
       _requestedSwitchInfo : TSwitchInfo;
       _buttons : array of TDrawableButton;
     public
       constructor Create(); overload;
       function RequireSwitch() : TSwitchInfo;
       function GetCompositionType() : CompositionType;
       procedure Render(bitmap : TBGRABitmap; deltaTime : Int64);
       procedure Initialize(parameter : TObject);

       procedure KeyDown(var Key: Word; Shift: TShiftState);
       procedure MouseMove(Shift: TShiftState; X, Y: Integer);
       procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
       procedure DrawButton(drawableButton : TDrawableButton; bitmap : TBGRABitmap);
       procedure CalculateButtonPositions(width, height : integer);
       procedure DoButtonAction(button : TDrawableButton);
  end;

implementation

constructor TMenuComposition.Create();
begin
    _requestedSwitchInfo := nil;

    SetLength(_buttons, 3);

    _buttons[0] := TDrawableButton.Create('Tutorial starten', 0);
    _buttons[1] := TDrawableButton.Create('Level wählen', 1);
    _buttons[2] := TDrawableButton.Create('Beenden', 2);
end;

procedure TMenuComposition.Initialize(parameter : TObject);
begin

end;

function TMenuComposition.RequireSwitch() : TSwitchInfo;
begin
    result := _requestedSwitchInfo;
    _requestedSwitchInfo := nil;
end;

function TMenuComposition.GetCompositionType() : CompositionType;
begin
    exit(CompositionType.Menu);
end;

procedure TMenuComposition.Render(bitmap : TBGRABitmap; deltaTime : Int64);
var i : integer;
begin
    bitmap.FontAntialias := true;

    CalculateButtonPositions(bitmap.Width, bitmap.Height);
    for i := 0 to Length(_buttons) - 1 do
        DrawButton(_buttons[i], bitmap);

    if(deltaTime < 1000) then
       bitmap.Rectangle(0, 0, bitmap.Width, bitmap.Height, BGRA(0, 0, 0,
       round(255 - (deltaTime / 1000 * 255))), BGRA(0, 0, 0,
       round(255 - (deltaTime / 1000 * 255))), dmDrawWithTransparency);
end;

procedure TMenuComposition.CalculateButtonPositions(width, height : integer);
var i, buttonWidth, buttonHeight, buttonAreaHeight, buttonX, buttonYStart : integer;
begin
    buttonWidth := round(width * MenuButtonRelWidth);
    buttonHeight := MenuButtonHeight;
    buttonX := round((width - buttonWidth) / 2);

    //minus 1 because the space is between the buttons
    buttonAreaHeight := buttonHeight * Length(_buttons) + MenuButtonSpace * (Length(_buttons) - 1);
    buttonYStart := round((height - buttonAreaHeight) / 2);

    for i := 0 to Length(_buttons) - 1 do begin
        _buttons[i].Width := buttonWidth;
        _buttons[i].Height := buttonHeight;
        _buttons[i].X := buttonX;
        _buttons[i].Y := buttonYStart + i * buttonHeight;
        if (i <> 0) then //only add the space if it's not the last element
           _buttons[i].Y := _buttons[i].Y + i * MenuButtonSpace;
    end;
end;

procedure TMenuComposition.DrawButton(drawableButton : TDrawableButton; bitmap : TBGRABitmap);
var borderColor : TBGRAPixel;
textSize : TSize;

begin
    case drawableButton.State of
       ElementState.Normal:
         borderColor := BGRA(148, 148, 148, 255);
       ElementState.Hovered:
         borderColor := BGRA(250, 250, 250, 255);
       ElementState.Selected:
         borderColor := BGRA(212, 212, 212, 212);
    end;

    if((drawableButton.Id = 2) and (drawableButton.State = ElementState.Hovered)) then
       borderColor := BGRA(194, 17, 25, 255);

    bitmap.Rectangle(drawableButton.X, drawableButton.Y, drawableButton.X + drawableButton.Width,
                     drawableButton.Y + drawableButton.Height, borderColor, BGRA(0,0,0,0), dmDrawWithTransparency);

    textSize := bitmap.TextSize(drawableButton.Text);
    bitmap.TextOut((drawableButton.Width - textSize.cx) / 2 + drawableButton.X, (drawableButton.Height - textSize.cy) / 2 + drawableButton.Y, drawableButton.Text, borderColor);
end;

procedure TMenuComposition.KeyDown(var Key: Word; Shift: TShiftState);
var i : integer;
begin
    if(Key = VK_Down) then begin
         for i := 0 to Length(_buttons) - 1 do begin
             if (_buttons[i].State = ElementState.Selected) then begin
                //if a button is already selected
                _buttons[i].State := ElementState.Normal; //unselect
                if(i = Length(_buttons) - 1) then
                     _buttons[0].State := ElementState.Selected //first element
                else
                     _buttons[i + 1].State := ElementState.Selected;
                exit; //we're done
             end;
         end;
         _buttons[0].State := ElementState.Selected; //we select the first element if none was selected yet
         exit;
    end;

    if(Key = VK_Up) then begin
         for i := 0 to Length(_buttons) - 1 do begin
             if (_buttons[i].State = ElementState.Selected) then begin
                //if a button is already selected
                _buttons[i].State := ElementState.Normal; //unselect
                if(i = 0) then
                     _buttons[Length(_buttons) - 1].State := ElementState.Selected //last element
                else
                     _buttons[i - 1].State := ElementState.Selected;
                exit; //we're done
             end;
         end;
         _buttons[Length(_buttons) - 1].State := ElementState.Selected; //we select the last element if none was selected yet
         exit;
    end;

    if((Key = VK_Space) or (Key = VK_Return)) then begin
         for i := 0 to Length(_buttons) - 1 do begin
             if(_buttons[i].State = ElementState.Selected) then begin
                DoButtonAction(_buttons[i]);
                exit;
             end;
         end;
    end;
end;

procedure TMenuComposition.MouseMove(Shift: TShiftState; X, Y: Integer);
var i : integer;
begin
   for i := 0 to Length(_buttons) - 1 do begin
       if ((X > _buttons[i].X) and (X < _buttons[i].X + _buttons[i].Width)
          and (Y > _buttons[i].Y) and (Y < _buttons[i].Y + _buttons[i].Height)) then
             _buttons[i].State := ElementState.Hovered
       else
             if(_buttons[i].State = ElementState.Hovered) then
                _buttons[i].State := ElementState.Normal;
   end;
end;

procedure TMenuComposition.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i : integer;
begin
   for i := 0 to Length(_buttons) - 1 do begin
       if ((X > _buttons[i].X) and (X < _buttons[i].X + _buttons[i].Width)
          and (Y > _buttons[i].Y) and (Y < _buttons[i].Y + _buttons[i].Height)) then begin
              DoButtonAction(_buttons[i]);
              exit;
          end;
   end;
end;

procedure TMenuComposition.DoButtonAction(button : TDrawableButton);
begin
   Case button.Id of
      0: _requestedSwitchInfo := TSwitchInfo.Create(CompositionType.Game, TGameCompositionInfo.Create(TTutorialLevel.Create(), TCharacterSoldier.Create()));
      1: ;
      2: Application.Terminate;
   end;
end;

end.

