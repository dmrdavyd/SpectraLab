{$H-}
unit SPL32_01;

interface

uses SPL32DEF,SPL32BASE,GRKERN32, Link2opti,matrix,optidef,SPL32STR,math;

const alphasize=1;
      measuring=false; (*!!*)
      AllCurves=false;
      OnlyThis=true;

procedure frame;
procedure setscl(locn:integer);
procedure putscl;
function replot(newscale,locn:longint):pointer; export; stdcall;
function plotlisted(var lista:inarr):pointer;  export; stdcall;
procedure minimaXY(curno:integer;ax, takeall :boolean); export; register;
function sort(ptptr,nset:longint):longint; export; stdcall;
function aitken(wm:integer;xi:real;i1,np:integer):real;
function mash(ax:boolean;x:real):integer;
function inscr(x,y:real):boolean;
procedure calcint(wm,dm:integer;step:real);
function ViewResults(showfit:longint):pointer; export; stdcall;

implementation
var l0,l9:integer;
    fnd:partype;
{  ============================================================= }


function sort(ptptr,nset:longint):longint;
var i,j,k,k1,jpk:integer;
    temp,temp1:single;
    xptr,yptr:single;
    ax:boolean;
begin
  with Spectra.dir(nset)^ do begin
   if ((ptptr>0) and (ptptr<=npts)) then begin
     pull(xptr,nset,FALSE,ptptr);
     pull(yptr,nset,TRUE,ptptr)
   end;
   if npts<=1 then begin result:=0; exit end;
   k:=1;
   while k<=npts do k:=k*2;
   k:=(k div 2)-1;
   repeat
    k1:=npts-k;
    for i:=1 to k1 do begin
      j:=i;jpk:=j+k;
      repeat
       pull(temp,nset,FALSE,j);pull(temp1,nset,FALSE,jpk);
       if temp>temp1 then
        for ax:=false to true do begin
          pull(temp,nset,ax,j);
          pull(temp1,nset,ax,jpk);
          push(temp1,nset,ax,j);
          push(temp,nset,ax,jpk)
        end else j:=1;
       jpk:=j;j:=j-k;
      until j<1
    end;
    k:=k div 2
   until k=0;
   if ((ptptr>0) and (ptptr<=npts)) then begin
     jpk:=0;
     repeat
       inc(jpk);
       pull(temp,nset,FALSE,jpk);
       pull(temp1,nset,TRUE,jpk)
     until ((temp=xptr)and(temp1=yptr))or(jpk=npts);
     result:=jpk;
   end else result:=-1;
 end (* with ddir *);
end (* sort *);

procedure minimaXY(curno:integer; ax,takeall :boolean);export; register;
var j:integer;
    bgn,regularx:boolean;
    tmp,tmp1,dx,dx1:single;
begin
   with xyaxis[ax]^ do
      with Spectra.dir(curno)^ do if npts>0 then begin
       if ax then begin
         j:=0;repeat inc(j) until pull(tmp,curno,false,j)and(takeall or(tmp>=xyaxis[false]^.off));
         j:=1;
         bgn:=true;
         while (pull(tmp,curno,false,j)and(takeall or (tmp<=xyaxis[false]^.lim))) do begin
          pull(tmp,curno,true,j);
          if bgn then begin max[true]:=tmp; min[true]:=tmp; bgn:=false end else begin
            if (tmp>max[true]) then max[true]:=tmp else
              if (tmp<min[true]) then min[true]:=tmp;
          end;
          inc(j)
         end
       end else begin
         pull(min[false],curno,false,1);
         pull(max[false],curno,false,npts);
         stepx:=0;
         regularx:=(npts>2);
         j:=0;
         while regularx and (j<npts) do begin
           inc(j);
           pull(tmp1,curno,false,j);
           if j>1 then begin
             dx1:=tmp1-tmp;
             if j>2 then regularx:=(abs(dx1-dx)=0){<1E-9)};
           end;
           dx:=dx1;tmp:=tmp1
         end;
         if regularx then stepx:=dx;
{            if (dx>1E-4)and(dx<=2147) then stepx:=round(dx*1E6) else stepx:=2147483647;}
       end;
     end (* with  *)
end;

{ ========================================================================== }

function mash(ax:boolean;x:real):integer;
var tmp:single;
begin
     tmp:=x-xyaxis[ax]^.off;
     mash:=trunc(tmp*xyaxis[ax]^.factor)
