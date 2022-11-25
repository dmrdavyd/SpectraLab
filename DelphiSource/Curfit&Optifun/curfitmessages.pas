{$H-}

unit CurfitMessages;

interface
Uses Dialogs,forms;

function _getstring(var iv:extended; var ss:String):longint; export; stdcall;

implementation

function _getstring(var iv:extended; var ss:String):longint;
var ssv:AnsiString;
    v:extended;
    err:integer;
begin
  v:=iv;
  if v=0 then ssv:='0' else
    if (abs(v)>=1e6)or(abs(v)<1e-6) then str(v:12:-4,ssv) else
       if abs(v-trunc(v))<1e-6 then str(trunc(v),ssv) else str(v:14:6,ssv);
  ssv:=InputBox('Query',ss,ssv);
  val(ssv,v,err);
  if err=0 then result:=-1 else result:=0;
  iv:=v
end;

begin
{ confirm_del:=CreateMessageDialog('About to delete data. Continue?', mtWarning, mbOKCancel); }
end.

