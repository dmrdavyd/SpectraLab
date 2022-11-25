{$H-}
{$I-}

unit SPL32BASE;

interface
uses spl32def,IniFiles, rdtsc, Matrix, Math;


var Spectra: ArrayOfDir;
    obj: ^longint;
    prmblk: r_splab_param_block;
    xyaxis :biaxis;
    ax:boolean;
    ercode: integer;

function push(v:single;n:integer;ax:boolean;var i:integer):boolean; export; register;
function pull(var a:single;n:integer;ax:boolean;i:integer):boolean; export; register;
function getn(curnum:longint): longint; export; stdcall ;
function getsel(curnum:longint): longint; export;stdcall;
function getz(curnum:longint): single; export; stdcall;
function putz(vz:single; curnum:longint): longint; export; stdcall;
function getx(i,n:longint):single; export; stdcall;
function gety(i,n:longint):single; export; stdcall;
function gethead(curnum:longint; hedptr:pointer): longint; export; stdcall;
function GetRef2Spec(n:longint):pointer; export; register;
function GetRef2Axis(Ax:boolean):pointer; export; register;
function n_locations_used: longint; export; register;
procedure clear_location(n:longint);
procedure clear_all; export;stdcall;
procedure clearmem(n:longint); export; stdcall;
function delpnt(n,i:longint): longint; export; stdcall;
procedure _setddir(var obj_,xaxis,yaxis:longint; dir_paths,specname,browspath: pointer);export; stdcall ;
function _GetDirAddr(memno:longint): longint; export; stdcall ;
function ptr2obj: pointer; export; register;
function ptr2prmblock: pointer; export; register;
function GetDirAddr(memno:longint): pointer; export; register ;

implementation

function getn(curnum:longint): longint; export; stdcall ;
begin
  if (curnum<mincur)or(curnum>maxcur) then result:=0 else result:=spectra.dir(curnum)^.npts
end;

function getsel(curnum:longint): longint; export;stdcall;
begin
  if (curnum<mincur)or(curnum>maxcur) then result:=0 else
    if (spectra.dir(curnum)^.plotcolor and 128)=0 then result:=-1 else result:=0
end;

function getz(curnum:longint): single; export; stdcall;
var     sv:single;
begin
  sv:=spectra.dir(curnum)^.z;
  result:=sv
end;

function putz(vz:single; curnum:longint): longint; export; stdcall;
begin
  if (curnum>=mincur) and (curnum<=maxcur) then begin
    spectra.dir(curnum)^.z:=vz;
    result:=-1
  end else result:=0;
end;

function gethead(curnum:longint; hedptr:pointer): longint; export; stdcall;
var hed:^shortstring;
begin
  hed:=hedptr;
  hed^:=spectra.dir(curnum)^.head;
  result:=length(hed^)
end;

function GetRef2Spec(n:longint):pointer; export; register;
begin
  GetRef2Spec:=Spectra.dir(n)
end;

function GetRef2Axis(Ax:boolean):pointer; export; register;
begin
  GetRef2Axis:=xyaxis[ax]
end;

procedure clear_location(n:longint);
var n1,n2,i:integer;
begin
(** Clear memory <n> **)
  if (n=Not_Defined) then begin n1:=1;n2:=maxcur end else
     begin  n:=max(n,mincur);n:=min(n,maxcur);n1:=n; n2:=n end;
  for i:=n1 to n2 do with spectra.dir(i)^ do begin
    spectra.ClearLoc(i);
    spectra.clearfitrecord(i);
  end
end;

procedure clear_all; export;stdcall;
begin
  clear_location(Not_Defined)
end;

procedure clearmem(n:longint); export; stdcall;
begin
 clear_location(n)
end;

function push(v:single;n:integer;ax:boolean;var i:integer):boolean;
begin
   if (v>MaxSafeReal) then v:=maxsafereal else
     if (V<-MaxSafeReal) then v:=-maxsafereal;
   if (i>0)and(i<=maxpoints)and(n>=mincur)and(n<=maxcur) then with spectra.dir(n)^ do begin
         if ax then
           ydata^[i]:=v
         else
           xdata^[i]:=v;
         if npts<i then npts:=i;
         push := true;
    end else push:=false;
