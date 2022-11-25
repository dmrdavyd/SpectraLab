 {$H-}
unit SpanIo;
interface
  uses Win32CRT,SpanDef,StrngSub;

 var pgcount:real;
     txtcopy_on:boolean;

function iorpt(i:integer):boolean;
procedure curon;
procedure curoff;
procedure cray(rem:string);
procedure disp(rem:string);
procedure say(rem:string);
function message(rem:string):boolean;
procedure FastText(s:string;y,x:byte);
procedure FastWrite(s:string;y,x,att:byte);

implementation

var maxx,maxy,maxx2,maxy2,quartsize:integer;
    screen_saved:boolean;
    w_ptr:pointer;
    ext:boolean;

procedure FastText(s:string;y,x:byte);
begin
  gotoxy(x,y);
  write(s)
end;

procedure FastWrite(s:string;y,x,att:byte);
var i,l,xe:byte;
begin
  gotoxy(x,y);
  clreol;
  writeln(s)
end;


function iorpt(i:integer):boolean;
var ior:boolean;ioestr:string[3];
begin
  ior:=(i<>0);
  if ior then begin
    str(i:3,ioestr);
    cray('I/O error #'+ioestr)
  end;
  iorpt:=ior
end;

procedure curon;
begin
{ curtgl(false);}
end;

procedure curoff;
begin
{ curtgl(true)}
end;

procedure disp(rem:string);
var i:integer;c:char;
begin
   Fastwrite(rem,25,1,78)
end;

function message(rem:string):boolean;
var i:integer;c:char;
begin
 if rem[0]>#53 then rem[0]:=#53;
 AppendBlanck(rem,53);
 rem:=rem+' Hit any key to continue...';
 disp(rem);
 repeat until keypressed;
 c:=readkey;
 message:=not(c=#27);
 disp('');
end;

procedure say(rem:string);
begin
  disp(rem);
end;

procedure cray(rem:string);
var i:integer;c:char;
begin
{ if rem<>'' then sound(400);}
 if rem<>'' then begin
    if rem[0]>#44 then rem[0]:=#44;
    rem:='Warning: '+rem;
 end;
{ delay(200);
 nosound;}
 message(rem);
end;

end.