end;

function inscr(x,y:real):boolean;
var t,ax:boolean;v:real;
begin
  t:=true;
  for ax:=false to true do begin
     if ax then v:=y else v:=x;
     t:=t and (v>=xyaxis[ax]^.off);
     t:=t and (v<=xyaxis[ax]^.lim);
     grap.dest[ax]:=corner[ax]+mash(ax,v)
   end;
   inscr:=t
end;

procedure setscl(locn:integer);
var ax,t,quitloop:boolean;
    i,j,k,l,m:integer;z1,len,normlen,step,flen:real;
    convstr:string;
begin
  if locn<0 then begin l0:=1;l9:=maxcur end else begin l0:=locn;l9:=locn end;
  i:=l0;
  repeat
    if (Spectra.dir(i)^.npts>0)
      and((l0=l9)or((Spectra.dir(i)^.plotcolor and $F0)=0)) then sort(0,i);
    inc(i)
  until (i>l9);
  for ax:=false to true do with xyaxis[ax]^ do begin
    if auto<>0 then begin
     t:=true;
     i:=l0;
     repeat
      if (Spectra.dir(i)^.npts>0)
       and((l0=l9)or((Spectra.dir(i)^.plotcolor and $F0)=0)) then begin
        minimaXY(i,ax,true);
        if t or(Spectra.dir(i)^.min[ax]<off) then off:=Spectra.dir(i)^.min[ax];
        if t or(Spectra.dir(i)^.max[ax]>lim) then lim:=Spectra.dir(i)^.max[ax];
        if off=lim then begin
         off:=off-1;
         lim:=lim+1;
        end;
        t:=false
      end;
      inc(i)
     until (i>l9)
    end (* if auto *);
    repeat
      len:=lim-off;
      if len<1E-6 then len:=1E-6;
      normlen:=1;step:=abs(len);if abs(len)<1 then flen:=10 else flen:=0.1;
      while (step<1)or(step>=10) do step:=step*flen;
      normlen:=abs(len/step);
      if step<1.5 then step:=0.25 else
        if step<3 then step:=0.5 else
          if step<6 then step:=1
      else step:=2;
      Z1:=off/normlen;
      if lim*off<0 then begin
        scaling[1]:=0;
        while scaling[1]>z1 do scaling[1]:=scaling[1]-step;
      end else begin
         scaling[1]:=int(z1);
         if (z1<0)and(frac(z1)<>0) then scaling[1]:=scaling[1]-1;
      end;
      scaling[1]:=normlen*scaling[1];
      step:=step*normlen;
      quitloop:=true;
      if (auto<>0) and (off<>scaling[1]) and ((off-scaling[1])<(0.25*step))
      then begin
         off:=scaling[1];
         quitloop:=false
      end else
         while scaling[1]<off do scaling[1]:=scaling[1]+step;
    until quitloop;
    nscaling:=1;
    repeat
     nscaling:=nscaling+1;
     scaling[nscaling]:=scaling[nscaling-1]+step
    until scaling[nscaling]>=lim;
    if (auto<>0)and((scaling[nscaling]-lim)<(0.25*step)) then
    lim:=scaling[nscaling];
    if scaling[nscaling]>lim then nscaling:=nscaling-1;
    for i:=1 to nscaling do if (scaling[i]<1E5)and(scaling[i]>-1E4) then
    begin
     if scaling[i]=0 then scs[i]:='0' else begin
      if step<0.01 then str(scaling[i]:10:4,convstr) else
       if step<0.1 then str(scaling[i]:10:3,convstr) else
        if step<1 then str(scaling[i]:9:2,convstr) else
          if step<10 then str(scaling[i]:8:1,convstr) else
            str(round(scaling[i]):6,convstr);
      cut(convstr,' ');
      scs[i]:=convstr
     end;
     while length(scs[i])>6 do delete(scs[i],length(scs[i]),1);
    end else scs[i]:='######';
    factor:=(npixel[ax]-1)/(lim-off);
   end (* with *);
 end (* setscl *);

