unit Fmx.MediaPlayerStream;

interface

uses
  System.Classes, Fmx.Types
{$IFDEF ANDROID}
    , Fmx.Media.Android
{$ENDIF}
{$IFDEF iOS}
    , Fmx.Media.iOS, Fmx.Media, iOSapi.AVFoundation, iOSapi.Foundation,
  System.Types,
  Posix.Dlfcn,
  Macapi.ObjectiveC, Macapi.ObjCRuntime,
  iOSapi.CocoaTypes, iOSapi.uikit, iOSapi.CoreGraphics
{$ENDIF}
{$IFDEF mswindows}
    , Fmx.Media.Win
{$ENDIF}
    ;
{$IFDEF iOS}

type
  czDamekPlayer = interface(NSObject)
    ['{AAF116B8-58D7-4A28-B755-ADDA11442E09}']
    procedure streamPlay(urlStream: NSString); cdecl;
    procedure play; cdecl;
    procedure stop; cdecl;
    function meta: NSString; cdecl;
    function isPlaying: boolean; cdecl;
    function init:Pointer; cdecl;
  end;

  czDamekPlayerClass = interface(NSObjectClass)
    ['{689B04E2-F080-437F-8F49-26CE0AD2730F}']
  end;

  TczDamekPlayerClass = class(TOCGenericImport<czDamekPlayerClass,
    czDamekPlayer>)
  end;
{$ENDIF}

type
  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidOSX32 or
    pidiOSSimulator or pidiOSDevice or pidAndroid)]
  TMediaPlayerStream = class(TFmxObject)
  private
    FURLStream: String;
{$IFDEF ANDROID}
    FPlayer: TAndroidMedia;
{$ENDIF}
{$IFDEF iOS}
    FPlayer: czDamekPlayer;
{$ENDIF}
{$IFDEF mswindows}
    FPlayer: TWindowsMedia;
{$ENDIF}
    procedure SetURLStream(const Value: String);
    function getMeta: String;
  public
    procedure play;
    procedure stop;
  published
    property urlStream: String read FURLStream write SetURLStream;
    property meta: String read getMeta;
  end;

procedure Register;

implementation

{$IFDEF IOS}

uses
  iOSapi.CoreMedia, Fmx.Forms, Fmx.Platform.iOS;
{$ENDIF}

procedure Register;
begin
  RegisterComponents('Damek', [TMediaPlayerStream]);
end;

{ TMediaPlayerStream }

function TMediaPlayerStream.getMeta: String;
begin
{$IFDEF iOS}
  if Assigned(FPlayer) then
    Result := String(FPlayer.meta.UTF8String)
  else
    Result := '';
{$ELSE}
  Result := 'N/A';
{$ENDIF}
end;

procedure TMediaPlayerStream.play;
begin
  if Assigned(FPlayer) then
    FPlayer.play;
end;

{$IFDEF iOS}
{$O-}
function AudioSessionSetProperty: NSString; cdecl;
  external '/System/Library/Frameworks/AudioToolbox.framework\AudioToolbox' name
  'AudioSessionSetProperty';
function fakeLoader(I: Integer): Integer; cdecl;
  external 'libczDamekPlayer.a' name 'fakeLoader';
{$O+}
{$ENDIF}

procedure TMediaPlayerStream.SetURLStream(const Value: String);
begin
  FURLStream := Value;
  if Assigned(FPlayer) then
  begin
    FPlayer.stop;
  end;
{$IFDEF iOS}
  fakeLoader(1);
  FPlayer := TczDamekPlayerClass.Create;
  FPlayer.init;
  FPlayer.streamPlay(NSStr(Value));
{$ENDIF}
{$IFDEF ANDROID}
  FPlayer := TAndroidMedia.Create(Value);
{$ENDIF}
{$IFDEF mswindows}
  FPlayer := TWindowsMedia.Create(Value);
{$ENDIF}
end;

procedure TMediaPlayerStream.stop;
begin
  if Assigned(FPlayer) then
    FPlayer.stop;
end;

end.
