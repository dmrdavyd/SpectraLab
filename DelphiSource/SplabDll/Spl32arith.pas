unit Spl32arith;

interface
uses math,spl32def,Spl32Base,SPL32_01,Spn_08,Spn_Pcor,mdefine,matrix,SplabMessages;
const maxstack=-1*mincur;
      plus=1;
      minus=2;
      multiply=3;
      divide=4;
type sstktype= array[0..maxstack] of integer;

var sstk:sstktype;
    sstkptr:integer;

function _depth_:longint; export; stdcall;
function pull_(dest:integer):boolean;
function _pull_(dest:longint):longint; export; stdcall;
function push_(src:integer):boolean;
function _push_(src:longint):longint; export; stdcall;
function swap_:boolean;
function _swap_:longint; export; stdcall;
function rot_:boolean;
function _rot_:longint; export; stdcall;
function drop_:boolean;
function _drop_:longint; export; stdcall;
function dup_:boolean;
function _dup_:longint; export; stdcall;
function over_:boolean;
function _over_:longint; export; stdcall;
function plus_(OY:boolean; konst: single):boolean;
function _plus_(OY:longint; konst: single):longint; export; stdcall;
function minus_(OY:boolean; konst: single):boolean;
function _minus_(OY:longint; konst: single):longint; export; stdcall;
function multiply_(OY:boolean; konst: single):boolean;
function _multiply_(OY:longint; konst: single):longint; stdcall;
function divide_(OY:boolean; konst: single):boolean;
function _divide_(OY:longint; konst: single):longint; export; stdcall;
function log_(OY:boolean):boolean;
function _log_(OY:longint):longint; export; stdcall;
function abs_(OY:boolean):boolean;
function _abs_(OY:longint):longint; export; stdcall;
function exp_(OY:boolean):boolean;
function _exp_(OY:longint):longint; export; stdcall;
function smo_(framewdth:integer):boolean;
function _smo_(framewdth:longint):longint; export; stdcall;
function tri_(framewdth:integer):boolean;
function _tri_(framewdth:longint):longint; export; stdcall;
function der_(Ordr:integer):boolean;
function _der_(Ordr:longint):longint; export; stdcall;
function trunc_(var maxi:extended):boolean;
function _trunc_(var maxi:extended):longint;export; stdcall;
function _resample_(memno:longint;var dx,x0,x9:extended):longint; export; stdcall;
function ave_(var a:extended):longint; export; stdcall;
function area_(var a:extended):longint; export; stdcall;
function min_(lx:longint; var a:extended):longint; export; stdcall;
function max_(lx:longint; var a:extended):longint; export; stdcall;
function _corpress_(memno:longint):longint; export; stdcall;
function _xcorpress_(memno:longint):longint; export; stdcall;
function matrix_invert:longint; export; stdcall;
implementation

function depth_:integer; stdcall;
begin
  result:=maxstack-sstkptr+1
end;

function _depth_:longint; stdcall;
begin
  result:=depth_
end;

function drop_:boolean;
begin
 result:=false;
 if (depth_<1) or (depth_>=maxstack) then exit;
 clear_location(-sstkptr);
 inc(sstkptr);
 result:=true
end;

function _drop_:longint; export; stdcall;
begin
  if drop_ then result:=-1 else result:=0;
end;

function copycur(src,dest:integer):boolean;
var i,npts:integer;
    xx:single;
    ss:shortstring;
begin
  result:=false;
  npts:=getn(src);
  if npts=0 then begin
     ss:='#Copy: Invalid source dataset';
     SplabErrorMessage(ss);
     exit
  end;
  if (dest<mincur) or (dest>maxcur) then begin
     ss:='#Copy: Invalid destination';
     SplabErrorMessage(ss);
     exit
  end;
  clear_location(dest);
  for i:=1 to npts do begin
    pull(xx,src,false,i);
    push(xx,dest,false,i);
    pull(xx,src,true,i);
    push(xx,dest,true,i);
  end;
  move(Spectra.DirArray[src],Spectra.DirArray[dest],sizeof(shortstring)+sizeof(single)*8);
  Spectra.DirArray[dest].fitparam:=NIL;
  result:=true
