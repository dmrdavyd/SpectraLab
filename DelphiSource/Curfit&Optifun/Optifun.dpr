library Optifun;

uses
  splsolve in 'splsolve.pas',
  cfit2fun,
  math,
  CubicRoot in 'E:\delphi-SRC\optifun\CubicRoot.pas';

{$I-}
{$R-}
{$H-}

const maxp=21;
const harddefined=16;
type partype=array[0..maxp] of extended;

const
        Rconst=83.14 (* Univers. gase constant, ml*bar/(mol*grad)) *);
        Rcci=8.314E-3;
        ABSZERO=273.15;
Var savedmode,savedsubmode:integer;

function funct(mode,submode:integer; var der:boolean;
               x,z,u:extended;var psi,fnd:partype):boolean;

var  temp,z1,z2,z3,z4,z5,z6,z7,z8,v0,u0,S0,E0,S,SES,ES:extended;
     i,j,l,n_par:integer;
     dercalc:boolean;

function exp_c(x:extended):extended;
 begin
   if x<-87 then begin exp_c:=0;exit end;
   if x>87 then x:=87;
   exp_c:=exp(x)
 end;

procedure kdpress(var fnd,psi:partype;x:extended;temp:extended);
var a,expo,rt:extended;
begin
 a:=x-psi[3];
 if isnan(temp) then temp:=25;
 temp:=temp+ABSZERO;
 RT:=Rconst*temp;
 expo:=exp_c(-a*psi[4]/RT);
 fnd[2]:=expo/(1+expo);
 fnd[0]:=psi[1]+psi[2]*fnd[2];
 if der then begin
   fnd[3]:=psi[2]*fnd[2]/((1+expo)*rt);
   fnd[4]:=-a*fnd[3];   (*Vhalf*)
   fnd[3]:=psi[4]*fnd[3];
   fnd[2]:=1+fnd[2];
   fnd[1]:=1;
 end
end;

procedure kdpress2(var fnd,psi:partype;x:extended;gamma,temp:extended);
var expo,rt:extended;
begin
 if isnan(temp) then temp:=25;
 temp:=temp+ABSZERO;
 RT:=Rconst*temp;
 z1:=x/RT;  {P/RT}
 expo:=exp_c(-z1*psi[4]);
 z3:=psi[3]*expo; {K}
 z4:=(2+z3/gamma)/2; {alpha}
 z5:=sqrt(z4*z4-1); {beta}
 fnd[2]:=z4-z5;
 fnd[0]:=psi[1]+psi[2]*fnd[2];
 if der then begin
   fnd[1]:=1;
   z2:=psi[3]*z1/2;   {PKo/(2*RT)}
   z6:=1-z4/z5;
   fnd[4]:=-z2*z6*psi[2];
   fnd[3]:=expo*psi[2]*z6/(2*gamma)
 end
end;

procedure solve2parallel;
begin
          z1:=psi[4]+psi[3];   {sigma}
          z2:=psi[4]*psi[3];   {¶=K1*K2}
          z3:=(2*E0-S0+z1);                     {square part coefficient}
          z4:=(z1*(E0-S0)+z2);                  {LINEAR part coefficient}
          z5:=-z2*S0;                          {FREE part}
          z8:=s0; Z7:=z8-2*E0; if Z7<0 then Z7:=0; {limits for the root}
          solve3(z3,z4,z5,z6,z7,z8,i);
          S:=z6;
          z5:=z6*z6;
          z3:=z5+z6*z1+z2;
          if z3=0 then z3:=omicron;
          Z6:=E0*z5/z3;   {Z6 is set to ternary complex conc}
          z3:=S0-z6*2-S;    {Z3 set to total concentrations of both binary complexes}
end;

