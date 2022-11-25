{$R-}
{$H-}
library F2INT;

uses  SysUtils,
  Classes,SPL32STR;
const XFACTOR=1000;
type longsingle=record
      case boolean of
        false: (l:longint);
        true:  (s:single)
      end;

function UPNDOT(var str:shortstring):longint; export; stdcall;
begin
  str:=upshift(str);
  result:=pos('.',str)
end;
(* FSTRING-BUF FNAME 46 CALL NEXTSTR *)

function NEXTSTR(charcode:longint; var str,nextstr:shortstring):longint; export; stdcall;
var c:char;
begin
  c:=char(charcode);
  nextstr:=next(str,c);
  result:=length(str)
end;

function SINGLE2FIX(a:longint):longint;export; stdcall;
var sa:longsingle;
begin
  sa.l:=a;
  result:=round(sa.s*XFACTOR)
end;

function SINGLE2INT(a:longint):longint;export; stdcall;
var sa:longsingle;
begin
  sa.l:=a;
  result:=round(sa.s)
end;

function INT2FLOAT(var ex:extended;fx:longint):longint; export; stdcall;
var lx:longsingle;
begin
 ex:=fx;
 lx.s:=ex;
 result:=lx.l
end;

function FIX2FLOAT(var ex:extended;fx:longint):longint; export; stdcall;
var lx:longsingle;
begin
 ex:=fx/xfactor;
 lx.s:=ex;
 result:=lx.l
end;

function SINGLE2EXT(var ex:extended; a:single):longint; export; stdcall;
var exx:extended;
begin
 exx:=a;
 move(exx,ex,10);
 result:=round(a)
end;

function EXT2SINGLE(var ex:extended):longint; export; stdcall;
var sx: longsingle;
    lsx: longint;
begin
  sx.s:=ex;
  result:=round(sx.l)
end;

function INT2STRING(li:longint; str_ptr: pointer):longint; export; stdcall;
var convstr:string;
    str_:^string;
begin
   str_:=str_ptr;
   str(li:8,convstr);
   cut(convstr,' ');
   str_^:=convstr;
   INT2STRING:=length(convstr)
end;

function EXT2STRING(var ex:extended; str_ptr: pointer):longint; export; stdcall;
var li: longint; tmp: extended;
    convstr:string;
    str_:^string;
begin
   str_:=str_ptr;
   if abs(ex)<1E-12 then ex:=0;
   li:=round(ex);
   tmp:=abs(ex-li);
   if ex<>0 then tmp:=abs(tmp/ex);
   if tmp<1E-4 then str(li:8,convstr) else
    if (abs(ex)<1E-3)or(abs(ex)>9999.9) then str(ex:5,convstr) else
     if abs(ex)<0.1 then str(ex:8:5,convstr) else
       if abs(ex)<1 then str(ex:8:4,convstr) else
        if abs(ex)<10 then str(ex:8:3,convstr) else
          if abs(ex)<100 then str(ex:8:2,convstr) else
            if abs(ex)<1000 then str(ex:8:1,convstr) else
                str(li:8,convstr);
   cut(convstr,' ');
   str_^:=convstr;
   EXT2STRING:=length(convstr)
end;

function STRING2EXT(var ex:extended; str_ptr: pointer):longint; export; stdcall;
var i: integer;
    str_: ^string;
    convstr:string;
begin
   str_:=str_ptr;
   convstr:=str_^;
   cut(convstr,' ');
   val(convstr,ex,i);
   if i=0 then result:=-1 else string2ext:=0
end;

exports SINGLE2EXT,
        EXT2SINGLE,
        INT2STRING,
        EXT2STRING,
        SINGLE2FIX,
        SINGLE2INT,
        FIX2FLOAT,
        INT2FLOAT,
        STRING2EXT,
        UPNDOT,
        NEXTSTR;
begin
end.