end;

function push_(src:integer):boolean;
var dest:integer;
    ss:shortstring;
begin
  result:=false;
  if (depth_<0)or(depth_>(maxstack+1)) then begin
     ss:='#Push: Stack overflow';
     SplabErrorMessage(ss);
     exit
  end;
  dec(sstkptr);dest:=-sstkptr;
  result:=copycur(src,dest);
end;

function _push_(src:longint):longint; stdcall;
begin
  if push_(src) then result:=-1 else result:=0;
end;

function pull_(dest:integer):boolean;
var npts,src:integer;
    ss:shortstring;
begin
  result:=false;
  src:=-sstkptr;
  npts:=getn(src);
  if npts=0 then begin
     ss:='#Pull: Stack is empty';
     SplabErrorMessage(ss);
     exit
  end;
  result:=copycur(src,dest);
  drop_
end;

function _pull_(dest:longint):longint; stdcall;
begin
  if pull_(dest) then result:=-1 else result:=0;
end;

function swap_:boolean;
var Databuf:DataSpec;
    top,undertop:integer;
begin
 result:=false;
 if depth_<2 then exit;
 top:=-sstkptr;
 undertop:=-sstkptr-1;
 DataBuf:=Spectra.DirArray[undertop];
 Spectra.DirArray[undertop]:=Spectra.DirArray[top];
 Spectra.DirArray[top]:=DataBuf;
 result:=true;
end;

function _swap_:longint; stdcall;
begin
  if swap_ then result:=-1 else result:=0;
end;

function rot_:boolean;
var Databuf:DataSpec;
    top,u1top,u2top:integer;
begin
 result:=false;
 if depth_<3 then exit;
 top:=-sstkptr;
 u1top:=-sstkptr-1;
 u2top:=-sstkptr-2;
 DataBuf:=Spectra.DirArray[top];
 Spectra.DirArray[top]:=Spectra.DirArray[u1top];
 Spectra.DirArray[u1top]:=Spectra.DirArray[u2top];
 Spectra.DirArray[u2top]:=DataBuf;
 result:=true;
end;

function _rot_:longint; stdcall;
begin
  if rot_ then result:=-1 else result:=0;
end;


function dup_:boolean;
begin
 result:=false;
 if (depth_<1) or (depth_>=maxstack) then exit;
 result:=push_(-sstkptr);
end;

function _dup_:longint; stdcall;
begin
  if dup_ then result:=-1 else result:=0;
end;

function over_:boolean;
begin
 result:=false;
 if (depth_<2) or (depth_>=maxstack) then exit;
 result:=push_(-sstkptr-1);
end;

function _over_:longint; stdcall;
begin
  if over_ then result:=-1 else result:=0;
end;

function arithm_curve(OY:boolean;arithmop:integer):boolean;
var i,top,undertop,npts:integer;
var xx,yy:single;
begin
 result:=false;
 if depth_<2 then exit;
 top:=-sstkptr;
 undertop:=-sstkptr-1;
 npts:=min(getn(top),getn(undertop));
 for i:=1 to npts do begin
    pull(xx,top,OY,i);
    pull(yy,undertop,OY,i);
    case arithmop of
      plus: xx:=xx+yy;
      minus: xx:=yy - xx;
      multiply: xx:=xx*yy;
      divide: if xx<>0 then xx:=yy/xx else if yy=0 then xx:=0 else xx:=maxreal ;
    end;
    push(xx,undertop,OY,i);
 end;
 result:=drop_
end;

