 {$H-}
unit initspan;
interface
uses spandef,spanfile,spanlib,spanio,StrngSub,inifiles;
var splab32dir:string;

procedure reinit_df;
function restart:boolean;
{ function SPLAB32DIR:shortstring;     }

implementation

procedure reinit_df;
begin
  if not(ReadAll(sysname)) then begin
    scan_on:=true;
    nptoget:=64;
    tchp:=0;
    dt1:=10.0;
    dt2:=10.0;
    start_w:=400;
    end_w:=500;
    scan_step:=2;
    scan_rate:=3;
    meas_w:=450;
    ref_w:=490;
    auto_corr:=false;
    cornum:=0;
    correct_w:=490;
    corval:=0;
    refnum:=maxcur;
    comment:='';
    obj:=1;
    firstdisp:=1;
  end;
(********************************************************)
end;

{
function SPLAB32DIR:shortstring;
var IniFile: TIniFile;
    ss:string;
begin
  IniFile:=TIniFile.Create('Splab-MMX.ini');
  ss:=IniFile.ReadString('Directories','RootDir','');
  cut(ss,' ');
  if ss[length(ss)]<>'\' then ss:=ss+'\';
  result:=ss;
  IniFile.Free
end;
}

function restart:boolean;
var ax:boolean;
    i,j,ncolr:integer;
    fprm:text;
    fn,fnb:string;
    fnc,fne:string[8];
    buf:array [1..16] of byte;
    fbgi:file;

begin
(************* INITIALISATION OF THE PARAMETERS *************)
  if paramcount<>0 then begin
      sysname:=paramstr(1);
      splab32dir:=sysname;
      i:=length(splab32dir);
      while (i>0) and (splab32dir[i]<>'\')  do dec(i);
      if i<length(SPLAB32DIR) then delete(splab32dir,i+1,255);
  end else begin sysname:='SPLAB'; splab32dir:='' end;
  dir:=1;
  firstdisp:=1;
  for ax:=false to true do begin
    xyaxis[ax].bottom:=0;
    xyaxis[ax].scale:=1
  end;
  for ax:=false to true do begin xyaxis[ax].token:='';xyaxis[ax].auto:=true end;
  converting:=false;
  ClearMemory;
  obj:=1;
  restart:=true;
end;

end.

