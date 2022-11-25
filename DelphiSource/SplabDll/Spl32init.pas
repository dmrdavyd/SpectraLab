unit Spl32init;

interface

uses spl32def,Spl32base,IniFiles,{ LINK2DIGILINK,} Spl32str,Win32Crt,windows;

type tws=array [1..6] of longint;
var WCRTSTR:shortstring;
    winsizes:array [0..6] of longint;
    inipath:string;
    pcmdline: pchar;
    
procedure writeparam; export; stdcall;
function readparam: boolean; export; stdcall;
function SPLAB32DIR:longint; export; stdcall;
procedure writewinsizes(var wstable:tws); export; stdcall;

implementation

procedure writeparam; export; stdcall;
var IniFile: TIniFile;

begin
  with prmblk^ do begin
     IniFile:=TIniFile.Create(splabdir^+'\'+'Spl32prm.ini');
     if spectroname^<>'none' then begin
       if speccode.v<4 then begin
           IniFile.WriteInteger('Spectrometer','Integration time (탎)',inttime_.v);
           IniFile.WriteInteger('Spectrometer','Flash pulse time (탎)',delay_.v);
           IniFile.WriteInteger('Spectrometer','Number of samples to average',average_.v);
           IniFile.WriteInteger('Spectrometer','Triggering mode',triggr.v);
           if speccode.v>1 then begin
             IniFile.WriteInteger('Spectrometer','Master chan. number',Master_num.v);
             IniFile.WriteInteger('Spectrometer','Reference channel ON',doublechan.v);
             IniFile.WriteInteger('Spectrometer','Current Wvl1',current_w1.v);
             IniFile.WriteInteger('Spectrometer','Current Wvl2',current_w2.v)
           end
       end;

       if speccode.v in [2,3,4] then
         IniFile.WriteInteger('Spectrometer','Com port',ei_port.v);
       IniFile.WriteInteger('Scan','Start Wvl',start_w.v);
       IniFile.WriteInteger('Scan','End Wvl',end_w.v);
       IniFile.WriteInteger('Scan','Step',scan_step.v);
       if speccode.v>1 then IniFile.WriteInteger('Scan','Emission scan ON',master_.v);
       if speccode.v=1 then begin
          IniFile.WriteInteger('Scan','NPIX for b/l adjustment',nnorm.v);
          IniFile.WriteInteger('Scan','Absorbance mode',ABSRBNCE.v);
       end;
//       IniFile.WriteInteger('Scan','Scan rate',scan_rate.v);
       IniFile.WriteInteger('Scan','BaseLine location',REFNUM.v);
       IniFile.WriteInteger('Scan','Show progress window',showwin_.v);
       IniFile.WriteInteger('Kinetics','DT1(탎)',dt1.v);
       IniFile.WriteInteger('Kinetics','DT2(탎)',dt2.v);
       IniFile.WriteInteger('Kinetics','Number of points to get', nptoget.v);
       IniFile.WriteInteger('Kinetics','DT change point', tchp.v);
       IniFile.WriteInteger('Kinetics','Sampling Wvl',meas_w.v);
       IniFile.WriteInteger('Kinetics','Reference Wvl',ref_w.v);
       IniFile.WriteInteger('Kinetics','Sampling curve location',kinloc.v);
       if speccode.v=1 then begin
          IniFile.WriteInteger('CCD Detector','Number of scans in the block',numscans.v);
          IniFile.WriteInteger('CCD Detector','Master channel ON',master_.v);
          IniFile.WriteInteger('CCD Detector','Slave channel ON',slave_.v);
          IniFile.WriteInteger('CCD Detector','Alternate slave ON',slave2.v);
          IniFile.WriteInteger('CCD Detector','Number of scans to average',average_.v);
          IniFile.WriteInteger('CCD Detector','Smoothing window size',boxcar_.v);
          IniFile.WriteInteger('CCD Detector','Dark subtraction',dark_.v);
          IniFile.WriteInteger('CCD Detector','Multiscan ON',simul_scan.v);
          IniFile.WriteInteger('DigiLink','Nu_Port',Nu_port.v);
          IniFile.WriteInteger('DigiLink','Sens_Port',Sens_port.v);
          IniFile.WriteInteger('DigiLink','Therm_Port',Therm_port.v);
          IniFile.WriteInteger('DigiLink','Counters',Counters.v)
       end;
    end;
  end;
  IniFile.Free ;
end;

function readparam: boolean; export; stdcall;
var IniFile: TIniFile;
    l:longint;
label read_failure;
begin
  readparam:=false;
  with prmblk^ do begin
     IniFile:=TIniFile.Create(splabdir^+'\'+'Spl32prm.ini');
     spectroname^:=IniFile.ReadString('Spectrometer','Type','none');
     if spectroname^<>'none' then begin
        if (pos('CCD',spectroname^)=1) then speccode.v:=1 else
           if (pos('EI',spectroname^)=1) then speccode.v:=2 else
              if (pos('PTI',spectroname^)=1) then speccode.v:=3 else
        speccode.v:=4;
        if speccode.v<4 then begin
          l:=IniFile.ReadInteger('Spectrometer','Integration time (탎)',1000);
          inttime_.v:=l;
          l:=IniFile.ReadInteger('Spectrometer','Flash pulse time (탎)',20000);
          delay_.v:=l;
          l:=IniFile.ReadInteger('Spectrometer','Number of samples to average',1);
          average_.v:=l;
          if speccode.v>1 then begin
            l:=IniFile.ReadInteger('Spectrometer','Master chan. number',1);
            Master_num.v:=l;
            l:=IniFile.ReadInteger('Spectrometer','Reference channel ON',1);
            doublechan.v:=l;
            l:=IniFile.ReadInteger('Spectrometer','Current Wvl1',450000);
            current_w1.v:=l;
            l:=IniFile.ReadInteger('Spectrometer','Current Wvl2',450000);
            current_w2.v:=l
          end
        end;
        l:=IniFile.ReadInteger('Spectrometer','Triggering mode',0);
        triggr.v:=l;
        if speccode.v in [2,3,4] then
           Ei_port.v:=IniFile.ReadInteger('Spectrometer','Com Port',0);
        l:=IniFile.ReadInteger('Scan','Start Wvl',340000);
        start_w.v:=l;
        l:=IniFile.ReadInteger('Scan','End Wvl',700000);
        end_w.v:=l;
        l:=IniFile.ReadInteger('Scan','Step',1000);
        scan_step.v:=l;
        if speccode.v>1 then begin
          l:=IniFile.ReadInteger('Scan','Emission scan ON',1);
          master_.v:=l
        end;
        if speccode.v=1 then begin
           l:=IniFile.ReadInteger('Scan','NPIX for b/l adjustment',20);
           nnorm.v:=l;
           l:=IniFile.ReadInteger('Scan','Absorbance mode',0);
           ABSRBNCE.v:=l;
        end;
//        l:=IniFile.ReadInteger('Scan','Scan rate',1);
//        scan_rate.v:=l;
        l:=IniFile.ReadInteger('Scan','BaseLine location',0);
        REFNUM.v:=l;
        l:=IniFile.ReadInteger('Scan','Show progress window',1);
        showwin_.v:=l;
        l:=IniFile.ReadInteger('Kinetics','DT1(탎)',NOT_DEFINED);
        if l=NOT_DEFINED then goto read_failure else dt1.v:=l;
        l:=IniFile.ReadInteger('Kinetics','DT2(탎)',NOT_DEFINED);
        if l=NOT_DEFINED then goto read_failure else dt2.v:=l;
        l:=IniFile.ReadInteger('Kinetics','Number of points to get',NOT_DEFINED);
        if l=NOT_DEFINED then goto read_failure else nptoget.v:=l;
        l:=IniFile.ReadInteger('Kinetics','DT change point',NOT_DEFINED);
        if l=NOT_DEFINED then goto read_failure else tchp.v:=l;
        l:=IniFile.ReadInteger('Kinetics','Sampling Wvl',NOT_DEFINED);
        if l=NOT_DEFINED then goto read_failure else meas_w.v:=l;
        l:=IniFile.ReadInteger('Kinetics','Reference Wvl',NOT_DEFINED);
        if l=NOT_DEFINED then goto read_failure else ref_w.v:=l;
        l:=IniFile.ReadInteger('Kinetics','Sampling curve location',NOT_DEFINED);
        if l=NOT_DEFINED then goto read_failure else kinloc.v:=l;

        if speccode.v=1 then begin                         // Ocean optics CCD
           l:=IniFile.ReadInteger('CCD Detector','Number of scans in the block',NOT_DEFINED);
           if l=NOT_DEFINED then goto read_failure else numscans.v:=l;
           l:=IniFile.ReadInteger('CCD Detector','Slave channel ON',NOT_DEFINED);
           if l=NOT_DEFINED then goto read_failure else slave_.v:=l;
           l:=IniFile.ReadInteger('CCD Detector','Alternate slave ON',NOT_DEFINED);
           if l=NOT_DEFINED then slave2.v:=0 else slave2.v:=l;
           l:=IniFile.ReadInteger('CCD Detector','Multiscan ON',NOT_DEFINED);
           if l=NOT_DEFINED then goto read_failure else simul_scan.v:=l;
           l:=IniFile.ReadInteger('CCD Detector','Smoothing window size',NOT_DEFINED);
           if l=NOT_DEFINED then goto read_failure else boxcar_.v:=l;
           l:=IniFile.ReadInteger('CCD Detector','Dark subtraction',NOT_DEFINED);
           if l=NOT_DEFINED then goto read_failure else dark_.v:=l;
        end;
        Nu_port.v:=IniFile.ReadInteger('DigiLink','Nu_Port',0);
        Sens_port.v:=IniFile.ReadInteger('DigiLink','Sens_Port',0);
        Therm_port.v:=IniFile.ReadInteger('DigiLink','Therm_Port',0);
        Counters.v:=IniFile.ReadInteger('DigiLink','Counters',0);
        Relays.v:=IniFile.ReadInteger('DigiLink','Relays',0);
        Switches.v:=IniFile.ReadInteger('DigiLink','Switches',0);
{        DIGI_INIT(Nu_port.v,Sens_port.v,Therm_port.v,Counters.v, Relays.v,Switches.v); }
     end else speccode.v:=0;
  end;
  readparam:=true;
  read_failure:  IniFile.Free ;
end;


function _getsize:longint; export; stdcall;
begin
_getsize:=sizeof(dataspec)
end;

function SPLAB32DIR:longint; export; stdcall;
var IniFile: TIniFile;
    ss:string;
    wsptr: ptr2int;
    i: integer;
begin
  ss:=upshift(GetCommandLine);
  i:=pos('WIN32FOR.EXE',ss);
  if i=0 then
    inipath:=splitpath(progname)
  else
    inipath:=prmblk^.splabdir^;
  ss:=inipath+'\Splab-MMX.ini';
  IniFile:=TIniFile.Create(ss);
  ss:=IniFile.ReadString('Directories','RootDir','');
  if ss='' then begin
     IniFile.WriteString('Directories','RootDir',inipath);
     winsizes[0]:=0
  end else begin
   prmblk^.splabdir^:=ss;
   winsizes[0]:=length(ss)
  end;
  ss:=IniFile.ReadString('Help','Browser','');
  if ss='' then begin
     ss:='help.exe';
     IniFile.WriteString('Help','Browser',ss);
  end;
  prmblk^.browspath^:=ss;
  winsizes[1]:=IniFile.ReadInteger('WinSizes','MainWidth',0); (* splab-width *)
  winsizes[2]:=IniFile.ReadInteger('WinSizes','MainHeight',0); (* splab-height *)
  winsizes[3]:=IniFile.ReadInteger('WinSizes','RightWidth',0); (* rightwidth *)
  winsizes[4]:=IniFile.ReadInteger('WinSizes','GraphWidth',0); (* graphwidth *)
  winsizes[5]:=IniFile.ReadInteger('WinSizes','GraphHeight',0); (* graphheight *)
  winsizes[6]:=IniFile.ReadInteger('WinSizes','TableHeight',0); (* graphheight *)
  IniFile.Free ;
  wsptr.p:=addr(winsizes);
{ Defining position for Win32Crt window: 96 points below Splab control pane }
{ and 168 points to the left of the right side of the Chart window }
  i:=winsizes[4]-168;
  if i>0 then WindowOrg.X:=i else WindowOrg.X:=400;
  i:=winsizes[2]+96;
  if i>0 then WindowOrg.Y:=i else WindowOrg.Y:=360;
  InitWinCrt;
  ShowWindow(CRTWindow,SW_Hide);
  result:=wsptr.l;
  if not(readparam) then writeparam;
  (***************************************
  with prmblk^ do
  { if getcalibr then NO_SLAVE.v:=0 else } begin
     NO_SLAVE.v:=-1;
     MASTER_.v:=1;
     Slave_.v:=0
   end
 ************************************)
end;

procedure writewinsizes(var wstable:tws); export; stdcall;
var IniFile: TIniFile;
    ss:string;
begin
  ss:=inipath+'\Splab-MMX.ini';
  IniFile:=TIniFile.Create(ss);
  IniFile.WriteInteger('WinSizes','MainWidth',wstable[1]);
  IniFile.WriteInteger('WinSizes','MainHeight',wstable[2]);
  IniFile.WriteInteger('WinSizes','RightWidth',wstable[3]);
  IniFile.WriteInteger('WinSizes','GraphWidth',wstable[4]);
  IniFile.WriteInteger('WinSizes','GraphHeight',wstable[5]);
  IniFile.WriteInteger('WinSizes','TableHeight',wstable[6]);
  IniFile.Free
end;

begin
inipath:='';
end.