procedure solve2sequential;
var fminus:boolean;
begin
           Z6:=E0;
           if Z6>(S0/2) then
                z6:=S0/2;
           fminus:=solve4(S0,E0,psi[3],psi[4],z6);
           z3:=z6*z6-(S0+psi[4])*z6+s0*s0/4;
           if Z3>omicron then z3:=sqrt(z3) else z3:=0;
           if fminus then z3:=z3*-1;
           z3:=S0/2-z6+z3
end;

procedure solve2bindingsites(seqbind:boolean;titrmode:integer;demicloche:boolean);
var jobtitr,dilution:boolean;
begin
       SES:=0; ES:=0; l:=1;
       jobtitr:=(titrmode=0);
       if jobtitr then dilution:=false else dilution:=(titrmode>0); (* titrmode: -1=normal titr,0=Job,+1=dilution *)
       if jobtitr then begin
         if demicloche then l:=2;
         S0:=Z*x;
         E0:=Z-S0
       end else
        if dilution then begin
         E0:=X;
         S0:=X*Z
        end else begin
         E0:=Z;
         S0:=X
        end;
       repeat
        if jobtitr then begin
          if e0>z then e0:=z else if e0<0 then e0:=0;
          if s0>z then s0:=z else if s0<0 then s0:=0
        end;
        if seqbind then solve2sequential else solve2parallel;
        SES:=SES+z6;
        ES:=ES+z3;
        dec(l);
        if l>0 then begin z5:=E0; E0:=S0; S0:=z5 end;
       until l=0;
       if demicloche then begin SES:=SES/2; ES:=ES/2 end;
 end;

 (* **********************MAIN PROCEDURE ********************************)
