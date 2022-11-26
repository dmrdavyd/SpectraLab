unit estima;
interface
USES spl32def,link2opti,link2splab,optidef,curfit_def,mdefine,matrix,optima,spl32str,
     Math,WinTypes,WinProcs,Win32crt;
Procedure Calc_Est(nobj:integer;var psi:partype;var ok:boolean);
function build_curve(lim,off:extended; npts,n:integer; var phi,fnd:partype):boolean;
function get_estimates(var fitprm:rfitrecord):boolean;

implementation
const   Rconst=83.14 (* Univers. gase constant, ml*bar/(mol*grad)) *);
        Rcci=8.314E-3;
        ABSZERO=273.15;
        ttab:array[1..20] of integer=(1270,430,318,278,257,245,237,231,226,223,
                                    220,218,216,215,213,212,211,210,209,208);
var offst:real;
    yncrease:boolean;

function exp_c(x:real):real;
 begin
   if x<-87 then begin exp_c:=0;exit end;
   if x>87 then x:=87;
   exp_c:=exp(x)
 end;

Procedure Calc_Est(nobj:integer;var psi:partype;var ok:boolean);
var i,j,k,l,mm,n9:integer;
    a,b,psi1,psi2,step,temp:single;

  procedure tra(var x,y:single);
  var x1,y1,r:real;
(******** transformation of coordinates ***********)
  begin
   with curmode^ do with optiprm^ do begin
    if (modl=10) then x1:=1/(RCCI*(ABSZERO+x)) else
      if (modl=8)and(psi[4]=1) then begin
            if x=0 then x:=1e-9;
            x1:=1/x
      end else x1:=x;
    case modl of
      1,2:y1:=y;
      3,4,5:begin                     (* Mich., Two michaelises, Hill *)
            y1:=abs(y-psi[1]);
            if Y1=0 then y1:=omikron;
            y1:=x/y1
          end;
      8: if psi[4]=1 then begin     (* 2-nd order kinetics *)
            if y=0 then y:=1e-9;
            y1:=1/y
          end else begin
            r:=psi[4]*(psi[2]-y)/(psi[2]*psi[4]-y);
            if r>0 then r:=ln(r) else r:=-1E9;
            y1:=r/(psi[4]-1);
          end;
      10:y1:=ln(abs(y));  (* Arrhenius *)
      11:begin   (* Pressure eq. *)
        if y>=psi1+abs(psi2) then y:=psi1+abs(psi2)-omikron else
         if y<=psi1 then y:=psi1+omikron;
        r:=y-psi1;
        r:=r/(psi1+abs(psi2)-y);
 (*       if not(yncrease) then r:=1/r; *)
        y1:=ln(r)
       end;
       else y1:=y
    end;
    x:=x1;y:=y1
   end
  end;

  procedure lsq(nobj,p5,n9:integer;var e:boolean);
  var a:mtype;w:partype;
    m2,i,j,k,p2,p3:integer;
    x,y,r,w1:single;


  begin
   with curmode^ do begin
   m2:=p5*2;
   p2:=p5+1;
   p3:=p2+1;
   for i:=1 to m2 do w[i]:=0;
   for i:=1 to np do a[i,p3]:=0;
   for i:=1 to n9 do begin
    w1:=1;
    pull(x,nobj,false,i);pull(y,nobj,true,i);
    for j:=1 to m2 do begin
     w1:=w1*x;
     w[j]:=w[j]+w1;
    end;
    r:=1;
    for j:=1 to p2 do begin
     a[j,p3]:=a[j,p3]+r*y;
     if x<>0 then r:=r*x
    end;
   end;
   for i:=1 to p2 do
     for j:=1 to p2 do begin
       k:=i+j-2;
       if k<>0 then a[i,j]:=w[k] else a[1,1]:=n9
     end;
   gauss(a,p2,psi,e);
   e:=not(e)
   end;
  end;

(************************ exponenta *****************************)


  procedure calc_exp_est(nobj:integer);
  var i,j,k,n9,n09,s,jf,nexp:integer;
    a,c,b,z0,z1,z2,z3,z5,z8,z9,z10,ampli,fin1,fin2,fin3,w1:single;
    w:array[1..32] of real;
  label e1;
