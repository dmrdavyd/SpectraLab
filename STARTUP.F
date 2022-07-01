: TEST-STARTUP
        True to @work
        CLEARCRT
        s" This is a test STARTUP-added" dup 40 swap - 2 / 2 XYTYPE$
        s" command" dup 40 swap - 2 / 3 XYTYPE$
        s" Press any key to close this window" dup 40 swap - 2 / 16 XYTYPE$
        call CRTREADAKEY drop
        CLEARCRT
        NOCRT
        False to @work
;

: CORTRANS { \ &K &EPSILN &J }
   E2S TO &EPSILN
   TO &K
   1 !$
   &K 1+ DUP CLEAR
   TO &J
   &K 1 + 1 DO
    @Z &J $ !X::
    @Z &J $ !Y::
    INC
   loop
   &J #: &EPSILN S2E -2.3026E0 F* #* #EXPY &J #!
   1 !$
   &K 1 + 1 DO
     $ #: J $ y:: #/ #!
     INC
  loop
  1 !$
;

: DILCOR { \ &CONCTR &VOLM &K }
  E2S to &CONCTR
  to &volm
  to &K
  1 !$
  &K 1 + 1 DO
    $ . cr
    &VOLM I2E FDUP @Z F+ F/ !Z
    #$ @Z #/ $ #!
    @Z &CONCTR S2E F* !Z
    INC
  loop
;

: flrl { \ &polyorder &fitdest &polydest }
  to &K
  to &NP
  polyorder to &polyorder
  fitdest to &fitdest
  polydest to &polydest
  depth 0= if 3 then
  to polyorder
  132 to fitdest
  0 to polydest
  s" flrl@3A4" put: STD$ SURFIT-BY-FILE $ getddir
  polyorder 5 + @p mincur 3 + #: #* 131 #!
  132 #: 131 #: #- @#131
  polyorder 6 + @p mincur 4 + #: #* 130 #!
  131 #: 130 #: #- 131 #!
  &NP &K 131 sub
  &polyorder to polyorder
  &fitdest to fitdest
  &polydest to polydest
;

: fitcor { \ &polyorder &fitdest &polydest }
  to &K
  to &NP
  polyorder to &polyorder
  fitdest to &fitdest
  polydest to &polydest
  depth 0= if 3 then
  to polyorder
  131 to fitdest
  0 to polydest
  SURFIT-BY-FILE
  &NP &K 131 sub
  131 clear
  &polyorder to polyorder
  &fitdest to fitdest
  &polydest to polydest
;

: pbcor { \ &polyorder &fitdest &polydest }
  to &K
  to &NP
  polyorder to &polyorder
  fitdest to &fitdest
  polydest to &polydest
  depth 0= if 3 then
  to polyorder
  132 to fitdest
  0 to polydest
  s" PB@3A4D" put: STD$
  SURFIT-BY-FILE
  $ getddir
  polyorder 4 + @p mincur 2 + #: #* 131 #!
  132 #: 131 #: #- @#131
  polyorder 5 + @p mincur 3 + #: #* 130 #!
  131 #: 130 #: #- 131 #!
  130 clear
  132 clear
  &NP &K 131 sub
  131 clear
  &polyorder to polyorder
  &fitdest to fitdest
  &polydest to polydest
;

: pbcor0
  s" PY-ERWGH" put: STD$
  fitcor
;

: pbcor1
  s" PY1ERWGH" put: STD$
  fitcor
;

: lcorr
  put: std$1
  put: std$2
  polycor
;

: ARTFM
$ #: $ 1 - #: #/ #dup $ 3 + #! 273.15e0 #X+ #logx -1e0 #X* #expx 8.314e-3 #X/ #logy $ 4 + #!
;

: tndclc { \ uu volm }
   @z 0E0 F= not if exit else inc then
   to volm
   1 DO
      dec
      @z 1E0 fswap f- fdup f2s to uu
      inc
      @z volm i2f F/
      fswap f/
      fdup 1E0 fswap f- uu s2f f*
      fswap 1E0 uu s2f f- f*
      f+
      1E0 fswap F- !z
      inc
   LOOP
;