procedure putscl;
var i,j,k,l,m,offs,lenscs,lastpix,shift,m2:integer;ax,c,nax:boolean; label 101;
begin
  for ax:=false to true do with xyaxis[ax]^ do begin
    if ax then nax:=false else nax:=true;
    grap.size:=alphasize;
    if ax then grap.slope:=6 else grap.slope:=0;
    if token<>'' then begin
     repeat
      offs:=(npixel[ax]-length(token)*8);
      if offs>=0 then goto 101;
      delete(token,l,1)
     until false;
101: if ax then begin grap.dest[ox]:=corner[ox]; grap.dest[oy]:=corner[oy]+npixel[oy]+16 end
       else begin grap.dest[ox]:=corner[ox]+(offs div 2)+1;grap.dest[oy]:=corner[oy]-20*grap.size end;
    gra(0);
    grap.wstr:=token;
    gra(5);
   end (*if token *);
   if ax then l:=corner[ax]-4*grap.size else l:=0;
    shift:=4*grap.size;
    lastpix:=npixel[ax]+corner[ax]-1;
    for i:=1 to nscaling do begin
      grap.wstr:=scs[i];
      j:=corner[ax]+mash(ax,scaling[i]);
      lenscs:=length(scs[i]);
      if ax then begin
         k:=j+7*grap.size;
         if k>lastpix then k:=lastpix;
         m:=k;
         shift:=(lenscs+1)*7*grap.size;
      end else begin
         k:=j-4*lenscs*grap.size;
         m:=k+8*(lenscs-1)*grap.size;
         if m>lastpix then begin
           k:=lastpix-lenscs*8+2;
           m:=lastpix
         end;
      end;
      if k>l then begin
        grap.dest [ax]:=k;
        grap.dest[nax]:=corner[nax]-shift;
        gra(0);
        gra(5);
        l:=m+10*grap.size
      end;
      if (j<>corner[ax])and(j<>lastpix) then begin
        grap.dest[ax]:=j;
        grap.dest[nax]:=corner[nax];
        gra(0);
        if ax then grap.vcode:=2 else grap.vcode:=0;
        grap.vlen:=3*grap.size;
        gra(2);
        grap.dest[nax]:=corner[nax]+npixel[nax]-4;
        gra(0);
        gra(2)
     end;
     if (ax) and (l0=0) and (l9=0) and inscr(xyaxis[false].off,0) then begin
          gra(0);
          grap.vcode:=2;
          grap.vlen:=npixel[nax]-1;
          gra(2)
     end
   end
 end;
end;

procedure frame;
var ax:boolean;
begin
  for ax:=false to true do grap.dest[ax]:=corner[ax];
  gra(0);
  grap.vcode:=2;grap.vlen:=npixel[false]-1;gra(2);
  grap.vcode:=0;grap.vlen:=npixel[true]-1;gra(2);
  grap.vcode:=6;grap.vlen:=npixel[false]-1;gra(2);
  grap.vcode:=4;grap.vlen:=npixel[true]-1;gra(2)
end;

function aitken(wm:integer;xi:real;i1,np:integer):real;
var p,u:array [1..5] of single;
    np1,i,ip1,j:integer;
    a,uxi:real;
begin
 with Spectra.dir(wm)^ do begin
  if np>4 then np:=4;
  iF (NP+1)>npts then NP:=Npts-1;
  IF I1<=0 then i1:=1;
  IF (I1+NP)>npts then I1:=npts-NP;
  NP1:=NP+1;
  for I:=1 to NP1 do begin
    J:=I1+I-1;
    pull(u[i],wm,false,j);
    pull(p[i],wm,true,j)
  end;
  for I:=1 to NP do begin
   UXI:=U[I]-XI;
   IP1:=I+1;
   for  J:=IP1 to NP1 do begin
    a:=U[j]-U[i];
    if a<>0 then
      P[J]:=(P[I]*(U[J]-XI)-P[J]*UXI)/(U[J]-U[I])
       else p[j]:=0;
   end
  end;
  aitken:=p[np1]
 end
end;

procedure putint(wm,ix:integer);
var i0,ixdest,i:integer;
    step,x1,y1:single;
begin
  if ix<=1 then exit;
  if grap.axis[false]=grap.dest[false] then begin
    gra(3);exit
  end;
  step:=1/xyaxis[false]^.factor;
  with Spectra.dir(wm)^ do begin
   ixdest:=grap.dest[false];
   i0:=grap.axis[false];
   pull(x1,wm,false,ix-1);
   for i:=i0 to ixdest do begin
     x1:=x1+step;
     y1:=aitken(wm,x1,ix-2,4);
     grap.dest[false]:=i;
     grap.dest[true]:=corner[true]+mash(true,y1);
     gra(3)
   end
  end