(************* local procedures for calc_exp_est **************)


    function nextk(nn,i:integer):real;
    var j:integer;a,b,c:single;
    begin
      pull(a,nobj,true,nn);pull(b,nobj,true,i);
      c:=(a-b)/(b-optiprm^.lim);
      nextk:=c;
    end;


    procedure calclastexp(var scc:boolean);
    var i,nn:integer;
    x,y,sx,sy,sx2,sy2,sxy,a,b:single;
    label cc1;
    begin
     with optiprm^ do begin
     scc:=true;
     for i:=1 to n9 do begin
      pull(a,nobj,true,i); a:=sign_exp*(lim-a);
      if a<=0 then if i>2 then
        begin nn:=i-1;goto cc1 end
      else
        begin scc:=false;exit end;
      push(a,nobj,true,i);  (* Corrected: TRUE instead of ax !! *)
     end;
 cc1:for i:=1 to n9 do begin
      pull(a,nobj,true,i);
      a:=ln(abs(a));
      push(a,nobj,true,i)
     end;
     lsq(nobj,1,n9,scc);
     if scc and(psi[2]<0) then begin
       psi[3]:=-psi[2];
       psi[2]:=-sign_exp*exp_c(psi[1])
     end else begin
      b:=(curdef^.max[OY]-curdef^.min[OY])*1.05;
      if nexp>1 then begin
       psi[3]:=psi[5]*10;
       a:=b;
       for i:=2 to nexp do a:=a-abs(psi[i*2]);
       if a>0 then psi[2]:=a else psi[2]:=b/nexp
      end else begin
       psi[3]:=curdef^.max[OX]-curdef^.min[OX];
       if psi[3]=0 then psi[3]:=omikron;
       psi[3]:=3/psi[3];
       psi[2]:=b
      end;
      psi[2]:=-sign_exp*psi[2];
      if sign_exp<0 then psi1:=curdef^.min[OY] else psi1:=curdef^.max[OY];
     end
  end
 end;


(******************** calc_exp_est itself *******************)
 begin
  dir:=GetDirAddr(nobj);
  with dir^ do with optiprm^ do begin
   nexp:=curmode.np div 2;
   n9:=npts;
   lim:=psi[1];
   for i:=1 to nexp*2 do psi[i]:=0;
   if nexp>1 then
    for k:=nexp downto 2 (* 2 *) do begin
      pull(ampli,nobj,true,1);
      ampli:=sign_exp*(lim-ampli);
      pull(fin1,nobj,true,n9);
      fin1:=fin1-sign_exp*ampli*0.05/k;
      fin2:=fin1-sign_exp*ampli*0.1/k;
      pull(fin3,nobj,true,n9);
      fin3:=fin3-sign_exp*ampli/k;
      jf:=k*3;
      while (jf<n9)and pull(z10,nobj,oy,jf) and (sign_exp*(fin1-z10)>=0) do jf:=jf+1;
      n9:=jf;
      n09:=n9;
      j:=0;
      while (n09>1)and(j=0) do begin
        pull(a,nobj,ox,n09-1);
        pull(z10,nobj,ox,n09);
        a:=a-2*z10;
        pull(z10,nobj,ox,n09+1);
        a:=a+z10;
        j:=round(100*a);
        n09:=n09-1;
      end;
      while (n09<(n9-2))and pull(z10,nobj,oy,n09)and(sign_exp*(fin2-z10)>=0) do
         n09:=n09+1;
      jf:=n9-n09;
      w1:=nextk(n09+jf,n09);
      w[1]:=w1;
      z9:=0;j:=1;z0:=w1;
      pull(z3,nobj,ox,n09+1);
      pull(z10,nobj,ox,n09);
      z3:=z3-z10;
      z2:=z3;z8:=0;
      while
       (n09>0)and(j<=32)and((z9<=z8)or(j<3))and pull(z10,nobj,oy,n09)
         and(sign_exp*(z10-fin3)>=0)and(z2=z3)
       do begin
        z8:=z9;
        j:=j+1;
        n09:=n09-1;
        w[j]:=nextk(n09+jf,n09);
        z0:=z0+w[j];w1:=z0/j;
        z9:=0;
        for i:=1 to j do begin
         a:=w1-w[j];
         if abs(a)>1e12 then a:=1e12;
         if z9>1e24 then z9:=1e24;
         z9:=z9+a*a
        end;
        z9:=sqr(z9/(j-1));
        if j<=21 then a:=ttab[j-1]/100 else a:=2.05;
        z9:=a*z9/sqr(j);
        pull(z2,nobj,ox,n09+1);
        pull(z10,nobj,ox,n09);
        z2:=z2-z10;
      end;
      w1:=0;if j<2 then j:=2;
      for i:=1 to j-1 do w1:=w1+w[i];
      if w1=0 then w1:=omikron else w1:=w1/(j-1);
      a:=ln(w1+1)/(jf*z3);
      z9:=0;
      for i:=n09 to n9-jf do begin
       pull(b,nobj,oy,i+jf);pull(z10,nobj,oy,i);
       b:=sign_exp*(b-z10);
       pull(z10,nobj,ox,i);
       c:=exp_c(a*z10)*w1;
       z5:=b/c;
       z9:=z9+z5
      end;
      z9:=z9/(n9-jf-n09+1);
      if z9>=0 then z9:=-ampli*0.05;
      if -z9>ampli then z9:=-ampli*0.95;
      for i:=1 to n09 do begin
         pull(c,nobj,false,i);
         c:=z9*exp_c(a*c);
         pull(b,nobj,true,i);
         c:=b-sign_exp*c;
         if sign_exp*(lim-c)<=0 then begin n09:=i-1;goto e1 end;
         push(c,nobj,true,i);
      end;
