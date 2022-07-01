variable wchar

0 CONSTANT movetoxy
1 constant putdot
2 constant putvector
3 constant putline
4 constant putchar
5 constant putstr
6 constant setgramode
8 constant setxtmode
9 constant clr
14 constant clrstr
1310720 constant MAXGBUF
6     CONSTANT SYMBOL-MAX
16    CONSTANT COLOR-MAX

Create Farbe

WHITE , BLACK , RED , GREEN , BLUE , YELLOW , MAGENTA , CYAN ,
GRAY  , DKGRAY , LTRED , LTGREEN , LTBLUE , LTYELLOW , LTMAGENTA , LTCYAN ,


create npixel 512 , 512 , \ 346 , 432 ,
796 value graph-mwidth
596 value graph-mheight
0 value OriginX-Graph
0 value OriginY-Graph
0 value ax
0 value vga-bitmap
0 value gseq
0 value glen
0 value glimit

0  VALUE SCHART-WINDW
0  VALUE CHART-ON
0  value BIT-WINDW

Font ChartFont
Font ChartBold
NEEDS SPN_DEF
: GSCREEN-WIDTH npixel @ ;
: GSCREEN-HEIGHT npixel cell + @ ;

: maxx npixel @ ;

: maxy npixel cell + @ ;
maxx to screen-height
maxy to screen-width
Windc chart-win

: Startchart
   CHART-ON not if START: SCHART-WINDW then
;

: CallReplot
        0 0 maxx maxy farbe @ FillArea: chart-win
        call replot
        plotseq: bit-windw
;

: new-chart     ( n -- )          \ draw a new chart,
        STARTCHART
        CallReplot
;

: Plot-spc
   over to Last-Obj
   1 to last-plot
   STARTCHART
   npixel dup cell + @ swap @ call initgra drop
   CallReplot
   Paint: bit-windw

;


: Plot
      true depth 2 < if dup plot-spc else
        over true = if plot-spc else
          over call getn
          0 > if plot-spc else
            STARTCHART
            drop to Last-Obj
            ClearViewPort: bit-windw
            Paint: bit-windw
          then
        then
       then
       update: bit-windw
;


: Plot-results
     dup to last-obj
     STARTCHART
     npixel dup cell + @ swap @ call initgra drop
     0 0 maxx maxy farbe @ FillArea: chart-win
     True call ViewResults
     plotseq: bit-windw
     Paint: bit-windw
     2 to last-plot
;

: plot-list
   STARTCHART
   npixel dup cell + @ swap @ call initgra drop
   0 0 maxx maxy farbe @ FillArea: chart-win
   LISTA call plotlisted plotseq: bit-windw
   Paint: bit-windw
   1 to last-plot
;

\ ---------------------------------------------------------------
\       Define the BIT-WINDOW window class
\ ---------------------------------------------------------------


:Class GraParm  <super child-window

record: AddrOf
      int  mode
      int  destx
      int  desty
      int  axisx
      int  axisy
      int  couleur
      int  vcode
      int  size
      int  wslope
      int  wfont
      int  vlen
      int  wstr
;recordsize: SizeOfGraParm

:M Classinit:   ( -- )
                ClassInit: super               \ init super class
                self to Bit-Windw           \ make myself the cur window
                ;M


:M !mode: to mode ;M
:M @mode: mode ;M
:M @dest: if desty else destx then ;M
:M !dest: if to desty else to destx then ;M
:M @axis: if axisy else axisx then ;M
:M !axis: if to axisy else to axisx then ;M
:M @color: couleur ;M
:M !color: to couleur ;M
:M @vcode: vcode ;M
:M !vcode: to vcode ;M
:M @size: size ;M
:M !size: to size ;M
:M @vlen: vlen ;M
:M !vlen: to vlen ;M
:M @size: size ;M
:M !size: to size ;M
:M @char: wstr ;M
:M !char: to wstr ;M

\ ---------------------------------------------------------------
\       Define the BIT-WINDOW global drawing functions
\ ---------------------------------------------------------------

: line-color    ( -- )
     farbe couleur cells + @ LineColor: chart-win
;

:M movexy: destx dup to axisy maxy desty dup to axisy - MoveTo: chart-win
   destx to axisx
   desty to axisy
;M


