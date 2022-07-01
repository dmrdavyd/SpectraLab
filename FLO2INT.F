NEEDS NANS

CREATE DBUF CELL ALLOT
CREATE FBUF 10 cells ALLOT
ZSTRING FSTRING-BUF

WinLibrary F2INT

         FLOAT    FXFACTOR
         1E3      TO FXFACTOR
FXFACTOR F>D D>S VALUE    XFACTOR
         FLOAT    FYFACTOR
         1E6      TO FYFACTOR
FYFACTOR F>D D>S VALUE    YFACTOR

: S2X call SINGLE2FIX ;
: X2S FBUF call FIX2FLOAT ;
: X2F FBUF call FIX2FLOAT drop FBUF F@ ;
: S2I call SINGLE2INT ;
: S2E dup isnan4 if drop nan10 else FBUF call SINGLE2EXT drop FBUF then F@ ;
: E2S fdup isnan10 if fdrop nan4 else FBUF F! FBUF call EXT2SINGLE then ;
: S2F S2E ;
: F2S E2S ;
: I2E FBUF call INT2FLOAT drop FBUF F@  ;
: I2S FBUF call INT2FLOAT ;
: I2F I2E ;
: F2I E2S S2I ;
: E2I F2I ;
: F2X E2S S2X ;


: FLO2STR
          FDEPTH 0= if s" NONE" exit then
          FDUP isnan10 if s" NAN" FDROP exit then
          FDUP 2.14E9 F> if s" +INF" FDROP exit then
          FDUP -2.14E9 F< if s" -INF" FDROP exit then
          FBUF F!
          FSTRING-BUF
          FBUF
          call EXT2STRING drop
          GET: FSTRING-BUF
;

: STR2FLO PUT: FSTRING-BUF  { \ tmp1 tmp2 -- }
          dup to tmp2
          FSTRING-BUF
          depth to tmp1
          FBUF
          call STRING2EXT
          depth tmp1 < if tmp2 swap then
          DUP if FBUF F@ then ;

\ ** END of F2D definition **
