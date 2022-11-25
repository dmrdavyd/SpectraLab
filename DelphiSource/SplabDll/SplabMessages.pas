{$H-}

unit SplabMessages;

interface
Uses Dialogs,WinProcs,Win32Crt,Math, SPL32STR;
function confirm:longint; export; stdcall;
procedure SplabErrorMessage(var ss:shortstring); export; stdcall;
function SplabWarning(var ss:string):longint; export; stdcall;
function SplabInfo(var ss:string):longint; export; stdcall;
function SplabQuestion(var ss:string):longint; export; stdcall;
function _getreal(var xv:extended; var ss:String):longint; export; stdcall;
function _getinteger(dflt:longint; var ss:String):longint; export; stdcall;
function CRT_ON:longint; export; stdcall;
function CRT_OFF:longint; export; stdcall;
function CRTCLRSCR:longint; export; stdcall;
function CRTTYPE(var s:string):longint; export; stdcall;
function CRTCR:longint; export; stdcall;
function CRTIWRITE(i:longint):longint; export; stdcall;
function CRTFWRITE(var v:extended):longint; export; stdcall;
function CRTREADAKEY: longint; export; stdcall;
function CRTTEXTOUT(iy,ix:longint;var s:string):longint; export; stdcall;
function InitCrt: longint; export; stdcall;
function DoneCrt: longint; export; stdcall;
implementation

var reslt:integer;

function confirm:longint;
begin
  reslt:=MessageDlg('About to delete data. Continue?', mtWarning, mbOKCancel,0);
  confirm:=reslt
end;

function _getreal(var xv:extended; var ss:String):longint;
type longsingle=record
      case boolean of
        false: (l:longint);
        true:  (s:single)
      end;

var ssv:AnsiString;
    v:longsingle;
    err:integer;
    OK:boolean;
begin
  v.s:=xv;
  if v.s=0 then ssv:='0' else
    if (abs(v.s)>=1e6)or(abs(v.s)<1e-6) then str(v.s:12:-4,ssv) else
       if abs(v.s-trunc(v.s))<1e-6 then str(trunc(v.s),ssv) else str(v.s:14:6,ssv);
  OK:=InputQuery('Query',ss,ssv);
  val(ssv,v.s,err);
  if OK then begin
    if err=0 then xv:=v.s else begin
     v.s:=NAN;
     xv:=NAN;
    end;
    result:=v.l
  end else result:=-1
end;

procedure SplabErrorMessage(var ss:string);
begin
  MessageDlg(ss, mtError, [mbOK], 0);
end;

function SplabWarning(var ss:string):longint;
begin
  reslt:=MessageDlg(ss, mtWarning,mbOKCancel,0);
  result:=reslt
end;

function SplabInfo(var ss:string):longint;
begin
  reslt:=MessageDlg(ss,mtInformation, [mbOK] ,0);
  result:=reslt
end;

function SplabQuestion(var ss:string):longint;
begin
  result:=MessageDlg(ss, mtConfirmation,[mbNo,mbYes],0);
end;

function _getinteger(dflt:longint; var ss:String):longint;
var ssv:AnsiString;
    L:longint;
    err:integer;
    OK:boolean;
begin
  str(dflt,ssv);
  OK:=InputQuery('Query',ss,ssv);
  val(ssv,L,err);
  if OK and (err=0) then result:=L else result:=-1;
end;

function CRT_ON:longint; export; stdcall;
begin
ShowWindow(CRTWindow,SW_Show);
result:=-1
end;

function CRT_OFF:longint; export; stdcall;
begin
ShowWindow(CRTWindow,SW_Hide);
result:=-1
end;

function CRTCLRSCR:longint; export; stdcall;
begin
clrscr;
result:=-1
end;

function CRTTYPE(var s:string):longint; export; stdcall;
begin
write(s);
result:=-1
end;

function CRTCR:longint; export; stdcall;
begin
writeln('');
result:=-1
end;


function CRTIWRITE(i:longint):longint; export; stdcall;
begin
write(i);
result:=-1
end;

function CRTFWRITE(var v:extended):longint; export; stdcall;
var convstr:string;
begin
     if V>=1000 then  begin str(round(v):16,convstr); cut(convstr,' ') end else begin
       if v=0 then convstr:='0.0' else
         if abs(v)<0.001 then str(v:17:-8,convstr) else
            if abs(v)<1 then str(v:12:8,convstr) else
              if abs(v)<10 then str(v:12:6,convstr) else
                if abs(v)<100 then str(v:12:4,convstr) else
                      str(v:12:2,convstr);
       cut(convstr,' ');
       CutTrailingChar(convstr,'0');
     end;
     if convstr[length(convstr)]='.' then convstr:=convstr+'0';
     write(convstr);
     result:=-1
end;

function CRTTEXTOUT(iy,ix:longint;var s:string):longint; export; stdcall;
begin
  TextOutPos(ix,iy,s);
  Result:=-1
end;


function CRTREADAKEY: longint; export; stdcall;
Var c:char;
begin
  GotoXY(39,16);
  c:=ReadKey;
  Result:=ord(c)
end;

function InitCrt: longint; export; stdcall;
begin
InitWinCrt;
result:=-1
end;

function DoneCrt: longint; export; stdcall;
begin
DoneWinCrt;
result:=0
end;

end.