end;

procedure calcint(wm,dm:integer;step:real);
var i,k,nget:integer;
    x0,x2,x9,x1,y1:single;
begin
  PULL(X0,WM,FALSE,1);
  PULL(X9,WM,FALSE,Spectra.DIR(WM)^.NPts);
  NGET:=trunc((x9-x0)/ step)+1;
  x1:=x0;i:=1;
  pull(y1,wm,true,i);
  push(x0,dm,false,i);
  push(y1,dm,true,i);
  k:=3;
  for i:=2 to nget-1 do begin
    repeat
      pull(x2,wm,false,k);
      if x2<x1+step then inc(k);
    until x2>=(x1+step);
    if k>Spectra.dir(wm)^.npts-1 then k:=Spectra.dir(wm)^.npts-1;
    x1:=x1+step;
    y1:=aitken(wm,x1,k-2,4);
    push(x1,dm,false,i);
    push(y1,dm,true,i);
  end;
  i:=Spectra.dir(wm).npts;
  pull(y1,wm,true,i);
  push(x9,dm,false,nget);
  push(y1,dm,true,nget);
end;

procedure plot(newscale:boolean; locn:integer); export; stdcall;
var i,j,ix:integer;x:real;inscrn,inscrl,ax,ext:boolean;c,key:char;ic,fa,kb_stat:byte;
   oldcorner:boolint;
   tmp,tmp1:single;
   putfit:boolean;
   axsave,destsave:boolint;
   savecolor:integer;
label abort;
begin
 if locn<0 then begin l0:=1;l9:=maxcur end else begin l0:=locn;l9:=locn end;
 grap.color:=1;
 frame;
 grap.slope:=0;grap.size:=1;
 grap.dest[ox]:=corner[ox]-4;grap.dest[oy]:=16 (*corner[oy]-32*);
 gra(0);
 grap.wstr:=xyaxis[false].footnote+' '+xyaxis[true].footnote;
 gra(5);
 if (n_locations_used>0)or(locn=0) then begin
   oldcorner:=corner;
   if newscale then
      setscl(locn);
   putscl;
   i:=l0;
   repeat
    with Spectra.dir(i)^ do if (npts>1)           (* No plots for 1-point "curves" ! *)
                 and ((l0=l9) or ((plotcolor and $F0)=0)) then begin
     putfit:=(fitparam<>NIL);
     with fitparam^ do if putfit then putfit:=((mode<>0)and(fitting_path<>0)and(EstimatesReady(fitparam)));
     grap.color:=plotcolor and $0F;
     inscrl:=false;
     grap.wch:=char(symbol);
     for j:=1 to npts do begin
      pull(tmp,i,oX,j);pull(tmp1,i,oY,j);
      inscrn:=inscr(tmp,tmp1);
      if inscrn then begin
        if (prmblk^.Cursor_On.v<>0)and(i=obj^)and(j=prmblk^.pntptr.v) then begin
           savecolor:=grap.color; grap.color:=5;
           axsave:=grap.axis;destsave:=grap.dest;
           grap.dest[false]:=corner[false];
           gra(0);grap.vcode:=2;grap.vlen:=npixel[false]-1;gra(2);
           grap.dest[false]:=destsave[false];grap.dest[true]:=corner[true];
           Gra(0);grap.vcode:=0;grap.vlen:=npixel[true]-1;gra(2);
           grap.dest:=axsave; gra(0);
           grap.dest:=destsave;
           grap.color:=savecolor
        end;
        if inscrl=false then gra(0) else
          if inter<>0 then putint(i,j) else
            if connect<>0 then gra(3) else gra(0);
        if not(((connect<>0) or (inter<>0))and(symbol=0)) then gra(4);
      end (*if inscr*);
      inscrl:=inscrn;
     end;
     if putfit then with fitparam^ do begin
       inscrl:=false;
       for ix:=1 to npixel[oX] do begin
         x:=(ix/xyaxis[oX].factor)+xyaxis[oX].off;
         fun(prm,fnd,x,z,u_prm,false,mode,submode);
         inscrn:=inscr(x,fnd[0]);
         if not(inscrl) then gra(0) else gra(3);
         inscrl:=inscrn
       end;
     end;
     for ax:=false to true do
        corner[ax]:=corner[ax]+cornshift[ax];
    end; (* with *)
    inc(i);
   until i>l9;
   corner[ax]:=oldcorner[ax];
   end (* if ncurves *);
