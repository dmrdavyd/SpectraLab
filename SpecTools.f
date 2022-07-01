: RESAMPLE
    XDELTA F!
    XEND F!
    XSTART F!
    depth 0= if $ then
    dup 0= not if
      XEND swap XSTART swap XDELTA swap call _resample_
    else
      drop
      maxcur 1 + 1 do
        i call getn 0= not
        i call getsel
        and
        if
         XEND XSTART XDELTA i call _resample_
        then
      loop
    then
;

: SMO  { \ frame obj }
    depth case
       0 of 5 $ endof
       1 of $ endof
    endcase
    to obj
    to frame
    obj 0= not if
      obj #: frame #SMO obj #!
    else
      maxcur 1 + 1 do
        i call getn 0= not
        i call getsel
        and
        if
         i #: frame #SMO i #!
        then
      loop
    then
;


: TRI { \ frame obj }
    depth case
       0 of 3 $ endof
       1 of $ endof
    endcase
    to obj
    to frame
    obj 0= not if
      obj #: frame #TRI obj #!
    else
      maxcur 1 + 1 do
        i call getn 0= not
        i call getsel
        and
        if
         i #: frame #TRI i #!
        then
      loop
    then
;

: corpress
    depth 0= if $ then
    dup 0= not if
      call _corpress_
      if
       s" The amplitude of the current spectrum is now corrected"
       put: ss$ ss$ call SplabInfo
      else
       s" Unable to perform correction"
       put: ss$ ss$ call SplabErrorMessage
     then
    else
      drop
      maxcur 1 + 1 do
        i call getn 0= not
        i call getsel
        and
        if
         i call _corpress_ drop
        then
      loop
      s" All selected spectra are now pressure-corrected"
      put: ss$ ss$ call SplabInfo
    then
;

: PlusMinusSpc   { SUBTR \ subloc destloc sublen -- }
    curdir.npts 0 > if
      begin
        SUBTR if
          s" Which trace to subtract?"
        else
          s" Which trace to add?"
        then
        s" " polydest getinteger
        not if drop exit then
        to subloc
        subloc 1 < subloc maxcur > or if exit then
        subloc call getn to sublen
        sublen curdir.npts < if
          s" This trace is shorter. The result will be truncated. Continue?" PUT: SS$
          SS$ call SplabWarning 1 =
        else true then
      until
      begin
        s" Destination slot?" s" " $ getinteger
        not if drop exit then
        to destloc
        destloc 1 < destloc maxcur > or if exit then
        destloc dup $ = not swap call getn 0= not and if
          call confirm 1 =
        else true then
      until
      begin FDEPTH 0 > while FDROP repeat
      $ #: subloc #:
      SUBTR if #- else #+ then
      destloc #!
      SetCurveList: Data-Window
      $ to last-obj
      $ plot
      $ destloc = if
        $ getddir
        pnt_ptr curdir.npts > if curdir.npts to pnt_ptr then
        SetCurveList: DATA-WINDOW
        SetListEdit: Splab-Window
        SetDataEdit: Splab-Window
        $ to last-obj StkClr $ PLOT
      then
    then
;


: PlusMinusConst   { SUBTR \ subloc destloc sublen axis -- }
    curdir.npts 0 > if
      SUBTR if
         s" Enter the constant to subtract from the current trace:"
      else
         s" Enter the constant to add to the current trace:"
      then
      s" Operation with X-axis"
      0E0 getreal
      dup 0= if drop exit then
      1 = to axis
      begin
        s" Destination slot:" s" " $ getinteger
        0= if drop exit then
        to destloc
        destloc 1 < destloc maxcur > or if exit then
        destloc dup $ = not swap call getn 0= not and if
          call confirm 1 =
        else true then
      until
      $ #:
      Axis if
        SUBTR if #Y- else #Y+ then
      else
        SUBTR if #X- else #X+ then
      then
      destloc #!
      SetCurveList: Data-Window
      $ to last-obj StkClr $ plot
      $ destloc = if
        $ getddir
        pnt_ptr curdir.npts > if curdir.npts to pnt_ptr then
        SetCurveList: DATA-WINDOW
        SetListEdit: Splab-Window
        SetDataEdit: Splab-Window
        $ to last-obj StkClr $ PLOT
      then
    then
