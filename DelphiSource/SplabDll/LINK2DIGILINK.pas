unit LINK2DIGILINK;

interface
Uses Dll6, Dialogs ;

Function Send2Port(Port:word; var ss,ss1:string):integer;
Function Send2Sens(var ss:string):integer;
Function Send2NUDAM(var ss:string):integer;
Function GETCHAN(ch:word;var Y:real):boolean;
Function setzero(ch:word):boolean;
Function offzero(ch:word):boolean;
Function TOGGLEZERO(ch:word):boolean;
Function GET_RELAYS(var W:word):integer;
function SET_RELAYS(w:word):integer;
Function GET_SWITCHES(var W:word):integer;
function SET_SWITCHES(w:word):integer;
function LCHN:boolean;
Procedure TOGGLE_LCHN;
function VANNE:boolean;
Procedure TOGGLE_VANNE;
function LAMP:boolean;
Procedure TOGGLE_LAMP;
function STFVALVE:boolean;
Procedure TOGGLE_STFVALVE;
Procedure COUNTERINIT(w:longint);
function GETCOUNT(ch:word):longint;
procedure CLEARCOUNT(ch:word);
procedure STARTCOUNT(ch:word);
procedure STOPCOUNT(ch:word);
procedure STARTBOTH;
procedure STOPBOTH;
procedure releaseports;
procedure DIGI_INIT(var Nu,Sens,Therm,Counters,Relays,Switches:integer);
function  cpuGetTick:int64;
function  cpuGetms( Tick:int64 ):longword; export; register;
function  cpuGetmks( Tick:int64 ):longword; export; register;

implementation

Function Send2Port(Port:word; var ss,ss1:string):integer;
 register; external 'DIGILINK.dll' name 'Send2Port';

Function Send2Sens(var ss:string):integer;
 register; external 'DIGILINK.dll' name 'Send2Sens';

Function Send2Nudam(var ss:string):integer;
 register; external 'DIGILINK.dll' name 'Send2Nudam';

Function GETCHAN(ch:word;var Y:real):boolean;
 register; external 'DIGILINK.dll' name 'GETCHAN';

Function setzero(ch:word):boolean;
 register; external 'DIGILINK.dll' name 'setzero';

Function offzero(ch:word):boolean;
 register; external 'DIGILINK.dll' name 'offzero';

Function TOGGLEZERO(ch:word):boolean;
 register; external 'DIGILINK.dll' name 'TOGGLEZERO';

Function GET_RELAYS(var W:word):integer;
 register; external 'DIGILINK.dll' name 'GET_RELAYS';

function SET_RELAYS(w:word):integer;
 register; external 'DIGILINK.dll' name 'SET_RELAYS';

Function GET_SWITCHES(var W:word):integer;
 register; external 'DIGILINK.dll' name 'GET_SWITCHES';

function SET_SWITCHES(w:word):integer;
 register; external 'DIGILINK.dll' name 'SET_SWITCHES';

function LCHN:boolean;
 register; external 'DIGILINK.dll' name 'LCHN';

Procedure TOGGLE_LCHN;
 register; external 'DIGILINK.dll' name 'TOGGLE_LCHN';

function VANNE:boolean;
 register; external 'DIGILINK.dll' name 'VANNE';

Procedure TOGGLE_VANNE;
 register; external 'DIGILINK.dll' name 'TOGGLE_VANNE';

function LAMP:boolean;
 register; external 'DIGILINK.dll' name 'LAMP';

Procedure TOGGLE_LAMP;
 register; external 'DIGILINK.dll' name 'TOGGLE_LAMP';

function STFVALVE:boolean;
 register; external 'DIGILINK.dll' name 'STFVALVE';

Procedure TOGGLE_STFVALVE;
 register; external 'DIGILINK.dll' name 'TOGGLE_STFVALVE';

Procedure COUNTERINIT(w:longint);
 register; external 'DIGILINK.dll' name 'COUNTERINIT';

function GETCOUNT(ch:word):longint;
 register; external 'DIGILINK.dll' name 'GETCOUNT';

procedure CLEARCOUNT(ch:word);
 register; external 'DIGILINK.dll' name 'CLEARCOUNT';

procedure STARTCOUNT(ch:word);
 register; external 'DIGILINK.dll' name 'STARTCOUNT';

procedure STOPCOUNT(ch:word);
 register; external 'DIGILINK.dll' name 'STOPCOUNT';

procedure STARTBOTH;
 register; external 'DIGILINK.dll' name 'STARTBOTH';

procedure STOPBOTH;
 register; external 'DIGILINK.dll' name 'STOPBOTH';

procedure releaseports;
 register; external 'DIGILINK.dll' name 'releaseports';

procedure DIGI_INIT(var Nu,Sens,Therm,Counters,Relays,Switches:integer);
  register; external 'DIGILINK.dll' name 'DIGI_INIT';

function cpuGetTick:int64;
  register; external 'DIGILINK.dll' name 'cpuGetTick';

function cpuGetms( Tick:int64 ):longword; export; register;
  register; external 'DIGILINK.dll' name 'cpuGetms';

function cpuGetmks( Tick:int64 ):longword; export; register;
  register; external 'DIGILINK.dll' name 'cpuGetmks';


end.
