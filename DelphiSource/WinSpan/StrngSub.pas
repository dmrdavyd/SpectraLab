 {$H-}
unit strngsub;
interface
type rstring=^string;

const delimiteurs=[' ','!','&',';',':',','];

function next(var s:string;del:char):string;
function UpShift(s:string):string;
procedure CutStartChar(var s:string;c:char);
procedure CutTrailingChar(var s:string;c:char);
procedure Cut(var s:string;c:char);
function FindWildCard(s,s1:string):boolean; (*search s in s1 *)
procedure AppendBlanck(var s:string;l:integer);
procedure Center(var s:string;l:integer);
procedure CutRef(sr:pointer;c:char);
procedure RemoveChar(var s:string;c:char);
procedure NextOperand(var s,s1:string;var c:char);
function RemoveExt(var s:string):string;

implementation
var chset: set of char;
procedure AppendBlanck(var s:string;l:integer);
begin
          while length(s)<l do S:=S+' ';
end;

procedure Center(var s:string;l:integer);
var len,i:integer;
begin
   if length(s)>l then s:=copy(s,1,l);
   len:=length(s);
   len:=trunc((l-len)/2);
   if len>0 then for i:=1 to len do s:=' '+s;
   while length(s)<l do S:=S+' ';
end;

procedure CutChar(var s:string;c:char; trail:boolean);
var chset:set of char;
begin
 if c=#128 then chset:=[#0..#42,#44,#47,#58..#255]     (* non-numeric*)
   else chset:=[c];
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

procedure RemoveChar(var s:string;c:char);
var i:integer;
begin
  repeat
    i:=pos(c,s);
    if i<>0 then delete(s,i,1)
  until i=0
end;

function RemoveExt(var s:string):string;
var i:integer;
begin
  i:=length(s);
  while (i>0)and(s[i]<>'.') do dec(i);
  if i>1 then removeext:=copy(s,1,i-1) else removeext:=s
end;

procedure NextOperand(var s,s1:string;var c:char);
var i:integer;
label empty;
begin
  if length(s)<3 then goto empty;
  i:=2;
  while (i<length(s))and(not(s[i] in ['+','-','/','*'])) do inc(i);
  if i<length(s) then begin
     s1:=copy(s,1,i-1);
     c:=s[i];
     delete(s,1,i);
  end else begin
empty:
    s1:=s;
    s:='';
    c:=' '
  end
end;

procedure CutRef(sr:pointer;c:char);
var s:^string;
begin
  s:=sr;
  cut(s^,c)
end;

function UpShift(s:string):string;
var i:integer;
    s1:string;
begin
  s1[0]:=s[0];
  for i:=1 to length(s) do s1[i]:=UpCase(s[i]);
  UpShift:=s1;
end;

function FindWildCard(s,s1:string):boolean;
var p:byte;
    s2:string;
begin
   CutStartChar(s,'*');
   repeat
     s2:=next(s,'*');
     p:=pos(s2,s1);
     if p<>0 then delete(s1,1,p+length(s2)-1);
   until (p=0) or (s='');
   FindWildCard:=(p<>0)
end;

function next(var s:string;del:char):string;
var p,p1:integer;
    inparenth:boolean;
label l0,l1,l2;
begin
  cut(s,' ');
  if del<>#0 then begin
    p:=pos(del,s);
    if del=#9 then begin
      p1:=pos(',',s);
      if ((p=0)or(p1<p))and (p1>0) then p:=p1;
      p1:=pos(' ',s);
      if ((p=0)or(p1<p))and (p1>0) then p:=p1;
    end;
l0: if p=0 then begin
l1:   next:=s;s:='';
    end else begin
l2:   next:=copy(s,1,p-1);
      delete(s,1,p);
    end
  end else begin
    if s[1]='"' then begin
      p:=1;
      repeat
        inc(p)
      until (p>length(s))or(s[p]='"');
      p:=p+1;
      goto l2
    end;
    if s[1]='(' then begin
      p:=0;
      delete(s,1,1);
      repeat
        inc(p)
      until (p>length(s))or(s[p]=')');
      if p<=length(s) then begin delete(s,p,1);dec(p) end else goto l1;
    end else p:=0;
    inparenth:=false;
    repeat
      if s[p]='(' then inparenth:=true else
       if s[p]=')' then inparenth:=false;
      inc(p)
    until (p>length(s))or (not(inparenth))and(s[p] in delimiteurs);
    if p>length(s) then goto l1;
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

end.




