unit HypixelAPI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, fpjson, jsonparser, fphttpclient, openssl, opensslsockets, clipbrd, dateutils, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    GNameST: TLabel;
    GLevelST: TLabel;
    GNameL: TLabel;
    GLevelL: TLabel;
    authorname: TLabel;
    JoinedOnST: TLabel;
    JoinedOnL: TLabel;
    gCreatedOnSL: TLabel;
    gCreatedOnL: TLabel;
    lastLoginL: TLabel;
    lastLoginSL: TLabel;
    message8: TLabel;
    message9: TLabel;
    message7: TLabel;
    message6: TLabel;
    message4: TLabel;
    message1: TLabel;
    pname: TLabel;
    mostRecentGame: TLabel;
    mostRecentGameSL: TLabel;
    networkLevel: TLabel;
    NetworkLevelSL: TLabel;
    PageControl1: TPageControl;
    HAPITabs: TPageControl;
    RankL: TLabel;
    RankSL: TLabel;
    submit: TButton;
    HypixelAPIInfoT: TTabSheet;
    GeneralStatsT: TTabSheet;
    GuildStatsT: TTabSheet;
    Credits: TTabSheet;
    UserIdentityT: TTabSheet;
    usernameEdit: TEdit;
    text2: TLabel;
    procedure dataChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HypixelGTCChange(Sender: TObject);
    procedure submitClick(Sender: TObject);
    procedure usernameEditChange(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  username,MApi,HPlayer,HGuild,networkLvNC,GLevelLarge,msg,doNothing,apikey: string;
  Mresponse,Hresponse,uuid,RankStorage,Gresponse,GuildStorage,mostRecentGameSto,mPRSto,legacyRankSto: AnsiString;
  MresponseArray,HresponseArray,HGuildArray: TJSONArray;
  networkExp,UnixEpochTimeStampFL,UnixEpochRealFL,UnixEpochTimeStampLL,UnixEpochRealLL,UETTGuild,UERGuild: real;
  GEXP,UnixEpochTimeFL,UnixEpochTimeLL,UETGuild: longint;
  f: textfile;
  boxstyle: integer;
  const
    tf = 'apikey.txt';
    reversePQPrefix = -3.5;
    reverseConst = 12.25;
    growthDivides2 = 0.0008;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.dataChange(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.HypixelGTCChange(Sender: TObject);
begin

end;

procedure TForm1.submitClick(Sender: TObject);
begin
  assignfile(f,tf);
  if FileExists(tf) then
  doNothing:=''
  else
  begin
  boxstyle:= MB_OK + MB_ICONEXCLAMATION;
  Application.MessageBox('"apikey.txt" is not found in the executable folder. Recreate the file and launch the program again.','Fatal error', boxstyle);
  halt(2);
  end;
  reset(f);
  readln(f,apikey);
  system.close(f);
  if apikey = '' then
    begin
    apikey:= InputBox('HyAPI',
    'Please type in your API key. You do not need to do this a second time.', '');
    with tstringlist.create do
    try
     add(apikey);
     savetofile(tf);
    finally
      free;
    end;
    end;
  if apikey = '' then
    exit;
  MApi:=Concat('https://api.mojang.com/users/profiles/minecraft/',username,'?');
  with TFPHTTPClient.Create(nil) do
  try
  AddHeader('Content-Type','application/json');
  Mresponse:=Get(MApi);
  finally
    free;
  end;
  try
  MresponseArray:=TJSONArray(GetJSON(Mresponse));
  uuid:=utf8tostring(MresponseArray.FindPath('id').AsString);
    insert('-',uuid,9);
    insert('-',uuid,14);
    insert('-',uuid,19);
    insert('-',uuid,24);
    HPlayer:=Concat('https://api.hypixel.net/player?key=',apikey,'&uuid=',uuid);
    with TFPHttpClient.Create(nil) do
    try
    AddHeader('Content-Type','application/json');
    Hresponse:=Get(HPlayer);
    finally
      free;
    end;
    HresponseArray:=TJSONArray(GetJSON(Hresponse));
    if HresponseArray.FindPath('player.newPackageRank') = nil then
    RankL.Caption:='Default'
    else
    RankStorage:=utf8tostring(HresponseArray.FindPath('player.newPackageRank').AsString);
    if RankStorage = 'NONE' then
    RankL.Caption:='Default'
    else if RankStorage = 'VIP' then
    RankL.Caption:='VIP'
    else if RankStorage = 'VIP_PLUS' then
    RankL.Caption:='VIP+'
    else if RankStorage = 'MVP' then
    RankL.Caption:='MVP'
    else if RankStorage = 'MVP_PLUS' then
    RankL.Caption:='MVP+';
    if HresponseArray.FindPath('player.packageRank') = nil then
    doNothing:=''
    else
    legacyRankSto:=utf8tostring(HresponseArray.FindPath('player.packageRank').AsString);
    if legacyRankSto = 'NONE' then
    doNothing:=''
    else if legacyRankSto = 'VIP' then
    RankL.Caption:='Legacy VIP'
    else if legacyRankSto = 'VIP_PLUS' then
    RankL.Caption:='Legacy VIP+'
    else if legacyRankSto = 'MVP' then
    RankL.Caption:='Legacy MVP'
    else if legacyRankSto = 'MVP_PLUS' then
    RankL.Caption:='Legacy MVP+';
    if HresponseArray.FindPath('player.monthlyPackageRank') = nil then
    doNothing:=''
    else
    mPRSto:=utf8tostring(HresponseArray.FindPath('player.monthlyPackageRank').AsString);
    if HresponseArray.FindPath('player.rank') = nil then
    doNothing:=''
    else
    RankStorage:=utf8tostring(HresponseArray.FindPath('player.rank').AsString);
    if mPRSto = 'SUPERSTAR' then
    RankL.Caption:='MVP++'
    else if mPRSto = 'NONE' then
    doNothing:='';
    if RankStorage = 'YOUTUBER' then
    RankL.Caption:='Youtuber'
    else if RankStorage = 'HELPER' then
    RankL.Caption:='Helper'
    else if RankStorage = 'MODERATOR' then
    RankL.Caption:='Moderator'
    else if RankStorage = 'ADMIN' then
    RankL.Caption:='Admin'
    else if RankStorage ='OWNER' then
    RankL.Caption:='Owner';
    RankStorage:='';
    mPRSto:='';
    legacyRankSto:='';
    if HresponseArray.FindPath('player.mostRecentGameType') =  nil then
    doNothing:=''
    else
    mostRecentGameSto:=utf8tostring(HresponseArray.FindPath('player.mostRecentGameType').AsString);
    if mostRecentGameSto = 'QUAKECRAFT' then
    mostRecentGame.Caption:='Quake'
    else if mostRecentGameSto = 'WALLS' then
    mostRecentGame.Caption:='Walls'
    else if mostRecentGameSto = 'PAINTBALL' then
    mostRecentGame.Caption:='Paintball'
    else if mostRecentGameSto = 'SURVIVAL_GAMES' then
    mostRecentGame.Caption:='Blitz Survival Games'
    else if mostRecentGameSto = 'TNTGAMES' then
    mostRecentGame.Caption:='TNT Games'
    else if mostRecentGameSto = 'VAMPIREZ' then
    mostRecentGame.Caption:='VampireZ'
    else if mostRecentGameSto = 'WALLS3' then
    mostRecentGame.Caption:='Mega Walls'
    else if mostRecentGameSto = 'Arcade' then
    mostRecentGame.Caption:='Arcade'
    else if mostRecentGameSto = 'ARENA' then
    mostRecentGame.Caption:='Arena'
    else if mostRecentGameSto = 'UHC' then
    mostRecentGame.Caption:='UHC Champions'
    else if mostRecentGameSto = 'MCGO' then
    mostRecentGame.Caption:='Cops and Crims'
    else if mostRecentGameSto = 'BATTLEGROUND' then
    mostRecentGame.Caption:='Warlords'
    else if mostRecentGameSto = 'SUPER_SMASH' then
    mostRecentGame.Caption:='Smash Heroes'
    else if mostRecentGameSto = 'GINGERBREAD' then
    mostRecentGame.Caption:='Turbo Cart Racers'
    else if mostRecentGameSto = 'HOUSING' then
    mostRecentGame.Caption:='Housing'
    else if mostRecentGameSto = 'SKYWARS' then
    mostRecentGame.Caption:='SkyWars'
    else if mostRecentGameSto = 'TRUE_COMBAT' then
    mostRecentGame.Caption:='Crazy Walls'
    else if mostRecentGameSto = 'SPEED_UHC' then
    mostRecentGame.Caption:='Speed UHC'
    else if mostRecentGameSto = 'SKYCLASH' then
    mostRecentGame.Caption:='SkyClash'
    else if mostRecentGameSto = 'LEGACY' then
    mostRecentGame.Caption:='Classic Games'
    else if mostRecentGameSto = 'PROTOTYPE' then
    mostRecentGame.Caption:='Prototype'
    else if mostRecentGameSto = 'BEDWARS' then
    mostRecentGame.Caption:='Bed Wars'
    else if mostRecentGameSto = 'MURDER_MYSTERY' then
    mostRecentGame.Caption:='Murder Mystery'
    else if mostRecentGameSto = 'BUILD_BATTLE' then
    mostRecentGame.Caption:='Build Battle'
    else if mostRecentGameSto = 'DUELS' then
    mostRecentGame.Caption:='Duels'
    else if mostRecentGameSto = 'SKYBLOCK' then
    mostRecentGame.Caption:='SkyBlock'
    else if mostRecentGameSto = 'PIT' then
    mostRecentGame.Caption:='Pit';
    mostRecentGameSto:='';
    if HresponseArray.FindPath('player.firstLogin') = nil then
    doNothing:=''
    else
    val(HresponseArray.FindPath('player.firstLogin').AsString,UnixEpochTimeStampFL);
    UnixEpochRealFL:=UnixEpochTimeStampFL/1000;
    UnixEpochTimeFL:=round(UnixEpochRealFL);
    if HresponseArray.FindPath('player.lastLogin') = nil then
    doNothing:=''
    else
    JoinedOnL.Caption:=Concat(DateTimeToStr(UnixToDateTime(UnixEpochTimeFL)),' GMT');
    if HresponseArray.FindPath('player.lastLogin') = nil then
    doNothing:=''
    else
    val(HresponseArray.FindPath('player.lastLogin').AsString,UnixEpochTimeStampLL);
    UnixEpochRealLL:=UnixEpochTimeStampLL/1000;
    UnixEpochTimeLL:=round(UnixEpochRealLL);
    if HresponseArray.FindPath('player.lastLogin') =  nil then
    doNothing:=''
    else
    lastLoginL.Caption:=Concat(DateTimeToStr(UnixToDateTime(UnixEpochTimeLL)),' GMT');
    val(HresponseArray.FindPath('player.networkExp').AsString,networkExp);
    Str((sqrt(reverseConst+(growthDivides2*networkExp))+reversePQPrefix+1):4:2, networkLvNC);
    networkLevel.Caption:=networkLvNC;
    HGuild:=Concat('https://api.hypixel.net/guild?key=',apikey,'&player=',uuid);
    with TFPHttpClient.Create(nil) do
    try
     AddHeader('Content-Type','application/json');
     Gresponse:=Get(HGuild);
    finally
      free;
    end;
      HGuildArray:=TJSONArray(GetJSON(Gresponse));
      if HGuildArray.FindPath('guild.name') = nil then
      GNameL.Caption:=''
      else
      GNameL.Caption:=utf8tostring(HGuildArray.FindPath('guild.name').AsString);
      if HGuildArray.FindPath('guild.exp') = nil then
      GLevelL.Caption:=''
      else
      begin
      val(HGuildArray.FindPath('guild.exp').AsString,GEXP);
      if GEXP < 100000 then
      GLevelL.Caption:='0';
      if GEXP < 250000 then
      GLevelL.Caption:='1';
      if GEXP < 500000 then
      GLevelL.Caption:='2';
      if GEXP < 1000000 then
      GLevelL.Caption:='3';
      if GEXP < 1750000 then
      GLevelL.Caption:='4';
      if GEXP < 2750000 then
      GLevelL.Caption:='5';
      if GEXP < 4000000 then
      GLevelL.Caption:='6';
      if GEXP < 5500000 then
      GLevelL.Caption:='7';
      if GEXP < 7500000 then
      GLevelL.Caption:='8';
      if GEXP >=7500000 then
        if GEXP < 15000000 then
        Str((((GEXP-7500000)/2500000)+9):4:0, GLevelLarge)
        else
        Str((((GEXP-15000000)/3000000)+9):4:0, GLevelLarge);
      if GEXP >=7500000 then
        if GEXP < 15000000 then
        GLevelL.Caption:=GLevelLarge
        else
        GLevelL.Caption:=GLevelLarge;
      GEXP:=0;
      end;
      if HGuildArray.FindPath('guild.created') = nil then
      gCreatedOnL.Caption:=''
      else
      begin
      val(HGuildArray.FindPath('guild.created').AsString,UETTGuild);
    UERGuild:=UETTGuild/1000;
    UETGuild:=round(UERGuild);
    gCreatedOnL.Caption:=Concat(DateTimeToStr(UnixToDateTime(UETGuild)),' GMT');
      end;
  except
      on E:Exception do showmessage('Got invalid data');
  end;
end;


procedure TForm1.usernameEditChange(Sender: TObject);
begin
  username:=usernameEdit.Text;
end;

end.

