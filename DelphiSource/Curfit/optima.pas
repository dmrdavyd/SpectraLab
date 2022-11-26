unit optima;

interface
uses mdefine,matrix,spl32def,Link2opti,link2splab,curfit_def,optidef,math,WinTypes,WinProcs,Win32crt;

const
        ttab:array[1..20] of integer=(1270,430,318,278,257,245,237,231,226,223,
                                    220,218,216,215,213,212,211,210,209,208);

        BuildUp=true;
        NotBuild=false;
procedure marquar(var psi,fnd:partype;var spsi:extended); export; stdcall;
procedure simplex(var psi,fnd:partype;var spsi:extended); export; stdcall;
procedure optimize(var psi,fnd:partype;var spsi:extended); export; stdcall;

function ssd(var psi,fnd:partype; disp: boolean; var ok:boolean):extended;
function compute_average:boolean; export; stdcall;
function putfit(path:longint):longint;export;stdcall;

implementation

const nimax=100;

var phi:partype;
    a:extended;p:pointer;
    wcrt:text;

function isadjustable(i:integer):boolean;
var j,b:integer;
begin
  b:=1;
  if i>1 then b:=b shl (i-1);
  result:=((b and curmode^.parmask)=0)
end;

function idx(i:integer):integer;
var i1,j,b:integer;
begin
  b:=1; j:=0; i1:=0;
  repeat
     inc(j);
     if (curmode^.parmask and b)=0 then inc(i1);
     b:=b shl 1
  until not(i1<i);
  result:=j
end;

function nvarpar:integer;
var i1,j,b:integer;
begin
  b:=1;
  i1:=0;
  for j:=1 to curmode^.np do if isadjustable(j) then inc(i1);
  result:=i1
end;


function Compute_Average:boolean;
var i,oobj,nnpts:integer;
    estimates:boolean;
    temp:single;
label loop8,loop9,ex8;
begin
with optiprm^ do begin
  midy:=0;nnpts:=0;sm:=0;
   if optiprm^.fitglobal<>0 then begin
       oobj:=0;obj^:=0;
loop8: repeat obj^:=obj^+1 until (getn(obj^)<>0) or (obj^>16);
       if obj^>16 then goto ex8 else if oobj=0 then oobj:=obj^;
    end else if getn(obj^)=0 then
      begin
        compute_average:=false;
        exit
      end;
    for i:=1 to getn(obj^) do begin
      pull(temp,obj^,true,i);
      midy:=midy+temp;
    end;
    nnpts:=nnpts+getn(obj^);
    if optiprm^.fitglobal<>0 then goto loop8;
ex8:if nnpts<=curmode^.np then compute_average:=false else
    begin
      compute_average:=true;
      midy:=midy/nnpts;
      if optiprm^.fitglobal<>0 then begin
       obj^:=0;
loop9: repeat obj^:=obj^+1 until (getn(obj^)<>0) or (obj^>16);
       if obj^>16 then begin obj^:=oobj; exit end;
      end;
      for i:=1 to getn(obj^) do begin
          pull(temp,obj^,true,i);
          temp:=midy-temp;
          sm:=sm+temp*temp
      end;
      if optiprm^.fitglobal<>0 then goto loop9
    end
  end
end;

function ssd(var psi,fnd:partype; disp: boolean;var ok:boolean):extended;
var i,j,ix,oobj:integer;
    st,yi:extended;
    temp:single;
    key:char;
    vstr:string;
label loop8,ex8;
begin
 ok:=false;
 with curmode^ do begin
    if disp then begin
      gotoxy(28,2);
      write('- Cycle ',optiprm^.nit:3)
    end;
    st:=0;
    if optiprm^.fitglobal<>0 then begin
      oobj:=obj^;obj^:=0;
loop8: repeat obj^:=obj^+1 until (getn(obj^)<>0) or (obj^>16);
       if obj^>16 then begin obj^:=oobj; goto ex8 end;
    end;
    for ix:=1 to getn(obj^) do begin
      pull(temp,obj^,false,ix);
      if not(fun(psi,fnd,temp,getz(obj^),u,false,modl,submodl)) then begin
        ClrScr;
        gotoxy(1,5);
        write(' Error evaluating function (invalid parameters)');
        gotoxy(1,25);
        Writeln(' Press any key to continue');
        repeat until keypressed;
        key:=readkey;
        ShowWindow(CRTWindow,SW_Hide);
        result:=NaN;
        exit
      end;
      pull(temp,obj^,true,ix);
      temp:=temp-fnd[0];
      if abs(temp)>1e12 then
        temp:=1e12;
      if st>1e24 then
         st:=1e24;
      st:=st+temp*temp;
    end;
    if optiprm^.fitglobal<>0 then goto loop8;
