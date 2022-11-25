unit SPL32STR;
{$H-}
interface

function UpShift(s:string):string;
procedure CutChar(var s:string;c:char; trail:boolean);
procedure CutStartChar(var s:string;c:char);
procedure CutTrailingChar(var s:string;c:char);
procedure Cut(var s:string;c:char);
function SplitPath(var ss:string):string;
function TRIM(ps:pointer;c:longint):longint; export; stdcall;
function next(var s:string;del:char):string;
function UPNDOT(str:pointer):longint; export; stdcall;
function NEXTSTR(charcode:longint; str,nextstr:pointer):longint; export; stdcall;
function PREPARSE(insptr:pointer):longint; export; stdcall;

implementation
const delimiteurs=[' ',#9,';','&',':','!',','];

function UpShift(s:string):string;
var i:integer;
    s1:string;
begin
  s1[0]:=s[0];
  for i:=1 to length(s) do s1[i]:=UpCase(s[i]);
  UpShift:=s1;
end;

procedure CutChar(var s:string;c:char; trail:boolean);
var chset:set of char;
begin

 if c=#0 then chset:=[#43,#45,#46] else (* +- *)
   if c=#128 then chset:= [#0..#42,#44,#47,#58..#255] else    (* non-numeric*)
     chset:=[c];
 if trail then
   while (s<>'')and(s[ord(s[0])] in chset) do s[0]:=pred(s[0])
 else
   while (s<>'')and(s[1] in chset) do delete(s,1,1)
end;

procedure CutStartChar(var s:string;c:char);
begin
  CutChar(s,c,false)
end;

procedure CutTrailingChar(var s:string;c:char);
begin
  CutChar(s,c,true)
end;

procedure Cut(var s:string;c:char);
begin
 CutStartChar(s,c);
 CutTrailingChar(s,c)
end;

function TRIM(ps:pointer;c:longint):longint; export; stdcall;
var ss: ^string;
begin
   ss:=ps;
   cut(ss^,char(c));
   result:=length(ss^)
end;

function SplitPath(var ss:string):string;
var ss1,ss2:string; i:integer;
begin
 ss2:=upshift(ss);
 i:=length(ss2);
 while (i>0)and(ss2[i]<>'\') do dec(i);
 if i>1 then begin
   ss1:=copy(ss2,1,i-1);
   delete(ss2,1,i)
 end else ss1:='';
 result:=ss1;ss:=ss2
end;




function next(var s:string;del:char):string;
var p,p1,p2:integer;
    inparenth:boolean;
    tmps1,tmps2:string;
label l2;
begin
  cut(s,' ');
  if del<>#0 then begin
    CutStartChar(s,'+');
    p:=pos(del,s);
    if p=0 then p:=256;
    if del=#9 then begin
      p1:=pos(';',s);
      if (((p and 255)=0)or(p1<p))and (p1>0) then p:=p1;
      p1:=pos(',',s);
      if (((p and 255)=0)or(p1<p))and (p1>0) then p:=p1;
      p1:=pos(' ',s);
      if (((p and 255)=0)or(p1<p))and (p1>0) then p:=p1;
      p2:=pos('-',s); if (p2=1)or(upcase(s[p2-1])='E') then begin
       p1:=pos('-',copy(s,p2+1,255));
       if p1<>0 then p1:=p1+p2 else p1:=-1*p2
      end else p1:=p2;
      p2:=pos('+',s);
      if (p2>0)and(upcase(s[p2-1])='E') then p2:=0;
      if (p1<=0)or((p2>0) and (p2<abs(p1))) then p1:=p2;
      if (p1>0) and (p1<p) then
      begin s:=copy(s,1,p1-1)+#9+copy(s,p1,255); p:=p1 end;
    end;
l2: next:=copy(s,1,p-1);
    delete(s,1,p);
  end else begin
    p:=0;
    if s[1]='"' then begin
      inc(p);
      repeat
        inc(p)
      until (p>length(s))or(s[p]='"');
      p:=p+1;
      goto l2
    end;
    if s[1]='(' then begin
      delete(s,1,1);
      repeat
        inc(p)
      until (p>length(s))or(s[p]=')');
      if p<=length(s) then begin delete(s,p,1);dec(p) end else begin p:=256; goto l2 end;
    end;
    inparenth:=false;
    repeat
      if s[p]='(' then inparenth:=true else
       if s[p]=')' then inparenth:=false;
      inc(p)
    until (p>length(s))or (not(inparenth))and(s[p] in delimiteurs);
    if p>length(s) then goto l2;
    if S[P] IN [' ',','] then goto l2;
    if p<>1 then begin
       if s[p]=':' then inc(p);
       next:=copy(s,1,p-1);
       delete(s,1,p-1)
    end else begin
       next:=copy(s,1,1);
       delete(s,1,1)
    end;
  end;
end;

function nextword(var s:string):string;
var p,i,j:integer;
begin
  cut(s,' ');
  if (pos('S" ',upshift(S))=1) then begin
      p:=4;
      repeat
        inc(p)
      until (p>=length(s))or((s[p-1]='"') and (s[p]=' '));
      p:=p+1;
  end else p:=pos(' ',s);
  if p=0 then p:=length(s)+1;
  result:=copy(s,1,p-1);
  delete(s,1,p-1)
end;

function UPNDOT(str:pointer):longint; export; stdcall;
var strS:^string;
begin
  strS:=str;
  strS^:=upshift(strS^);
  result:=pos('.',strS^)
end;
(* FSTRING-BUF FNAME 46 CALL NEXTSTR *)

function NEXTSTR(charcode:longint;str,nextstr:pointer):longint; export; stdcall;
var c:char;
    sss:string;
    strS,nextstrS:^string;
begin
  strS:=str;
  nextstrS:=nextstr;
  c:=char(charcode);
  sss:=next(strS^,c);
  nextstrS^:=sss;
  result:=length(strS^)
end;

function PREPARSE(insptr:pointer):longint; export; stdcall;
   var instring: ^string;
       pstr,nextstr,outstring: string;
       a:real; count,nrepeats, err:integer;


function isfloat(s: string): boolean;
var i,v:integer;
begin
      result:=false;
      CutStartChar(s,#0);
      i:=pos('.',s);
      if i=0 then exit;
      delete(S,i,1);
      if length(s)=0 then exit;
      val(s,v,i);
      result:=(i=0)
end;

begin
   instring:=insptr;
   outstring:='';
   pstr:=instring^;
   nrepeats:=1;
   nextstr:=upshift(copy(pstr,1,3));
   if nextstr='DO(' then begin
     nextstr:=next(pstr,#32);
     nextstr:=copy(nextstr,4,255);
     cut(nextstr,')');
     cut(nextstr,#32);
     if length(nextstr)>0 then begin
       val(nextstr,nrepeats,err);
       if err<>0 then nrepeats:=1;
     end
   end;
   while length(pstr)>0 do begin
      nextstr:=nextword(pstr);
      if isfloat(nextstr) then begin
         val(nextstr,a,err);
         if err=0 then begin
           str(a:17:-8,nextstr);
           cut(nextstr,#32);
           CutTrailingChar(nextstr,'0');
         end
      end;
      outstring:=outstring+nextstr+' '
   end;
   cut(outstring,' ');
   instring^:=outstring;
   result:=nrepeats
end;

end.

