unit curfit_def;
interface
uses Spl32def,Link2opti,Link2splab,optidef,mdefine,Math;

type opti_prm = record
     nitmax:longint;
     dummy1:longint;
     autolambda:longint;
     lambda:extended;
     accur:extended;
     smin:extended;
     nu:extended;
     alpha:extended;
     sm:extended;
     lim:extended;
     spsi:extended;
     dummy2:longint;
     nit:longint;
     dummy3:longint;
     way:longint;
     dummy4:longint;
     fitglobal:longint
     end;
type r_optprm = ^opti_prm ;
     rstring = ^shortstring ;
var  optiprm: r_optprm;
     sign_exp:integer;
     midy,savealfa: real;
     saveautol:boolean;
     dp:partype;


function clearfitprm(fitparam:rfitrecord):longint;export;stdcall;
function clearfitrecord(fitparam:rfitrecord):longint;export;stdcall;
function newfitprm(var fitparam:rfitrecord):boolean;
procedure disposefitprm(var fitparam:rfitrecord);

function newfitprm44(cdir:rdataspec):longint;export;stdcall;
function getfitprm(fitparam:rfitrecord):longint;
procedure putfitprm(refresh:boolean;fitparam:rfitrecord);
function _getfitprm(DataSet:rDataSpec):longint;export;stdcall;
function _putfitprm(DataSet:rDataSpec):longint;export;stdcall;
function _PrmReady(curdef:rdataspec):longint; export;stdcall;

implementation

function clearfitprm(fitparam:rfitrecord):longint;export;stdcall;
var i:integer;
begin
   result:=rSpectra^.clearfitprmr(fitparam);
end;

function clearfitrecord(fitparam:rfitrecord):longint;
begin

   result:=rSpectra^.clearfitrecordr(fitparam)
end;

procedure disposefitprm(var fitparam:rfitrecord);
begin
   rSpectra.disposefitprmr(fitparam);
end;

function newfitprm(var fitparam:rfitrecord):boolean;
begin
   result:=false;
   if fitparam=NIL then begin
     new(fitparam);
     clearfitrecord(fitparam);
     clearfitprm(fitparam);
     result:=true
   end;
end;

function newfitprm44(cdir:rdataspec):longint;export;stdcall;
begin
  if newfitprm(cdir^.fitparam) then result:=-1 else result:=0
end;

function _PrmReady(curdef:rdataspec):longint; export;stdcall;
begin
  if EstimatesReady(curdef^.fitparam) then result:=-1 else result:=0
end;

function getfitprm(fitparam:rfitrecord):longint;
begin
   curmode^.modl:=fitparam^.mode;
   curmode^.submodl:=fitparam^.submode;
   curmode^.u:=fitparam^.u_prm;
   result:=setmode(-1);
end;

procedure putfitprm(refresh:boolean;fitparam:rfitrecord);
var d3here:longint;
begin
   if refresh then with curmode^ do
   fitparam^.mode:=curmode^.modl;
   fitparam^.submode:=curmode^.submodl;
   fitparam^.u_prm:=curmode^.u;
   fitparam^.n_par:=curmode^.np;
   if fitparam^.fitting_path=0 then fitparam^.n_it:=0;
   fitparam^.cause:=''
end;


function _getfitprm(DataSet:rDataSpec):longint;export;stdcall;
begin
     if DataSet^.fitparam<>NIL then
        result:=getfitprm(DataSet^.fitparam)
     else result:=0
 end;

function _putfitprm(DataSet:rDataSpec):longint;export;stdcall;
begin
    result:=0;
    if DataSet^.fitparam<>NIL then begin
       putfitprm(false,DataSet^.fitparam);
       result:=-1
    end
end;


end.