e1:   psi[k*2]:=sign_exp*z9;
      psi[k*2+1]:=-a;
      n9:=n09;
    end;
   calclastexp(ok);
   psi[1]:=psi1
  end
 end;

function aitken(wm:integer;xi:single;i1,np:integer):single;
var p,u:array [1..5] of single;
    np1,i,ip1,j:integer;
    a,uxi:single;
begin
 dir:=GetDirAddr(wm);
 with dir^ do begin
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

(**************************CALC_EST itself*********************************)

begin
 n9:=getn(nobj);
 curdef:=GetDirAddr(nobj);
 psi1:=psi[1];psi2:=psi[2];
 ClearLocation(0);
 with curmode^ do with optiprm^ do begin
  if (pnames[3]='Phalf')and(IsNAN(curdef^.z)) then curdef^.z:=25;(*Pressure dep., deflt. t=25 °C *)
  for i:=1 to curdef^.npts do begin
    pull(a,nobj,OX,i);
    pull(b,nobj,OY,i);
    tra(a,b);
    push(a,0,false,i);
    push(b,0,true,i)
   end;
  if modl=1 then calc_exp_est(0) else begin
    if modl=2 then lsq(0,curmode.np-1,n9,ok) else
     lsq(0,1,n9,ok);
    ClearLocation(0);
    if not(ok) then exit;
    case modl of
      3,4,5:begin
           temp:=1/psi[2];
           psi[3]:=psi[1]*temp;
           psi[2]:=temp*sign(psi2);
           psi[4]:=1;
           psi[1]:=psi1;
           if modl=4 then begin
              psi[2]:=psi[2]/2;
              psi[3]:=psi[3]*3/10;
              psi[4]:=psi[2];
              psi[5]:=psi[3]*10
           end
         end;
     8:if u=1 then begin
           psi[3]:=psi[1]/psi[2];
           psi[2]:=1/psi[1];
           psi[1]:=lim
         end else psi[2]:=-psi[2];
     10:begin
           psi[2]:=-psi[2];
           psi[1]:=exp_c(psi[1])
         end;
     11:begin
           temp:=curdef^.z+ABSZERO;
           psi[4]:=-psi[2]*RCONST*temp;
           psi[3]:=psi[1]/(-psi[2]);
           psi[1]:=psi1;
           psi[2]:=sign_exp*psi2;
         end;
    end;
  end;
{  curcur:=0; }
 end;
end;


function build_curve(lim,off:extended; npts,n:integer; var phi,fnd:partype):boolean;
var xx,yy,dx:single;
    i:integer;
begin
 result:=false;
 curdef:=GetDirAddr(n);
 dx:=(lim-off)/(npts-1);
 for i:=1 to npts do begin
    xx:=off+(i-1)*dx;
    if not(fun(phi,fnd,xx,curdef^.z,curmode^.u,false,curmode^.modl,curmode^.submodl)) then begin
      clearlocation(obj^); exit end;
    yy:=fnd[0];
    push(xx,n,false,i);
    push(yy,n,true,i)
 end;
 curdef^.fitparam^.fitting_path:=0;
 curdef^.fitparam^.mode:=curmode^.modl;
 curdef^.fitparam^.submode:=curmode^.submodl;
 curdef^.fitparam^.n_par:=curmode^.np;
 for i:=0 to curmode^.np do curdef^.fitparam^.dev[i]:=NAN;
 curdef^.fitparam^.prm[0]:=NAN;
 curdef^.fitparam^.n_it:=0;
 curdef^.fitparam^.u_prm:=curmode^.u;
 curdef^.fitparam^.globalfit:=0;
 curdef^.fitparam^.SqCorr:=NAN;
 curdef^.fitparam^.sumsd:=NAN;
 curdef^.fitparam^.cause:='';
 with curdef^ do begin connect:=0; inter:=1; symbol:=0 end;
 result:=true
end;

function get_estimates(var fitprm:rfitrecord):boolean;
var i,swap:integer;
    lim,a,y0,yampli,x1,x2,x3:single;
    scc:boolean;


