unit timer;
interface
uses   rdtsc,
       spl32base;

function start_timer:longword; export; stdcall;
function get_timer:longint; export; stdcall;

var CPU_ticks: comp;
    CPU_freq: word;
    offset,lasttime,lastdt:real;

implementation

function start_timer:longword; export; stdcall;
var p:pointer; w:longword;
begin
   CPU_ticks:=CPUGETTICK;
   prmblk^.BTIME:=0;
   p:=addr(CPU_ticks); move(p,w,4);
   lasttime:=0; lastdt:=0; offset:=0;
   result:=w+4
end;

function get_timer:longint; export; stdcall;
var mks:comp;
    stmp:single;ltmp:longint;
begin
   mks:=cpugetmks(trunc(CPU_ticks));
   stmp:=mks/1E3+offset;
   if stmp<lasttime then begin
     offset:=lasttime+lastdt;
     stmp:=offset;
     CPU_ticks:=CPUGETTICK;
     prmblk^.BTIME:=0;
   end else begin
     lastdt:=stmp-lasttime;
     lasttime:=stmp;
     prmblk^.BTIME:=round(mks / 100);
   end;
   move(stmp,ltmp,sizeof(single));
   get_timer:= ltmp;
end;


end.
