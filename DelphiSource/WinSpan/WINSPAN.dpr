 {$H-}
 {$I-}
program Span;

{ Units }

{$R 'WINSPAN.res' 'WINSPAN.RC'}

uses
  WINPROCS,
  SysUtils,
  Win32crt,
  Matrix in '..\SplabDll\matrix.pas',
  mdefine in '..\SplabDll\mdefine.pas'
  SpanDef,
  SpanLib,
  Spanio,
  Spanfile,
  InitSpan,
  StrngSub,
  SpanPri,
  matrdef,
  IniFiles;

{ Global variables }

type inarr=array[1..MaxCur] of integer;
     dynvector=array[1..MaxCur] of real;

var
   rrd,rho2thresh:real; (*Rel. SSD threshold for princ. comp. analysis *)
   rpr:matprof;
   standard,NewStandard:matprof;
   ncur,ifirst:integer;
   zloc:dynvector;
   dynarray:array[0..maxprin] of dynvector;
   SaveComment:string;
   savaxis:biaxis;
   DataFitted,ElimiBad:boolean;
   Wl0,Wl9,DeltaWl0,ssd,ssd1:real;
   firsttime,ok,regular:boolean;
   vecc:matprof;
   alf,gamma:array [0..maxcur] of alfatype;
   lambda:alfatype;
   covar:mtype;
   beta:partype;
   lista,jb:inarr;
   sig:rdata;
   lenspec,nr:integer;
   LenStandards:integer;
   NStandards,Nbad,polyorder:integer;
   rho,rho2:array [0..maxcur] of real;
   stanhead:array[1..maxprin-1] of string[16];
   MaxNr:integer;
   TabName:string;
   matrx:mtype;
   PartCalc,PartSwitch,BaseComp:boolean;
   WOold,WEold,DWOld:real;
   WlOrigin:real;
   WlEnd:real;
   DeltaWl:real;
   UseNew:array[1..5] of boolean;
   mw:array[1..5] of real;
   sfile:text;
   prhead:array[0..MaxCur] of string[48];

procedure initscroll;
const linelen=78;
begin
   assign(sfile,SPLAB32DIR+'SPANOUT.TXT');
   rewrite(sfile);
end;

procedure sprint(ss:string);
begin
  write(sfile,ss);
end;

procedure sprintln;
begin
 writeln(sfile);
end;

procedure closescroll;
begin
  close(sfile);
end;

function afunc(ix,i:integer):real;
var j,k:integer;
    af:real;
begin
 if i>nstandards then begin
     af:=1;
     k:=i-nstandards-1;
     if k>0 then for j:=1 to k do af:=af*ix;
     afunc:=af
  end else
     if (basecomp)and(usenew[i]) then afunc:=newstandard[i]^[ix]
        else afunc:=standard[i]^[ix]
end;

{
function afunc(ix,i:integer):extended;
var j:integer;
begin
  if ((i<1)or(i>Mfit)) then
       afunc:=0
  else
   if (i<=(polyorder+1)) then
     if i=1 then
       powx:=1
     else powx:=powx*ix
  else
    pull(powx,lista[i-polyorder-1],true,ix);
  afunc:=powx
end;
}


function lfit(var y,w:xydata;ndata:integer;var a:partype;ma:integer;
               lista:inarr;mfit:integer;var covar:mtype;var rho:real;
               savefit:boolean):boolean;
{  y - Y-axis,
   w - weight,
   ndata - number of points,
   a - fitting results?
   ma - number of standards (+1??)
   lista: array with standards' locations ?
   mfit: total number of parameters: number of standards+polyorder+1 ?
   covar: covar matrix;
   rho: sq.corr.coef;
   savefit: save fit switch
}
var k,kk,j,ihit,i:integer;
    my,sy,ym,tmp,sum,wt:real;
    beta:partype;
    erro:boolean;