ex8:
   if disp then begin
     for j:=1 to np do if pnames[j]<>'' then begin
        gotoxy(3,j+5);
        write(pnames[j],'= ');
        gotoxy(12,j+5);
        write(psi[j]:16:6)
     end;
     with optiprm^ do str(1-st/sm:8:6,vstr);
     gotoxy(3,np+7);
     write('Sq.corr.coef.=');
     gotoxy(20,np+7);
     write(vstr)
   end;
   ssd:=st;
 end;
 ok:=true;
end;

function putfit(path:longint):longint;export;stdcall;
 var i,lobj,obj0,ncurves:integer;
     convstr:string;
     curdef:rDataSpec;
     par0:rfitrecord;
     ok:boolean;
 begin
  result:=0;
  curdef:=GetDirAddr(obj^);
  curdef^.fitparam^.prm[0]:=NAN;
  if _PrmReady(curdef)=0 then exit;
  if path=3 then if not(Compute_Average) then exit;
  optiprm^.spsi:=ssd(curdef^.fitparam^.prm,curdef^.fitparam^.dev,false,ok)/optiprm^.sm;
  if not(ok) then exit;
  if optiprm^.fitglobal<>0 then lobj:=0 else lobj:=obj^-1;
  par0:=curdef^.fitparam;
  obj0:=obj^; ncurves:=0;
  repeat
   repeat
         inc(lobj);
         curdef:=GetDirAddr(lobj);
   until (curdef^.npts<>0) or (lobj>maxcur);
   if lobj>maxcur then begin result:=-1; exit end else inc(ncurves);
   newfitprm(curdef^.fitparam);
   putfitprm(true,curdef^.fitparam);
   if lobj<>obj0 then
        curdef^.fitparam^.prm:=par0^.prm;
   with curdef^.fitparam^ do begin
    fitting_path:=path;
    if fitting_path in [1,2] then begin
      n_it:=optiprm^.nit;
      case optiprm^.way of
      -4:cause:='!!! Interrupted by user !!!';
      -3:cause:='At minimum';
      -2:cause:='!!! Matrix invert error !!!';
      -1:cause:='!!! Matrix is singular !!!';
       0,1:cause:='';
       2:begin
           cause:='Changes are less than ';
           str((optiprm^.accur*100):6:4,convstr);
           cause:=cause+convstr+'%'
         end;
       3:begin
           cause:='Sq.corr.coef. is higher than ';
           str((1-optiprm^.smin):7:5,convstr);
           cause:=cause+convstr
         end;
       4:begin
           str(optiprm^.nitmax:3,cause);
           cause:=cause+' iterations performed';
         end;
       end
    end else begin
       cause:='';
       n_it:=0;
    end;
    SqCorr:=1-optiprm^.spsi;
    prm[0]:=SqCorr;
    sumsd:=optiprm^.spsi*optiprm^.sm;
    globalfit:=optiprm^.fitglobal;
    if (fitting_path=2) then  dev:=dp else
         for i:=1 to n_par do dev[i]:=NAN
   end;
 until (optiprm^.fitglobal=0)or(lobj>=maxcur);
 result:=-1
end;

procedure marquar(var psi,fnd:partype;var spsi:extended);
const lm=10000;
var
   a,al:mtype;
   i,j,n_of_par1,np:integer;
   sphi,temp,lw:extended;
   e,ext,ok:boolean;
   key:char;
   kb_status:byte;
label 1,2;

function mta(var psi:partype):boolean;
var i,j,l,ix:integer;
    dy:extended;
    temp:single;