function arithm_const(OY:boolean;konst:single;arithmop:integer):boolean;
var top,i,npts:integer;
var xx:single;
begin
 result:=false;
 if depth_<1 then exit;
 top:=-sstkptr;
 npts:=getn(top);
 for i:=1 to npts do begin
    pull(xx,top,OY,i);
    case arithmop of
      plus: xx:=xx+konst;
      minus: xx:=xx-konst;
      multiply: xx:=xx*konst;
      divide: if konst<>0 then xx:=xx/konst else if xx<>0 then xx:=maxreal ;
    end;
    push(xx,top,OY,i);
 end;
end;

function plus_(OY:boolean; konst: single):boolean;
begin
  if isnan(konst) then result:=arithm_curve(OY,plus) else result:=arithm_const(OY,konst,plus)
end;

function _plus_(OY:longint; konst: single):longint; stdcall;
begin
  if plus_(OY<>0,konst) then result:=-1 else result:=0
end;

function minus_(OY:boolean; konst: single):boolean;
begin
  if isnan(konst) then result:=arithm_curve(OY,minus) else result:=arithm_const(OY,konst,minus)
end;

function _minus_(OY:longint; konst: single):longint; stdcall;
begin
  if minus_(OY<>0,konst) then result:=-1 else result:=0
end;

function multiply_(OY:boolean; konst: single):boolean;
begin
  if isnan(konst) then result:=arithm_curve(OY,multiply) else result:=arithm_const(OY,konst,multiply)
end;

function _multiply_(OY:longint; konst: single):longint; stdcall;
begin
  if multiply_(OY<>0,konst) then result:=-1 else result:=0
end;

function divide_(OY:boolean; konst: single):boolean;
begin
  if isnan(konst) then result:=arithm_curve(OY,divide) else result:=arithm_const(OY,konst,divide)
end;

function _divide_(OY:longint; konst: single):longint; stdcall;
begin
  if divide_(OY<>0,konst) then result:=-1 else result:=0
end;

function log_(OY:boolean):boolean;
begin
  result:=false;
  if (depth_=0)or(getn(sstkptr*-1)<1) then exit;
  loga(sstkptr*-1,OY);
  result:=true;
end;

function _log_(OY:longint):longint; stdcall;
begin
  if log_(OY<>0) then result:=-1 else result:=0
end;

function abs_(OY:boolean):boolean;
begin
  result:=false;
  if (depth_=0)or(getn(sstkptr*-1)<1) then exit;
  absa(sstkptr*-1,OY);
  result:=true;
end;
function _abs_(OY:longint):longint; stdcall;
begin
  if abs_(OY<>0) then result:=-1 else result:=0
end;

function exp_(OY:boolean):boolean;
begin
  result:=false;
  if (depth_=0)or(getn(sstkptr*-1)<1) then exit;
  expa(sstkptr*-1,OY);
  result:=true;
end;

function _exp_(OY:longint):longint; stdcall;
begin
  if exp_(OY<>0) then result:=-1 else result:=0
end;

function der_(Ordr:integer):boolean;
begin
  result:=false;
  if (depth_=0)or(getn(sstkptr*-1)<5) then exit;
  deriv(Ordr,sstkptr*-1);
  result:=true
end;

function _der_(Ordr:longint):longint; stdcall;
begin
  if der_(ordr) then result:=-1 else result:=0
end;

function smo_(framewdth:integer):boolean;
begin
  result:=false;
  if (depth_=0)or(getn(sstkptr*-1)<5) then exit;
  smooth(framewdth,sstkptr*-1,FALSE);
  result:=true
end;

function _smo_(framewdth:longint):longint; export; stdcall;
begin
  if smo_(framewdth) then result:=-1 else result:=0
end;

function tri_(framewdth:integer):boolean;
begin
  result:=false;
  if (depth_=0)or(getn(sstkptr*-1)<5) then exit;
  triade(framewdth,sstkptr*-1);
  result:=true
end;

function _tri_(framewdth:longint):longint; export; stdcall;
begin
  if tri_(framewdth) then result:=-1 else result:=0
end;

function trunc_(var maxi:extended):boolean;
begin
  result:=false;
  if (depth_=0)or(getn(sstkptr*-1)<5) then exit;
  truny(sstkptr*-1,maxi);
  result:=true