:M linexy:        ( x y -- )
     line-color
     destx dup to axisx maxy desty dup to axisy - LineTo: chart-win
;M

:M On_Paint:    ( -- )
               SRCCOPY 0 0 GetHandle: chart-win GetSize: self 0 0 BitBlt: dc
                ;M
:M Paint:   ( -- )
            Paint: Super
;M

:M Clearviewport:       ( -- )
                0 0 maxx maxy farbe @ FillArea: chart-win
                ;M

:M WM_CREATE    ( hwnd msg wparam lparam -- res )

                0 to destx
                0 to desty
                0 to axisx
                0 to axisy
                1 to couleur
                0 to vcode
                1 to vlen
                1 to size
                0 to wstr

                get-dc
                0 call CreateCompatibleDC PutHandle: chart-win
                graph-mwidth graph-mheight CreateCompatibleBitmap: dc
                to vga-bitmap
                vga-bitmap             SelectObject: chart-win drop
\                OEM_FIXED_FONT    SelectStockObject: chart-win drop
                BLACK_PEN         SelectStockObject: chart-win drop
                farbe @                  SetBkColor: chart-win
                farbe cell + @         SetTextColor: chart-win

                s" Arial" SetFaceName: ChartFont
                8 Width: ChartFont
                Create: ChartFont drop

                s" Arial Black" SetFaceName: ChartBold
                12 Width: ChartBold
                Create: ChartBold drop

                Handle: ChartFont        SetFont: chart-win

                clearviewport: self
                release-dc
                0 ;M


:M On_Done:     ( -- )
                vga-bitmap call DeleteObject drop
                0 to vga-bitmap
                On_Done: super
                ;M

:M gra: { \ dx dy vc cha -- }
  mode
  case
   0 of movexy: self endof
   1 of movexy: self
        axisx maxy axisy - farbe couleur cells + @ SetPixel: chart-win
     endof
   2 of vcode 7 and
       case
          0 of  0  1  endof
          1 of  1  1  endof
          2 of  1  0  endof
          3 of  1 -1  endof
          4 of  0 -1  endof
          5 of -1 -1  endof
          6 of -1  0  endof
          7 of -1  1  endof
       endcase
       to dy
       to dx
       axisx dx vlen * + to destx
       axisy dy vlen * + to desty
       vcode 8 < if linexy: self else movexy: self then
      endof
    3 of linexy: self endof
    4 of
      wstr 0XFF and
      dup 6 < if
       farbe couleur cells + @ BrushColor: chart-win
       farbe couleur cells + @ PenColor: chart-win
       case
         0 of axisx maxy axisy - farbe couleur cells + @ SetPixel: chart-win
              endof
         1 of axisx maxy axisy - size 2 * FillCircle: chart-win
              endof
         2 of axisx maxy axisy - size 2 * Circle: chart-win
              endof
         3 of axisx maxy axisy - size 3 * Circle: chart-win
              endof
         4 of axisx maxy axisy - size 3 * FillCircle: chart-win
\              axisx maxy axisy - size 3 * Circle: chart-win
              endof
         5 of axisx maxy axisy - size FillCircle: chart-win
              axisx maxy axisy - size 3 * Circle: chart-win
              endof
       endcase
      else
        farbe couleur cells + @ SetTextColor:   chart-win
        axisx maxy axisy - wchar 1 TextOut: chart-win
      then
      endof
    5 of
\ ." Text:" wstr 1+ wstr c@ type ." ; Size= " size . cr


\        size 8 * Width: ChartFont
\        Create: ChartFont drop

        size 1 > if Handle: ChartBold else Handle: ChartFont then
                SetFont: chart-win

        farbe couleur cells + @ SetTextColor:   chart-win
        axisx maxy axisy - wstr 1+ wstr c@
        TextOut:     chart-win
      endof
    6 of clearviewport: self endof
    7 of clearviewport: self endof
    8 of (( :begin closegraph;graph_screen:=false )) endof
    9 of clearviewport: self endof
   14 of
        axisx size 4 * -
        npixel cell + @ axisy - size 4 * +
        dup
        npixel @
        swap
        size 8 * -
        FARBE @ FillArea: chart-win
      endof
  endcase
;M

