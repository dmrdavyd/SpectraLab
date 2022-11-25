unit span2splab;
{$H-}
{$I-}
interface
uses
  SysUtils,
  Classes,
  SPL32STR,
  Spl32def,
  SPL32BASE,
  IniFiles;

  type SpanParBlock=record
    tabname:string;
    rrd,rho2thresh,MaxNr,elimibad,polyorder:longint;
  end;
  function TruncStdFname(ps:pointer):longint;export; stdcall;
  function ReadSpanPar(var ParBlock:SpanParBlock):longint; export; stdcall;
  function WriteSpanPar(var ParBlock:SpanParBlock):longint; export; stdcall;


  implementation
var dfile:text;

function TruncStdFname(ps:pointer):longint;export; stdcall;
var ss:^ShortString;
    ss1,ss2,ss3:ShortString;
begin
  result:=0;
  ss:=ps;
  ss1:=ss^;
  ss2:=prmblk^.splabdir^+'\STANDARDS';
  ss3:=SplitPath(ss1);
  if ss3=ss2 then begin
     ss^:=ss1;
     result:=-1
  end
end;

function ReadSpanPar(var ParBlock:SpanParBlock):longint; export; stdcall;
var i,j:integer;x:real;sss:string;

function cutitle(ss:string):string;
var i:integer;
begin
 i:=pos('::',ss);
 if i<>0 then delete(ss,1,i+1);
 cut(ss,' ');
 cutitle:=ss;
end;

begin
 with ParBlock do begin
  readspanpar:=0;
  sss:=prmblk^.splabdir^;
  sss:=sss+'\SPANPAR.PRM';
  assign(dfile,sss);
  reset(dfile);
  if ioresult<>0 then exit;
  readln(dfile,sss);
  if ioresult<>0 then exit;
  tabname:=cutitle(sss);
  readln(dfile,sss);
  if ioresult<>0 then exit;
  sss:=cutitle(sss);
  val(sss,x,i);
  if i<>0 then x:=1 else if x<0 then x:=0 else if x>1 then x:=1;
  rrd:=round(x*1e6);
  readln(dfile,sss);
  if ioresult<>0 then exit;
  sss:=cutitle(sss);
  val(sss,x,i);
  if i<>0 then x:=0.5 else
     if x<0 then x:=0 else if x>1 then x:=1;
  rho2thresh:=round(x*1e6);
  readln(dfile,sss);
  if ioresult<>0 then exit;
  sss:=cutitle(sss);
  val(sss,MaxNr,i);
  if i<>0 then MaxNr:=3 else
    if MaxNr<1 then MaxNr:=1 else if MaxNr>5 then MaxNr:=1;
  readln(dfile,sss);
  if ioresult<>0 then exit;
  sss:=cutitle(sss);
  if not((sss='0')or(sss='')or(sss[1]='N')) then elimibad:=-1 else elimibad:=0;
  readln(dfile,sss);
  if ioresult<>0 then polyorder:=0 else begin
     sss:=cutitle(sss);
     val(sss,polyorder,i);
     if i<>0 then polyorder:=0 else
       if polyorder>3 then polyorder:=3 else if polyorder<0 then polyorder:=0
  end;
  close(dfile);
  readspanpar:=-1
 end
end;

function WriteSpanPar(var ParBlock:SpanParBlock):longint; export; stdcall;
var i:integer; x:real; sss:string;
begin
 with ParBlock do begin
  writespanpar:=0;
  sss:=prmblk^.splabdir^;
  sss:=sss+'\SPANPAR.PRM';
  assign(dfile,sss);
  rewrite(dfile);
  if ioresult<>0 then exit;
  writeln(dfile,'Standards file name       ::  ',tabname);
  if ioresult<>0 then exit;
  x:=rrd/1e6;
  writeln(dfile,'Threshold for standards   :: ',x:9:6);
  if ioresult<>0 then exit;
  x:=rho2thresh/1e6;
  writeln(dfile,'Threshold for components  :: ',x:9:6);
  if ioresult<>0 then exit;
  writeln(dfile,'Max. number of components :: ',MaxNr:2);
  if ioresult<>0 then exit;
  write(dfile,'Ignore bad standards      ::  ');
  if (elimibad<>0) then writeln(dfile,'Y') else writeln(dfile,'N');
  if ioresult<>0 then exit;
  writeln(dfile,'Order of polynomial       :: ',polyorder:2);
  close(dfile);
  writespanpar:=-1
 end
end;

end.

