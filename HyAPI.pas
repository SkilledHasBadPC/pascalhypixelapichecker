unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, fpjson, jsonparser, fphttpclient, openssl, opensslsockets,
  dateutils, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label10: TLabel;
    guildLV: TLabel;
    guildEXP: TLabel;
    gMaster: TLabel;
    Label11: TLabel;
    gTag: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    joinedOn: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    guildName: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    networkLV: TLabel;
    lastLogin: TLabel;
    mostRecentGame: TLabel;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    tle: TLabeledEdit;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure tleChange(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  username,apikey,guildLVL,networkl: string;
   responses1,responses2,responses3,responses4,responses5,responseapikeyvalid: AnsiString;
   rankstorage: array [1..4] of AnsiString;
   uuid,gMasterUUID,recentgame,gRank,apikeyvalid: AnsiString;
   sbProfileID,cuteName: array [1..5] of AnsiString;
   unixEpochTimeReal: array [1..4] of real;
   networkEXP: real;
   unixEpochTimeInt: array [1..2] of longint;
   arrays: array [1..6] of TJSONArray;
   objects: array [1..2] of TJSONObject;
   enums1,enums2: TJSONEnum;
   f,handler,GEXP: longint;
   fileh: textfile;
const filename = 'apikey.cache';
      reversePQPrefix = -3.5;
      reverseConst = 12.25;
      growthDivides2 = 0.0008;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
   if fileexists(filename) = FALSE then
    begin
     f:=FileCreate(filename);
     FileClose(f);
    end
  else
    begin
     assignfile(fileh,filename);
     reset(fileh);
     readln(fileh,apikey);
     system.close(fileh);
       if apikey = '' then
         begin
          apikey:=inputbox('HyAPI','Please paste in your Hypixel API key. You do not need to do this a second time.','You can get your Hypixel API key by doing /api in any Hypixel lobby.');
          with tstringlist.create do
            try
              add(apikey);
              savetofile(filename);
            finally
              free;
            end;
         end;
    end;
    with tfphttpclient.create(nil) do
      try
     addheader('Content-Type','application/json');
     responseapikeyvalid:=get(concat('https://api.hypixel.net/key?key=',apikey));
     arrays[6]:=TJSONArray(GetJSON(responseapikeyvalid));
     if arrays[6].FindPath('success') = nil then begin end;
     apikeyvalid:=utf8tostring(arrays[6].FindPath('success').AsString);
     if apikeyvalid = 'false' then begin
       showmessage('Your API Key is not valid, please open apikey.cache and replace the invalid API Key.');
       halt;
       end;
      finally
      free;
      end;
    if checkbox1.Checked = TRUE then
      showmessage(concat('API Key checked, result: ',apikeyvalid,'.'));
    //checks apikey, if apikey is not in apikey.cache then it requests user to input apikey
    with tfphttpclient.create(nil) do
      try
        AddHeader('Content-Type','application/json');
        responses1:=get(Concat('https://api.mojang.com/users/profiles/minecraft/',tle.Text,'?'));
      finally
        free;
      end;
    arrays[1]:=TJSONArray(GetJSON(responses1));
    uuid:=utf8tostring(arrays[1].FindPath('id').AsString);
    with tfphttpclient.create(nil) do
      try
        AddHeader('Content-Type','application/json');
        responses2:=get(Concat('https://api.hypixel.net/player?key=',apikey,'&uuid=',uuid));
        responses3:=get(Concat('https://api.hypixel.net/guild?key=',apikey,'&player=',uuid));
        responses4:=get(concat('https://sky.shiiyu.moe/api/v2/profile/',tle.Text));
      finally
        free;
      end;
    if checkbox1.Checked = TRUE then
      showmessage('Successfully got data from Mojang API, Hypixel API and sky.shiiyu.moe API.');
    // scout mojang api, hypixel api and sky.shiiyu.moe apiv2 for data
    arrays[2]:=TJSONArray(GetJSON(responses2));
    if arrays[2].FindPath('player.newPackageRank') = nil then
      Label2.Caption:='Default'
    else begin
     rankstorage[1]:=utf8tostring(arrays[2].FindPath('player.newPackageRank').AsString);
     if (rankstorage[1] = 'VIP') or (rankstorage[1] = 'MVP') then
       Label2.Caption:=rankstorage[1];
     if rankstorage[1] = 'NONE' then
      Label2.Caption:='Default';
     if rankstorage[1] = 'VIP_PLUS' then
      Label2.Caption:='VIP+';
     if rankstorage[1] = 'MVP_PLUS' then
      Label2.Caption:='MVP+';
    end;
    if arrays[2].FindPath('player.packageRank') = nil then begin end
    else begin
     rankstorage[2]:=utf8tostring(arrays[2].FindPath('player.packageRank').AsString);
     if rankstorage[2] = 'NONE' then begin end;
     if (rankstorage[2] = 'VIP') or (rankstorage[2] = 'MVP') then
      Label2.Caption:=Concat('Legacy ',rankstorage[2]);
     if rankstorage[2] = 'VIP_PLUS' then
      Label2.Caption:='Legacy VIP+';
     if rankstorage[2] = 'MVP_PLUS' then
      Label2.Caption:='Legacy MVP+';
    end;
    if arrays[2].FindPath('player.monthlyPackageRank') = nil then begin end
    else begin
     rankstorage[3]:=utf8tostring(arrays[2].FindPath('player.monthlyPackageRank').AsString);
     if rankstorage[3] = 'NONE' then begin end;
     if rankstorage[3] = 'SUPERSTAR' then
      Label2.Caption:='MVP++';
    end;
    if arrays[2].FindPath('player.Rank') = nil then begin end
    else begin
     rankstorage[4]:=utf8tostring(arrays[2].FindPath('player.Rank').AsString);
     if rankstorage[4] = 'NONE' then begin end;
     if rankstorage[4] = 'YOUTUBER' then
      Label2.Caption:='YouTuber';
     if rankstorage[4] = 'HELPER' then
      Label2.Caption:='Helper';
     if rankstorage[4] = 'MODERATOR' then
      Label2.Caption:='Moderator';
     if rankstorage[4] = 'ADMIN' then
      Label2.Caption:='Administrator';
     if rankstorage[4] = 'OWNER' then
      Label2.Caption:='Owner';
    end;
    if checkbox1.Checked = TRUE then
     showmessage(concat('Rank status is: ', rankstorage[1],', Legacy rank package: ',rankstorage[2],', Monthly rank package: ',rankstorage[3],', Elevated rank is: ',rankstorage[4]));
    rankstorage[1]:='';
    rankstorage[2]:='';
    rankstorage[3]:='';
    rankstorage[4]:='';
    // checks rank data, owner rank is broken atm
    if arrays[2].FindPath('player.mostRecentGameType') = nil then
    else begin
     recentgame:=utf8tostring(arrays[2].FindPath('player.mostRecentGameType').asString);
    if recentgame = 'QUAKECRAFT' then
    mostRecentGame.Caption:='Quake';
    if recentgame = 'WALLS' then
    mostRecentGame.Caption:='Walls';
    if recentgame = 'PAINTBALL' then
    mostRecentGame.Caption:='Paintball';
    if recentgame = 'SURVIVAL_GAMES' then
    mostRecentGame.Caption:='Blitz Survival Games';
    if recentgame = 'TNTGAMES' then
    mostRecentGame.Caption:='TNT Games';
    if recentgame = 'VAMPIREZ' then
    mostRecentGame.Caption:='VampireZ';
    if recentgame = 'WALLS3' then
    mostRecentGame.Caption:='Mega Walls';
    if recentgame = 'Arcade' then
    mostRecentGame.Caption:='Arcade';
    if recentgame = 'ARENA' then
    mostRecentGame.Caption:='Arena';
    if recentgame = 'UHC' then
    mostRecentGame.Caption:='UHC Champions';
    if recentgame = 'MCGO' then
    mostRecentGame.Caption:='Cops and Crims';
    if recentgame = 'BATTLEGROUND' then
    mostRecentGame.Caption:='Warlords';
    if recentgame = 'SUPER_SMASH' then
    mostRecentGame.Caption:='Smash Heroes';
    if recentgame = 'GINGERBREAD' then
    mostRecentGame.Caption:='Turbo Cart Racers';
    if recentgame = 'HOUSING' then
    mostRecentGame.Caption:='Housing';
    if recentgame = 'SKYWARS' then
    mostRecentGame.Caption:='SkyWars';
    if recentgame = 'TRUE_COMBAT' then
    mostRecentGame.Caption:='Crazy Walls';
    if recentgame = 'SPEED_UHC' then
    mostRecentGame.Caption:='Speed UHC';
    if recentgame = 'SKYCLASH' then
    mostRecentGame.Caption:='SkyClash';
    if recentgame = 'LEGACY' then
    mostRecentGame.Caption:='Classic Games';
    if recentgame = 'PROTOTYPE' then
    mostRecentGame.Caption:='Prototype';
    if recentgame = 'BEDWARS' then
    mostRecentGame.Caption:='Bed Wars';
    if recentgame = 'MURDER_MYSTERY' then
    mostRecentGame.Caption:='Murder Mystery';
    if recentgame = 'BUILD_BATTLE' then
    mostRecentGame.Caption:='Build Battle';
    if recentgame = 'DUELS' then
    mostRecentGame.Caption:='Duels';
    if recentgame = 'SKYBLOCK' then
    mostRecentGame.Caption:='SkyBlock';
    if recentgame = 'PIT' then
    mostRecentGame.Caption:='Pit';
    if checkbox1.Checked = TRUE then
    showmessage(concat('Recent game checked, Hypixel type name: ',recentgame,', clean name is: ',mostRecentGame.Caption));
    recentgame:='';
    end;
    // find latest game played
    if arrays[2].FindPath('player.firstLogin') = nil then
    else begin
     val(arrays[2].FindPath('player.firstLogin').AsString, unixEpochTimeReal[1]);
     unixEpochTimeReal[2]:=unixEpochTimeReal[1]/1000;
     unixEpochTimeInt[1]:=round(unixEpochTimeReal[2]);
     joinedOn.Caption:=Concat(DateTimeToStr(UnixToDateTime(unixEpochTimeInt[1])),' GMT');
    end;
    if checkbox1.Checked = TRUE then
     showmessage('First joined date checked.');
    if arrays[2].FindPath('player.lastLogin') = nil then
    else begin
     val(arrays[2].FindPath('player.lastLogin').asString, unixEpochTimeReal[3]);
     unixEpochTimeReal[4]:=unixEpochTimeReal[3]/1000;
     unixEpochTimeInt[2]:=round(unixEpochTimeReal[4]);
     lastLogin.Caption:=Concat(DateTimeToStr(UnixToDateTime(unixEpochTimeInt[2])),' GMT');
    end;
    if checkbox1.Checked = TRUE then
     showmessage('Last login date checked.');
    // calculate joined date and last login date
    if arrays[2].FindPath('player.networkExp') = nil then
    else begin
    val(arrays[2].FindPath('player.networkExp').asString, networkEXP);
    str((sqrt(reverseConst+(growthDivides2*networkExp))+reversePQPrefix+1):4:2, networkl);
    networkLV.Caption:=networkl;
    end;
    if checkbox1.Checked = TRUE then
     showmessage('Network level calculated.');
    // calculate network level using reverse constant, growth divide 2 and reverse PQ prefix (see declaration above)
    arrays[3]:=TJSONArray(GetJSON(responses3));
     if arrays[3].FindPath('guild.name') = nil then
      guildName.Caption:=''
     else
      guildName.Caption:=utf8tostring(arrays[3].FindPath('guild.name').asString);
     if checkbox1.Checked = TRUE then
     showmessage('Guild name checked.');
     if arrays[3].FindPath('guild.exp') = nil then begin
      guildEXP.Caption:='';
      guildLV.Caption:='';
     end
     else begin
      guildEXP.Caption:=utf8tostring(arrays[3].FindPath('guild.exp').AsString);
      val(arrays[3].FindPath('guild.exp').AsString, GEXP);
      if GEXP < 100000 then
      guildLV.Caption:='0';
      if GEXP < 250000 then
      guildLV.Caption:='1';
      if GEXP < 500000 then
      guildLV.Caption:='2';
      if GEXP < 1000000 then
      guildLV.Caption:='3';
      if GEXP < 1750000 then
      guildLV.Caption:='4';
      if GEXP < 2750000 then
      guildLV.Caption:='5';
      if GEXP < 4000000 then
      guildLV.Caption:='6';
      if GEXP < 5500000 then
      guildLV.Caption:='7';
      if GEXP < 7500000 then
      guildLV.Caption:='8';
      if GEXP >=7500000 then
        if GEXP < 15000000 then begin
        Str((((GEXP-7500000)/2500000)+9):4:0, guildLVL);
        guildLV.Caption:=guildLVL;
        end
        else begin
        Str((((GEXP-15000000)/3000000)+9):4:0, guildLVL);
        guildLV.Caption:=guildLVL;
        end;
      GEXP:=0;
     end;
     if checkbox1.Checked = TRUE then
     showmessage('Guild LV and EXP has been successfully calculated.');
    if arrays[3].FindPath('guild.members') = nil then
    gMaster.Caption:=''
    else
    for enums1 in arrays[3].FindPath('guild.members') do begin
       objects[1]:=TJSONObject(enums1.value);
       gRank:=utf8tostring(objects[1].FindPath('rank').AsString);
       if (gRank = 'Guild Master') or (gRank = 'GUILDMASTER') then begin
         gMasterUUID:=utf8tostring(objects[1].FindPath('uuid').AsString);
         with tfphttpclient.create(nil) do
           try
             addheader('Content-Type','application/json');
             responses5:=get(concat('https://api.hypixel.net/player?key=',apikey,'&uuid=',gmasteruuid));
           finally
             free;
           end;
         arrays[5]:=TJSONArray(GetJSON(responses5));
         gmaster.caption:=utf8tostring(arrays[5].FindPath('player.displayname').asString);
       end;
    end;
           if checkbox1.Checked = TRUE then
           showmessage('Guild Master checked.');
    if arrays[3].FindPath('guild.tag') = nil then
     gTag.Caption:=''
    else
     gTag.Caption:=utf8tostring(arrays[3].FindPath('guild.tag').AsString);
    if checkbox1.Checked = TRUE then
     showmessage('Guild tag checked.');
     // get guild name, level, guild master and tag.
    arrays[4]:=TJSONArray(GetJSON(responses4));
    handler:=1;
    if arrays[4].FindPath('profiles') = nil then
    else
    for enums2 in arrays[4].FindPath('profiles') do begin
     objects[2]:=TJSONObject(enums2.value);
     sbProfileID[handler]:=utf8tostring(objects[2].FindPath('profile_id').asString);
     cuteName[handler]:=utf8tostring(objects[2].FindPath('cute_name').asString);
     if checkbox1.Checked = TRUE then
     showmessage(concat(sbProfileID[handler],' with cute name ',cuteName[handler]));
     handler:=handler+1;
    end;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if checkbox1.Checked = TRUE then
  showmessage('Debug messages will be shown.');
  if checkbox1.Checked = FALSE then
  showmessage('Debug messages will not be shown.');
end;

procedure TForm1.tleChange(Sender: TObject);
begin
  username:=tle.Text;
end;

end.

