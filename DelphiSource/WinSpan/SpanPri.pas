 {$H-}
unit spanpri;
interface
uses SpanDef,matrix,Win32CRT,spanio,matrdef;

procedure compute_alfa(rrr,rrbase:rdata;var alfa:alfatype;n,ty:integer;
                         var vect:matprof);

procedure mainv(m0,                       (* n of prof *)
                len:integer;           (* length of each prof. *)
                var psi,vecc:matprof; (* psi- array pointers on
                                         profile [1..m1,1..n1] and average
                                         of profile  [m1+1,1..n1]
                                         vecc- array of pointers on
                                         main vectors *)
                var lambda:alfatype;
                var ty:integer;       (* n of main comp. *)
                var bon:boolean;
                var lsum,lsum1:real;
                    qrho:real (* max. relative residual dispersion *);
                var UserMaxPrin:integer );

implementation

procedure compute_alfa(rrr,rrbase:rdata;var alfa:alfatype;n,ty:integer;
                         var vect:matprof);
var j,k:integer;
begin
       for j:=1 to ty do
        begin
           alfa[j]:=0;
           for k:=1 to n do
             alfa[j]:=alfa[j]+(rrr^[k]-rrbase^[k]*alfa[0])*vect[j]^[k];
        end;
end;

procedure mainv(m0,len:integer;var psi,vecc:matprof;
                var lambda:alfatype;
                var ty:integer;var bon:boolean;
                var lsum,lsum1:real;qrho:real;var UserMaxPrin:integer);
 var i,j,i1,j1,m1:integer;
     a,s:array [0..maxmat] of rdata;
     mval:rdata;
     n11:integer;


procedure jacobi(n:integer;rho:real);     (* sobstv. znacheniya i vectora *)
  var norm1,norm2,thr,dthr,mu,omega,sint,cost,int1,v1,v2,v3,siglen,sigstep
                                                                     :real;
      i,j,p,q,ind,NCycle:integer;
      SigStr:string;
  begin
     for i:=1 to n do
       for j:=1 to i do
         if i=j
          then s[i]^[j]:=1
          else begin
                  s[i]^[j]:=0;
                  s[j]^[i]:=0;
               end;
     int1:=0;
     for i:=2 to n do
       for j:=1 to i-1 do
         int1:=int1+2*sqr(a[i]^[j]);
     if int1=0
      then exit;
     thr:=sqrt(int1);
     norm1:=thr;
     norm2:=(rho/n)*norm1;
     ind:=0;
     i:=0;dthr:=thr;
     while dthr>norm2 do begin dthr:=dthr/n; i:=i+1 end;
     if i>1 then sigstep:=24/(i-1) else sigstep:=24;
     siglen:=0;
     thr:=thr/n;
     SigStr:='........................';
     fasttext(SigStr,17,28);
     fasttext('Cycle',18,35);
     NCycle:=0;
     repeat
       inc(NCycle);
       str(NCycle:4,SigStr);
       fasttext(SigStr,18,40);
       for q:=2 to n do
       for p:=1 to q-1 do
         if abs(a[p]^[q])>=thr
          then
           begin
              ind:=1;
              v1:=a[p]^[p];
              v2:=a[p]^[q];
              v3:=a[q]^[q];
              mu:=0.5*(v1-v3);
              if mu=0
               then omega:=-1
               else if mu>0
                     then omega:=-v2/sqrt(sqr(v2)+sqr(mu))
                     else omega:=v2/sqrt(sqr(v2)+sqr(mu));
              sint:=omega/sqrt(2*(1+sqrt(1-sqr(omega))));
              cost:=sqrt(1-sqr(sint));
              for i:=1 to n do
                begin
                   if ((i<>p) OR (i<>q))
                    then
                     begin
                        int1:=a[i]^[p];
                        mu:=a[i]^[q];
                        a[q]^[i]:=int1*sint+mu*cost;
                        a[i]^[q]:=int1*sint+mu*cost;
                        a[p]^[i]:=int1*cost-mu*sint;
                        a[i]^[p]:=int1*cost-mu*sint;
                     end;
                   int1:=s[i]^[p];
                   mu:=s[i]^[q];
                   s[i]^[q]:=int1*sint+mu*cost;
                   s[i]^[p]:=int1*cost-mu*sint;
                end;
              mu:=sqr(sint);
              omega:=sqr(cost);
              int1:=sint*cost;
              a[p]^[p]:=v1*omega+v3*mu-2*v2*int1;
              a[q]^[q]:=v1*mu+v3*omega+2*v2*int1;
              a[p]^[q]:=(v1-v3)*int1+v2*(omega-mu);
              a[q]^[p]:=(v1-v3)*int1+v2*(omega-mu);
           end;
       if ind=1 then begin
          ind:=0;
          thr:=thr/n;
          siglen:=siglen+sigstep;
          SigStr:='';
          for i:=1 to round(siglen) do SigStr:=SigStr+'#';
          for i:=round(siglen+1) to 24 do SigStr:=SigStr+'.';
          fasttext(SigStr,17,28);
       end;
     until (thr<=norm2)or(NCYCLE>100);
     for i:=1 to n do
       for j:=1 to i-1 do
         begin
            mu:=s[i]^[j];
            s[i]^[j]:=s[j]^[i];
            s[j]^[i]:=mu;
         end;
     clrscr;