begin
 result:=false;
  for i:=1 to np do for j:=1 to n_of_par1 do a[i,j]:=0;
  for ix:=1 to getn(obj^) do begin
    pull(temp,obj^,false,ix);
    if not(fun(psi,fnd,temp,getz(obj^),curmode^.u,true,curmode^.modl,curmode^.submodl)) then begin
     ClrScr;
     gotoxy(1,5);
     write(' Error evaluating function (invalid parameters)');
     spsi:=NaN;
     gotoxy(1,25);
     Writeln(' Press any key to continue');
     repeat until keypressed;
     key:=readkey;
     ShowWindow(CRTWindow,SW_Hide);
     exit
    end;
    pull(temp,obj^,true,ix);
    dy:=temp-fnd[0];
    for j:=1 to np do begin
      for l:=j to np do a[j,l]:=a[j,l]+fnd[idx(j)]*fnd[idx(l)];
      a[j,n_of_par1]:=a[j,n_of_par1]+fnd[idx(j)]*dy
    end
   end;
 result:=true
end;

begin
 ShowWindow(CRTWindow,SW_Show);
 clrscr;
 gotoxy(1,2);
 writeln('   Marquardt Optimization');
 if (optiprm^.fitglobal<>0) then
    writeln('____________(Global Fitting)____________')
 else
    writeln('________________________________________');
 if (optiprm^.fitglobal=0) and (getn(obj^)<(curmode^.np+1))  then begin
   gotoxy(1,5);
   write('Not enough data for fitting');
   spsi:=NaN;
   gotoxy(1,25);
   Writeln(' Press any key to continue');
   repeat until keypressed; key:=readkey;
   ShowWindow(CRTWindow,SW_Hide);
   exit
 end;
 gotoxy(1,25);
 Writeln(' Press <Esc> to abort');
 with optiprm^ do begin
  np:=nvarpar;
  if np<2 then begin np:=curmode^.np;curmode^.parmask:=0 end;
  n_of_par1:=np+1;
  way:=0;nit:=0;
  if autolambda<>0 then begin
    nu:=2;
    if 1-spsi>-0.5 then lambda:=1 else lambda:=20;
  end;
  lw:=lambda*nu;
  repeat
   nit:=nit+1;
   if not(mta(psi)) then exit ;
   lw:=lw/(nu*nu);
