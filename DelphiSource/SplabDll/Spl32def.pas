{$H-}
unit Spl32def;

interface
uses mdefine,optidef,math;
Const MaxCur=132;
      MinCur=-10;
      MaxPoints=16384;
      MaxTicks=10;
(*      NO_Z=99999; *)
      NOT_DEFINED=2147483647;
      XFACTOR=1000;
      YFACTOR=1000000;
      minreal=1e-38;
      maxreal=1e38;
      MaxSafeReal=1e10;
      MinSafeReal=1e-10;

type datatype=array [1..MaxPoints] of single;
     rdatatype= ^datatype;
     rstring=^shortstring;
     ptr2int=record
           case boolean of
              true:(p:pointer);
              false:(l:longint)
           end;
const ox=false;
      oy=true;

type fitrecord=record
       fitting_path      :longint; 
       prm               :partype;
       dev               :partype; (* 210 *)
       mode              :longint;
       submode           :longint;
       n_it              :longint;
       n_par             :longint;
       globalfit         :longint;
       u_prm             :single;
       sumsd             :single;
       SqCorr            :single;
       cause             :shortstring;
(*       opt               :array [1..max] of boolean; *)
end;

type rfitrecord=^fitrecord;

TYPE DataSpec=record
      head:          shortstring;
      npts:          longint;
      plotcolor:     longint;
      stepx:         single;
      ysum:          single;
      inter:         longint;
      connect:       longint;
      symbol:        longint;
      z:             single;
      XDATA,YDATA:   rdatatype;
      locX,locY:     longint;
      min,max:       array[False..True] of single;
      fitparam:      rfitrecord;
      spare:         pointer;
end; (*DataSpec*)

     rDataSpec=^DataSpec;

Type AxisType=object
      auto             :longint;
      off              :single;
      lim              :single;
      factor           :single;
      scale            :longint;
      bottom           :single;
      nscaling         :integer;
      token            :string[255];
      scaling          :array[1..12] of single;
      scs              :array[1..12] of string[15];
      footnote         :string[255]
end;
    BIAxis=array[false..true] of ^axistype;
    bufax=array[1..sizeof(axistype)] of byte;

Type DataArray=array [MinCur..MaxCur] of DataSpec;

    type fv = record
        i1:    longint;
        v:     longint;
        i2,i3: longint;
    end;

    type splab_param_block = record
      none0,none1: longint;
      splabdir:  rstring;
      pntptr      :fv;
      tchp        :fv;
      nptoget     :fv;
      REFNUM      :fv;
      kinloc      :fv;
      spectravail :fv;
      kinavail    :fv;
      scanavail   :fv;
      start_w     :fv;
      end_w       :fv;
      current_w1   :fv;
      meas_w      :fv;
      ref_w       :fv;
      current_w2  :fv;
      scan_step   :fv;
      nnorm       :fv;
      scan_rate   :fv;
      dt1         :fv;
      dt2         :fv;
      xcontrol    :fv;
      kinetic     :fv;
      triggr      :fv;
      valve_CTL   :fv;
      ksynchro    :fv;
      doublechan  :fv;
      fixn        :fv;
      fixregion   :fv;
      chanmin     :fv;
      chanmax     :fv;
      nfix        :fv;
      wmin        :fv;
      wmax        :fv;
      stepmin     :fv;
      stepmax     :fv;
      MINDT       :fv;
      maxdt       :fv;
      NUMSCANS    :fv;
      INTTIME_    :fv;
      DELAY_      :fv;
      MASTER_     :fv;
      SLAVE_      :fv;
      AVERAGE_    :fv;
      BOXCAR_     :fv;
      DARK_       :fv;
      SHOWWIN_    :fv;
      MASTER_NUM  :fv;
      TRIG_       :fv;
      ABSRBNCE    :fv;
      Cursor_on   :fv;
      Nu_Port     :fv;
      Sens_Port   :fv;
      Therm_Port  :fv;
      Counters    :fv;
      Relays      :fv;
      Switches    :fv;
      NO_SLAVE    :fv;
      SIMUL_SCAN  :fv;
      LCHN_ON     :fv;
      LCHN_N      :fv;
      SLAVE2      :fv;
      speccode    :fv;
      Ei_Port     :fv;
      CRT_is_ON   :fv;
      calibr: array [0..7] of longint;    (* calibr[0] and calibr[7] are to fill extra space. Do not use! *)
      BCNT        :longword;
      dummy1      :longword;
      BTIME       :longint;
      spectroname :rstring;
      browspath   :rstring
 end;

type  r_splab_param_block= ^splab_param_block;

Type ArrayOfDir=object
   DirArray: DataArray;
   function dir(n:integer): rDataSpec;
   function fitprm(n:integer):rfitrecord;
   procedure CreateDir;
   procedure CreateFitPrm(n:integer);
   function clearfitprmr(fitparam:rfitrecord):longint;
   function clearfitrecordr(fitparam:rfitrecord):longint;
   function newfitprmr(var fitparam:rfitrecord):boolean;
   procedure disposefitprmr(var fitparam:rfitrecord);
   function newfitprm(n:integer):boolean;
   function clearfitprm(n:integer):integer;
   function clearfitrecord(n:integer):integer;
   procedure disposefitprm(n:integer);
   procedure ClearLoc(n:integer);
   function PushPnt(v:single;n:integer;ax:boolean;var i:integer):boolean;
   function PullPnt(var a:single;n:integer;ax:boolean;i:integer):boolean;
   function DelPnt(n,i:longint):boolean;
   function GetDirPtr(memno:integer):pointer;
   function GetNpts(curnum:integer): integer;
   function GetZValue(curnum:integer): single;
   function NLocUsed: integer;

end;