begin
  lfit:=false;
  kk:=mfit+1;

  for j:=1 to ma do begin
    ihit:=0;
    for k:=1 to mfit do
      if lista[k]=j then inc(ihit);
    if ihit=0 then begin lista[kk]:=j; inc(kk) end
      else if ihit>1 then begin
        cray('Bad LISTA permutation in LFIT#1');
        exit
      end
  end;
  if kk<>(ma+1) then begin
        cray('Bad LISTA permutation in LFIT#2');
        exit
  end;
  for j:=1 to mfit do begin
    for k:=1 to mfit+1 do covar[J,K]:=0;
  end;
 {
  i0:=1;i9:=ndata;
  if offst<0 then i0:=abs(offst)+1 else i9:=ndata-offst;
  ndata:=ndata-abs(offst);
  for i:=i0 to i9 do begin
     pull(ym,iy,true,i);
     ii:=i+offst;
     for j:=1 to mfit do begin
       wt:=afunc(ii,j);
       if iw>=mincur then begin
          pull(tmp,iw,true,ii);wt:=wt*tmp
       end;
       for k:=1 to j do covar[j,k]:=covar[j,k]+wt*afunc(ii,k);
       covar[j,mfit+1]:=covar[j,mfit+1]+ym*wt
     end
   end;
   if mfit>1 then
     for j:=2 to mfit do for k:=1 to j-1 do covar[k,j]:=covar[j,k];
   gauss(covar,mfit,lfitparm,erro);
 }


  for i:=1 to ndata do begin
     ym:=y[i];
     if mfit<ma then
       for j:=mfit+1 to ma do
         ym:=ym-a[lista[j]]*afunc(i,lista[j]);
     for j:=1 to mfit do begin
       wt:=afunc(i,lista[j])*w[i];
       for k:=1 to j do covar[j,k]:=covar[j,k]+wt*afunc(i,lista[k]);
       covar[j,mfit+1]:=covar[j,mfit+1]+ym*wt
     end
   end;
   if mfit>1 then
     for j:=2 to mfit do
       for k:=1 to j-1 do covar[k,j]:=covar[j,k];
   gauss(covar,mfit,beta,erro);
   if erro then begin
        cray('LFIT: Matrix is singular');
        exit
   end;
   for  j:=1 to mfit do a[lista[j]]:=beta[j];
   my:=0;
   for i:=1 to ndata do my:=my+y[i];
   my:=my/ndata;
   sy:=0;
   rho:=0;
   for i:=1 to ndata do begin
      sum:=0;
      for j:=1 to ma do begin
        tmp:=a[j]*afunc(i,j);
        sum:=sum+tmp;
      end;
      if savefit then vecc[0]^[i]:=sum;
      tmp:=(y[i]-sum);
      rho:=rho+tmp*tmp;
      tmp:=(y[i]-my);
      sy:=sy+tmp*tmp;
   end;
   if sy<>0 then rho:=1-rho/sy else rho:=1;
   lfit:=true
end;

function Yintercept(n:integer;var wav:real):real;
var i:integer;
begin
  if (n=0)or(n>maxcur)or(ddir[n].npts=0) then begin
    Yintercept:=0;
    Wav:=0
   end else begin
     i:=0;
     repeat
      inc(i)
     until (i>=ddir[n].npts)or(pull(n,false,i)>=wav);
     Yintercept:=pull(n,true,i);
     wav:=pull(n,false,i)
   end
end;

function fread(var ss:string;var ok:boolean):real;
var i,err:integer;
    ss1:string;
    a:real;
begin
  i:=1;
  ok:=false;
  ss1:=next(ss,',');
  while not(ss1[i] in ['0'..'9','.','+','-','E'])and(i<length(ss1)) do inc(i);
  delete(ss1,1,i-1);
  i:=1;
  while (i<=length(ss1))and(ss1[i] in ['0'..'9','.','+','-','E']) do inc(i);
  ss1:=copy(ss1,1,i-1);
  val(ss1,a,err);
  fread:=a;
  ok:=(err=0)
end;

function AllocateStandards(n:integer):boolean;
var i,l:integer;
begin
  AllocateStandards:=false;
  l:=LenSpec*Sizeof(single);
  lenstandards:=LenSpec;
  for i:=1 to n do begin
      getmem(Standard[i],l);
      getmem(NewStandard[i],l)
  end;
  NStandards:=n;
  AllocateStandards:=true;
end;

procedure FreeStandards;
var i,l:integer;
begin
  if NStandards=0 then exit;
  l:=LenStandards*Sizeof(single);
  for i:=1 to NStandards do begin
     freemem(Standard[i],l);
     freemem(NewStandard[i],l);
  end;
  NStandards:=0;
end;

function xaxis(w0,dW:real;i:integer):real;
begin
   xaxis:=W0+dW*(i-1);
end;

function readstandards:boolean;
var i,n,k:integer;
    a,x,xcalc:real;
    ok:boolean;
