132    VALUE  MaxCur
-10     Value MinCur
16384   VALUE  MAXPOINTS
256    CONSTANT HEADLEN
10    CONSTANT MAXTICKS

ZSTRING SPLABDIR$
ZSTRING SPECTRONAME$
ZSTRING BROWSPATH$
ZSTRING LSTRING
ZSTRING L0STRING
ZSTRING TMPSTR
ZSTRING TMPSTR2
ZSTRING TMP$
ZSTRING FNAME
ZSTRING FNAME0
Zstring SS$
Zstring ss1$



ColorObject FrmColor      \ the background color

1280 value maxwidth
1024 value maxheight
20 constant FontHeight
438  constant min-splab-width
268 constant min-splab-height \ 268
12 constant min-right-width
56 constant min-header-width
min-splab-width  value splab-width
min-splab-height value splab-height \ 268
min-right-width value rightwidth
320 constant graph-min-width
320 constant graph-min-height
graph-min-width value graph-start-width
graph-min-height value graph-start-height
2 value thickness
min-splab-width min-right-width - thickness - value LeftWidth
0   value inix
0   value iniy
152 constant min-table-height  \ 152
min-table-height value tableheight  \ 152
0 value ToolBarHeight
0 VALUE DataSpecSize
0 VALUE _CURDIR

FALSE VALUE    auto_corr
FALSE VALUE    scan_on
FALSE VALUE    press
FALSE VALUE    measuring
FALSE VALUE    triggeron
FALSE  VALUE OXYMEASURE
FALSE VALUE STOP-EXEC
1  value LAST-OBJ
0  value LAST-PLOT

\ *********************** PRMBLK record of SPLAB.DLL starts here. Do not change!
         Variable obj
         create   ^splabdir$ cell allot
1        VALUE    pnt_ptr
0        VALUE    tchp
64       VALUE    nptoget
MAXCUR   VALUE    REFNUM
MAXCUR 2 -  VALUE    kinloc
TRUE     VALUE    spectravail
TRUE     VALUE    kinavail
TRUE     VALUE    scanavail
340 XFACTOR * VALUE    start_w
700 XFACTOR * VALUE    end_w
450 XFACTOR * VALUE    current_w1
418 XFACTOR * VALUE    meas_w
490 XFACTOR * VALUE    ref_w
450 XFACTOR * VALUE    current_w2
1   XFACTOR * VALUE    scan_step
8        VALUE      nnorm
0        VALUE      scan_rate
6000     VALUE      dt1                   \ microsec
6000     VALUE      dt2                   \ microsec
TRUE     VALUE    xcontrol
TRUE     VALUE    kinetic
0        VALUE    triggr
0        VALUE    valve-CTL
FALSE    VALUE    ksynchro
TRUE     VALUE    doublechan
TRUE     VALUE    Fixn
TRUE     VALUE    fixregion
0        VALUE    chanmin
1        VALUE    chanmax
2048     VALUE    nfix
192 XFACTOR *     VALUE    wmin
900 XFACTOR *     VALUE    wmax
365 XFACTOR 1000 M*/  VALUE    stepmin
10  XFACTOR *      VALUE    stepmax
1        VALUE    MINDT                   \ msec
999999    VALUE    maxdt                   \ msec
1  VALUE NUMSCANS
6  VALUE INTTIME_
20 VALUE FlashTime_
TRUE  VALUE MASTER_
0  VALUE SLAVE_
1  VALUE AVERAGE_
0  VALUE BOXCAR_
0  VALUE DARK_
0  VALUE SHOWWIN_
1  VALUE Master#
0 VALUE TRIG_
FALSE  VALUE ABSORBANCE
FALSE   Value CursorON
0 VALUE Nu_Port
0 VALUE Sens_Port
0 VALUE Therm_Port
0 VALUE Counters
0 VALUE Relays
0 VALUE Switches
0 VALUE NO_SLAVE_PRESENT
0 VALUE SIMUL_SCAN
FALSE  Value LCHN_ON
0 VALUE LCHN#
0 VALUE SLAVE2
0 value speccode
0 VALUE Spec_Port
FALSE VALUE CRT_IS_ON
create OO-CALIBR 180366820 , 367914 , -20 , 342700594 , 351949 , -8 ,
create BCNT cell allot
create BTIME cell allot
create ^SPECTRONAME$ cell allot
create ^BROWSPATH$ cell allot

\ *********************** end of PRMBLK record of SPLAB.DLL

