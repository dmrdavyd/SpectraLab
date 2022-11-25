unit OOIHSD;

interface

uses inifiles,math,Spl32def,Spl32base,Spl32_08,link2digilink;
Const TRIG_NORMAL=0 ;    // not triggered
      TRIG_SOFTWARE=1 ;  // external software trigger
      TRIG_SYNC=2 ; // external synchronization (S2000 only)
      TRIG_HARD=3 ; // external hardware trigger (S2000 only)
      OOIHSD_ERROR_NONE=0 ;
      OOIHSD_ERROR_WINDOW_CREATION=-1 ;
      OOIHSD_ERROR_MEMORY_ALLOCATION=-2 ;
      OOIHSD_ERROR_REGISTERING=-3 ;
      OOIHSD_ERROR_SETTING_PARAMS=-4 ;
      OOIHSD_ERROR_BAD_SCAN_NUM=-5 ;
      OOIHSD_ERROR_NOT_INITIALIZED=-6 ;
      OOIHSD_ERROR_CHANNEL_NOT_ENABLED=-7 ;

Type ooihsd_param=record
	inttime: smallint;
	flashdelay: smallint;
	average: smallint;
	boxcar: smallint;
        updatescannumber: smallint;
	extrig: smallint;
	correct_dark: smallint;
	channel_enabled: array[1..8] of smallint;
	numberofscans: smallint;
	showwindow: smallint;
  multiscan: byte;
end;

Type ooihsd_spectrum=record
	timestamp: single;
	data: array [1..2048] of single;
end;
Type rspectrum=^ooihsd_spectrum;
Type fluout=array[1..4] of single;
TYPE rfluout=^fluout;

var OOIERR:integer;
    MEMREQ: longint;
    at_SCAN: boolean;
    OOIDATA: rspectrum;
    OOIPRM: ^ooihsd_param;

FUNCTION GETTICKS:LONGINT;

function prm_init_:longint; export; stdcall;
function ooireset(var param:ooihsd_param):longint;export; stdcall;
function OOICLOSE:integer; export; stdcall;
function OOIINIT:integer; export; stdcall;
function fluoinit(nscns:longint):longint; export; stdcall;
function fluorelease:longint; export; stdcall;
function GETSPC(syncro:boolean):integer;
function GETDATA(SP_N,CH_N:longint):integer;
function get_fluo(f:rfluout):longint;export; stdcall;
function get_spc_(mem_n,ch,nnorm,refnum,sstep,endw,startw:longint):boolean;
             export; stdcall;
function put_spc_(ooidatex:rspectrum;mem_n,ch,nnorm,refnum,sstep,endw,startw:longint):boolean;
             export; stdcall;
function GetCalibr:boolean;

implementation


 Const
      MAXCHAN=2;
(*      NUMSCANS=1;
      INTTIME_=6;
      DELAY_=6;
      AVERAGE_=0;
      BOXCAR_=0;
      DARK_=0;
      SHOWWIN_=0;
      UPDATE_N=0;
      TRIG_=TRIG_NORMAL;
      SIMUL_SCAN=0; *)

type WL_CALIBR_TYPE=record
     WL_0,WL_1,WL_2:single
end;


var ABSINTT,ABSFLASH,FLUINTT,FLUFLASH:integer;
    ABSSTART,ABSMEAS,FLUSTART,FLUMEAS,ABSAVERAN,FLUAVERAN,FLUEND,ABSEND:single;
    WL_CALIBR: array [1..MAXCHAN] of WL_CALIBR_TYPE;

Function OOIHSD_Init(var params: OOIHSD_PARAM):smallint; stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_Init_stdcall';
Function OOIHSD_StartAcquisition:smallint;  stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_StartAcquisition_stdcall';
Function OOIHSD_StopAcquisition:smallint;  stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_StopAcquisition_stdcall';
Function OOIHSD_GetScan(var data: OOIHSD_SPECTRUM; chan,scannum: smallInt):smallint; stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_GetScan_stdcall';
Function OOIHSD_Close:smallInt;  stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_Close_stdcall';
Function OOIHSD_GetTimeStamps(chan:smallInt; var data:single):smallInt;  stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_GetTimeStamps_stdcall';
Function OOIHSD_GetTimeSeries(chan,pixel:smallInt; var timestamp,data: Single): smallInt; stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_GetTimeSeries_stdcall';
Function OOIHSD_EstimateMemoryRequirements(var param: OOIHSD_PARAM): longint;  stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_EstimateMemoryRequirements_stdcall';
Function OOI_GetPointerToArray(var arr:Single):pointer;  stdcall ;
  external 'OOIDRV32.DLL' name 'OOIHSD_GetPointerToArray_stdcall';
