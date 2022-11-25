unit splsolve;
interface
uses math;
const omicron=5E-8;
      maxnturns=127;
procedure solve3(c,b,a:extended;var x1,x2,x3:extended;var nroot:integer);
function solve4(S0,E0,K1,K2:extended;var x1:extended):boolean;
procedure solve_n(N_CTR:integer;S0,E0,KD:extended;var x1:extended);

{const fgold=0.61803398875; }

implementation

var x0,l,m,e,f,aa,bb,cc,kk,fgold:extended;
    nn,nturns:integer;
    fminus:boolean;
    FMODE:integer;

function fun(x:extended):extended;
var i:integer;
begin
   case fmode of
     1: begin (* cubic equation *)
         x0:=x+cc;
         l:=x0*x+bb;
         result:=l*x+aa
       end;
     2: begin (* "sequential binding" (2.5-order) equation
                 Variables: AA=[S]0,BB=[E]0,CC=K1,KK=K2 *)
            x0:=X*X-(AA+KK)*X+AA*AA/4;
            if not(x0<0) then begin
              x0:=sqrt(x0);
              if fminus then x0:=-1*x0;
              x0:=AA/2-X+x0;    (* [ES], switching roots depending on fminus *)
              result:=x0*(x-CC-BB)-(AA+2*BB+KK)*X+2*x*x+AA*BB
            end else result:=NAN;
{             result:=x*x+CC*X0*X0/KK-X*(BB-X0)               }
        end;
     3: begin (* infinite cooperativity with n centers
                 Variables: AA=[S]0,BB=[E]0,nn=n,KK=Kd *)
                 x0:=BB-x;
                 l:=AA-X*nn;
                 for i:=1 to nn do x0:=x0*l;
                 result:=x0-KK*x
         end
   end;
end;


function gold(g,d:extended;var x:extended):extended;
var tx1,tx,x1,delt:extended;
(* var nturns:integer;  *)
begin
  tx:=0;tx1:=0;
  nturns:=0;
  repeat
   if tx=0 then begin
     x:=d+fgold*(g-d);
     tx:=fun(x);
{     if isnan(tx) then begin
       result:=NAN ;
       exit
     end; }
     if tx=0 then begin x:=tx; exit end;
   end;
   if tx1=0 then begin
     x1:=g+fgold*(d-g);
     tx1:=fun(x1);
{     if isnan(tx1) then begin
       result:=NAN;
       exit
     end; }
     if tx1=0 then begin x:=x1; exit end;
   end;
   if abs(tx)<abs(tx1) then begin
      d:=x1;
      tx1:=tx;
      x1:=x;
      tx:=0
   end else begin
      g:=x;
      tx:=tx1;
      x:=x1;
      tx1:=0
   end;
   inc(nturns);
   delt:=abs(d-g);
  until (nturns>maxnturns)or(delt<omicron);
  result:=max(abs(TX),abs(TX1));
end;

procedure solve3(c,b,a:extended;var x1,x2,x3:extended;var nroot:integer);

begin
{  k:=x1;}
  aa:=a;bb:=b;cc:=c; fmode:=1;
  gold(X2,X3,x1);
  e:=-(x1+c)/2;m:=e*e-l;
  if m<=0 then begin
    nroot:=1;
    exit
  end else begin
    nroot:=3;
    f:=sqrt(m);
    x2:=f+e;
    x3:=e-f
  end;
end;

function solve4(S0,E0,K1,K2:extended;var x1:extended):boolean;
var X2,plusroot,minusroot,plusres,minusres:extended;
begin
  result:=true;
  if (S0<omicron)or(E0<omicron) then X1:=0 else begin
    aa:=S0;bb:=E0;cc:=K1;kk:=K2;fmode:=2;
    x2:=(AA+KK-sqrt(KK*(2*AA+KK)))/2;(* OUFF!! Border limit for non-neqative discriminant *)
    x2:=min(AA/2,X2);
    x2:=min(BB,X2);
    fminus:=true;
(*            x0:=X*X-(AA+KK)*X+AA*AA/4; *)
   if x2<omicron then x1:=x2 else begin
      minusroot:=x1;      (* probing two roots - with "+" and with "-" *)
      minusres:=gold(X2,omicron,minusroot);

      if minusres>1E3*omicron then begin
        plusroot:=x1;
        fminus:=false;
        plusres:=gold(X2,omicron,plusroot);
        { fminus:=not(plusres<1E3*omicron)}
        fminus:=not((plusres<minusres)and(plusroot>2*omicron));
      end;
{
      if S0<2*E0 then begin
        fminus:=false;
        plusroot:=x1;
        OK:=gold(X2,omicron,plusroot);
        if OK and not(isnan(plusroot)) then begin
          fminus:=(plusroot<2*omicron);
          fminus:=fminus or (minusroot<plusroot);
          if fminus and not(isnan(minusroot)) then x1:=minusroot else x1:=plusroot;
          result:=fminus
        end else x1:=minusroot;
}

      if fminus then x1:=minusroot else x1:=plusroot;
      if isnan(X1) then X1:=0
   end;
  end;
  result:=fminus
end;

procedure solve_n(N_CTR:integer;S0,E0,KD:extended;var x1:extended);
(* infinite cooperativity with n centers
                 Variables: AA=[S]0,BB=[E]0,NN=n,KK=Kd *)
var X2:extended;
begin
 aa:=S0;bb:=E0;nn:=N_CTR;kk:=Kd;fmode:=3;
 x2:=s0; if e0<x2 then x2:=e0;
 gold(0,X2,x1);
end;

begin
  fgold:=5;
  fgold:=(sqrt(fgold)-1)/2.0;
  fminus:=true
end.



