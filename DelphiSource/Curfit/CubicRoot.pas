unit CubicRoot;
interface
uses math;
function TrimRoot(var S50,C:extended):extended;

implementation

function Sinh(f: extended): extended;
begin
  sinh := (exp(f)-exp(-f))/2;
end;

function Sign(f: extended): extended;
begin
  if f<>0 then sign := f/(abs(f)) else sign:=0;
end;

function Arsh(f: extended): extended;
begin
  arsh := ln(f + sqrt(f*f + 1));
end;

function TrimRoot(var S50,C:extended):extended;
var X,Fi:extended;
(* S50=2*SQRT(KD/3) *)
begin
  Fi:=sqrt(27)*C/S50;
  X:=(C/3)-S50*sinh(arsh(Fi)/3)/sqrt(27);
  result:=x
end;

end.