CREATE XMIN 10 ALLOT
CREATE XMAX 10 ALLOT
CREATE YMIN 10 ALLOT
CREATE YMAX 10 ALLOT
\ =========================== SPEC-DEC (SPAN) variables: =======================

20 constant max_lista
CREATE LISTA MAX_LISTA 1 + CELLS ALLOT
0 value nstd
0 value polyorder
130 value fitdest
131 value polydest
0 value WeightLoc
FALSE value FileFit
zstring std$
zstring std$1
zstring std$2

1 value ncomponents

CREATE FTMP 10 ALLOT
CREATE FTMP1 10 ALLOT
\ ==============================================================================


:Class DataSpec <SUPER OBJECT
   record: AddrOf
      HEADLEN   BYTES header
      int       npts
      int       plotcolor
      int       stepx
      int       ysum
      int       inter
      int       connect
      int       symbol
      int       zz
      int       XDATA_
      int       YDATA_
      int       XDATA
      int       YDATA
      int       minx
      int       miny
      int       maxx
      int       maxy
      4 bytes   fitrec
      4 bytes   spareptr
   ;recordsize: SizeOfDataSpec


:M !FZ: E2S to ZZ ;M
:M !NZ: to ZZ ;M
:M !XZ: X2S to ZZ ;M
:M !IZ: XFACTOR * X2S to ZZ ;M



:M @FZ: ZZ S2E ;M
:M @XZ: ZZ S2X ;M
:M @IZ: ZZ S2X XFACTOR / ;M

:M !color: to plotcolor ;M

:M !inter: to inter ;M

:M !connect: to connect ;M

:M !symbol: to symbol ;M

:M !npts: to npts ;M

:M @header: header 1+ header C@ ;M

:M !header:  HEADLEN 1- min put: tmpstr tmpstr header len: tmpstr 2 + HEADLEN min move ;M

:M ClassInit:   ( -- )
      SizeOfDataSpec to DataSpecSize
;M

:M ALLOCXY:
\  ( --- addr )
     ydata_
     to ydata
     xdata_
     to xdata
;M