;
: MultiDivSpc   { divide \ subloc destloc sublen -- }
    curdir.npts 0 > if
      begin
        divide if
          s" Divisor trace:"
        else
          s" Multiplier trace:"
        then
        s" "
        polydest getinteger
        not if drop exit then
        to subloc
        subloc 1 < subloc maxcur > or if exit then
        subloc call getn to sublen
        sublen curdir.npts < if
          s" This trace is shorter. The resulting trace will be truncated. Continue?" PUT: SS$
          SS$ call SplabWarning 1 =
        else true then
      until
      begin
        s" Destination slot:" s" " $ getinteger
        not if drop exit then
        to destloc
        destloc 1 < destloc maxcur > or if exit then
        destloc dup $ = not swap call getn 0= not and if
          call confirm 1 =
        else true then
      until
      begin FDEPTH 0 > while FDROP repeat
      $ #: subloc #:
      divide if #/ else #* then
      destloc #!
      SetCurveList: Data-Window
      $ to last-obj StkClr $ plot
      $ destloc = if
        $ getddir
        pnt_ptr curdir.npts > if curdir.npts to pnt_ptr then
        SetCurveList: DATA-WINDOW
        SetListEdit: Splab-Window
        SetDataEdit: Splab-Window
        $ to last-obj StkClr $ PLOT
      then
    then
;


: MultiDiv   { divide \ subloc destloc sublen axis -- }
    curdir.npts 0 > if
      divide if
       s" Divisor:"
      else
       s" Multiplier:"
      then
      s" Operation with X-axis"
      1E0 getreal
      dup 0= if drop exit then
      1 = to axis
      begin
        s" Destination slot:" s" " $ getinteger
        0= if drop exit then
        to destloc
        destloc 1 < destloc maxcur > or if exit then
        destloc dup $ = not swap call getn 0= not and if
          call confirm 1 =
        else true then
      until
      $ #:
      Axis if
        DIVIDE if #Y/ else #Y* then
      else
        DIVIDE if #X/ else #X* then
      then
      destloc #!
      SetCurveList: Data-Window
      $ to last-obj StkClr $ plot
      $ destloc = if
        $ getddir
        pnt_ptr curdir.npts > if curdir.npts to pnt_ptr then
        SetCurveList: DATA-WINDOW
        SetListEdit: Splab-Window
        SetDataEdit: Splab-Window
        $ to last-obj StkClr $ PLOT
      then
    then
;

: Add-spc
    FALSE PlusMinusSpc
;

: Subtract-spc
    True PlusMinusSpc
;

: Add-const
    FALSE PlusMinusConst
;

: Subtract-const
    True PlusMinusConst
;

: Multiply-const
    FALSE MultiDiv
;

: Divide-const
    TRUE MultiDiv
;

: Multiply-spc
    FALSE MultiDivSpc
;

: Divide-spc
    TRUE MultiDivSpc
;


: FindCompLoc  { \ n2cor daddr npts maxcomp }
      1 call getn to npts
      npts 0= if exit then
      1 to daddr
      begin
         1 +to daddr
         TMP$ daddr call gethead drop
         tmp$ 1+ @ 1852404304 = \ Longint value for the first four bytes of "Principal vector"
         daddr maxcur =
         or
      until
      daddr 1 - to n2cor
      begin
         1 +to daddr
         daddr call getn npts =
         TMP$ daddr call gethead drop  \ length of "Principal vector # 1"
         tmp$ 1+ @  1852404304 = \ Longint value for the first four bytes of "Principal vector"
         and
         not
         daddr maxcur < not
         or
      until
      daddr n2cor - 1 - to maxcomp
      begin
       daddr call getn n2cor =
       daddr maxcur = or not
       while
       1 +to daddr
      repeat
      daddr call getn n2cor = not if 0 to daddr then
      n2cor daddr maxcomp
