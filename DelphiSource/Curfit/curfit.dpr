(*$H-*)
library curfit;

uses
  spl32def in '..\SplabDll\Spl32def.pas',
  curfit_def,
  curfit_ini,
  optima,
  estima,
  optidef,
  Link2splab,
  Link2opti,
  WinTypes,
  WinProcs,
  Win32crt,
  mdefine in '..\SplabDll\mdefine.pas',
  matrix in '..\SplabDll\matrix.pas';

var WCRTSTR: string;

function _build( npts,locn:longint; var lim,off :extended; fitprm:rfitrecord):longint; export; stdcall;
var err:boolean;
    llim,loff:extended;
begin
 llim:=lim; loff:=off;
 err:=build_curve(llim,loff,npts,locn,fitprm^.prm,fitprm^.dev);
 if err then result:=0 else begin
    result:=-1 ;
    putfitprm(true,fitprm)
 end
end;

function _get_estimates(fitprm:rfitrecord):longint; export; stdcall;
var err:boolean;
begin
 newfitprm(fitprm);
 err:=not(get_estimates(fitprm));
 if err then result:=0 else begin
    result:=-1 ;
    putfitprm(true,fitprm)
 end
end;

Exports
read_optiprm,
write_optiprm,
mode2curfit,
CurfitInit,
newfitprm44,
clearfitprm,
clearfitrecord,
_PrmReady,
_build,
_get_estimates,
_getfitprm,
_putfitprm,
putfit,
marquar,
simplex,
optimize,
compute_average,
putfit;

begin
  ScreenSize.X:=40;
  ScreenSize.Y:=25;
  AutoTracking:=False;
  CheckEOF:=False;
  CheckBreak:=False;
  ShowScroll:=False;
  ScrollScreen:=False;
  UseScrollKeys:=False;
  CanResize:=False;
  WCRTSTR:='Fit: Non-Linear Regression              '+#0;
  move(wcrtstr[1],WindowTitle,41);
  InitWinCrt;
  ShowWindow(CRTWindow,SW_Hide);
end.