end;                                           (*-----END OF JACOBI-----*)

 procedure matcomp(m,n:integer);                 (*  matriza component    *)
  var i,j,k1,sn,pr,pn,kr:integer;
      sumr:real;c:char;
      boxlen,linlen:real;
      curlinlen:integer;
  begin
      boxlen:=24/n;
      curlinlen:=0;
      fasttext('........................',17,28);
      for i:=1 to n do begin
        linlen:=i*boxlen;
        j:=round(linlen);
        if j>curlinlen then begin
          for curlinlen:=curlinlen+1 to j do
           fasttext('#',17,27+curlinlen);
        end;
        for j:=1 to i do
          begin
             a[i]^[j]:=0;
             for k1:=1 to m do
                       a[i]^[j]:=a[i]^[j]+psi[k1]^[i]*psi[k1]^[j];
             a[i]^[j]:=a[i]^[j]/len;
             a[j]^[i]:=a[i]^[j];
          end;
      end
  end;                                          (*-----END OF MATCOMP-----*)

procedure maxval(n:integer);              (*  uporyadoch. sobstv. znach.  *)
 var i,j,ge:integer;
     gw,gq:real;
 begin
    for i:=1 to n-1 do
     begin
        gw:=ABS(a[i]^[i]);
        ge:=i;
        for j:=i+1 to n do
         if gw<ABS(a[j]^[j])
          then
           begin
              gw:=ABS(a[j]^[j]);
             ge:=j;
           end;
        if ge<>i
        then
          begin
             gw:=a[ge]^[ge];
             a[ge]^[ge]:=a[i]^[i];
             a[i]^[i]:=gw;
             for j:=1 to n do
              begin
                 gq:=s[i]^[j];
                 s[i]^[j]:=s[ge]^[j];
                 s[ge]^[j]:=gq;
              end;
          end;
     end;
 end;                                            (*-----END OF MAXVAL-----*)

 procedure glkoeff(n:integer;qrho:real);   (* col-vo gl. component *)
  var i:integer;
  begin
     lsum1:=0;
     for i:=1 to n do
      lsum1:=lsum1+a[i]^[i];
     lsum:=0;
     ty:=0;
     repeat
       ty:=ty+1;
       lsum:=lsum+a[ty]^[ty];
       lambda[ty]:=a[ty]^[ty]
     until (lsum>=lsum1*qrho)or(ty>=UserMaxPrin);
  end;                                          (*-----END OF GLKOEFF-----*)

procedure normatr;           (*  usrednenie po matrize      *)
  var i,j,ij:integer;temp:pointer;
  begin
      for j:=m1+1 downto 2 do begin
        for i:=1 to len do
          psi[j]^[i]:=(psi[j]^[i]-psi[1]^[i]);
      end;
      temp:=psi[1];
      for i:=1 to m1 do psi[i]:=psi[i+1];
      psi[m1+1]:=temp
  end;                                          (*-----END OF NORMATR-----*)

  procedure NormRemove;
   var i,j:integer;
       k,l:shortint;
       temp:pointer;
   begin
      for j:=1 to m1 do begin
       for i:=1 to len do
           psi[j]^[i]:=psi[j]^[i]+psi[m1+1]^[i];
      end;
      temp:=psi[m1+1];
      for i:=m1 downto 1 do psi[i+1]:=psi[i];
      psi[1]:=temp;
   end;                                     (*-----END OF PROVERKA-----*)

begin
     bon:=false;
     m1:=m0-1;
     if UserMaxPrin>MaxPrin then UserMaxPrin:=MaxPrin;
     if len>maxmat then exit;
     n11:=len;
     for i:=0 to n11 do getmem(s[i],n11*sizeof(real));
     for i:=1 to n11 do getmem(a[i],n11*sizeof(real));
     fasttext('Evaluating matrix...     ',16,30);
     normatr;
     matcomp(m1,n11);
     fasttext('Eigenvalue analysis...',16,30);
     jacobi(n11,omikron);
     maxval(n11);
     glkoeff(n11,qrho);
     NormRemove;
     for i:=1 to n11 do freemem(a[i],n11*sizeof(real));
     for i:=0 to n11 do if i<=ty then vecc[i]:=s[i]
        else freemem(s[i],n11*sizeof(real));
     bon:=TRUE;
end;
(*-----END OF MAIN-----*)

end.

