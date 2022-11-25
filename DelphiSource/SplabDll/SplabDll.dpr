{$H-}
{$I-}
library SplabDll;

uses
  SysUtils,
  Classes,
  Math,
  IniFiles,
  Spl32def in 'Spl32def.pas',
  SPL32BASE in 'SPL32BASE.PAS',
  SPL32STR in 'SPL32STR.pas',
  SPL32_01 in 'SPL32_01.pas',
  GRKERN32 in 'GRKERN32.pas',
  spl32_06 in 'spl32_06.pas',
  timer in 'timer.pas',
  Spl32_08 in 'Spl32_08.pas',
  Spl32arith in 'Spl32arith.pas',
  Spl32init in 'Spl32init.pas',
  Spn_sdec in 'Spn_sdec.pas',
  SplabMessages in 'SplabMessages.pas',
  WinTypes,
  WinProcs,
  Win32crt,
  span2splab in 'span2splab.pas';

{ function ShowCRT:longint; export;stdcall;
begin
   ShowWindow(CRTWindow,SW_Show);
   repeat until keypressed; result:=ord(readkey);
   clrscr;
   ShowWindow(CRTWindow,SW_Hide);
end;
}

exports
 _setddir,
 _GetDirAddr,
 _dsave,
 initgra,
 DX_save,
 DX_load,
 SaveSPC,
 ReadSPC,
 SaveInAsc,
 ReadInAsc,
 replot,
 plotlisted,
 viewresults,
 normy,
 logy,
 suby,
 lfit,
 {
 ooireset,
 OOIINIT,
 OOICLOSE,
  get_spc_,
 put_spc_,
 fluoinit,
 fluorelease,
 get_fluo,
}
 SPLAB32DIR,
 WriteWinSizes,
 readparam,
 writeparam,
 clearmem,
 clear_all,
 delpnt,
 sort,
{ DL_SEND2SE,
 DL_SEND2NU,
 DL_GETCHN,
 DL_SETZ,
 DL_OFFZ,
 DL_TGLZ,
 DL_GETRL,
 DL_SETRL,
 DL_GETSWITCH,
 DL_SETSWITCH,
 DL_LCHN,
 DL_TGLLCHN,
 DL_VA,
 DL_TGLVA,
 DL_LA,
 DL_TGLLA,
 DL_STF,
 DL_TGLSTF,
 DL_INICNT,
 DL_GETCNT,
 DL_CLRCNT,
 DL_STRTCNT,
 DL_STOPCNT,
 DL_STRTBTH,
 DL_STOPBTH, }
 start_timer,
 get_timer,
 push,
 pull,
 getn,
 getz,
 putz,
 getsel,
 getx,
 gety,
 gethead,
 GetRef2Spec,
 GetRef2Axis,
 n_locations_used,
 ptr2obj,
 ptr2prmblock,
 GetDirAddr,
 minimaXY,
 _depth_,
 _pull_,
 _push_,
 _swap_,
 _rot_,
 _drop_,
 _dup_,
 _over_,
 _plus_,
 _minus_,
 _multiply_,
 _divide_,
 _log_,
 _abs_,
 _exp_,
 _smo_,
 _tri_,
 _der_,
 _trunc_,
 _resample_,
 ave_,
 area_,
 min_,
 max_,
  _corpress_,
  _xcorpress_,
  matrix_invert,
 confirm,
 SplabErrorMessage,
 SplabWarning,
 SplabInfo,
 SplabQuestion,
 _getreal,
 _getinteger,
 input_list,
 readstandards,
{ ShowCRT,}
 CRT_ON,
 CRT_OFF,
 CRTCLRSCR,
 CRTIWRITE,
 CRTCR,
 CRTTYPE,
 CRTFWRITE,
 CRTREADAKEY,
 CRTTEXTOUT,
 InitCrt,
 DoneCrt,
 UPNDOT,
 NEXTSTR,
 TRIM,
 PREPARSE,
 TruncStdFname,
 ReadSpanPar,
 WriteSpanPar
;

begin

  ScreenSize.X:=40;
  ScreenSize.Y:=16;
  WindowOrg.X:=1;
  WindowOrg.Y:=480;
  AutoTracking:=False;
  CheckEOF:=False;
  CheckBreak:=False;
  ShowScroll:=TRUE;
  ScrollScreen:=TRUE;
  UseScrollKeys:=False;
  CanResize:=False;
  WCRTSTR:='SpectraLab                              '+#0;
  move(wcrtstr[1],WindowTitle,41);
end.