begin
  readstandards:=false;
  if not(regular) then exit;
  if pos('\',tabname)=0 then tabname:=SPLAB32DIR+'STANDARDS\'+tabname;
  if pos('.',tabname)=0 then tabname:=tabname+'.ASC';
  assign(dfile,tabname);
  reset(dfile);
  if ioresult<>0 then exit;
  readln(dfile,convstr);
  if ioresult<>0 then exit;
  n:=0;
  next(convstr,',');
  cut(convstr,' ');
  if pos('"',convstr)=1 then begin
   n:=1;
   while pos(',"',convstr)<>0 do begin
    i:=pos(',"',convstr);
    delete(convstr,i,1);
    inc(n)
   end;
  end;
  for i:=1 to n do begin
    cut(convstr,'"');
    stanhead[i]:=next(convstr,'"');
  end;
  if n>9 then n:=9;
  if n=0 then exit;
  if (n<>NStandards)or(LenSpec<>LenStandards) then begin
    freestandards;
    if not(AllocateStandards(n)) then exit;
  end;
  say('Loading standards. Wait...');
  i:=1;
  repeat
    xcalc:=xaxis(WlOrigin,DeltaWl,i);
    repeat
      readln(dfile,convstr);
      if (ioresult<>0)or(eof(dfile)) then begin
         freestandards;
         close(dfile);
         say('');
         exit
      end;
      x:=fread(convstr,ok);
    until (ok)and(x=xcalc);
    if (x=xcalc) then begin
     for k:=1 to nstandards do begin
      a:=fread(convstr,ok);
      if ok then
         standard[k]^[i]:=a
      else begin
          freestandards;
          close(dfile);
          say('');
          exit
      end;
     end;
     inc(i);
    end;
  until (xcalc>=WlEnd)or(EOF(dfile));
  WlEnd:=xaxis(WlOrigin,DeltaWl,i-1);
  if stanhead[nstandards]='Weight' then begin
    for i:=1 to lenspec do sig^[i]:=standard[nstandards]^[i];
     freemem(Standard[nstandards],lenspec*sizeof(single));
     freemem(NewStandard[nstandards],lenspec*sizeof(single));
     dec(nstandards)
    end
  else
    for i:=1 to lenspec do sig^[i]:=1;
  say('');
  close(dfile);
  readstandards:=true;
end;

function ReadSpanPar:boolean;
var i:integer;sss:string;

function cutitle(ss:string):string;
var i:integer;
begin
 i:=pos('::',ss);
 if i<>0 then delete(ss,1,i+1);
 cut(ss,' ');
 cutitle:=ss;
end;

begin
  readspanpar:=false;
  assign(dfile,SPLAB32DIR+'SPANPAR.PRM');
  reset(dfile);
  if ioresult<>0 then exit;
  readln(dfile,sss);
  if ioresult<>0 then exit;
  tabname:=cutitle(sss);
  readln(dfile,sss);
  if ioresult<>0 then exit;
  sss:=cutitle(sss);
  val(sss,rrd,i);
  if i<>0 then rrd:=1 else if rrd<0 then rrd:=0 else if rrd>1 then rrd:=1;
  readln(dfile,sss);
  if ioresult<>0 then exit;
  sss:=cutitle(sss);
  val(sss,rho2thresh,i);
  if i<>0 then rho2thresh:=0.5 else
     if rho2thresh<0 then rho2thresh:=0 else if rho2thresh>1 then rho2thresh:=1;
  readln(dfile,sss);
  if ioresult<>0 then exit;
  sss:=cutitle(sss);
  val(sss,MaxNr,i);
  if i<>0 then MaxNr:=3 else
    if MaxNr<1 then MaxNr:=1 else if MaxNr>5 then MaxNr:=1;
  readln(dfile,sss);
  if ioresult<>0 then exit;
  sss:=cutitle(sss);
  elimibad:=not((sss='0')or(sss='')or(sss[1]='N'));
  readln(dfile,sss);
  if ioresult<>0 then polyorder:=0 else begin
     sss:=cutitle(sss);
     val(sss,polyorder,i);
     if i<>0 then polyorder:=0 else
       if polyorder>3 then polyorder:=3 else if polyorder<0 then polyorder:=0
  end;
  close(dfile);
  readspanpar:=true
end;

function WriteSpanPar:boolean;
begin
  writespanpar:=false;
  assign(dfile,SPLAB32DIR+'SPANPAR.PRM');
  rewrite(dfile);
  if ioresult<>0 then exit;
  writeln(dfile,'Standards file name       ::  ',tabname);
  if ioresult<>0 then exit;
  writeln(dfile,'Threshold for standards   :: ',rrd:9:6);
  if ioresult<>0 then exit;
  writeln(dfile,'Threshold for components  :: ',rho2thresh:9:6);
  if ioresult<>0 then exit;
  writeln(dfile,'Max. number of components :: ',MaxNr:2);
  if ioresult<>0 then exit;
  write(dfile,'Ignore bad standards      ::  ');
  if elimibad then writeln(dfile,'Y') else writeln(dfile,'N');
  if ioresult<>0 then exit;
  writeln(dfile,'Order of polynomial       :: ',polyorder:2);
  close(dfile);
  writespanpar:=true
end;


function SpanInit:boolean;
var i,j,k:integer;
    wl,tmp,tmpy:real;
label 1;
begin
  SpanInit:=false;
  curoff;
 { ClearMemory; }
  if not(ReadAll(sysname)) then exit;
  if not(ReadSpanPar) then begin
     tabname:='STANDARD';
     rrd:=1.0;
     rho2thresh:=0.5;
     MaxNr:=3;
     polyorder:=0;
     ElimiBad:=false;
   end;
   NStandards:=0;LenStandards:=0;
   i:=0;
   while (ddir[i].npts=0)and(i<=maxcur) do inc(i);
   if firsttime then begin
     ifirst:=i;
     if i>maxcur then begin
        cray('Nothing to do - memory is empty');
        exit
     end;
(*     for k:=1 to ddir[i].npts do begin
       Wl0:=pull(i,false,k);
     end;  *)
     Wl0:=pull(i,false,1);
     Wl9:=pull(i,false,ddir[i].npts);
     WlOrigin:=Wl0;
     WlEnd:=Wl9;
     DeltaWl0:=pull(i,false,2)-WlOrigin;
     DeltaWl:=DeltaWl0;
     regular:=abs((WlEnd-WlOrigin)/(ddir[i].npts-1)-DeltaWl)<1E-6;
     firsttime:=false
   end else begin
    Yintercept(i,WlOrigin);
    Yintercept(i,Wlend);
   end;
   if regular then begin
     lenspec:=round((WlEnd-WlOrigin)/DeltaWl);
     lenspec:=lenspec+1
   end else lenspec:=ddir[ifirst].npts;
   ncur:=0;
   GetMem(Rpr[0],lenspec*sizeof(single));
   for i:=1 to maxcur do with ddir[i] do if npts>1 then begin
       inc(ncur);
       GetMem(Rpr[ncur],lenspec*sizeof(single));
       wl:=WlOrigin;
       j:=0;
       while (wl<=WlEnd)and(j<lenspec) do begin
         inc(j);
         tmp:=wl;
         tmpy:=yintercept(i,tmp);
         rpr[ncur]^[j]:=tmpy;
         if abs(tmp-wl)>1E-6 then begin
          if ncur<3 then begin
            cray('Bad data set');
            exit;
          end;
          FreeMem(Rpr[ncur],lenspec*sizeof(single));
          dec(ncur);
          goto 1
         end;
         rpr[ncur]^[j]:=tmpy;
         zloc[ncur]:=ddir[i].z;
         if (regular)or(j=lenspec) then wl:=Wl+DeltaWl else wl:=pull(ifirst,false, j+1);
       end;
       if j<>lenspec then begin
            cray('Bad wavelength boundaries');
            exit;
       end;
   end;
1:   Getmem(sig,lenspec*sizeof(single));
   for i:=1 to lenspec do sig^[i]:=1;
   for i:=1 to maxcur do lista[i]:=i;
   if not(readstandards) then tabname:='';
   SpanInit:=true;
end;

procedure SpanEmpty;
var i:integer;
begin
  FreeMem(sig,lenspec*sizeof(single));
  if datafitted then
    for i:=0 to nr do FreeMem(vecc[i],lenspec*sizeof(single));
  for i:=0 to ncur do FreeMem(Rpr[i],lenspec*sizeof(single));
  Datafitted:=false;
end;


Procedure SetResHead;
var i:integer;
    ss:string;
begin
  prhead[0]:='Fitted sp.1';
  for i:=1 to nr do begin
          str(i:2,ss);
          cut(ss,' ');
          prhead[i]:='Vector #'+ss;
  end;
end;


Procedure SetDatHead;
var i:integer;
    ss:string;
begin
  for i:=1 to ncur do begin
          str(i:2,ss);
          cut(ss,' ');
          prhead[i]:='#'+ss+'(P=';
          str(zloc[i]:7:1,ss);
          cut(ss,' ');
          prhead[i]:=prhead[i]+ss+')';
  end;
end;

procedure CalcVector(var gam:alfatype;var v,r:rdata);
var j,k:integer;
begin
   for j:=1 to lenspec do begin
     v^[j]:=gam[0]*r^[j];
     for k:=1 to nr do
       v^[j]:=v^[j]+gam[k]*vecc[k]^[j];
   end;
end;

procedure SprintDecResults;
   var i,j,k,nsignificant:integer;
       a,s0,totlam:real;
       ss:string;
begin
           sprint
('—————————————————————————————————————————————————————————————————————————————');
           sprintln;
           sprint
('              •••••••   Principal Component Analysis   •••••••              ');
           sprintln;
           sprint
('—————————————————————————————————————————————————————————————————————————————');
           sprintln;
           sprintln;
           ss:=DateTimeToStr(Date);
           sprint(ss);
           sprintln;
           sprint(SaveComment);
           sprintln;
           i:=1;
           while(ddir[i].head='')and(i<maxcur) do inc(i);
           if ddir[i].head<>'' then sprint(ddir[i].head);
           sprintln;
           sprintln;
           sprint('Parameters were set as follows:');
           sprintln;
           str(WlOrigin:3:0,ss);
           ss:='Lower wavelength bound.:'+ss;
           sprint(ss);
           sprintln;
           str(WlEnd:3:0,ss);
           ss:='Upper wavelength bound.:'+ss;
           sprint(ss);
           sprintln;
           str(DeltaWl:3:1,ss);
           ss:='Wavelength step:'+ss;
           sprint(ss);
           sprintln;
           str(MaxNr:2,ss);
           ss:='Max number of components:'+ss;
           sprint(ss);
           sprintln;
           ss:='File of standards:'+tabname;
           sprint(ss);
           sprintln;
           sprint('Order of background correction polynomial: '+char(48+polyorder));
           sprintln;
           str(rrd:8:6,ss);
           sprint('Threshold of corr.coeff. to accept the fitting of standard: '+ss);
           sprintln;
           if (PartCalc)and(PartSwitch) then begin
             str(rho2thresh:8:6,ss);
             sprint('Thresh. of corr.coeff. to take the component into account:'+ss);
             sprintln;
           end;
           if (elimibad) and (nbad>0) then begin
             sprint('Concentrations of poorly fitted compounds were fixed');
             sprintln
           end;
           sprintln;
           str(nr:2,ss);
           sprint(ss+' Principal components were found');
           sprintln;
           str(ssd1/ssd:8:4,ss);
           sprint(ss+' of total SSD were covered');
           sprintln;
           Sprint
('================== Fitting of standars by principal vectors ==================');
          Sprintln;
          Sprint('•—————');
          for i:=1 to Nstandards do sprint('•————————————');
          sprint('•——————————•');
          sprintln;
          sprint('¦Vect.¦');
          for i:=1 to Nstandards do sprint('   Std. '+char(i+48)+'   ¦');
          sprint('          ¦');
          sprintln;
          sprint('¦  #  ¦');
          for i:=1 to Nstandards do begin
            ss:=copy(stanhead[i],1,12);
            k:=(12-length(ss)) div 2;
            for j:=1 to k do ss:=' '+ss;
            while (length(ss)<12) do ss:=ss+' ';
            ss:=ss+'¦';
            sprint(ss);
          end;
          sprint('Contrib.,%¦');
          sprintln;
          sprint('¦     ¦');
          for i:=1 to Nstandards do begin
            str(jb[i]:2,ss);
            sprint('Based on #'+ss+'¦')
          end;
          sprint('          ¦');
          sprintln;
          Sprint('•—————');
          for i:=1 to Nstandards do sprint('•————————————');
          sprint('•——————————•');
          sprintln;
          for i:=0 to nr do begin
            if i=0 then sprint ('¦ Base¦') else sprint('¦  '+char(48+i)+'  ¦');
            for j:=1 to nstandards do begin
              str(gamma[j][i]:12:6,ss);
              ss:=ss+'¦';
              sprint(ss);
            end;
            if (i>0)and(ssd<>0) then
                str(100*lambda[i]:7:2,ss)
            else ss:='';
            while length(ss)<10 do ss:=ss+' ';
            ss:=ss+'¦';
            sprint(ss);
            sprintln;
          end;
          sprint('¦C.Cor¦');
          for j:=1 to nstandards do begin
              str(rho[j]:12:6,ss);
              ss:=ss+'¦';
              sprint(ss);
          end;
          sprint('          ¦');
          sprintln;
          Sprint('•—————');
          for i:=1 to Nstandards do sprint('•————————————');
          sprint('•——————————•');
          sprintln;
          sprintln;
          if not(PartCalc) then exit;
          Sprint
('===================== Fitting of principal vectors by standards ==============');
          Sprintln;
          Sprint('•—————•');
          for i:=1 to Nstandards+polyorder+3 do sprint('————————•');
          sprintln;
          sprint('¦Vect.¦');
          for i:=1 to Nstandards do sprint('Stand. '+char(i+48)+'¦');
          for i:=1 to 2 do  sprint('        ¦');
          if polyorder=0 then ss:='' else ss:='Polynomial';
          k:=((polyorder+1)*9-length(ss)) div 2;
          for j:=1 to k do ss:=' '+ss;
          while (length(ss)<((polyorder+1)*9-1)) do ss:=ss+' ';
          ss:=ss+'¦';
          sprint(ss);
          sprintln;
          sprint('¦  #  ¦');
          for i:=1 to Nstandards do begin
            ss:=copy(stanhead[i],1,10);
            k:=(8-length(ss)) div 2;
            for j:=1 to k do ss:=' '+ss;
            while (length(ss)<8) do ss:=ss+' ';
            ss:=ss+'¦';
            sprint(ss);
          end;
          sprint(' Total  ¦');
          sprint(' C.Corr.¦');
          sprint(' Offset ¦');
          if polyorder>0 then for i:=1 to polyorder do begin
            ss:='  A('+char(i+48)+')  ¦';
            sprint(ss)
          end;
          sprintln;
          Sprint('•—————•');
          for i:=1 to Nstandards+polyorder+3 do sprint('————————•');
          sprintln;
          for i:=0 to nr do begin
            if i=0 then sprint ('¦ Base¦') else sprint('¦  '+char(48+i)+'  ¦');
            S0:=0;
            for j:=1 to nstandards do begin
              a:=matrx[i][j];
              str(a:8:4,ss);
              s0:=s0+a;
              ss:=ss+'¦';
              sprint(ss);
            end;
            str(s0:8:4,ss);
            ss:=ss+'¦';
            sprint(ss);
            str(rho2[i]:8:4,ss);
            ss:=ss+'¦';
            sprint(ss);
            for j:=nstandards+1 to nstandards+polyorder+1 do begin
              a:=matrx[i][j];
              str(a:8:4,ss);
              ss:=ss+'¦';
              sprint(ss);
            end;
            sprintln;
          end;
          Sprint('•—————•');
          for i:=1 to Nstandards+polyorder+3 do sprint('————————•');
          sprintln;
          nsignificant:=0;
          totlam:=0;
          for i:=1 to nr do
            if rho2[i]>rho2thresh then begin
              inc(nsignificant);
              totlam:=totlam+sqrt(lambda[i]*mw[i]);
            end;
          sprintln;
          str(nsignificant:2,ss);
          Sprint('Number of significant components:'+ss);
          sprintln;
          sprint('The following components are significant:');
          sprintln;
          Sprint('                    ');
          Sprint('•—————•————————————•————————————•');
          sprintln;
          Sprint('                    ');
          sprint('¦ No. ¦Fr. of molar¦Correlation ¦');
          sprintln;
          Sprint('                    ');
          sprint('¦     ¦ changes, % ¦coefficient ¦');
          sprintln;
          Sprint('                    ');
          Sprint('•—————•————————————•————————————•');
          sprintln;
          for i:=1 to nr do
            if rho2[i]>rho2thresh then begin
              str(i:3,ss);
              Sprint('                    ');
              sprint('¦ '+ss+' ¦');
              a:=sqrt(lambda[i]*mw[i])*100/totlam;
              str(a:11:6,ss);
              sprint(ss+' ¦');
              str(rho2[i]:11:6,ss);
              sprint(ss+' ¦');
              sprintln;
            end;
            Sprint('                    ');
            Sprint('•—————•————————————•————————————•');
            sprintln
end;

function decompose:boolean;
var i,j,k,jj,l2,jbest,ncurr:integer;
    setbad:set of byte;
    check:boolean;
    emptymem:pointer;
    ssd0,wl,S0,S1,S2,total,rhobest,d,plus,minus:real;
  (*  ste:text;  *)
label abort0;
begin  (* Decompose itself *)
  decompose:=false;
  if not(DataFitted) then begin
    k:=maxnr+1;
    mainv(ncur,lenspec,rpr,vecc,lambda,nr,check,ssd1,ssd,1,MaxNr);  (*rrd!*)
    if ssd<>0 then for i:=1 to nr do lambda[i]:=(lambda[i]/ssd);
    if not(check) then begin cray('Memory allocation error'); exit end;
    alf[0][0]:=1;
    alf[1][0]:=1;
    for i:=1 to nr do alf[1][i]:=0;
    for i:=2 to ncur do begin
      alf[i][0]:=1;
      compute_alfa(rpr[i],rpr[i-1],alf[i],lenspec,nr,vecc);
    end;
  end;
(* Change sign of eig.vectors and eig.spectra to have positive deriv. at 0*)
  l2:=ncur div 2;
  for i:=1 to nr do  begin
    if l2>0 then begin
         d:=0;
         for j:=2 to l2+1 do d:=d+alf[j][i]
    end else d:=0;
    if d<0 then begin
      for j:=1 to ncur do alf[j][i]:=-alf[j][i];
      for j:=1 to lenspec do vecc[i]^[j]:=-vecc[i]^[j];
    end
  end;
(*************************Fit standards by eigenspectra********************)
  if Nstandards>0 then begin
    basecomp:=false;
    for i:=1 to Nstandards do begin
      lfit(rpr[i]^,sig^,lenspec,beta,nstandards+1,
               lista,nstandards+1,covar,rho2[0],true);     (*no polynomial while fitting standards *)
      total:=0;
      for j:=1 to nstandards do total:=total+beta[j];
      if total<>0 then total:=1/total else total:=1;
      gamma[i][0]:=total;
      rhobest:=0;jbest:=1;
      S0:=0;
      for j:=1 to lenspec do S0:=S0+standard[i]^[j];
      S0:=S0/lenspec;
      for j:=1 to ncur do begin
        compute_alfa(standard[i],rpr[j],gamma[i],lenspec,nr,vecc);
        CalcVector(gamma[i],NewStandard[i],rpr[j]);
        S1:=0;S2:=0;
        for jj:=1 to lenspec do begin
            S1:=S1+sqr(standard[i]^[jj]-NewStandard[i]^[jj]);
            S2:=S2+sqr(standard[i]^[jj]-S0)
        end;
        if S2<>0 then rho[i]:=1-S1/S2 else rho[i]:=1;
        if rho[i]>rhobest then begin
          rhobest:=rho[i];
          jbest:=j
        end
      end;
      compute_alfa(standard[i],rpr[jbest],gamma[i],lenspec,nr,vecc);
      jb[i]:=jbest;
      CalcVector(gamma[i],NewStandard[i],rpr[jbest]);
      rho[i]:=rhobest;
      usenew[i]:=(rho[i]>=rrd);        (*!*)
    end;
    basecomp:=true;
    lfit(rpr[1]^,sig^,lenspec,beta,nstandards+polyorder+1,
             lista,nstandards+polyorder+1,covar,rho2[0],true);
    for j:=1 to nstandards+polyorder+1 do matrx[0,j]:=beta[j];
(* if switch "elimibad" is on, than we should exclude parameters
          with bad standards from the fitting *)
    setbad:=[];
    nbad:=0;
    for k:=1 to nstandards do
         if pos('*',stanhead[k])<>0 then begin
          setbad:=setbad+[k];
          inc(nbad)
         end;
    if elimibad then
        for k:=1 to nstandards do
         if not(usenew[k]) then begin
          setbad:=setbad+[k];
          inc(nbad)
         end;
    if nbad>0 then begin
          ncurr:=0;
          for k:=1 to nstandards+polyorder+2 do
            if (k in setbad) then begin
              ncurr:=ncurr+1;
              lista[nstandards+polyorder+1-nbad+ncurr]:=k;
            end else lista[k-ncurr]:=k;
          end;
    i:=0;
    for i:=1 to nr do begin
      if nbad>0 then
         for k:=1 to nstandards do if (k in setbad) then beta[k]:=0;
      lfit(vecc[i]^,sig^,lenspec,beta,nstandards+polyorder+1,
              lista,nstandards+polyorder+1-nbad,covar,rho2[i],false);
(*normalise eigenvectors on the concentrations*)
      plus:=0;minus:=0;
      for j:=1 to nstandards do
        if beta[j]>0 then plus:=plus+beta[j]
          else minus:=minus-beta[j];
      if minus+plus>0 then
           if (minus/(minus+plus)>0.2) then mw[i]:=minus else mw[i]:=plus
        else mw[i]:=1;
      for j:=1 to nstandards do gamma[j][i]:=gamma[j][i]*mw[i];
      for j:=1 to lenspec do vecc[i]^[j]:=vecc[i]^[j]/mw[i];
      for j:=1 to nstandards+polyorder+1 do matrx[i,j]:=beta[j]/mw[i];
      for j:=1 to ncur do alf[j][i]:=alf[j][i]*mw[i];
    end;
    if elimibad then for i:=1 to nstandards+polyorder+1 do lista[i]:=i;
    PartCalc:=true;
  end;
  decompose:=true
end;

Procedure SetNumHeads;
var i:integer;
begin
   for i:=1 to Nr do
     prhead[i]:='#'+char(i+48);
end;

Procedure SetDynHead(partitions:boolean);
var i:integer;
begin
  if Partitions then
    for i:=1 to NStandards do
     prhead[i]:='Dynamics of compound #'+char(i+48)+'('+stanhead[i]+')'
  else
   for i:=0 to Nr do begin
     str(i:2,prhead[i]);
     cutref(@prhead[i],' ');
     prhead[i]:='Dynamics of component #'+prhead[i];
   end;
end;

procedure calcdyn(stanum:integer;var dv:dynvector;partitions:boolean);
var i,j:integer;
begin
  if partitions then begin
   for j:=2 to Ncur do begin
     dv[j]:=0;
     for i:=1 to Nr do
       if rho2[i]>rho2thresh then dv[j]:=dv[j]
                           +matrx[i,stanum]*alf[j][i];
   end;
   dv[1]:=matrx[0,stanum];
  end else
  for j:=1 to ncur do dv[j]:=alf[j][stanum];
  for j:=2 to ncur do dv[j]:=dv[j]+dv[j-1];
end;

procedure clrloc(n:integer);
begin
(** Clear memory <n> **)
end;

procedure ClrMem_SavHead;
var i,j:integer;
begin
  for i:=1 to maxcur do
   with ddir[i] do begin
    for j:=1 to MaxBlock do
     if ref[j]<>nil then begin
      freemem(ref[j],DataMax*2*sizeof(single));  (* !! *)
      ref[j]:=nil
    end;
    npts:=0;
   end;
  n_locations_used:=0;
end;

procedure SaveResults;
var i,j,k,spwritten:integer;
    xx: real;
    ss,ss1:string;
    PSTR:Pchar;
begin
    comment:=savecomment;
(*    ClrMem_SavHead; *)
    spwritten:=0;
    for i:=1 to ncur  do begin
      for j:=1 to LenSpec do begin
        if regular then xx:=xaxis(WlOrigin,DeltaWl,j)
          else xx:=pull(ifirst,false,j);
        push(xx,i,false,j);
        push(rpr[i]^[j],i,true,j);
      end;
      ddir[i].inter:=false;
      ddir[i].connect:=true;
      inc(spwritten)
    end;
    for i:=1 to nr do begin
      inc(spwritten);
      for j:=1 to LenSpec do begin
        if regular then xx:=xaxis(WlOrigin,DeltaWl,j)
          else xx:=pull(ifirst,false,j);
        push(xx,spwritten,false,j);
        push(vecc[i]^[j],spwritten,true,j)
      end;
      ddir[spwritten].inter:=true;
      str(i:2,ss1);
      ss1:='Principal vector #'+ss1;
      if (ssd<>0)and(i>0) then begin
        str(100*lambda[i]:5:2,ss);
        cut(ss,' ');
        ss:=concat(' (',ss,'%)');
        ss1:=concat(ss1,ss);
        ddir[spwritten].head:=ss1;
      end;
    end;
    if NStandards>0 then
       for j:=1 to nstandards do if spwritten<maxcur then begin
        inc(spwritten);
        for i:=1 to lenspec do begin
          push(xaxis(WlOrigin,DeltaWl,i),spwritten,false,i);
          push(NewStandard[j]^[i],spwritten,true,i)
        end;
        str(rho[j]:6:4,ddir[spwritten].head);
        ddir[spwritten].head:=stanhead[j]+'('+ddir[spwritten].head+')';
        ddir[spwritten].connect:=true;
    end;
    k:=nr;
    SetDynHead(false);
    for j:=1 to k do if spwritten<maxcur then begin
     inc(spwritten);
     calcdyn(j,dynarray[j],false);
     for i:=1 to ncur do begin
      if zloc[i]<9999 then push(zloc[i],spwritten,false,i)
        else push(i,spwritten,false,i);
      push(dynarray[j][i],spwritten,true,i)
     end;
     ddir[spwritten].head:=prhead[j];
     ddir[spwritten].connect:=true;
    end;
    if (PartCalc)and(PartSwitch) then begin
      k:=Nstandards;
      SetDynHead(true);
      for j:=1 to k do if spwritten<maxcur then begin
        inc(spwritten);
        calcdyn(j,dynarray[j],true);
        for i:=1 to ncur do begin
         if zloc[i]<9999 then push(zloc[i],spwritten,false,i)
          else push(i,spwritten,false,i);
         push(dynarray[j][i],spwritten,true,i)
        end;
        ddir[spwritten].head:=prhead[j];
        ddir[spwritten].connect:=true;
      end;
      if spwritten<maxcur then begin
        inc(spwritten);
        for j:=1 to ncur do dynarray[0][j]:=0;
        for i:=1 to nstandards do
          for j:=1 to ncur do dynarray[0][j]:=dynarray[0][j]+dynarray[i][j];
        for i:=1 to ncur do begin
           if zloc[i]<9999 then push(zloc[i],spwritten,false,i)
             else push(i,spwritten,false,i);
           push(dynarray[0][i],spwritten,true,i)
        end;
        ddir[spwritten].head:='Total dynamics';
        ddir[spwritten].connect:=true;
      end;
    end;
    SaveAll(SysName);
    writespanpar;
{
    ss:=splab32dir+'WINBROWS.EXE '+ splab32dir+'SPANOUT.TXT'+#0;
    Pstr:=@ss[1];
    winexec(Pstr,0)
}    
end;

procedure ShowDecResults;
begin
              SetResHead;
              InitScroll;
              SprintDecResults;
              CloseScroll
end;

begin
  firsttime:=true;
{  StrCopy('Principal component analysis',WindowTitle);}
  InitWinCrt;
  obj:=1;
  say('Wait, please...');
  if not(restart) then exit;
{  reinit_df; }
{  for i:=1 to 80 do putattr(i,25,colr[14]);
  for i:=1 to 80 do putchar(i,25,' ');}

  DataFitted:=false;
(***********************************************)
  if not(SpanInit) then begin
     cray('Data transfer error');
     halt(255)
  end;
  clrscr;
(*  if ConfigSpanpar then begin *)

    partcalc:=false;
    PartSwitch:=(rho2thresh<1) and (tabname<>'');
    savaxis:=xyaxis;
    SaveComment:=Comment;
    Comment:='';
    say('');
    say('Principal component analysis in progress');
    ok:=true;
    if decompose then begin
     say('Wait,please...');
     if nstandards>0 then ShowDecResults;
     SaveResults
    end;
    DoneWinCrt;
end.

