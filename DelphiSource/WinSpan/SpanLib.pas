{$R-}
 {$H-}
unit spanlib;
interface
uses (*WinDos,Wincrt,*)SpanIo,SpanDef,StrngSub;


procedure push(v:real;n:integer;ax:boolean;var i:integer);
function pull(ds:integer;ax:boolean;ix:integer):real;
procedure clear_location(n:integer);
procedure delpnt(n:integer;var i:integer);
procedure ClearMemory;

implementation

var i,j:integer;

procedure push(v:real;n:integer;ax:boolean;var i:integer);
var l,j,k:integer;
    oo:boolean;
begin
(** Put value <v> to coord. <ax> of point <i> of curve <n> **)
 if (i<1)or(i>Datamax*MaxBlock) then exit;
 with ddir[n] do begin
  if ((i div DataMax)>(npts div DataMax))or(ref[1]=nil) then begin
    { Get memory, if neccessary }
    if ref[1]=nil then npts:=0;
    l:=i div DataMax + 1;
    for j:=1 to l do if ref[j]=nil then begin
      getmem(ref[j],DataMax*2*sizeof(single));
    end
  end;
  if (npts=0) then begin
      if n>0 then begin
        inc(n_locations_used);
        plotcolor:=((n-1) mod 7)+1
      end else plotcolor:=1;
      connect:=true;
      symbol:=chr(1);
      inter:=false;
  end;
  if i>npts then npts:=i;
  k:=i mod datamax;
  ref[i div DataMax+1]^[ax][k]:=v
 end
end;

function pull(ds:integer;ax:boolean;ix:integer):real;
var k,l:integer;
    a:real;
begin
(** Return value of coordinate <ax> of point <i> of curve <n> **)
  k:=ix div DataMax + 1;
  l:=ix mod DataMax;
  if ddir[ds].ref[k]=nil then pull:=0 else
    a:=ddir[ds].ref[k]^[ax][l];
    result:=a
end;

procedure clear_location(n:integer);
var i:integer;
begin
(** Clear memory <n> **)
  with ddir[n] do begin
    for i:=1 to MaxBlock do
     if ref[i]<>nil then begin
      freemem(ref[i],DataMax*2*sizeof(single));
      ref[i]:=nil
    end;
    if (n_locations_used>0)and(n>0)and(npts<>0) then dec(n_locations_used);
    z:=99999;head:='';
    npts:=0;
  end
end;

procedure delpnt(n:integer;var i:integer);
var l,j,jm1:integer;
    ax:boolean;
begin
(*** Исключение точки i из кривой n ***)
 with ddir[n] do begin
  if npts<=1 then begin clear_location(n);exit end;
  if npts>i then
    for j:=i+1 to npts do
     begin
      jm1:=j-1;
      for ax:=oX to oY do
       push(pull(n,ax,j),n,ax,jm1)
     end;
  npts:=npts-1;
  l:=npts div DataMax + 1;
  if l<MaxBlock then for j:=l+1 to MaxBlock do
    if ref[j]<>nil then begin
      freemem(ref[j],Datamax*2*sizeof(single));
      ref[j]:=nil
    end
 end
end;


procedure ClearMemory;
var i,l:integer;
begin
  n_locations_used:=0;
  for i:=mincur to maxcur do clear_location(i);
end;

begin
  for i:=mincur to maxcur do with ddir[i] do
    for j:=1 to MaxBlock do ref[j]:=nil;
{  for i:=1 to MaxPar do MacPar[i]:='';   }
end.

