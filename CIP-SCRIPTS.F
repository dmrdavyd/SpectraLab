\ ******************************** MACROS from SPLAB.CIP **************************************

: sub { \ obj }
  to &K
  to &J
  to &NP
  stkclr
  &NP 1 + 1 DO
     &K #:
     &J 0= not if
       &J i call gety -1 call _multiply_ drop     \ An equivalent of #Y*, but without any use of F-Stack
     then
     i #: #SWAP #Y- i #!
  LOOP
  &J 0 = not if
    $ #: &K #:
    #Y-
    $ #!
  then
;


: TITCOR { &K \ &VOLM &CONCTR }
  F2S to &CONCTR
  F2S to &VOLM
  1 !$
  &K  1 + 1 DO
    @Z &VOLM S2F F+ &VOLM S2F F/ #$ #Y* @#$
    @Z FDUP &VOLM S2F F+ F/ &CONCTR S2F F* !Z
    INC
  loop
  1 !$
;

: AVR { navr \ }
  $ call getn 2 < if exit then
  $ #:
  navr 1 do
    $ i + dup #: #Y+
    clear
  loop
  navr I2E #Y/
  $ #!
;

: polycor { \ &polyorder &nstd &nstd1 &nstd2 &mincur }
  to &K
  to &NP
  to &polyorder
  mincur to &mincur
  stkclr
  len: std$1 0= if exit then
  std$1 &mincur call readstandards dup dup 0= if drop exit then to &nstd1
  stkclr
  len: std$2 0= if
    0 to &nstd2
  else
    std$2 &mincur &nstd1 + call readstandards dup dup 0= if drop exit then to &nstd2
  then
  &nstd1 &nstd2 + to &nstd
  &mincur 1 - 0 !lista
  &nstd
  begin
   dup 0> while
   dup dup &mincur + 1 - swap !lista
   1-
  repeat
  stkclr
  false lista 0 &polyorder &nstd 131 132 $ call lfit
  if
    $ getddir
    &nstd2 0> if
      &nstd2 1 + 1 do
       i &nstd1 + 1+ &polyorder + @p
       i &nstd1 + &mincur + 1 -
       #:
       #*
       i 1 = if 130 #! else 130 #: #+ 130 #! then
       1-
      loop
      130 #: 131 #: #+ 131 #!
    then
    stkclr
    &NP &K 131 sub
  then
  130 clear
  131 clear
  132 clear
;