end;

function _trunc_(var maxi:extended):longint;export; stdcall;
begin
  if trunc_(maxi) then result:=-1 else result:=0
end;

function _resample_(memno:longint;var dx,x0,x9:extended):longint; export; stdcall;
var x00,x99,xx,xxx,yy:single;
    i0,ix,ix0:longint;
begin
   result:=0;
   if getn(memno)<5 then exit;          (* too short dataset *)
   pull(x00,memno,false,1);
   pull(x99,memno,false,getn(memno));
   if (x0<x00) then x0:=x00;
   if x9>x99 then x9:=x99;
   x99:=x9-x0;
   x00:=2*dx;
   if x99<x00 then  exit ;
   sort(0,memno);
   clear_location(0);
   move(Spectra.DirArray[memno],Spectra.DirArray[0],sizeof(shortstring)+sizeof(single)*8);
   Spectra.DirArray[0].fitparam:=NIL;
   Spectra.DirArray[0].npts:=0;
   xx:=x0;
   ix0:=1; i0:=1;
   while ((xx)<=x9)and(i0<=maxpoints) do begin
     ix:=ix0;
     while (pull(xxx,memno,false,ix))and(xxx<xx) do inc(ix);
     if xxx=xx then pull(yy,memno,true,ix) else begin
       if ((ix-ix0)>2) then ix0:=ix-2;
       yy:=aitken(memno,xx,ix0,4);
     end;
     push(yy,0,true,i0);
     push(xx,0,false,i0);
     xx:=xx+dx;inc(i0)
   end;
   clear_location(memno);
   copycur(0,memno);
   clear_location(0);
   result:=-1
end;

function ave_(var a:extended):longint; export; stdcall;
begin
  result:=0; a:=0;
  if (depth_=0)or(getn(sstkptr*-1)<1) then exit;
  a:=avera(sstkptr*-1,true);
  result:=round(a*yfactor);
  drop_
end;

function area_(var a:extended):longint; export; stdcall;
begin
  result:=0; a:=0;
  if (depth_=0)or(getn(sstkptr*-1)<1) then exit;
  a:=area(sstkptr*-1);
  result:=round(a*yfactor);
  drop_
end;

function min_(lx:longint; var a:extended):longint; export; stdcall;
begin
 result:=0; a:=0;
 if (depth_=0)or(getn(sstkptr*-1)<1) then exit;
 a:=minimax(sstkptr*-1,not(lx=0),false);
  result:=round(a*yfactor);
  drop_
end;

function max_(lx:longint; var a:extended):longint; export; stdcall;
begin
 result:=0; a:=0;
 if (depth_=0)or(getn(sstkptr*-1)<1) then exit;
 a:=minimax(sstkptr*-1,not(lx=0),true);
 result:=round(a*yfactor);
 drop_
end;

function _corpress_(memno:longint):longint; export; stdcall;
begin
  if corpress(memno) then result:=-1 else result:=0
end;

function _xcorpress_(memno:longint):longint; export; stdcall;
begin
  if xcorpress(memno) then result:=-1 else result:=0
end;

function matrix_invert:longint; export; stdcall;
var top,i,j,ij,npts,n:integer;
    a:mtype;
    err:boolean;
    xx:single;
begin
 result:=0;
 if depth_<1 then exit;
 top:=-sstkptr;
 npts:=getn(top);
 n:=round(sqrt(npts));
 if n*n<>npts then exit;
 for i:=1 to n do
  for j:=1 to n do begin
    ij:=(i-1)*n+j;
    pull(xx,top,oY,ij);
    a[i,j]:=xx
  end;
 invert(a,n,err);
 if err then exit;
 for i:=1 to n do
  for j:=1 to n do begin
    xx:=a[i,j];
    ij:=(i-1)*n+j;
    push(xx,top,oY,ij);
  end;
 result:=n
end;

begin
 sstkptr:=maxstack+1;
end.