2: repeat
     lw:=lw*nu;
     for i:=1 to np do for j:=1 to n_of_par1 do
      if i=j then al[i,i]:=a[i,i]*(lw+1) else al[i,j]:=a[i,j];
      gauss(al,np,dp,e);
      if e then begin
        way:=-1;goto 1
      end;
      i:=0;
      phi:=psi;
      for j:=1 to np do begin  (* bumping parameters *)
        phi[idx(j)]:=phi[idx(j)]+dp[j];
        if abs(dp[j])<abs(psi[idx(j)]*accur) then i:=i+1
      end;
      if i=np then way:=2;
      sphi:=ssd(phi,fnd,true,ok)/sm;
      if not(ok) then exit ;
    until (lw=0) or (sphi<spsi) or (lw>lm);
    if sphi<1.5*spsi then begin
      spsi:=sphi;
      psi:=phi
    end else if lw=0 then begin lw:=5;nu:=2;goto 2 end;
    if lw>lm then way:=-3;
    if nit>=nitmax then way:=4;
    if spsi<=smin then way:=3;
    if keypressed then begin
      key:=readkey;
      if (key=#27) then way:=-4
    end;
  until way<>0;
  if getn(obj^)<=20 then temp:=ttab[getn(obj^)-1]*0.01 else temp:=2;
  temp:=temp/sqrt(getn(obj^)-1);
  if not(mta(psi)) then exit;
  invert(a,np,e);if e then begin way:=-2;goto 1 end;
  for i:=1 to curmode^.np do dp[i]:=NAN;
  for i:=1 to np do
     dp[idx(i)]:=temp*sqrt(spsi*sm*abs(a[i,i]));
1:end;
 putfit(2);
 gotoxy(1,25);
 Writeln('Finished.                               ');
 { repeat until keypressed; key:=readkey; }
 ShowWindow(CRTWindow,SW_Hide);
end;

procedure simplex(var psi,fnd:partype;var spsi:extended);
var i,j,mx1,mx2,mn0,n_of_par0,np,n_of_par1,msum  :integer;
  psim                          :array[1..10,1..11] of extended;
  d1,d2,ssn,f,temp              :extended;
theta,psi0,phi,ss               :partype;
ext,ok:boolean;
key:char;
kb_status:byte;
vstr:string[3];
c: char;
begin
  ShowWindow(CRTWindow,SW_Show);
  clrscr;
  gotoxy(1,2);
(*!*)
  np:=nvarpar;
  if np<2 then begin np:=curmode^.np;curmode^.parmask:=0 end;
  writeln('   Nelder-Mead Optimization');
  if (optiprm^.fitglobal<>0) then
    writeln('____________(Global Fitting)____________')
  else
    writeln('________________________________________');
  if (optiprm^.fitglobal=0) and (getn(obj^)<(curmode^.np+1)) then begin
    gotoxy(1,5);
    write('Not enough data for fitting');
    spsi:=NaN;
    gotoxy(1,25);
    Writeln(' Press any key to continue');
    repeat until keypressed; key:=readkey;
    ShowWindow(CRTWindow,SW_Hide);
    exit
  end;
  gotoxy(1,25);
  Writeln(' Press <Esc> to abort');
  with optiprm^ do begin
    n_of_par0:=np;
    n_of_par1:=n_of_par0+1;
    phi:=psi;
(*    psi0:=psi; *)
    way:=0;nit:=0;
    d1:=sqrt(n_of_par1)-1;d2:=1+d1*alpha/((n_of_par0)*1.414);
    d1:=1+(d1+n_of_par0)*alpha/(n_of_par0*1.414);
    for i:=1 to n_of_par1 do for j:=1 to n_of_par0 do
     if j=i then psim[j,i]:=d1 else psim[j,i]:=d2;
    for i:=1 to n_of_par1 do begin
     phi:=psi;
     for j:=1 to n_of_par0 do phi[idx(j)]:=psim[j,i]*phi[idx(j)];
     ss[i]:=ssd(phi,fnd,true,ok)/sm;
     if not(ok) then exit ;
    end;
    repeat
     mx1:=1;mx2:=1;
     mn0:=1;nit:=nit+1;
     if nit>=nitmax then way:=4;
     for i:=2 to n_of_par1 do begin
        if ss[i]>ss[mx1] then
          begin
            mx2:=mx1;
            mx1:=i
          end
         else if ss[i]<ss[mn0] then mn0:=i;
     end;
     if ss[mn0]<=smin then way:=3;
     phi:=psi;
     for i:=1 to n_of_par0 do begin
      theta[i]:=0;
      for j:=1 to n_of_par1 do if j<>mx1 then theta[i]:=theta[i]+psim[i,j];
      theta[i]:=theta[i]/n_of_par0;
      psi0[i]:=2*theta[i]-psim[i,mx1];
      phi[idx(i)]:=phi[idx(i)]*psi0[i]
     end;
     ssn:=ssd(phi,fnd,true,ok)/sm;
     if not(ok) then exit;
     f:=2;
     if ssn<ss[mn0] then f:=3 else
       if ssn>ss[mx1] then f:=0.5 else
          if ssn>ss[mx2] then f:=1.5;
     msum:=0;
     phi:=psi;
     for i:=1 to n_of_par0 do begin
      temp:=f*(theta[i]-psim[i,mx1]);
      temp:=psim[i,mx1]+temp;
      if abs(1-temp/psim[i,mx1])<accur then msum:=msum+1;
      psim[i,mx1]:=temp;
      phi[idx(i)]:=psim[i,mx1]*phi[idx(i)]
     end;
     if msum=n_of_par0 then way:=2;
     ss[mx1]:=ssd(phi,fnd,true,ok)/sm;
     if not(ok) then exit;
     if ssn<ss[mx1] then begin for i:=1 to n_of_par0 do psim[i,mx1]:=psi0[i];ss[mx1]:=ssn end;
     if keypressed then begin
      key:=readkey;
      if (key=#27) then way:=-4
     end;
    until way<>0;
    if ss[mx1]<ss[mn0] then mn0:=mx1;
    for i:=1 to n_of_par0 do psi[idx(i)]:=psim[i,mn0]*psi[idx(i)];
    spsi:=ssd(psi,fnd,true,ok)/sm;
    if not(ok) then exit;
  end;
  putfit(1);
  gotoxy(1,25);
  Writeln('Finished.                               ');
  ShowWindow(CRTWindow,SW_Hide);
end;


procedure optimize(var psi,fnd:partype;var spsi:extended);
begin
    if (curmode^.sx<>0) then simplex(psi,fnd,spsi);
    if isnan(spsi) then exit;
    if (curmode^.mq<>0) then marquar(psi,fnd,spsi);
end;

end.

