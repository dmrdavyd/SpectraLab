unit Link2opti;
interface
uses spl32def,optidef,matrix,math;
function fun(var psi,fnd:partype; x,z,u:extended;der:boolean;
              mode,submode:integer):boolean;
function setmode(refresh:longint):longint; stdcall;
function getmode(i:longint):pointer; register;
function EstimatesReady(fitprm:rfitrecord):boolean;

implementation

function opti_fun(mode_,submode_,der_:longint; var x_,z_,u_:extended;
             var psi,fnd:partype):longint; stdcall;
             external 'OPTIFUN.DLL' name 'opti_fun';

function fun(var psi,fnd:partype; x,z,u:extended;der:boolean;
              mode,submode:integer):boolean;
var i:integer;
    p0,dx:extended;
    phi,dp:partype;
    dercalc:boolean;
const delta=1e-4;

function callfun:boolean;
var x_f,z_f,u_f:extended;
    der_f:longint;
begin
  x_f:=x;z_f:=z;u_f:=u;
  if der then begin
     fnd[1]:=NAN;   (* To ensure the evaluation of the derivatives, if requested *) 
     der_f:=-1;
  end else
       der_f:=0;
  if opti_fun(mode,submode,der_f,x_f,z_f,u_f,psi,fnd)=0 then result:=false else result:=true;
end;

begin
   dercalc:=callfun;
   if der and isnan(fnd[1]) then begin (* Have the derivatives been requested  *)
       p0:=fnd[0];                     (* but not evaluated? If so - find them *)
       phi:=psi;                       (* numerically                          *)
       for i:=1 to curmode^.np do begin
         dx:=delta*phi[i];
         if dx=0 then dx:=delta*delta;
         psi[i]:=phi[i]-2*dx;
         callfun;dp[i]:=fnd[0];
         psi[i]:=phi[i]-dx;
         callfun;dp[i]:=dp[i]-8*fnd[0];
         psi[i]:=phi[i]+dx;
         callfun;dp[i]:=dp[i]+8*fnd[0];
         psi[i]:=phi[i]+2*dx;
         callfun;dp[i]:=dp[i]-fnd[0];
         dp[i]:=dp[i]/(12*dx);
         psi[i]:=phi[i]
       end;
       fnd:=dp;
       fnd[0]:=p0;
       dercalc:=true;
   end;
   result:=dercalc;
end;



function setmode(refresh:longint):longint; stdcall;
external 'OPTIFUN.DLL' name 'setmode';

function getmode(i:longint):pointer; register;
external 'OPTIFUN.DLL' name 'getmode';

function EstimatesReady(fitprm:rfitrecord):boolean;
var i:integer;
begin
  result:=false;
  if fitprm<>NIL then with fitprm^ do begin
   i:=0;
   repeat
    inc(i);
    if IsNAN(prm[i]) then exit
   until (i>=n_par);
   result:=true
  end;
end;

end.