:M plotseq: { \ gptr cmd -- }
    dup to gseq
    @ dup MAXGBUF > if drop MAXGBUF then
    to glen
    gseq cell + to gptr
    gseq glen + to glimit
    begin
      gptr glimit < while
      gptr c@ dup to mode 1 +to gptr
      case
        0 of
            gptr @
            to destx cell +to gptr
            gptr @
            to desty cell +to gptr
          endof
        1 of
            gptr @ to destx cell +to gptr
            gptr @ to desty cell +to gptr
            gptr c@ to couleur 1 +to gptr
          endof
        2 of
            gptr c@ to vcode 1 +to gptr
            gptr c@ to couleur 1 +to gptr
            gptr @  to vlen cell +to gptr
          endof
        3 of
            gptr @ to destx cell +to gptr
            gptr @ to desty cell +to gptr
            gptr c@ to couleur 1 +to gptr
          endof
        4 of
            gptr c@ to wstr  1 +to gptr
            gptr c@ to couleur 1 +to gptr
            gptr c@ to size  1 +to gptr
          endof
        5 of
            gptr c@ to couleur 1 +to gptr
            gptr c@ to size  1 +to gptr
            gptr c@ to wslope 1 +to gptr
            gptr c@ to wfont  1 +to gptr
            gptr dup to wstr c@ 1+ +to gptr
          endof
       14 of
            gptr c@ to couleur 1 +to gptr
            gptr c@ to size  1 +to gptr
          endof
      endcase
      gra: self
   repeat

;M

;class

GraParm bit-window

: Replot-It
      last-plot case
        1 of last-obj plot endof
        2 of last-obj plot-results endof
        0 of
           clearviewport: bit-window
           Paint: bit-window
        endof
      endcase
;

\ ============== Parent Chart window onject --------------------

:Object SCHART  <super window

0 constant marginSize  \ sets chart white margin size in pixels

Rectangle GraphRect

marginsize constant bitorigx
marginSize constant bitorigy

bitorigx marginSize + 1+ constant bitrightmargin
bitorigx marginSize + 1+ constant bitbottommargin

:M Classinit:   ( -- )
                ClassInit: super               \ init super class
                self to Schart-Windw           \ make myself the cur window
                ;M

:M WindowHasMenu: False ;M

:M On_Init:     ( -- )
                On_Init: super
                1    SetId: Bit-Window          \ then 2nd child window
                self Start: Bit-Window          \ then startup 2nd child window
                true to Chart-On
                ;M

:M On_Done:     ( h m w l -- res )
                On_Done: super                  \ cleanup the super class
                0 ;M

:M WM_CLOSE     ( h m w l -- res )
                False to Chart-ON
                WM_CLOSE WM: Super
                0 ;M

:M StartSize:   ( -- width height )     \ starting window size
                graph-start-width graph-start-height
                ;M

:M StartPos:    ( -- x y )
                OriginX-graph OriginY-graph ;M

:M MaxSize:     ( -- width height )             \ maximum window size
                graph-mwidth graph-mheight
                ;M
:M MinSize:     ( -- width height )             \ maximum window size
                graph-min-width graph-min-height
                ;M

:M WindowTitle: ( -- Zstring )          \ window caption
                z" Chart"
                ;M
:M WindowStyle: ( -- style )            \ return the window style
                 WindowStyle: super
                ;M
((
:M WindowStyle: ( -- style )
                WS_POPUP
                 WS_BORDER  \ OR
                 WS_CAPTION OR
                 WS_BORDER OR
                 WS_OVERLAPPED OR
                ;M
))

:M Refresh:     ( -- )
                Paint: bit-window
                Update: bit-window
                ;M

:M On_Size:     ( h m w -- )                  \ handle resize message
                 Width  8 - npixel !
                 Height npixel cell + !            \ assign new maxx and maxy
                 Width  dup to graph-start-width bitrightmargin  - to screen-width
                 Height dup to graph-start-height bitbottommargin - to screen-height
                 Replot-it
                 maxx maxy Move: bit-window
                ;M

:M On_Paint:    ( -- )
                On_Paint: super
                ;M

:M Close:        ( -- )
                ;M

:M WM_COMMAND   { hwnd msg wparam lparam -- res }
                hwnd msg wparam lparam WM_COMMAND WM: Super
                hwnd msg wparam lparam over LOWORD ( ID )
                0 ;M

;Object
\ ==========================================================


