{$N-}
unit matrix;
interface

const omikron=1e-12;
      maxp=20;

  type mtype=array[0..maxp,1..maxp+1] of extended;
  type partype=array[0..maxp] of extended;

procedure gauss(var a:mtype;u:integer;var x:partype;var e:boolean);
procedure invert(var a:mtype;n:integer;var e:boolean);
procedure multimat(var a,b,c:mtype;m,n,p:integer);
procedure transmat(var a,b:mtype;m,n:integer);

implementation

procedure gauss(var a:mtype;u:integer;var x:partype;var e:boolean);
var temp:extended;
    i,j,k,m,n,u1:integer;
label 1,2,3,4;
begin
  e:=false;
  u1:=u+1;
  n:=0;
4:n:=n+1;
  for k:=n to u do if abs(a[k,n])>omikron then goto 1;
  e:=true;goto 3;
1:if k=n then goto 2;
  for m:=n to u1 do
    begin temp:=a[n,m];a[n,m]:=a[k,m];a[k,m]:=temp end;
2:for j:=0 to u1-n do a[n,u1-j]:=a[n,u1-j]/a[n,n];
  for i:=k+1 to u do
    for j:=n+1 to u1 do a[i,j]:=a[i,j]-a[i,n]*a[n,j];
  if n<>u then goto 4;
  for j:=0 to u-1 do begin i:=u-j;
    for m:=1 to i-1 do begin
      k:=i-m;
      a[k,u1]:=a[k,u1]-a[k,i]*a[i,u1]
    end
  end;
  for i:=1 to n do x[i]:=a[i,u1];
3:end;

procedure invert(var a:mtype;n:integer;var e:boolean);
var q: extended;
    i,j,k:integer;
begin
  e:=true;
  for i:=1 to n do begin
    if abs(a[i,i])<=omikron then exit;
    q:=1/a[i,i];a[i,i]:=1;
    for k:=1 to n do a[i,k]:=a[i,k]*q;
    for j:=1 to n do if i<>j then begin
      q:=a[j,i];a[j,i]:=0;
      for k:=1 to n do a[j,k]:=a[j,k]-q*a[i,k]
    end
  end;
  e:=false
end;

procedure multimat(var a,b,c:mtype;m,n,p:integer);
var i,j,k:integer;
begin
  for i:=1 to m do
   for k:=1 to p do begin
     c[i,k]:=0;
     for j:=1 to n do c[i,k]:=c[i,k]+a[i,j]*b[j,k];
   end;
end;

procedure transmat(var a,b:mtype;m,n:integer);
var i,j,k:integer;
begin
  for i:=1 to m do
   for j:=1 to n do
     b[j,i]:=a[i,j];
end;
end.