{
 procedure minimax;
  var j:integer;
      step:single;
  begin
    j:=1;
    with dir^ do for j:=1 to npts do
         begin
          pull(step,obj^,true,j);
          if (step>maxi)or(j=1) then maxi:=step;
          if (step<mini)or(j=1) then mini:=step;
         end
    end;
}

begin
 if getn(obj^)<curmode^.np+1 then begin
   ShowWindow(CRTWindow,SW_Show);
   clrscr;
   gotoxy(1,2);
   writeln('   Get Estimates');
   writeln('________________________________________');
   gotoxy(1,5);
   write('Not enough data for fitting');
   get_estimates:=false;
   gotoxy(1,25);
   Writeln(' Press any key to continue');
   repeat until keypressed; readkey;
   ShowWindow(CRTWindow,SW_Hide);
   exit
 end;
 with fitprm^ do begin
  get_estimates:=false;
  clearfitprm(fitprm);
  with curmode^ do begin
   dir:=GetDirAddr(obj^);
   minimaXY(obj^,false,true);
   minimaXY(obj^,true,true);
   if not(compute_average) then exit;
   optiprm^.nit:=0;optiprm^.way:=0;
(* Determine direction of the changes - decreasing or increasing? *)
   pull(lim,obj^,true,dir^.npts);
   pull(a,obj^,true,round(dir^.npts*0.75));
   lim:=lim+a;
   pull(a,obj^,true,round(dir^.npts*0.5));
   lim:=(lim+a)/3;
   if (dir^.max[true]-lim)<(lim-dir^.min[true]) then sign_exp:=1 else sign_exp:=-1;
   yncrease:=(sign_exp>0); yampli:=dir^.max[true]-dir^.min[true];
   if pnames[1]='A0' then begin
       prm[1]:=dir^.min[true]-omikron;
   end else
    if (pnames[1]='Offset')or(curmode^.pnames[1]='Limit') then begin
      if (pnames[1]='Offset') then swap:=1 else swap:=-1;
      if (sign_exp*swap>0) then lim:=dir^.min[true]-yampli*0.025
           else lim:=dir^.max[true]+yampli*0.025;
      prm[1]:=lim
    end;
   if (pos('max',pnames[2])=2) then begin
       prm[2]:=1.1*sign_exp*yampli;
       if (pos('Ligand',dir^.head)=1) or  ((np=5) and (pnames[5]='F(ES)')) and not(isnan(dir^.z)) then
         prm[2]:=prm[2]/dir^.z
   end;
   i:=0;if yncrease then y0:=dir^.min[true] else y0:=dir^.max[true];
   repeat inc(i); pull(a,obj^,true,i) until (abs(a-y0)>=(yampli/3))or(i>=dir^.npts);
   pull(x1,obj^,false,i);
   while (i<dir^.npts)and(abs(a-y0)<yampli*0.5) do begin inc(i); pull(a,obj^,true,i) end;
   pull(x2,obj^,false,i);
   while (i<dir^.npts)and(abs(a-y0)<yampli*2/3) do begin inc(i); pull(a,obj^,true,i) end;
   pull(x3,obj^,false,i);
   if np>2 then begin
    if (pnames[3][1]='K')or(pos('S(50)',pnames[3])=1) then begin
          prm[3]:=2*x2/3;
          if ((np=5) and (pnames[5]='F(ES)')) then prm[5]:=omikron;
    end else  if pnames[3][1]='k' then prm[3]:=1/x1;
    if (pos('Hill',modename[modl])=1) then  begin
      prm[4]:=1.5;
      if np>4 then begin
        prm[4]:=1.5;
        prm[5]:=dir^.max[false];
        prm[6]:=0;
        prm[2]:=prm[2]*1.333
      end else prm[4]:=1.5;
     end else begin
      if (np>3) then
       if (pos('max',pnames[4])=2) and (pos('max',pnames[2])=2) then begin
          prm[2]:=prm[2]/2;
          prm[4]:=prm[2];
       end else
         if pnames[4][1]='K' then prm[4]:=x2 else
           if (pnames[4]='deltaV') then if yncrease then prm[1]:=prm[1]-yampli*0.1 else prm[1]:=prm[1]-yampli*0.01;
       if ((np>4) and (pnames[5][1]='K') and (pnames[3][1]='K')) then begin
        prm[5]:=x3;
        prm[3]:=x1
       end
    end;
  end;
   if ce<>0 then begin calc_est(obj^,prm,scc); scc:=true end else scc:=false;
   putfit(3);
  end;
  get_estimates:=true;
 end
end;

end.




