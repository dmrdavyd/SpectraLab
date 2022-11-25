unit cfit2fun;
{$H-}
{$I-}
interface
uses matrix,spl32def,spl32str,optidef;

type short_string = array [1..256] of byte;

var Mods: array[1..maxnmodes] of moderecord;
    nmodes:integer;
    ercode: integer;
    fcurm:  file of shortmoderecord44th;
    fn: shortstring;

function getmode(i:longint):pointer; export; register;
function setmode(refresh:longint):longint; export; stdcall;
function optini(curmode_addr,rsplabdir:pointer):longint; export; stdcall;

implementation

function getmode(i:longint):pointer; export; register;
var j:integer;
begin
  j:=i;
  if j<1 then j:=1 else if j>nmodes then j:=nmodes;
  result:=addr(Mods[i]);
end;

function setmode(refresh:longint):longint; export; stdcall;
var i:integer;
   ss:shortstring;
begin
  ercode:=73;
  setmode:=0;
  if (refresh<>0)or(curmode^.submodl=0) then begin
   with curmode^ do begin
    if (abs(modl)=0)or(abs(modl)>nmodes) then exit;
    ip:=mods[abs(modl)].ip;
    nv:=mods[abs(modl)].nv;
   end;
   with mods[abs(curmode^.modl)] do begin
    if CE then curmode^.CE:=-1 else curmode^.CE:=0;
    if sx then curmode^.sx:=-1 else curmode^.sx:=0;
    if mq then curmode^.mq:=-1 else curmode^.mq:=0;
    if d3 then curmode^.d3:=-1 else curmode^.d3:=0;
    curmode^.np:=np;
    curmode^.pmin:=pmin;
    curmode^.pmax:=pmax;
    if refresh=0 then curmode^.u:=u;
    move(mn,curmode^.mn,sizeof(shortstring));
    move(vn,curmode^.vn,sizeof(shortstring));
    move(pn,curmode^.pn,sizeof(shortstring));
    move(pnames,curmode^.pnames,sizeof(shortstring)*np);
   end;
   if curmode^.submodl=0 then begin
       curmode^.submodl:=1;
       curmode^.parmask:=0
   end
  end;
  with curmode^ do begin
    if modl=1 then begin
       if submodl=0 then submodl:=1;
       pnames[2*(submodl+1)]:=pnames[10];
       np:=2*abs(submodl)+1;
    end;
    if modl=2 then np:=submodl+1;
    if (ip<>0) and (submodl<0) then np:=np-1;
    ercode:=74;
    i:=pos(';',mn);
    if i<>0 then mn:=copy(mn,1,i-1);
    if vn<>'' then begin
       if (abs(submodl)>nv) then submodl:=nv;
       ss:='['+char(48+abs(submodl))+']:';
       i:=pos(ss,vn);
       if i<>0 then begin
         ss:=copy(vn,i+4,255);
         i:=pos(';',ss);
         if i<>0 then ss:=copy(ss,1,i-1)
       end else ss:='';
       if submodl<0 then ss:=ss+'(0)';
       mn:=mn+';'+ss;
    end else
    if pn<>'' then begin
       if (ip<>0) then begin
         str(abs(submodl):1,ss);
       end else begin
         str(u:6:1,ss);
         cut(ss,' ')
       end;
       mn:=mn+';'+pn+'='+ss;
    end;
    setmode:=np;
  end;
  assign(fcurm,fn);
  rewrite(fcurm);
  write(fcurm,shortcurmode^);
  close(fcurm);
end;

function optini(curmode_addr,rsplabdir:pointer):longint; export; stdcall;
var i,j,nmc:integer;
    fprm:text;
    ss:shortstring;
    splabdir:^shortstring;
    pdflt:real;
label abort;


function fieldnum(var ss:string):byte;
var ss1:shortstring;
type string2=string[2];
const fieldnames='NM_MN_PI_PR_SM_ M_ S_CE_3D_NP_VN_//';
begin
  ss1:=copy(ss,1,2);
  i:=pos(ss1,fieldnames);
  fieldnum:=0;
  if (i<>0)and((pos(' ',ss)=3)or(length(ss)=2))and((i mod 3)=1) then begin
     fieldnum:=i div 3 + 1;
     ss:=copy(ss,4,255);
  end
end;

begin
(************* Reading OPTIFUN.INI: fuction info *************)
  curmode:=curmode_addr;
  shortcurmode:=curmode_addr;
  splabdir:=rsplabdir;
  optini:=0;
  ercode:=501;
  fn:=splabdir^+'\'+'optifun.par';
  assign(fprm,fn);
  reset(fprm);
  if ioresult<>0 then goto abort;
  readln(fprm,ss);
  if fieldnum(ss)<>1 then goto abort;
  cut(ss,' ');
  val(ss,j,i);
  if (i<>0)or(j<=0)or(j>maxnmodes) then goto abort;
  nmodes:=j;
  nmc:=1;
  while not(eof(fprm)) and (nmc<=nmodes) do with mods[nmc] do begin
    ip:=0;vn:='';d3:=false;pn:='';mq:=false;sx:=true;mn:='BLANCK';CE:=false;
    u:=0.0;
    repeat
      repeat readln(fprm,ss) until (ss<>'')or(eof(fprm));
      j:=fieldnum(ss);
      case j of
        2:begin mn:=ss;  curmode^.modename[nmc]:=ss end;
        3:begin
            ip:=-1;
            pn:=ss;
            readln(fprm,pmin,pmax,pdflt);
            if ioresult<>0 then goto abort;
            submodl:=round(pdflt)
         end;
        4:begin
            ip:=0;
            pn:=ss;
            readln(fprm,pmin,pmax,pdflt);
             if ioresult<>0 then goto abort;
            u:=pdflt;
         end;
        5:begin
           mq:=true;
           sx:=true
          end;
        6:begin
           mq:=true;
           sx:=false
          end;
        7:begin
           mq:=false;
           sx:=true
          end;
        8:ce:=true;
        9:d3:=true;
       10:begin
           val(ss,np,j);
           if (j<>0)or(np<=0)or(np>nparmax) then goto abort;
           for i:=1 to np do begin
              readln(fprm,pnames[i]);
              if (ioresult<>0) then goto abort;
           end;
          end;
        11:begin
            vn:=ss;
            readln(fprm,nv);
            if ioresult<>0 then goto abort;
            submodl:=1;
         end;
       12:inc(nmc);
      end;
    until j=12;
  end;
  if (nmc>=nmodes) then  optini:=nmodes;
  fn:=splabdir^+'\'+'curmode.par';
  assign(fcurm,fn);
  reset(fcurm);
  if ioresult<>0 then goto abort;
  read(fcurm,shortcurmode^);
  close(fcurm);
  with curmode^ do begin
    if (modl<0) or (modl>nmodes) then modl:=1;
    if submodl=0 then submodl:=1;
    setmode(-1);
  end;
abort: close(fprm)
end;

begin
 nmodes:=maxnmodes;
end.