;


 : getslice      { \ #x #kinloc #xpos -- }
  depth 0= if 0 then
  to #XPOS
  depth 0 = not if
    dup 0 > over maxcur > not and if ChgDdir else drop then
  then
  $ to #kinloc $ clear
  1 ChgDdir
  0 to #X
  begin
    #xpos 0> not if
      @H str2flo
    else #xpos curdir.npts > not if
      #xpos pully: curdir
      true
     else false then
    then
    if
      @Z fdup isnan10 if fdrop $ I2F then
      $
      #kinloc ChgDdir
      #X pushx: curdir
      #X pushy: curdir
      1 +to #X
      ChgDdir
    then
    inc
    $ #kinloc < not
  until
  #kinloc ChgDdir
  #kinloc plot
  #sel
;

: Smooth-dialog { \ frame minframe global }
   $ call getn dup 3 < if drop exit then
   dup 9 < if 5 < if 3 else 5 then else drop 7 then to minframe
   s" Frame Width (3÷21):" s" Smooth all selected traces" minframe getinteger
   dup 0= if drop drop exit then
   2 = to global
   to frame
   frame 0= if exit then
   frame 3 < not frame 21 > not and
   not if s" This value is not allowed: " put: TMP$ frame i2f FLO2STR append: TMP$ TMP$ call SplabErrorMessage drop exit then
   global if 0 else $ then
   frame swap smo
   Replot-It
;

: Tri-dialog { \ frame global }
   $ call getn 3 < if exit then
   begin
     s" Frame Width (3..21)?" s" Smooth all selected traces" 3 getinteger
     dup 0= if drop drop exit then
     2 = to global
     to frame
     frame 0= if exit then
     frame 3 < not frame 21 > not and
   until
   global if 0 else $ then
   frame swap tri
   Replot-It
;

: CorPress-dialog
   s" Pressure Correction: Do you mean to correct all selected traces? " put: ss$ ss$ call SplabQuestion
   6 = \ mbYes
   if 0 else $ then
   corpress
   SetDataList: DATA-Window
   SetDataEdit: Splab-Window
   Replot-It
;

: Resample-dialog { \ npts minx maxx stepx resampleall }
   $ call getn to npts
   npts 3 < if exit then
   $ 1 call getx to minx
   $ npts call getx to maxx
   s" Resample from: "  s" "  minx S2E getreal
   not if exit then
   fdup MINX S2E F< not if
     f2s to MINX
   else fdrop then
   s" Resample to: "  s" " maxx S2E getreal
   not if exit then
   fdup MAXX S2E F> not if
     f2s to MAXX
   else drop then

   MAXX S2X MINX S2X - NPTS 1 - / 5 XFACTOR * 10 / + XFACTOR / XFACTOR *
   dup 0= if 5 XFACTOR * 10 / then
   X2F
   s" Resampling step (enter 0 to cancel): "  s" Resample all selected traces" getreal
   dup 0= if drop exit then
   2 = to resampleall
   fdup f2s to stepx 0E0 F>
 \  Step>0
    MAXX S2X MINX S2X - STEPX S2X < not
 \  and not too large
   and
   if
    resampleall if 0 else $ then
    MINX S2E MAXX S2E STEPX S2E resample
    $ getddir
    pnt_ptr curdir.npts > if curdir.npts to pnt_ptr then
    SetCurveList: DATA-WINDOW
    SetListEdit: Splab-Window
    SetDataEdit: Splab-Window
    Replot-it
   then
;

0     Value lfitoffst

: #lista cells lista + ;
: !LISTA #lista ! ;
: @LISTA #lista @ ;


: SURFIT { nstd polyorder iy ir ip \ nstd0  -- }
\ order in cmdline: list of std, weight fn., nstd, polyorder, iy, ir, ip
  depth 0 > not if 0 to nstd mincur 1 - else
    dup dup 0= swap maxcur > or
    if
      drop mincur 1 -
    then
  then
  0 !LISTA
  0 to nstd0
  nstd 0= NOT if
    begin
      DEPTH 0 >
      nstd0 nstd <
      and
      while
      1 +to nstd0
      nstd0 !lista
    repeat
  then
  false lista lfitoffst polyorder nstd0 ip ir iy call lfit
;

: SURFIT-BY-LIST
  polydest dup 0 >  if
       call clearmem
  then
  drop
  fitdest dup 0 >  if
       call clearmem
  then
  drop
  true lista lfitoffst polyorder nstd polydest fitdest $ call lfit
  $ GETDDIR
;


: SURFIT-BY-FILE { \ nstd@file sptr }
  polydest dup 0 >  if
       call clearmem
  then drop
  fitdest dup 0 >  if
       call clearmem
  then drop
  std$ mincur 1 + call readstandards
  dup 0= not if
    to nstd@file
    0 to nstd
    WeightLoc
    dup dup 0= swap maxcur > or
    if
      drop mincur 1 -
    then
    0 !LISTA
    1 nstd@file + 1 do
      i mincur + to sptr
      tmpstr sptr call gethead
      87 pos: tmpstr 1 =   \ W
      101 pos: tmpstr 2 =  \ e
      and
      if
        sptr 0 !lista
      else
        1 +to nstd
        sptr nstd !lista
      then
    loop
    true lista lfitoffst polyorder nstd polydest fitdest $ call lfit
    $ GETDDIR
  then
;

: findOFFSET { targ std minoffst maxoffst \ offst lastrho rho -- }
    minoffst to offst
    -1000000 to lastrho
    begin
     mincur 1 - 0 !LISTA
     std 1 !lista
     false lista offst 0 1 0 0 targ call lfit to rho
     offst minoffst = rho lastrho > or offst maxoffst < and while
     rho to lastrho
     1 +to offst
    repeat
    offst 1 -
    lastrho
;

: xadjust { minx maxx \ -- }
   $ 1 minx maxx findoffset drop i2f fdup !z
   $ #: #X+ $ #!
((
   1 1 call getn x:: XEND F!
   1 1 x:: XSTART F!
   1 2 X:: XSTART F@ F- XDELTA F!
   XEND XSTART XDELTA $ call _resample_ drop
))
;

: bckoff { nspc std minx maxx \ sumshift -- }
    1 chgddir
    0 to sumshift
    begin
      std $ minx maxx findoffset drop dup i2f !z +to sumshift
      inc
      $ nspc >
    until
    sumshift i2f nspc i2f F/
    std chgddir !z
;


: xadjust-all { minx maxx \ NN IXSTART IXEND -- }
  1 chgddir
  $ getn 0 = if exit then
  begin
   inc
   $ call getn 0 > while
   minx maxx xadjust
  repeat
  1 #: #maxx XEND F!
  1 #: #minx XSTART F!
  1 chgddir
  begin
   inc
    $ call getn 0 > while
    $ #: #MAXX fdup
    XEND F@ F< IF
     XEND F!
   ELSE
    FDROP
   THEN
   $ #: #MINX Fdup
   XSTART F@ F> IF
     XSTART F!
   ELSE
    FDROP
   THEN
  repeat
  $ 1 - chgddir
  $ #: #maxx f2x
  $ #: #minx f2x
  -
  $ call getn 1 -
  /
  x2f XDELTA F!
  begin
   XEND XSTART XDELTA $ call _resample_ drop
   $ getddir
   $ #: #dup #minx 1e0 f- #x- $ #!
   $ 1 > while
   dec
  repeat
;


\ 17 0 1 0 $ 130 131 surfit #$ #130 #- @#$ !sel true plot inc

: stanread   { dest \  -- }
  put: tmpstr
  tmpstr dest call readstandards
;

s" " put: std$
s" " put: std$1
s" " put: std$2

INCLUDE CIP-SCRIPTS

: Sub-dialog { \ npts n2cor dynaddr polyaddr }
      1 call getn to npts
      npts 0= if exit then
      polydest to polyaddr
      1 to n2cor
      begin
         1 +to n2cor
         n2cor call getn npts = not
         TMP$ n2cor call gethead 24 >  \ length of "Principal vector #..."
         tmp$ 1+ @ 1852404304 = \ Longint value for the first four bytes of "Principal vector"
         and or
         n2cor maxcur =
         or
      until
      -1 +to n2cor
      s" Number of spectra to correct:"  s" "
      n2cor getinteger
      if maxcur min to n2cor else drop exit then
      n2cor call getn npts = not if s" Uneven length of the traces" put: TMP$ TMP$ call SplabErrorMessage drop exit then
      TMP$ $ call gethead 24 >  \ length of "Principal vector #..."
      tmp$ 1+ @ 1852404304 = \ Longint value for the first four bytes of "Principal vector"
      and
      if
       $ 1 + maxcur min to dynaddr
       begin
         dynaddr maxcur = not
         dynaddr call getn npts =
         and
         while
         1 +to dynaddr
       repeat
       dynaddr call getn n2cor = not if
            0 to dynaddr
       else
            $ n2cor -
            1 - dup 0 < not if +to dynaddr else drop then
       then
       s" Loctation for the set of loading factors (0 for none):"  s" "
       dynaddr getinteger
       not if drop exit then
       dup 0= not if maxcur min n2cor 1 + max then
      else 0 then
      dup
      to dynaddr
      0=
      dynaddr call getn n2cor =
      or
      not if s" Improper length of the trace" put: TMP$ TMP$ call SplabErrorMessage drop exit then
      s" Loctation of the correction trace:" s" "
      polyaddr getinteger
      not if drop exit then
      maxcur min n2cor 1 + max to polyaddr
      polyaddr call getn npts =
      not if s" Uneven length of the traces" put: TMP$ TMP$ call SplabErrorMessage drop exit then
      n2cor dynaddr polyaddr sub
      SetCurveList: DATA-WINDOW
      SetListEdit: Splab-Window
      SetDataEdit: Splab-Window
      Replot-it
;

: Titcor-dialog { \ npts n2cor volm conctr }
      1 call getn to npts
      npts 0= if exit then
      1 to n2cor
      begin
         1 +to n2cor
         n2cor call getn npts = not
         n2cor call getz
         isnan4
         or
         n2cor maxcur =
         or
      until
      n2cor 1 - to n2cor
      s" Number of spectra to correct:"  s" " n2cor  getinteger
      not if drop exit then
      maxcur min to n2cor
      n2cor
      0= if exit then
      n2cor call getn npts = not if s" Uneven lenth of the traces" put: TMP$ TMP$ call SplabErrorMessage drop exit then
      s" Sample volume: "  s" "
      7E2 getreal
      0= if exit then
      FDUP FTMP F!
      F2S DUP to volm S2X
      0 > not if s" Bad value:" put: TMP$ FTMP F@ FLO2STR append: TMP$ TMP$ call SplabErrorMessage drop exit then
      s" Concentration of the titrant: "  s" " 2E4 getreal
      0= if exit then
      FDUP FTMP F!
      F2S DUP to conctr S2X
      0 > not if s" Bad value:" put: TMP$ FTMP F@ FLO2STR append: TMP$ TMP$ call SplabErrorMessage drop exit then
      n2cor volm S2E conctr S2E titcor
      SetCurveList: DATA-WINDOW
      SetListEdit: Splab-Window
      SetDataEdit: Splab-Window
      Replot-it
;

: Avr-dialog
   $ call getn 1 < if exit then
   s" Number of traces to average:" s" " 2 getinteger
   not if drop exit then
   dup 2 < if drop exit then
   avr
   SetCurveList: DATA-WINDOW
   SetDataList: DATA-Window
   SetDataEdit: Splab-Window
   $ to last-obj StkClr $ plot
;

