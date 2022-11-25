unit Spl32_08;

interface
uses math,spl32def,Spl32Base;

function log_y(locn:integer):boolean;
function logy:boolean; export; stdcall;
function norm_y(nnorm, src, ref:integer):single;
function normy(nnorm, ref:longint):longint; export; stdcall;
function sub_y(negate:boolean;src,ref:integer):boolean;
function suby(negate,ref:longint):boolean; export; stdcall;

implementation
function log_y(locn:integer):boolean;
var i,numpt:integer;tmp:single;
     a:extended;
    const mina=1e-6;
begin
  log_y:=false;
  with Spectra.dir(locn)^ do begin
    if npts=0 then exit;
    for i:=1 to npts do begin
       numpt:=i;
       pull(tmp,locn,oY,numpt);
       if tmp<=0 then a:=mina else a:=tmp;
       a:=log10(a);
       tmp:=a;
       push(tmp,locn,oY,numpt)
    end;
  end;
  log_y:=true
end;

function logy:boolean; export; stdcall;
begin
 logy:=log_y(obj^)
end;

function norm_y(nnorm, src, ref:integer):single;
var i,i0,npt:integer;tmp,tmp1,sum0,sum1:single;
begin
 norm_y:=0;
 with Spectra.dir(src)^ do  begin
  if (ref=src)or(ref>maxcur)or(nnorm<=0)or(npts<=nnorm)or(Spectra.dir(ref)^.npts<npts) then exit;
  sum0:=0;sum1:=0;i0:=npts-nnorm+1;
  for i:=i0 to npts do begin
       npt:=i;
       pull(tmp1,src,oY,npt);
       pull(tmp,ref,oY,npt);
       sum0:=sum0+tmp;
       sum1:=sum1+tmp1;
  end;
  if (sum1<=0)or(sum0<=0) then exit;
  tmp1:=(sum0-sum1)/nnorm;
  for i:=1 to npts do begin
       npt:=i;
       pull(tmp,src,oY,npt);
       tmp:=tmp+tmp1;
       push(tmp,src,oY,npt)
  end;
  norm_y:=tmp1;
 end
end;

function normy(nnorm, ref:longint):longint; export; stdcall;
begin
  normy:=round(norm_y(nnorm, obj^, ref)*1000)
end;

function sub_y(negate:boolean;src,ref:integer):boolean;
var i,npt:integer;tmp,tmp1:single;
begin
  sub_y:=false;
  if (ref=src)or(ref>maxcur) then exit;
  with Spectra.dir(src)^ do begin
    if (npts<=0)or(Spectra.dir(ref)^.npts<npts) then exit;
    for i:=1 to npts do begin
       npt:=i;
       pull(tmp,src,oY,npt);
       pull(tmp1,ref,oY,npt);
       tmp:=tmp-tmp1;
       if negate then tmp:=-1*tmp;
       push(tmp,src,oY,npt)
    end;
  end;
  sub_y:=true
end;

function suby(negate,ref:longint):boolean; export; stdcall;
begin
  suby:=sub_y((negate<>0),obj^,ref)
end;

end.
