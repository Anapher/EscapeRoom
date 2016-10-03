unit CharacterSoldier;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LevelDesign, BGRABitmap, LevelUtils;

type
  TCharacterImageCacheEntry = class
    Path : string;
    Image : TBGRABitmap;
  end;

type
  TCharacterSoldier = class(ICharacter)
    public
       constructor Create();
       function Render(state : CharacterState; deltaTimeSinceLastStateChange : Int64) : TBGRABitmap;
       function GetThumbnail() : TBGRABitmap;
       function GetDesiredSize(roomSize : TSize) : TSize;
    private
       function GetCachedImage(path : string) : TBGRABitmap;
       var _cachedEntries : array of TCharacterImageCacheEntry;
  end;

implementation

constructor TCharacterSoldier.Create();
begin
   SetLength(_cachedEntries, 10);
end;

function TCharacterSoldier.Render(state : CharacterState; deltaTimeSinceLastStateChange : Int64) : TBGRABitmap;
var characterBitmap : TBGRABitmap;
begin
   case state of
        CharacterState.DefaultSouth:
          exit(GetCachedImage('resources\character\soldier\normal_south.png'));
   end;

   exit(GetCachedImage('resources\character\soldier\normal_south.png'));
end;

function TCharacterSoldier.GetDesiredSize(roomSize : TSize) : TSize;
begin
   exit(TSize.Create(round(roomSize.Height / 800 * 133), round(roomSize.Width / 800 * 133)));
end;

function TCharacterSoldier.GetThumbnail() : TBGRABitmap;
begin
   exit(nil);
end;

function TCharacterSoldier.GetCachedImage(path : string) : TBGRABitmap;
var i : integer;
begin
   for i := 0 to Length(_cachedEntries) - 1 do
       if((_cachedEntries[i] <> nil) and (_cachedEntries[i].Path = path)) then
          exit(_cachedEntries[i].Image);

   for i := 0 to Length(_cachedEntries) - 1 do
       if(_cachedEntries[i] = nil) then begin
          _cachedEntries[i] := TCharacterImageCacheEntry.Create();
          _cachedEntries[i].Path := path;
          _cachedEntries[i].Image := TBGRABitmap.Create(path);
          exit(_cachedEntries[i].Image);
       end;

   i := Length(_cachedEntries);
   SetLength(_cachedEntries, i * 2);
   _cachedEntries[i] := TCharacterImageCacheEntry.Create();
   _cachedEntries[i].Path := path;
   _cachedEntries[i].Image := TBGRABitmap.Create(path);
   exit(_cachedEntries[i].Image);
end;

end.