:M PUSHY:
\ ( Y # -- )
        dup 1 + npts > if
         dup 1 + to npts
        then
        E2S swap cells ydata + !
;M

:M PUSHX:
\ ( X # -- )
        E2S swap cells xdata + !
\       1+ FBUF F! FBUF rel>abs  call _pushx
;M

:M PUSH:
\ ( XY # AX -- )
        IF PUSHY: self ELSE PUSHX: self then
;M

:M SPULLY:
\ ( # -- Y )
        cells ydata + @
;M

:M SPULLX:
\ ( # -- X )
        cells xdata + @
;M

:M PULLY:
\ ( # -- Y )
        cells
        ydata +
        @
        S2E
;M

:M PULLX:
\ ( # -- X )
        cells xdata + @ S2E
;M

:M PULL:
\ ( # AX -- XY )
        IF PULLY: self ELSE PULLX: self THEN
;M

;Class

:Class AxisType <SUPER OBJECT
  record: AddrOf
      int    auto
      int    offs
      int    lim
      int    factor
      int    scale
      int    bottom
      int    nscaling
      256 BYTES token
      12  CELLS BYTES scaling
      192 BYTES scs
      256 BYTES footnote
  ;recordsize: SizeOf_Axis

:M ClassInit:   ( -- )
   AddrOf SizeOf_Axis erase
   TRUE to auto
      1 to factor
      1 to scale
;M

:M !TOKEN: DUP TOKEN c! TOKEN 1+ swap move ;M
:M @TOKEN: TOKEN DUP 1+ swap c@ ;M
:M !FOOTNOTE: DUP footnote c! footnote 1+ swap move ;M
:M @FOOTNOTE: footnote DUP 1+ swap c@ ;M
:M !scale: to scale ;M
:M !auto:  to auto ;M
:M !offs: E2S to offs ;M
:M !lim:  E2S to lim ;M
:M @offs: offs S2E ;M
:M @lim:  lim S2E ;M

;Class

HERE to _CURDIR
DataSpec CURDIR

: fitpath curdir.fitrec @ ;
: psi curdir.fitrec @ 8 + ;
: fnd psi 210 + ;


Axistype Xaxis
Axistype Yaxis

(( ****************************** ))

: $ obj @ ;

: PutDdir
\ ( Obj -- )
   Call _GetDirAddr
   CurDir Swap DataSpecSize Move
   CurDir call _putfitprm drop
;

: GetDdir
\ ( NewObj -- )
   Dup obj !
   Call _GetDirAddr
   CurDir DataSpecSize Move
   allocxy: curdir
   CurDir call _getfitprm drop
;

: ChgDdir
   dup MinCur < if drop MinCur then
   dup MaxCur > if drop MaxCur then
   Obj @ PutDdir GetDdir
;

: inc
    obj @ Maxcur < if
    obj @ 1+ ChgDdir then
;

: dec
   obj @ 1 > if
   obj @ 1- ChgDdir then
;

: INITDDIR
  MinCur ChgDdir
  begin
    ALLOCXY: curdir
    obj @ MaxCur < while
    inc
  repeat
  1 GetDdir
;

: GETSPLABDIR  { \ wtab -- }
     current-dir$ count put: SPLABDIR$
     call SPLAB32DIR to wtab
     wtab cell + @ to splab-width
     wtab 2 cells + @ to splab-height
     wtab 3 cells + @ to rightwidth
     wtab 4 cells + @ to graph-start-width
     wtab 5 cells + @ to graph-start-height
     wtab 6 cells + @ to tableheight
     splab-width 0= if MAXWIDTH 55 * 100 / to splab-width then
     maxwidth splab-width - to INIX
     splab-height min-splab-height < if min-splab-height to splab-height then
     tableheight 0= if MAXHEIGHT splab-height - 90 - to tableheight then
     rightwidth min-right-width < if min-right-width to rightwidth then
     graph-start-height 0= if splab-height tableheight + 24 + to graph-start-height then
\     graph-start-height graph-min-height < if graph-min-height to graph-start-height then
     graph-start-width 0= if INIX 8 - TO graph-start-width then
\    graph-start-width graph-min-width < if graph-min-width to graph-start-width then
;

: APPEND-FNAME
    get: SPLABDIR$
    put: TMPSTR
    32 TMPSTR Call TRIM drop
    get: TMPSTR
    + 1- c@ 92 = not if             \ Is last char backslash?
      92 +char: TMPSTR              \ append backslash
    then
    append: TMPSTR
    get: TMPSTR
;

: StkClr
       begin depth 0> while drop repeat
;

: FStkClr  begin fdepth 0> while fdrop repeat ;

: FBACKUP$ s" SPLAB.SPC" append-fname ;

: tim$ time&date drop drop drop str$ put: tmp$ s" :" append: tmp$ str$ append: tmp$  s" ." append: tmp$ str$ append: tmp$ get: tmp$ ;
: !TIME tim$ !header: curdir obj @ putddir ;

: Save-It     PUT: FNAME
              FNAME
              call SaveSPC drop ;

: dsave
    put: FNAME
    FNAME \ rel>abs
    swap call _dsave
;

: dxload   { KeepLoc N Fname }
    put: FNAME
    FNAME
    ROT ROT swap call DX_load
    obj @ getddir
;

: spcload
    put: FNAME
    FNAME call DX_load
    obj @ getddir
;

: Save_State
  call writeparam drop
  splab-width FTMP !
  splab-height ftmp cell + !
  rightwidth ftmp 2 cells + !
  graph-start-width ftmp 3 cells + !
  graph-start-height ftmp 4 cells + !
  tableheight ftmp 5 cells + !
  ftmp call writewinsizes drop
  FBACKUP$ save-it
;
\ ===========================================
: beep-beep ;
\ ===========================================

: INIT_SPLAB32
  SM_CXSCREEN Call GetSystemMetrics  to MAXWIDTH
  SM_CYSCREEN Call GetSystemMetrics  to MAXHEIGHT
  s" Wavelength, nm"  !token: xaxis
  s" Counts"     !token: yaxis
  start_w X2F FDUP !offs: xaxis XMIN F!
  end_w X2F FDUP !lim: xaxis XMAX F!
  0E0         FDUP !offs: yaxis YMIN F!
  4096E0      FDUP !lim:  yaxis YMAX F!
  XFACTOR !scale: xaxis
  YFACTOR !scale: yaxis
  255 spectroname$ 1+ NULL call GetModuleFileName  spectroname$ C!
  1 obj !
  Browspath$
  Spectroname$
  Splabdir$
  yaxis
  xaxis
  obj
  call _setddir drop
  1 to pnt_ptr
  1 getddir
  GETSPLABDIR
  INITDDIR
;