abort:grap.color:=1;
   end (*plot*);

function replot(newscale,locn:longint):pointer; export; stdcall;
var ns:boolean;
begin
  ns:=(newscale<>0);
  gra(9);
  plot(ns,locn);
  result:=addr(grabuf)
end;

function plotlisted(var lista:inarr):pointer;export; stdcall;
var cbuf: array[1..maxcur] of byte;
    i:integer;
begin
   for i:=1 to maxcur do with Spectra.dir(i)^ do begin
      cbuf[i]:=plotcolor;
      plotcolor:=plotcolor or $80;
   end;
   i:=1;
   while (i<=maxlista)and (lista[i]<>0) do with Spectra.dir(lista[i])^do begin
     plotcolor:=plotcolor and $7F ;
     inc(i)
   end;
   result:=replot(-1,-1);
   for i:=1 to maxcur do with Spectra.dir(i)^ do plotcolor:=cbuf[i]
end;

function ViewResults(showfit:longint):pointer; export; stdcall;
var    i,locn,xleft,yup,dy,savecursor:integer;
       v,xx,yy :single;
       convstr:string;
       key:char;
       ext:boolean;
       p_n:string;
       w:word;
       corny,npixely1,npixely2,ffree:integer;
       fits:byte;
       axsave: array[false..True] of axistype;
       npixs,corns:boolint;
       savecomment:string;
       plotfit:boolean;
       onlyone,showresults,ax:boolean;
       fitmode:rmoderecord;
       DataSet,DataSet0:rDataSpec;