Procedure OOIHSD_EnableMultichannelSpectra(chan:smallInt);  stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_EnableMultichannelSpectra_stdcall';
Procedure OOIHSD_DisableMultichannelSpectra;  stdcall ;
  external 'OOIHSD.dll' name 'OOIHSD_DisableMultichannelSpectra_stdcall';

FUNCTION GETTICKS:LONGINT;
 TYPE LI=RECORD
  CASE BOOLEAN OF
   FALSE:(L:LONGINT);
   TRUE:(LO,HI:INTEGER);
END;
 var ticks:li;
 begin
  with ticks do
   ASM
     MOV AH , 00H
     XOR EDX , EDX
     INT 01AH
     MOV CX , HI
     MOV DX , LO
   END;
  getticks:=ticks.l
end;

function pix2wl(pix,ch:integer):single;
begin
 ch:=abs(ch);
 dec(pix);
 with WL_CALIBR[ch] do pix2wl:=WL_0+WL_1*pix+WL_2*pix*pix;
end;

function wl2pix(wl:single;ch:integer):integer;
var i,step:integer; wlthresh:single;
begin
   ch:=abs(ch);
   with WL_CALIBR[ch] do begin
     i:=trunc((wl - wl_0) / wl_1)+1;
     if i>2048 then i:=2048;
     if i<23 then i:=23 ;
     if WL_2<0 then begin step:=1; wlthresh:=wl_1 end
         else begin step:=-1; wlthresh:=wl_1+wl_2*2049 end;
     while (i>22)and(i<2049)and(abs(wl-pix2wl(i,ch))>wlthresh) do i:=i+step;
     wl2pix:=i
  end
end;


function prm_init_:longint; export; stdcall;
var i:integer;
begin
   with ooiprm^ do with prmblk^ do begin
    inttime:=INTTIME_.v;
	  flashdelay:=DELAY_.v;
  	average:=AVERAGE_.v;
	  boxcar:=BOXCAR_.v;
	  updatescannumber:=MASTER_NUM.v;
	  extrig:=TRIG_.v;
	  correct_dark:=DARK_.v;
    for i:=1 to 8 do  channel_enabled[i]:=0;
	  channel_enabled[1]:=MASTER_.v;
    i:=0;
    if SLAVE_.v<>0 then begin
      if ((SLAVE2.v<3)or(SLAVE2.v>8)) then
        i:=2
      else i:=SLAVE2.v;
      channel_enabled[i]:=SLAVE2.v
    end;
	  numberofscans:=NUMSCANS.v;
	  showwindow:=ShowWin_.v ;
    multiscan:=SIMUL_SCAN.v;
  end;
  result:=i
end;

function ooireset(var param:ooihsd_param):longint;export; stdcall;
begin
 ooiprm:=addr(param);
 memreq:=OOIHSD_EstimateMemoryRequirements(ooiprm^);
 if ooidata=nil then new(ooidata);
 ooireset:=memreq;
end;

function OOICLOSE:longint; export; stdcall;
begin
   ooierr:=OOIHSD_Close;
   ooiclose:=ooierr;
   dispose(ooidata);
   ooidata:=nil
end;

function OOIINIT:longint;export; stdcall;
begin
  if (ooiprm^.multiscan<>0) then
   OOIHSD_EnableMultichannelSpectra(1)
  else
   OOIHSD_DisableMultichannelSpectra;
  ooierr:=OOIHSD_Init(ooiprm^);
  ooiinit:=ooierr
end;

function GETSPC(syncro:boolean):integer; { \ stkpos -- }
begin
     AT_SCAN:=true;
     OOIERR:=OOIHSD_StartAcquisition;
     GETSPC:=OOIERR;
end;

function fluoinit(nscns:longint):longint; export; stdcall;
var i,j:integer;
begin
    prm_init_;
    with ooiprm^ do begin
      numberofscans:=nscns;
      inttime:=flashdelay div nscns;
  	  average:=1;
      if ((prmblk^.SLAVE2.v<3)or(prmblk^.SLAVE2.v>8)) then
        i:=2
      else i:=prmblk^.SLAVE2.v;
      for j:=1 to i do channel_enabled[j]:=1;
      multiscan:=1;
    end;
    memreq:=OOIHSD_EstimateMemoryRequirements(ooiprm^);
    if ooidata=nil then new(ooidata);
    result:=ooiinit
end;

function fluorelease:longint; export; stdcall;
begin
   result:=ooiclose;
   prm_init_
end;

