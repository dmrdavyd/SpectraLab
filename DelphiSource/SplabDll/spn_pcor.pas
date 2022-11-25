unit Spn_Pcor;
interface
{  Units }

uses Spl32def,
     SPL32BASE,
     math;
const tablen=13;
      tab:array [1..tablen,false..true] of real=
      ((1,1),
       (500,0.9779),
       (1000,0.9618),
       (1500,0.9497),
       (2000,0.9402),
       (2500,0.9325),
       (3000,0.9262),
       (3500,0.9209),
       (4000,0.9164),
       (4500,0.9122),
       (5000,0.9090),
       (5500,0.9063),
       (6000,0.9040));
function corpress(nspc:integer):boolean;
function xcorpress(ir:integer):boolean;

implementation

function pressaitken(xi:single):real;
var p,u:array [1..6] of real;
    np,i1,np1,i,ip1,j:integer;
    uxi:real;
begin
  np:=5;
  iF (NP+1)>tablen then NP:=tablen-1;
  i1:=1;
  while (xi>tab[i1,false])and(i1<tablen) do inc(i1);
  if xi=tab[i1,false] then begin
    pressaitken:=tab[i1,true];
    exit
  end;
  i1:=i1-2;
  if i1<1 then i1:=1;
  IF (I1+NP)>tablen then I1:=tablen-NP+1;
  NP1:=NP+1;
  for I:=1 to NP1 do begin
    J:=I1+I-1;
    U[I]:=tab[j,false];
    p[I]:=tab[j,true]
  end;
  for I:=1 to NP do begin
   UXI:=U[I]-XI;
   IP1:=I+1;
   for  J:=IP1 to NP1 do begin
    P[J]:=(P[I]*(U[J]-XI)-P[J]*UXI)/(U[J]-U[I])
   end
  end;
  pressaitken:=p[np1]
end;

function corpress(nspc:integer):boolean;
var corrcoef:real;
    tmp:single;
    i,j:integer;
begin
  result:=false;
  if (Spectra.dir(nspc)^.npts=0)or isnan(Spectra.dir(nspc)^.z) then exit;
  corrcoef:=pressaitken(Spectra.dir(nspc)^.z);
  for i:=1 to Spectra.dir(nspc)^.npts do begin
        j:=i;
        pull(tmp,nspc,true,j);
        push(corrcoef*tmp,nspc,true,j)
  end;
  result:=true;
end;

function xcorpress(ir:integer):boolean;
var i:integer;
    ax,ay:single;
    corrcoef:real;

begin
    result:=false;
    if (Spectra.dir(ir)^.npts=0) then exit;
    with spectra.dir(ir)^ do begin
     for i:=1 to npts do begin
      pull(ax,ir,false,i);
      pull(ay,ir,true,i);
      corrcoef:=pressaitken(ax);
      push(corrcoef*ay,ir,true,i)
     end
   end;
   result:=true;
end;

end.