end;

function pull(var a:single;n:integer;ax:boolean;i:integer):boolean;
begin
   if (i>0)and(i<=Spectra.Dir(n)^.npts)and(n>=mincur)and(n<=maxcur)
    { and (Spectra.Dir(n)^.locX<>0)and(Spectra.Dir(n)^.locY<>0) } then
    with Spectra.Dir(n)^ do begin
      if ax then a:=ydata^[i] else a:=xdata^[i];
      if a>MaxSafeReal then
                         a:=maxsafereal else
        if(a<-MaxSafeReal) then
                         a:=-maxsafereal;
      pull := true
    end else pull:=false;
end;

function getx(i,n:longint):single; export; stdcall;
var xx:single;
begin
  pull(xx,n,FALSE,i);
  result:=xx
end;

function gety(i,n:longint):single; export; stdcall;
var xx:single;
begin
  pull(xx,n,TRUE,i);
  result:=xx
end;

function delpnt(n,i:longint): longint;
var j,jm1:integer;
    ax:boolean;
    a:single;
begin
(*** Исключение точки i из кривой n ***)
 with spectra.dir(n)^ do begin
  if (i<1)or(i>npts) then begin delpnt:=0; exit end;
  delpnt:=-1;
  if npts=1 then begin clear_location(n); exit end;
  if npts>i then
    for j:=i+1 to npts do
     begin
      jm1:=j-1;
      for ax:=oX to oY do begin
       pull(a,n,ax,j);
       push(a,n,ax,jm1)
      end ;
     end;
     npts:=npts-1;
 end
end;

procedure _setddir(var obj_,xaxis,yaxis:longint; dir_paths,specname,browspath: pointer);export; stdcall ;
var nana:single;
begin
  Spectra.CreateDir;
  obj:=addr(obj_);
  prmblk:= addr(obj_);
  xyaxis[ox]:=addr(xaxis);
  xyaxis[oy]:=addr(yaxis);
  prmblk^.splabdir:=dir_paths;
  prmblk^.spectroname:=specname;
  prmblk^.browspath:=browspath;
  progname:=prmblk^.spectroname^;
  nana:=nan;
  move(nana,prmblk^.pntptr.v,4);
end;

(*
function SPLAB32DIR(Var OUTSTR:longint):longint; export; stdcall;
var IniFile: TIniFile;
    ss:string;
begin
  IniFile:=TIniFile.Create('Splab32.ini');
  ss:=IniFile.ReadString('Directories','RootDir','');
  IniFile.Free ;
  move(ss,outstr,length(ss)+1);
  splab32dir:=length(ss)
end;
*)

function _GetDirAddr(memno:longint): longint; export; stdcall ;
var ptr:ptr2int;
begin
  ptr.p:=Spectra.dir(memno);
  _GetDirAddr:=ptr.l
end;

function n_locations_used: longint;
var i,n:integer;
begin
  n:=0;
  for i:=1 to MaxCur do if Spectra.dir(i)^.npts>0 then inc(n) ;
  n_locations_used:=n
end;

procedure _push(var ex:extended; n:longint; ax:boolean);
var memno:integer;
begin
  memno:=obj^;
  if (n>0)and(n<=maxpoints)and(memno>=mincur)and(memno<=maxcur) then with spectra.dir(memno)^ do begin
         if ax then
           ydata^[n]:=ex
         else
           xdata^[n]:=ex;
  end
end;

function GetDirAddr(memno:longint): pointer; export; register ;
begin
  if (memno<mincur) or (memno>maxcur) then result:=addr(Spectra) else result:=Spectra.dir(memno);
end;


function ptr2obj: pointer; export; register;
begin
  result:=obj
end;

function ptr2prmblock: pointer; export; register;
begin
  result:=prmblk
end;

begin
{RSpectra:=addr(Spectra);}
end.