function GETDATA(SP_N,CH_N:longint):integer;
begin
  ch_N:=abs(CH_N);
  with ooiprm^ do begin
    if (SP_N>=numberofscans) then sp_n:=numberofscans-1;
    dec(ch_n);
    if (ch_N<0)or(ch_N>=maxchan)then ch_N:=0;
    if(channel_enabled[ch_N+1]=0) then while (ch_n<(maxchan-1)) and (channel_enabled[ch_N+1]=0) do inc(ch_n);
    if (prmblk^.slave2.v>0)and(channel_enabled[ch_N+1]=0) then ch_n:=prmblk^.slave2.v-1;
    if (channel_enabled[ch_N+1]=0) then begin GETDATA:=-999; exit end;
    OOIERR:=OOIHSD_GetScan(ooidata^,ch_n,sp_n);
    GETDATA:=ooierr
  end
end;

function get_fluo(f:rfluout):longint;export; stdcall;
var i,j,k,ch_n,nn:integer;
    a:single;
    imax:array[0..1] of integer;
    max_max,max_sum,max_here,sum_here:array [0..1] of single;
begin
    getspc(true);
    nn:=ooiprm^.numberofscans-1;
    for i:=0 to nn do begin
     for j:=0 to 1 do begin
       sum_here[j]:=0;
       if ((j=1)and(prmblk^.slave2.v>0))then ch_n:=prmblk^.slave2.v-1 else ch_n:=j;
       OOIERR:=OOIHSD_GetScan(ooidata^,ch_n,i);
       for k:=24 to 2047 do begin
         a:=ooidata^.data[k];
         if k=24 then max_here[j]:=a else max_here[j]:=max(max_here[j],a);
          sum_here[j]:=sum_here[j]+a;
       end;
       if i=0 then
         begin
            max_max[j]:=max_here[j];
            max_sum[j]:=sum_here[j]
         end
       else
         begin
            max_max[j]:=max(max_here[j],max_max[j]);
            max_sum[j]:=max(sum_here[j],max_sum[j])
         end;
         if max_max[j]=max_here[j] then imax[j]:=i
     end
   end;
   f^[1]:=max_max[0];
   f^[2]:=max_sum[0]/2024;
   f^[3]:=max_max[1];
   f^[4]:=max_sum[1]/2024;
   result:=imax[1]*256+imax[0]
end;


procedure put_spc(rdata:rspectrum; mem_n,ch,nnorm,refnum:integer; var START_W, END_W, SCAN_STEP :single);
var a,asum,current_w,dark,miny,maxy:single;
    absorbance:boolean;
    i,j,CURRENT_PIX:integer;
begin
   absorbance:=(ch<0);
   ch:=abs(ch); asum:=0;
   if (ch=1)or(prmblk^.SLAVE2.v=0) then begin
    dark:=0;
    for i:=3 to 16 do begin
     dark:=dark+RDATA^.DATA[i]
    end;
    dark:=dark/14;
    CURRENT_W:=START_W;
    i:=1;
    while (Current_w<=end_W)and (i<=maxpoints) do with rdata^ do begin
     current_pix:=wl2pix(current_w,ch);
     a:=(data[current_pix-1]+2*data[current_pix]+data[current_pix+1])/4 - dark;
     if i=1 then begin
       miny:=a;
       maxy:=a;
     end else begin
       miny:=min(a,miny);
       maxy:=max(a,maxy)
     end;
     asum:=asum+a;
     push(a,mem_n,true,i);
     push(current_w,mem_n,false,i);
     inc(i);
     CURRENT_W:=SCAN_STEP + CURRENT_W;
    end
   end else
     for i:=3 to 2048 do begin
       j:=i-2;a:=rdata^.data[i];
       if j=1 then begin
         miny:=a;
         maxy:=a;
       end else begin
         miny:=min(a,miny);
         maxy:=max(a,maxy)
       end;
       asum:=asum+a;
       push(a,mem_n,true,j);
       a:=j;
       push(a,mem_n,false,j)
   end;
   with spectra.dir(mem_n)^ do begin
       ysum:=asum;
       max[true]:=maxy;
       min[true]:=miny;
       stepx:=scan_step;
       plotcolor:=((mem_n-1) mod 15)+1;
       if (scan_step>=1)and((ch=1)or(prmblk^.SLAVE2.v=0)) then
          inter:=1
       else
          inter:=0;
       connect:=1-inter;
   end;
   if absorbance then log_Y(mem_n);
   if (nnorm>0)and (refnum>0) then norm_y(nnorm, mem_n, refnum);
   if (refnum>0) then sub_y(absorbance,mem_n,refnum);
end;

function get_spc_(mem_n,ch,nnorm,refnum,sstep,endw,startw:longint):boolean;
             export; stdcall;
var scan_step,end_w,start_w:single;
    mem2n,refnum2,ch1,ch2:integer;
    cnt1,cnt2:longint;