begin
 showresults:=(showfit<>0);
 DataSet:=spectra.dir(obj^);
 DataSet0:=spectra.dir(0);
 plotfit:=showresults and (DataSet^.fitparam<>NIL);
 if plotfit then onlyone:=(DataSet^.fitparam^.globalfit=0) else onlyone:=true;
 gra(9);
 if onlyone then locn:=obj^  else locn:=-1;
 with DataSet^ do begin
  with fitparam^ do if plotfit then plotfit:=((mode<>0)and(fitting_path<>0)and(EstimatesReady(fitparam)));
  if plotfit then with fitparam^ do begin
   fitmode:=getmode(mode);
   for ax:=false to true do axsave[ax]:=xyaxis[ax]^;
   npixs:=npixel;
   corns:=corner;
   if npixs[ox]<400 then
     npixel[ox]:=round(npixs[ox]/3) else
      npixel[ox]:=round(npixs[ox]/2);
   npixely1:=round((npixs[oy]-56)* 0.66666);
   npixel[oy]:=npixely1;
   npixely2:=round((npixs[oy]-56)* 0.33333);
   corny:=corns[oy]+28+npixely2;
   corner[oy]:=corny;
   savecomment:=xyaxis[false].footnote+xyaxis[true].footnote;
   savecursor:=prmblk^.Cursor_On.v;
   prmblk^.Cursor_On.v:=0;
   xyaxis[false].footnote:='';
   xyaxis[true].footnote:='';
   xyaxis[ox].token:=''
  end;
  grap.color:=1;
  plot(true,locn);
  if plotfit then with fitparam^ do begin
   xleft:=round((corner[ox]+npixel[ox])*1.1);
   yup:=corner[oY]+npixel[oY];
   with grap do begin
    wstr:=DataSet^.head;
    while (wstr[0]<>char(0))and(wstr[length(wstr)]=' ') do wstr[0]:=pred(wstr[0]);
    dest[ox]:=corner[ox];dest[oy]:=yup+36;
    color:=4;
    if length(wstr)<=33 then size:=2 else size:=1;
    gra(0);
    gra(5);
    size:=1;color:=7;
    dest[ox]:=xleft;dest[oy]:=round(yup);
    i:=pos(';',fitmode^.mn);
    if i<>0 then begin
        wstr:=copy(fitmode^.mn,1,i);
        if i<length(fitmode^.mn) then p_n:=copy(fitmode^.mn,i+1,255) else p_n:='';
    end else begin wstr:=fitmode^.mn;p_n:='' end;
    gra(0);gra(5);
    dy:=yup div 16;
    if p_n<>'' then begin
       yup:=yup-dy;
       dest[ox]:=xleft;dest[oy]:=yup;
       wstr:=p_n;gra(0);gra(5)
    end;
    if cause<>'' then begin
      yup:=yup-dy;
      dest[ox]:=xleft;dest[oy]:=yup;
      wstr:=cause;
      gra(0);gra(5);
    end;
    str(SqCorr:8:5,wstr);str(n_it:3,convstr);
    wstr:='Sq.corr.coef.='+wstr;
    yup:=yup-dy;
    dest[oy]:=yup;dest[ox]:=xleft;
    gra(0);gra(5);
    str(sqrt(sumsd/npts):8:5,wstr);str(n_it:3,convstr);
    wstr:='SD ='+wstr;
    yup:=yup-dy;
    dest[oy]:=yup;dest[ox]:=xleft;
    gra(0);gra(5);
    if n_it>0 then begin
      wstr:='Nbr. of iterations='+convstr;
      yup:=yup-dy;
      dest[oy]:=yup;dest[ox]:=xleft;
      gra(0);gra(5);
    end;
    color:=6;
    wstr:='P A R A M E T E R S :';
    yup:=yup-dy;
    dest[oy]:=yup;dest[ox]:=xleft;
    gra(0);gra(5);
    for i:=1 to n_par do begin
      (* if p_n='' then p_n:='P['+char(48+i)+']  ' else *)
      p_n:=fitmode^.pnames[i];
      while length(p_n)<6 do p_n:=p_n+' ';
      if npixs[ox]>400 then
       if (abs(prm[i])<1e4)and(abs(prm[i])>1e-3) then
         str(prm[i]:12:6,convstr) else str(prm[i]:12:-4,convstr)
      else begin
       if (abs(prm[i])<1e4)and(abs(prm[i])>1e-3) then
         str(prm[i]:9:4,convstr) else str(prm[i]:9:-2,convstr);
       cut(convstr,' ')
      end;
      wstr:=p_n+'='+convstr;
      if (fitting_path=2) and (not(isnan(dev[i]))) then begin
       if npixs[ox]>400 then
        if (abs(prm[i])<1e4)and(abs(prm[i])>1e-3) then
          str(dev[i]:10:6,convstr) else str(dev[i]:10:-3,convstr)
        else begin
          if (abs(prm[i])<1e4)and(abs(prm[i])>1e-3) then
           str(dev[i]:5:2,convstr) else str(dev[i]:7:-1,convstr);
           cut(convstr,' ');
        end;
        wstr:=wstr+'+-'+convstr
      end;
      yup:=yup-dy;
      dest[oy]:=yup;dest[ox]:=xleft;gra(0);gra(5);
    end;
   end;
    corner[oy]:=corns[oy]-16;
   npixel[oy]:=npixely2;
   xyaxis[false].footnote:=savecomment;
   prmblk^.Cursor_On.v:=savecursor;
   for ax:=false to true do xyaxis[ax]^:=axsave[ax];
   xyaxis[oy].token:='Residual';
   xyaxis[oy].auto:=-1;
   clear_location(0);
   for i:=1 to npts do begin
      pull(xx,obj^,ox,i);
      fun(prm,fnd,xx,z,u_prm,false,mode,submode);
      pull(yy,obj^,oy,i);
      yy:=yy-fnd[0];
      push(xx,0,false,i);
      push(yy,0,true,i);
   end;
   Spectra.CreateFitPrm(0);
   DataSet0^.inter:=0;
   DataSet0^.connect:=-1;
   DataSet0^.fitparam^.mode:=0;
   DataSet0^.symbol:=0;
   plot(true,0);
   clear_location(0);
   npixel[oy]:=npixely1;
   corner[oy]:=corny;
   for ax:=false to true do xyaxis[ax]^:=axsave[ax];
   xleft:=round((corner[ox]+npixel[ox])*1.1);
   yup:=corner[oY]+npixel[oY];
 
 end;
 if plotfit and(fitparam^.mode<>0) then begin
   npixel:=npixs;
   corner:=corns
 end;
 end (* with *);

 result:=addr(grabuf)
end;

end.