type rArrayOfDir=^arrayofdir;

const MaxLista=20 ;
type  inarr=array[0..MAXLISTA] of longint;
var progname:string;

implementation
procedure ArrayOfDir.CreateDir;
var i:integer;
begin
  i:=Mincur;
  repeat
   with DirArray[i] do begin
      head:='';
      npts:=0;
      plotcolor:=1;
      stepx:=0;
      ysum:=0;
      inter:=0;
      connect:=-1;
      symbol:=0;
      z:=NAN;
      new(xdata);
      new(ydata);
      locx:=0;
      locy:=0;
      fitparam:=NIL;
      spare:=NIL;
      inc(i)
  end
 until i>MaxCur
end;

function ArrayOfDir.dir(n:integer): rDataSpec;
begin
  if n<mincur then
     result:=addr(DirArray[mincur])
   else  if n>maxcur then dir:=addr(DirArray[maxcur]) else
     result:=addr(DirArray[n])
end;

function ArrayOfDir.fitprm(n:integer):rfitrecord;
begin
  if n<mincur then n:=mincur else  if n>maxcur then n:=maxcur;
  result:=DirArray[n].fitparam;
end;

function ArrayOfDir.clearfitprmr(fitparam:rfitrecord):longint;
var i:integer;
begin
   if fitparam<>NIL then
     with fitparam^ do begin
      for i:=0 to MaxP do begin
       prm[i]:=NAN;
       dev[i]:=NAN
      end;
      fitting_path:=0;
      result:=-1
     end
   else result:=0
end;

function ArrayOfDir.clearfitrecordr(fitparam:rfitrecord):longint;
begin
   if fitparam<>NIL then
     with fitparam^ do begin
      clearfitprmr(fitparam);
      mode:=0;
      submode:=0;
      n_it:=0;
      n_par:=0;
      globalfit:=0;
 {     u_prm:=NAN; }
      sumsd:=NAN;
      SqCorr:=NAN;
      cause:='';
      result:=-1
     end
   else result:=0
end;

function ArrayOfDir.newfitprmr(var fitparam:rfitrecord):boolean;
begin
   if fitparam=NIL then begin
     new(fitparam);
     clearfitrecordr(fitparam);
     clearfitprmr(fitparam);
     result:=true
   end else result:=false
end;

procedure ArrayOfDir.disposefitprmr(var fitparam:rfitrecord);
begin
   if fitparam<>NIL then dispose(fitparam)
end;

function ArrayOfDir.clearfitprm(n:integer):integer;
var i:integer;
begin
 with DirArray[n] do result:=clearfitprmr(fitparam)
end;

function ArrayOfDir.clearfitrecord(n:integer):integer;
begin
 with Dirarray[n] do result:=clearfitrecordr(fitparam)
end;

procedure ArrayOfDir.disposefitprm(n:integer);
begin
   with DirArray[n] do if fitparam<>NIL then dispose(fitparam)
end;

function ArrayOfDir.newfitprm(n:integer):boolean;
begin
  with Dirarray[n] do result:=newfitprmr(fitparam)
end;


procedure ArrayOfDir.CreateFitPrm(n:integer);
begin
   newfitprm(n);
end;

procedure ArrayOfDir.ClearLoc(n:integer);
begin
(** Clear memory <n> **)
  if (n>=mincur) and (n<=maxcur) then with DirArray[n] do begin
(*    if (n_locations_used>0)and(n>0)and(npts<>0) then dec(n_locations_used); *)
    z:=NAN; 
    head:='';
    npts:=0;
  end
end;

function ArrayOfDir.PushPnt(v:single;n:integer;ax:boolean;var i:integer):boolean;
begin
   if (i>0)and(i<=maxpoints)and(n>=mincur)and(n<=maxcur) then with DirArray[n] do begin
         if ax then
           ydata^[i]:=v
         else
           xdata^[i]:=v;
         if npts<i then npts:=i;
         result := true;
    end else result:=false;
end;

function ArrayOfDir.PullPnt(var a:single;n:integer;ax:boolean;i:integer):boolean;
begin
   if (i>0)and(i<=DirArray[n].npts)and(n>=mincur)and(n<=maxcur)
    { and (Spectra.Dir(n)^.locX<>0)and(Spectra.Dir(n)^.locY<>0) } then
    with DirArray[n] do begin
      if ax then a:=ydata^[i] else a:=xdata^[i];
      result:= true
    end else result:=false;
end;

function ArrayOfDir.delpnt(n,i:longint): boolean;
var j,jm1:integer;
    ax:boolean;
    a:single;
begin
(*** Исключение точки i из кривой n ***)
 with DirArray[n] do begin
  if (i<1)or(i>npts) then begin delpnt:=false; exit end;
  delpnt:=true;
  if npts=1 then begin ClearLoc(n); exit end;
  if npts>i then
    for j:=i+1 to npts do
     begin
      jm1:=j-1;
      for ax:=oX to oY do begin
       pullpnt(a,n,ax,j);
       pushpnt(a,n,ax,jm1)
      end ;
     end;
     npts:=npts-1;
 end
end;

function ArrayOfDir.GetDirPtr(memno:integer):pointer;
begin
  if (memno>=mincur) and (memno<=maxcur) then result:=addr(DirArray[memno]) else result:=NIL;
end;

function ArrayOfDir.getnpts(curnum:integer): integer;
begin
  result:=DirArray[curnum].npts
end;

function ArrayOfDir.getzvalue(curnum:integer): single;
begin
  result:=DirArray[curnum].z
end;

function ArrayOfDir.NLocUsed: integer;
var i,n:integer;
begin
  n:=0;
  for i:=1 to MaxCur do if DirArray[i].npts>0 then inc(n) ;
  result:=n
end;

end.