begin
  dercalc:=der;
  funct:=false;
  if (mode<=0) or (mode>harddefined) then exit ;
  case mode of
    1:begin    (* sum of exponents *)
       fnd[0]:=psi[1];
       for i:=1 to submode do begin
        l:=i*2+1;j:=l-1;
        temp:=exp_c(-x*psi[l]);fnd[j]:=temp;
        temp:=temp*psi[j];
        fnd[0]:=fnd[0]+temp;
        fnd[l]:=-temp*x
       end;
       fnd[1]:=1
     end;
    2:begin (* polynomal *)
        n_par:=submode+1;
        for i:=1 to n_par do fnd[i]:=1;
        for i:=2 to n_par do for j:=i to n_par do fnd[j]:=fnd[j]*x;
        fnd[0]:=psi[1];for i:=2 to n_par do fnd[0]:=fnd[0]+fnd[i]*psi[i]
      end;
    3:begin  (* Michaelis *)
        fnd[2]:=psi[3]+x; if fnd[2]=0 then fnd[2]:=omicron;fnd[2]:=1/fnd[2];
        fnd[3]:=psi[2]*x;
        fnd[0]:=fnd[2]*fnd[3]+psi[1];
        if der then begin
          fnd[3]:=-fnd[3]*fnd[2]*fnd[2];fnd[2]:=x*fnd[2]; fnd[1]:=1
        end;
      end;
    4:begin   (* Sum of two Michaelises *)
        fnd[2]:=psi[3]+x; if fnd[2]=0 then fnd[2]:=omicron;fnd[2]:=1/fnd[2];
        fnd[3]:=psi[2]*x;
        fnd[4]:=psi[5]+x; if fnd[4]=0 then fnd[4]:=omicron;fnd[4]:=1/fnd[4];
        fnd[5]:=psi[4]*x;
        fnd[0]:=fnd[2]*fnd[3]+fnd[4]*fnd[5]+psi[1];
        if der then begin
          fnd[3]:=-fnd[3]*fnd[2]*fnd[2];
          fnd[2]:=x*fnd[2];
          fnd[5]:=-fnd[5]*fnd[4]*fnd[4];
          fnd[4]:=x*fnd[4];
          fnd[1]:=1
        end;
      end;
     5: begin (* hill equation *)
          if psi[4]<0 then z3:=0 else z3:=psi[4];
          if x>0 then z1:=exp(ln(X)*z3) else z1:=0;
          if psi[3]>0 then z2:=exp(z3*ln(psi[3])) else z2:=0;
          z4:=z1+z2;
          if z4>0 then fnd[0]:= psi[1]+psi[2]*z1/z4 else
            fnd[0]:=Psi[1]+psi[2];
          dercalc:=false
        end;
     6:begin  (* ligand binding - square root *)
        if (isnan(z)) then exit;
        S0:=X;
        case abs(submode) of
          1:z8:=z;
          2:z8:=x*z;  (* E0 , dilution *)
          3:z8:=x;
          4:begin  (* Job: molar fraction of the substrate in X, Total conc. in Z *)
             S0:=S0*Z;
             z8:=Z-S0;
             if z8<0 then begin
               z8:=0;
               S0:=z
             end
            end
        end;
        z3:=(z8+S0+psi[3])/2;
        z4:=z3*z3-S0*Z8;
        if z4<=0 then z4:=1e-9 else z4:=sqrt(z4);
        fnd[2]:=(z3-z4);
        case abs(submode) of                  (* In all casses but Job's titration the output is normalized to [E]*)
          1: if z8<>0 then fnd[2]:=fnd[2]/z8; (* i.e. we calculate the degree of saturation *)
          2,3:if x<>0 then fnd[2]:=fnd[2]/x   (* "X" corresponds to [S] in titration setup, or to [E] in dilution *)
        end;
        fnd[2]:=fnd[2]-1;
        fnd[0]:=psi[1]+psi[2]*fnd[2];
        fnd[3]:=psi[2]*(1-z3/z4)/2;
        fnd[1]:=1
       end;
     7:begin     (* infinite cooperativity binding *)
       if (isnan(z)) or (isnan(u)) then exit;
        S0:=X;
        case abs(submode) of
         1: solve_n(round(u),X,Z,psi[3],z1) ;
         2: begin (* JOB - X stays for the molar fraction of substrate, Z - total conc. *)
             if S0<0 then S0:=0 else if S0>1 then S0:=1;
             solve_n(round(u),S0*Z,Z*(1-S0),psi[3],z1)
            end;
         3: begin (* DEMICLOCHE-JOB - X stays for the molar fraction of substrate, Z - total conc. *)
             if S0<0 then S0:=0 else if S0>0.5 then S0:=0.5;
             solve_n(round(u),S0*Z,Z*(1-S0),psi[3],z1);
             if (round(u)>1) then begin
               solve_n(round(u),Z*(1-S0),S0*Z,psi[3],z7);
               z1:=(z1+z7)/2
             end
            end
        end;
        fnd[0]:=psi[1]+psi[2]*z1;
        DERCALC:=FALSE
       end;
     8:begin  (* second order kinetics *)
         if (isnan(u)) then exit;
         if (u=1)or(u=0)then begin
           z3:=psi[3]*x;
           z4:=1+z3;
           fnd[2]:=z3/z4;
           if der then fnd[3]:=psi[2]*x/(z4*z4);
         end else begin
           if u<1 then z8:=1/u else z8:=u;
           z4:=x*(z8-1);
           z5:=exp_c(psi[3]*z4);
           u0:=z8*(1-z5);
           v0:=1-z8*z5;
           fnd[2]:=u0/v0;
           if der then fnd[3]:=psi[2]*z8*z4*z5*(z8-1)/(v0*v0);
         end;
         fnd[0]:=psi[1]+psi[2]*fnd[2];
         fnd[1]:=1
      end;
    9:begin   (* reversible 2-nd order kinetics *)
           if (isnan(z)) or (isnan(u)) then exit;
           z2:=z*(1+u);
           z3:=(z2+psi[4])/2; {a ;}
           z4:=sqrt(z3*z3-z*z*u); {b, psi[3]}
           z1:=(z3-z4)/(z3+z4); {beta, psi[4]}
           z5:=exp_c(-z4*2*psi[3]*x);
           u0:=1-z5;
           v0:=1-z1*z5;
           fnd[2]:=u0/v0;
           fnd[0]:=psi[2]*fnd[2]+psi[1];
           if der then begin
             fnd[1]:=1;
             fnd[3]:=psi[2]*z4*x*z5*(1-psi[4])/(v0*v0);
             fnd[4]:=psi[2]*z5*u0/(v0*v0);
           end;
          end;
   10:begin  (* Arrehnius*)
          fnd[1]:=exp_c(-psi[2]/(RCCI*(x+ABSZERO)));
          fnd[0]:=fnd[1]*psi[1];
          if der then
           fnd[2]:=fnd[0]/(-RCCI*(x+ABSZERO))
       end;
    11:kdpress(fnd,psi,x,z);  (* pressure dependence of equilibrium *)
    12:kdpress2(fnd,psi,x,z,u); (* Pressure dep. of 2nd order eq. *)
    13,14{,15}:begin            (* equilibrium with two binding sites: qubic eqilibrium eq., combination of binary and ternary signals *)
       if isnan(z) then exit;
       psi[3]:=max(psi[3],omicron);
       psi[4]:=max(psi[4],omicron); (* Attempt to apply limits *)
       psi[5]:=max(psi[5],0);
       psi[5]:=min(psi[5],1); (* Attempt to apply limits *)
       solve2bindingsites(((submode mod 2)=0),mode-14,submode>2);  (*seqbind,mode-14,demicloche:boolean*)
 {      if mode<>15 then begin }
          if z<>0 then begin
            ES:=ES/Z;
            SES:=SES/z; (* normalize on enzyme concentration or total conc. (JOB) *)
          end;
{        end
       else begin
          if x<>0 then begin
            ES:=ES/X;
            SES:=SES/X; (* dilution *)
          end
       end;
}
       if psi[5]>0.5 then (* if maximal amplitude is observed in the binary *)
          FND[0]:=ES+(1-PSI[5])*SES/psi[5]
       else
          FND[0]:=SES+psi[5]*ES/(1-PSI[5]);
        fnd[0]:=psi[1]-psi[2]+psi[2]*fnd[0];
       DERCALC:=FALSE
      end;
    15: begin (* hill+inhibition: V=Vmax*S*(K2+aS)/(K1*K2+S^n(K2+S)) *)
          if psi[4]<0 then z3:=0 else z3:=psi[4];
          if x>0 then z1:=exp(ln(X)*z3) else z1:=0;
          if psi[3]>0 then z2:=exp(z3*ln(psi[3]))*psi[5] else z2:=0;
          z4:=z1*(psi[5]+x)+z2;
          z1:=z1*(psi[5]+psi[6]*x);
          if z4>0 then fnd[0]:= psi[1]+psi[2]*z1/z4 else
            fnd[0]:=Psi[1]+psi[2];
          dercalc:=false
        end;
    16: begin (* trimeriztion: qubic equation *)
          z5:=TrimRoot(psi[3],x);
          if (not(isnan(z5)))and (x<>0) then fnd[0]:=3*psi[2]*z5/x else fnd[0]:=0;
          fnd[0]:=psi[1]+fnd[0];
          dercalc:=false
        end;
  end;
  der:=dercalc;
  funct:=true;
end;

function opti_fun(mode_,submode_,der_:longint; var x_,z_,u_:extended;
             var psi,fnd:partype):longint; export; stdcall;
var derbool:boolean;
begin
  derbool:=(der_<>0);
  if (mode_<1)or(mode_>harddefined) then begin
    mode_:=SavedMode;
    Submode_:=SavedSubmode;
  end else begin
    SavedMode:=Mode_;
    SavedSubmode:=Submode_
  end;
  if funct(mode_,submode_,derbool,x_,z_,u_,psi,fnd) then opti_fun:=-1 else opti_fun:=0;
end;


exports opti_fun,
        getmode,
        setmode,
        optini ;
begin
 SavedMode:=2 (* polynomal *) ;
 SavedSubmode:=1 (* first order *) ;
end.