begin
  scan_step:=sstep/1000;
  start_w:=startw/1000;
  end_w:=endw/1000;
  if  (ooiprm^.multiscan<>0) then
    if (ch=-2) then begin
      ch1:=2; ch2:=-1
    end else begin
      ch1:=ch;
      ch2:=sign(ch)*(3 xor (abs(ch)));
    end
  else begin
    ch1:=ch;
    ch2:=ch
  end;
  get_spc_:=false;
  if ooierr<0 then exit;
  GETSPC(true);
  if ooierr<0 then exit;
  GETDATA(0,CH1);
  if ooierr<0 then exit;
  put_spc(ooidata,mem_n,ch1,nnorm,refnum,START_W,END_W,SCAN_STEP);
  if prmblk^.simul_scan.v<>0 then begin
     if (ooiprm^.multiscan<>0) then begin
       GETDATA(0,CH2);
       if ooierr<0 then exit
     end else begin
       toggle_lchn;
       repeat cnt1:=getcount(0) until cnt1>1;
       repeat
         cnt2:=getcount(0)
       until ((cnt2-cnt1)>ooiprm^.numberofscans)or(cnt2=0);
       GETSPC(true);
       repeat cnt1:=getcount(0) until ((cnt1-cnt2)>ooiprm^.numberofscans)or(cnt1=0);
       toggle_lchn;
       GETDATA(0,CH1);
       if ooierr<0 then exit
     end;
     if mem_n<(Maxcur-3) then
       mem2n:=mem_n+((Maxcur-3) div 2)
     else
       mem2n:=mem_n+1;
     if (refnum<>0)and(refnum<maxcur) then refnum2:=refnum+1 else refnum2:=0;
     put_spc(ooidata,mem2n,ch2,nnorm,refnum2,START_W,END_W,SCAN_STEP);
     with spectra.dir(mem2n)^ do plotcolor:=plotcolor or 128;
  end;
  get_spc_:=true
end;

function put_spc_(ooidatex:rspectrum;mem_n,ch,nnorm,refnum,sstep,endw,startw:longint):boolean;
             export; stdcall;
var scan_step,end_w,start_w:single;

begin
  scan_step:=sstep/1000;
  start_w:=startw/1000;
  end_w:=endw/1000;
  put_spc_:=false;
  if ooierr<0 then exit;
  put_spc(ooidatex,mem_n,ch,nnorm,refnum,START_W,END_W,SCAN_STEP);
  put_spc_:=true;
end;

function GetCalibr:boolean;
var IniFile: TIniFile;
    l:longint;
begin
  GetCalibr:=false;
  IniFile:=TIniFile.Create(prmblk^.splabdir^+'\'+'OOCALIBR.ini');
  with wl_calibr[1] do begin
    l:=IniFile.ReadInteger('Master','WLIntercept*1E6',180366820);
    wl_0:=l/1e6;
    l:=IniFile.ReadInteger('Master','WLFirst*1E6',367914);
    wl_1:=l/1e6;
    l:=IniFile.ReadInteger('Master','WLSecond*1E9',-19050);
    wl_2:=l/1e9;
    with prmblk^ do begin
      calibr[1]:=round(wl_0*1E6);
      calibr[2]:=round(wl_1*1E6);
      calibr[3]:=round(wl_2*1E6)
    end;
  end;
  with wl_calibr[2] do begin
    l:=IniFile.ReadInteger('Slave','WLIntercept*1E6',0);
    if l=0 then begin
        result:=false; l:=345000000;
        (* NO SLAVE PRESENT !! *)
    end else result:=true;
    wl_0:=l/1e6;
    l:=IniFile.ReadInteger('Slave','WLFirst*1E6',350000);
    wl_1:=l/1e6;
    l:=IniFile.ReadInteger('Slave','WLSecond*1E9',0);
    wl_2:=l/1e9;
    with prmblk^ do begin
      calibr[4]:=round(wl_0*1E6);
      calibr[5]:=round(wl_1*1E6);
      calibr[6]:=round(wl_2*1E6)
    end;
  end;
end;

{ ********************

function OOIHSD_DIR:longint; export; stdcall;
begin
  with prmblk^ do
   if getcalibr then NO_SLAVE.v:=0 else begin
     NO_SLAVE.v:=-1;
     MASTER_.v:=1;
     Slave_.v:=0
   end
end;
******************** }

begin

      ABSINTT:=24;
      ABSFLASH:=6;
      FLUINTT:=6000;
      FLUFLASH:=6;
      ABSSTART:=340.0;
      ABSMEAS:=396.0;
      FLUSTART:=400.0;
      FLUMEAS:=600.0;
      ABSAVERAN:=10;
      FLUAVERAN:=1;
      FLUEND:=700;
      ABSEND:=485;

end.
