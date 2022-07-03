\ *!  Splab-main
\ *T SpectraLab Data Analysis and Data Aquisition Software
\ ** by Dmitri R. Davydov \n \n
\ ** \iVersion 3.1.1 (June 30, 2022)\d

true value turnkey?
\
\ *Q Abstract
\ **
\ ** SpectraLab (SpLab) is a universal tool for advanced data analysis in
\ ** (bio)chemical spectroscopy and kinetics. The program is designed
\ ** to manipulate a set of up to 132 spectra (or kinetic traces,
\ ** or any other kind of two-dimensional data sets) simultaneously.
\ ** It allows for easy manipulations and arithmetic operations with
\ ** traces (add, subtract, divide, take a derivative, etc).
\ ** It also has utilities for smoothing, re-sampling (including
\ ** interpolation), automatic baseline correction and manual editing.
\ ** The spectral analysis section of SpectraLab includes
\ ** multi-dimensional least-square fitting algorithm, which
\ ** allows approximating a spectrum with a linear combination
\ ** of spectral standards (spectral prototypes) and a
\ ** polynomial. This feature allows for quantitative determination of
\ ** concentrations  of individual components in  a mixture. The program
\ ** also includes the Principal Component Analysis (PCA) engine,
\ ** which is used in global analysis of spectral changes
\ ** in series of spectra obtained in spectral titrations, kinetic
\ ** experiments, etc. It allows for automatic correction of
\ ** changes in turbidity, absorbance of the titrant, or
\ ** fluctuation of the baseline during the experiment.
\ ** Program also incorporates non-linear least
\ ** regression routines based on Marquardt and Nelder-Mead
\ ** algorithms. It allows fitting of the data sets (including
\ ** global fitting of three-dimensional data sets) to various predefined
\ ** functions, such as Michaelis-Menten, Hill, or "Tight-Binding"
\ ** equations, sum of exponents, second order kinetic equation, etc.
\ *P The package thus includes most of the mathematical tools needed
\ ** in the routine work in biochemical spectroscopy and enzyme
\ ** kinetics. The program is menu-driven and (mostly) self-explanatory.
\ ** In addition, the software also implements a powerful, Forth-based scripting
\ ** language.
\ *P Besides the stand-alone version, the software is also available in
\ ** several instrument-specific versions incorporating instrument control
\ ** and data aquisition functions for the following instruments:
( *B Ocean Opics CCD spectrometer )
( *B Edinbourgh Instruments EI-900 fluorometer )
( *B Modified PTI QM-1 fluorometer )
\ ** equipped with a Hammamatsu H9059 photon-counting
\ ** photomultipler module and a USB-CTR04 high-speed
\ ** counter/timer module (Measurement Computing Corporation).
( *B Hitachi F2000 fluorometer )

ONLY FORTH ALSO DEFINITIONS

Vocabulary SpectraLab
Vocabulary Utilities
Vocabulary GRAKERN
Vocabulary SPN_DEF
Vocabulary SPL32CRT
Vocabulary Redefine
Vocabulary SpecArithm
Vocabulary SpecTools
Vocabulary Resources
Vocabulary INSTRUMENT

SpectraLab ALSO DEFINITIONS

\ INSTRUMENT SELECTION SWITCHES.
\ ONLY ONE of THE SWITCHES SHOULD BE SET TO "TRUE" FOR SUCCESSFUIL COMPILATION
      true  value INST-DUMMY \ no instrument control
      false value INST-OO  \ Ocean Opics CCD spectrometer
      false value INST-EI  \ EI-900
      false  value INST-PTI \ QM-1 fluorometer
      false  value INST-Hitachi \ Hitachi F2000
\ END of INSTRUMENT-SELECTION BLOCK

false value depthreported
false value fdepthreported
0 value WMCOUNT
0 value started
2 value formatcode
0 value tmpidx
0   VALUE DIR$ADR
0   VALUE SPLAB-WINDOW
0   VALUE DATA-WINDOW
0   VALUE ZEROSTACK
0   VALUE @WORK
0   VALUE @SCAN
0   VALUE WDTH0
0   VALUE HGHT0
0   VALUE MainPrmSet
0   value InHandling
0   value Splittermove

Font WinFont           \ default font
Create messagebuffer 32 allot

Utilities ALSO DEFINITIONS
NEEDS ZSTRINGS
NEEDS STRING$
NEEDS FLO2INT
NEEDS NANS
Needs SplabDlg
SPN_DEF ALSO DEFINITIONS
WinLibrary SplabDll
WinLibrary OptiFun
WinLibrary Curfit
WinLibrary F2INT
NEEDS SPN_DEF
GRAKERN ALSO DEFINITIONS
NEEDS WGRAKRN
SPL32CRT ALSO DEFINITIONS
Needs SPL32CRT
SpecArithm ALSO DEFINITIONS
Needs SpecArithm.F
SpecTools ALSO Definitions
Needs CURFIT.F
Needs Span.F
Needs SpecTools.F
Needs SurfitFrm.F
Needs CorForm.F
Resources ALSO DEFINITIONS
Needs ListView.f
Needs Resources.f
Needs Excontrols.f
Needs AcceleratorTables
Instrument ALSO DEFINITIONS

INST-DUMMY [IF]
        NEEDS INSTR-DUMMY
: VersTitle s" Stand Alone Version" ;
       [THEN]
INST-OO [IF]
        NEEDS OO_CTL
        Needs Thermo
: VersTitle        S" Ocean Optics Spectrometer Version" ;
      [THEN]
 INST-EI [IF]
         NEEDS EI_CTL
: VersTitle        S" EI Version" ;
        [THEN]
 INST-PTI [IF]
         NEEDS PTI_CTL
: VersTitle s" PTI Fluorometer Version" ;
        [THEN]
 INST-Hitachi [IF]
         NEEDS FLUO_CTL
: VersTitle        S" Hitachi F2000 Version" ;
        [THEN]

\ END of INSTRUMENT SELECTION BLOCK

ONLY FORTH ALSO Utilities ALSO SPN_DEF ALSO GRAKERN ALSO SPL32CRT ALSO SpecArithm ALSO
SpecTools ALSO Resources ALSO Instrument ALSO
SpectraLab ALSO Definitions


INCLUDE FKEYS

ZSTRING CMD$
ZSTRING JOB$
        4 constant sizeof(RGBQUAD)
       14 constant sizeof(BitmapFileHeader)
       40 constant sizeof(BitmapInfoHeader)

        0 constant biSize
        4 constant biWidth
        8 constant biHeight
       12 constant biPlanes
       14 constant biBitCount
       16 constant biCompression
       20 constant biSizeImage
       24 constant biXPelsPerMeter
       28 constant biYPelsPerMeter
       32 constant biClrUsed
       36 constant biClrImportant

AcceleratorTable ControlKeys
      12 constant Pg-Inc
lv_item lvitem


: AboutSplab
        True to @work
        CLEARCRT
        s" SpectraLab-MMX by Dmitri R. Davydov" dup 40 swap - 2 / 2 XYTYPE$
        s" Spectral data analysis software " dup 40 swap - 2 / 4 XYTYPE$
        s" Version 3.01.01" dup 40 swap - 2 / 5 XYTYPE$
        VersTitle dup 40 swap - 2 / 6 XYTYPE$
        s" Compiled June 10 2022" dup 40 swap - 2 / 7 XYTYPE$
        s" SpLab uses HTML-based help support." 2 9 XYTYPE$
        s" By default, the internal browser" 2 10 XYTYPE$
        s" (HELP.EXE) is used to navigate through" 2 11 XYTYPE$
        s" the help system. Otherwise, you can" 2 12 XYTYPE$
        s" provide the path to your internet" 2 13 XYTYPE$
        s" browser in the file SPLAB-MMX.INI" 2 14 XYTYPE$
        s" Press any key to close this window" dup 40 swap - 2 / 16 XYTYPE$
        call CRTREADAKEY drop
        CLEARCRT
        NOCRT
        False to @work
 ;

: GetHelp
     GET: BROWSPATH$ s" HELP.EXE" ISTR= NOT IF
       GET: BROWSPATH$ put: pname$ 32 +char: pname$
       s" Help\splab-index.htm " append-fname append: pname$
     else
       s" help.exe" append-fname put: pname$
    then
    pname$ $EXEC drop
;

\ ===================== Rplacements for FKERNEL "evaluate" procedure and error handler

CODE (%SAVE-INPUT) ( ... 7 -- R: ... 7 )               \ save input to rstack
                mov     -8 CELLS [ebp], ebx
                pop     -7 CELLS [ebp]
                pop     -6 CELLS [ebp]
                pop     -5 CELLS [ebp]
                pop     -4 CELLS [ebp]
                pop     -3 CELLS [ebp]
                pop     -2 CELLS [ebp]
                pop     -1 CELLS [ebp]
                sub     ebp, # 32
                pop     ebx
                next    c;

CODE (%RESTORE-INPUT) ( R: ... 7 -- ... 7 )            \ save input to stack
                push    ebx
                push    7 CELLS [ebp]
                push    6 CELLS [ebp]
                push    5 CELLS [ebp]
                push    4 CELLS [ebp]
                push    3 CELLS [ebp]
                push    2 CELLS [ebp]
                push    1 CELLS [ebp]
                mov     ebx, 0 CELLS [ebp]
                add     ebp, # 32
                next    c;

: %THROW         ( n -- ) \ throw an error, identified by n, while executing a word
                \ whose execution is "protected" by CATCH .
                ?DUP
                s" EXEC ERROR: " put: TMP$
                IF
                  dup case
                    -4  of drop s" Stack underflow" ENDOF
                    -13 of drop s" Undefined operator" ENDOF
                    -14 of drop s" Flow control sintax" ENDOF
                    -45 of drop s" Floating point stack underflow" ENDOF
                    DEFAULTOF
                        s" CODE " append: TMP$
                        s>d (D.)           \ integer to string conversion
                    endof
                   endcase
                   append: TMP$
                   TMP$ call SplabErrorMessage drop
                THEN ;


: %EVALUATE   ( addr len -- ) \ interpret string addr,len
                    ['] interpret
                    -rot -if
                      save-input (%save-input)
                      (SOURCE) 2!
                      >IN OFF
                      -1 TO SOURCE-ID
                      CATCH
                      (%restore-input) restore-input drop
                      %THROW
                    else 2drop drop then
;

\ ==========================================================================
: EXEC-IT  ( addr len -- ) \ Execute a command string entered in "EXEC" edit box
                         MainPrmSet @scan @work or not and if
                           PUT: CMD$
                           CMD$ Call PREPARSE
                           SetSpcPrms: Splab-Window
                           1 swap DO
                             stkclr
                             fstkclr
                             GET: CMD$
                             %EVALUATE
                             StkClr
                             fstkclr
                             SetCurveList: DATA-WINDOW
                           -1 +loop
                           SetListEdit: Splab-Window
                           SetCtrl:     Splab-Window
                           SetDataEdit: Splab-Window
                           beep-beep
                           replot-it
                         then
;



\ *Q Data File Formats Supported:
\ *B Splab-style .SPC files (*.SPC)
\ *B JCAMP files (*.DX)
\ *B Exel-style .CSV files (*.CSV)
\ *B Splab-style .ASC files (*.ASC)
\ *B Splab4-style .DAT Files (*.DAT)
\ *P In addition to full (read and write) support for the above formats,
\ ** the program also supports reading of GRAMS (Thermo Galactic) .SPC and
\ ** NanoDrop .NDV files. Reading of .CSV files allows seamless processing of the
\ ** files generated by EI-900 fluorometer, Voyager mass-spectrometer and Genesis
\ ** spectrophotometer.
\ *S

FileSaveDialog SaveSPC "Save Data File" "Splab-style .SPC Files|*.SPC|JCAMP Files|*.DX|Exel-style .CSV files|*.CSV|Splab-style .ASC files|*.ASC|Splab4-style .DAT Files|*.DAT|"

FileSaveDialog SaveDX "Save Data File" "JCAMP Files|*.DX|Splab-style .SPC Files|*.SPC|Exel-style .CSV files|*.CSV|Splab-style .ASC files|*.ASC|Splab4-style .DAT Files|*.DAT|"
FileSaveDialog SaveCSV "Save Data File" "Exel-style .CSV files|*.CSV|Splab-style .ASC files|*.ASC|JCAMP Files|*.DX|Splab-style .SPC Files|*.SPC|Splab4-style .DAT Files|*.DAT|"
FileSaveDialog SaveASC "Save Data File" "Splab-style .ASC files|*.ASC|Exel-style .CSV files|*.CSV|JCAMP Files|*.DX|Splab-style .SPC Files|*.SPC|Splab4-style .DAT Files|*.DAT|"
FileSaveDialog SaveDAT "Save Data File" "Splab4-style .DAT Files|*.DAT|JCAMP Files|*.DX|Splab-style .SPC Files|*.SPC|Exel-style .CSV files|*.CSV|Splab-style .ASC files|*.ASC|"

FileOpenDialog LoadDX "Load JCAMP File" "JCAMP Files|*.DX|"
FileOpenDialog AppendDX "Append data from JCAMP File" "JCAMP Files|*.DX|"
FileOpenDialog LoadSPC "Load SPC File" "SPC Files|*.SPC|"
FileOpenDialog LoadASC "Load ASC, CSV, DAT or NDV File" "ASC Files|*.ASC|Exel-style .CSV files|*.CSV|.DAT files|*.DAT|NanoDrop data files|*.NDV|"

: confirm  ( -- select )
  call confirm
;

: SetLVString0
    s" " put: lstring
    obj @ STR$
    4 over -
    begin
      dup 0 > while
      1-
      48 +CHAR: LSTRING
    repeat
    drop
    APPEND: LSTRING
;

: SetLVString1  { cur# sel# ref# \ -- }
    s" " put: lstring
    cur#  if 149 else 32 then
    +char: lstring
    SEL#  IF 187 ELSE 32 THEN
    ref#  IF drop 35 THEN
    +char: lstring
;

: SetLVString3
       s" " put: LSTRING
       curdir.zz IsNAN4 NOT IF
         @FZ: curdir flo2str
         APPEND: LSTRING
       THEN
;

: SetXYString0
    s" " put: lstring
    dup STR$
    4 over -
    begin
      dup 0 > while
      1-
      48 +CHAR: LSTRING
    repeat
    drop
    APPEND: LSTRING
    drop
;

: load-data    { append \ -- }
      GetHandle: Splab-Window
      append if
        Start: AppendDX
      else
        Start: LoadDX
      then
      dup c@
      if  count
         put: FNAME
         FNAME obj @ Append not dup if
           clearall
         then
         call DX_load drop
         append not if
           @offs: xaxis XMIN F!
           @lim: xaxis  XMAX F!
           @offs: yaxis YMIN F!
           @lim:  yaxis YMAX F!
         then
         obj @ getddir
     else  drop
     then    ;

: load-spc
      GetHandle: Splab-Window
      Start: LoadSPC  dup c@
      if  count
         put: FNAME
         FNAME call ReadSPC  drop
         @offs: xaxis XMIN F!
         @lim: xaxis  XMAX F!
         @offs: yaxis YMIN F!
         @lim:  yaxis YMAX F!
         obj @ getddir
     else  drop
     then    ;

: ascload
   put: FNAME
   FNAME call ReadInAsc drop
   obj @ getddir
;

: "load
    ascload
    SetListEdit: Splab-Window
    SetDataEdit: Splab-Window
    SetCurveList: DATA-WINDOW
    SetCtrl:     Splab-Window
    replot-it
;

: load-ASC
      GetHandle: Splab-Window
      Start: LoadASC dup c@
      if count ascload else drop
     then    ;

: "save-data    { sa sn -- }
                    sa sn put: FNAME
                    FNAME call UPNDOT
                    0
                    begin
                      swap 1+
                      dup dup 1 > swap len: fname > not and while
                      swap
                      256 *
                      over
                      getchar: fname +
                    repeat
                    drop
                    -1 swap
                    case
                      0   of drop 0 endof   \ no extention
                      17496   of drop 1 endof   \ ".DX"  156
                      4473172 of drop 4 endof   \ ".DAT" 217
                      4412246 of drop 3 endof   \ ".CSV"  236
                      4281155 of drop 5 endof   \ ".ASC"  215
                      5460035 of drop 2 endof   \ ".SPC"  230
                    endcase
                    dup 0 < if FSTRING-BUF FNAME 46 CALL NEXTSTR 2drop 0 then \ 46 is ASCII for '.'
;

: save-data     { format-code -- }
                 format-code 1 < format-code 5 > OR if 1 to format-code then
                 GetHandle: Splab-Window
                 format-code case
                    1 of
                           get: FNAME0 SetFile: SaveDx
                           get: FNAME0 SetDir: SaveDx
                           Start: SaveDX
                          endof
                    2 of
                           get: FNAME0 SetFile: SaveSpc
                           get: FNAME0 SetDir: SaveSpc
                           Start: SaveSPC
                     endof
                    3 of Start: SaveCSV endof
                    4 of Start: SaveDAT endof
                    5 of Start: SaveASC endof
                 endcase
                 dup c@
                 if
                   count "save-data
                   dup 0 = if
                     format-code case
                       1 of s" .DX" endof
                       2 of s" .SPC" endof
                       3 of s" .CSV" endof
                       4 of s" .DAT" endof
                       5 of s" .ASC" endof
                     endcase
                     append: fname
                     drop format-code
                   then
                   case
                    1 of s" Do you want to save all selected traces? " put: ss$ ss$ call SplabQuestion
                          6 = \ mbYes
                          if 0 else $ then
                          FNAME swap call DX_save
                          get: FNAME put: FNAME0
                       endof \ ".DX"
                    2 of
                          FNAME call SaveSPC
                          get: FNAME put: FNAME0
                        endof \ ".SPC"
                    3 of  FNAME call SaveInAsc endof \ ".CSV"
                    4 of  s" Do you want to save all selected traces? " put: ss$ ss$ call SplabQuestion
                          6 = \ mbYes
                          if 0 else $ then
                          FNAME swap  call _dsave
                      endof  \ ".DAT"
                    5 of  FNAME call SaveInAsc endof \ ".ACS"
                   endcase
                   not if
                      s" Data save error: File "
                      put: tmpstr
                      get: fname
                      append: tmpstr
                      tmpstr call SplabErrorMessage drop
                   then
                 else    drop
                 then
;
( *T User Interface )
( *S General Design )
\ ** Launching the stand-alone version of SpLab results in appearance of two main windows -
\ ** the chart window (on the left) and the main program conrol and data manipulation window (on the right).
\ ** The instrument-specific versions also open the instrument control interface window (in the right lower
\ ** corner of the screen). \bThe chart window\d displays a plot of either the focused trace or an overlay of the plots of
\ ** all traces selected for display (depending on the state of "Plot-all" checkbox in the control window).
\ ** \bThe main contrtol splitter window\d contains three panes: the top pane is used for general control of the program, the left
\ ** lower pane contains the list of all currently loaded data sets (individual spectra or kinetic traces)
\ ** and the right lower pane displays a list of the datapairs (X and Y values) of the focused dataset.

: chart-page-setup
        GetHandle: Splab-Window Setup: ThePrinter
;


: print-chart { nBits \  pbmi lpBits hbm  hdcMem    -- }
             Open: ThePrinter
        GetHandle: ThePrinter 0= ?EXIT
            Start: ThePrinter

        sizeof(BitmapInfoHeader) sizeof(RGBQUAD) 256 * + malloc to pbmi
        pbmi sizeof(BitmapInfoHeader) sizeof(RGBQUAD) 256 * + erase   \ (1) DON'T DELETE THIS LINE
                                                                      \

        sizeof(BitmapInfoHeader)                   pbmi biSize            + !
        SCREEN-WIDTH                               pbmi biWidth           + !
        SCREEN-HEIGHT                              pbmi biHeight          + !
        1                                          pbmi biPlanes          + w!
        nBits                                      pbmi biBitCount        + w!

        BI_RGB                                     pbmi biCompression     + !

      \  0    pbmi biSizeImage       +   !       NOT NEEDED           (1)
      \  0    pbmi biXPelsPerMeter   +   !       SINCE
      \  0    pbmi biYPelsPerMeter   +   !       pbmi IS ERASED
      \  0    pbmi biClrUsed         +   !       ABOVE
      \  0    pbmi biClrImportant    +   !


        SCREEN-HEIGHT
        SCREEN-WIDTH
        GetHandle: chart-win
        Call CreateCompatibleBitmap to hbm


        GetHandle: chart-win
        Call CreateCompatibleDC to hdcMem
        hbm hdcMem Call SelectObject drop

        SRCCOPY                                   \
        0 0                                       \ y,x origin
        GetHandle: chart-win                      \ from screen dc
        SCREEN-HEIGHT                             \ height of dest rect
        SCREEN-WIDTH                              \ width of dest rect
        0 0                                       \ y,x dest
        hdcMem                                    \ to memory dc
        Call BitBlt ?win-error                    \


        DIB_RGB_COLORS
        pbmi \ rel>abs
        NULL
        SCREEN-HEIGHT
        0
        hbm
        hdcMem
        Call GetDIBits 0= abort" 1st GetDIBits"


       \ pbmi show-bitmapinfoheader

        pbmi biSizeImage + @ malloc \ rel>abs
        to lpBits
        lpBits pbmi biSizeImage + @ erase


        DIB_RGB_COLORS
        pbmi \ rel>abs
        lpBits
        SCREEN-HEIGHT
        0
        hbm
        hdcMem
        Call GetDIBits 0= abort" 2nd GetDIBits"

      \  pbmi show-bitmapinfoheader


        SRCCOPY
        DIB_RGB_COLORS
        pbmi \ rel>abs
        lpBits

        SCREEN-HEIGHT
        SCREEN-WIDTH
        0
        0
        Height: ThePrinter
        Width: ThePrinter
        0
        0
        GetHandle: ThePrinter
        Call StretchDIBits GDI_ERROR = ABORT" StretchDIBits"
          End: ThePrinter
        Close: ThePrinter
        hdcMem call DeleteDC ?win-error
        hbm call DeleteObject ?win-error


        lpBits release
        pbmi release
        ;

tool-bar-file "fload

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define the menubar for the application
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


 MENUBAR Splab-Menu-bar

    POPUP "&File"
        MENUITEM        "&Save Data in JCAMP File "
                           1 save-data  ;
        MENUITEM        "&Save Data in SPC File "
                           2 save-data  ;
        MENUITEM        "&Save Data in ASC File "
                           5 save-data  ;
        MENUITEM        "&Save Data in CSV File "
                           3 save-data  ;
        MENUITEM        "&Save Data in DAT File "
                           4 save-data  ;
        MENUSEPARATOR
        MENUITEM        "&Load JCAMP File... "
                           false load-data
                           SetListEdit: Splab-Window
                           SetDataEdit: Splab-Window
                           SetCurveList: DATA-WINDOW
                           SetCtrl:     Splab-Window
                           obj @ plot
                           ;
        MENUITEM        "&Append Data from JCAMP File... "
                           true load-data
                           SetListEdit: Splab-Window
                           SetDataEdit: Splab-Window
                           SetCurveList: DATA-WINDOW
                           obj @ plot
                           ;
        MENUITEM        "&Load SPC File... "
                           load-SPC
                           SetListEdit: Splab-Window
                           SetDataEdit: Splab-Window
                           SetCurveList: DATA-WINDOW
                           SetCtrl:     Splab-Window
                           obj @ plot
                           ;
        MENUITEM        "&Load ASC, CSV or DAT File... "
                           load-ASC
                           SetCurveList: DATA-WINDOW
                           SetListEdit: Splab-Window
                           SetDataEdit: Splab-Window
                           SetCtrl:     Splab-Window
                           obj @ plot
                           ;

        MENUSEPARATOR
        MENUITEM        "P&age Setup... "  chart-page-setup     ;
        MENUITEM        "&Print... " 8 print-chart  ;
        MENUSEPARATOR
        MENUITEM        "C&lear All  "
                         confirm 1 = if
                          ~ClearAll                           \ keep reference
                          SetListEdit: Splab-Window
                          SetDataEdit: Splab-Window
                          SetCurveList: DATA-WINDOW
                          obj @ plot
                         then
                         ;
        MENUSEPARATOR
        MENUITEM        "E&xit "
                         Save_State
                         close-plugins
                         0 call PostQuitMessage drop     \ terminate application
                         bye ;

    POPUP "&Analysis"
        MENUITEM        "&Curve Fitting (CURFIT, Non-Linear Regression) " curfit ;
        MENUITEM        "&Spectra Decomposition (SURFIT) " Surfit-Dialog ;
        MENUITEM        "&Principal Component Analysis (SPAN) "  Span-Dialog ;

    POPUP "&Math"
        MENUITEM        "&Add Trace" add-spc ;
        MENUITEM        "&Subtract Trace" Subtract-spc ;
        MENUITEM        "A&dd Constant" Add-const ;
        MENUITEM        "S&ubtract Constant" Subtract-const ;
        MENUITEM        "&Multiply Traces" Multiply-spc ;
        MENUITEM        "Mu&ltiply by Constant" Multiply-const ;
        MENUITEM        "&Divide by Trace" Divide-spc ;
        MENUITEM        "D&ivide by Constant" Divide-const ;
        Menuitem        "&A&verage Traces" avr-dialog ;
        MENUSEPARATOR
        MENUITEM        "&Polynomial smoothing " Smooth-dialog ;
        MENUITEM        "&Moving median (triad) smoothing " Tri-dialog ;
        MENUSEPARATOR
        MENUITEM        "&Resample " Resample-dialog ;
    POPUP "&Spectra correction"
        MENUITEM        "&TitCor (Correction on dilution) \tAlt-T" titcor-dialog ;
        MENUITEM        "&Sub (Recursively subtract correction trace) \tAlt-S" sub-dialog ;
        MENUITEM        "&PolyCor (Background suppression) \tAlt-C" PolyCor-Dialog ;
        MENUSEPARATOR
        MENUITEM        "Pressure &Correction " CorPress-Dialog ;
    POPUP "&Help"
        MENUITEM        "&About SpLab "   AboutSplab ;
        MENUITEM        "&Help " GetHelp ;




ENDBAR

\ ------------------------------------------------------------------------
\ Define the Listview for the left part of the window.
\ ------------------------------------------------------------------------
:object ListViewLeft <super ListView

:M WindowStyle: ( -- style )
        WindowStyle: super
\     [ LVS_REPORT LVS_SHOWSELALWAYS OR LVS_SORTASCENDING or  LVS_SINGLESEL or LVS_NOLABELWRAP or ] literal or
      [ LVS_REPORT LVS_SHOWSELALWAYS OR LVS_SORTASCENDING or  LVS_SINGLESEL or ] literal or
        ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

;object

\ ------------------------------------------------------------------------
\ Define the Listview for the right part of the window.
\ ------------------------------------------------------------------------

:object ListViewRight <super ListView

:M WindowStyle: ( -- style )
        WindowStyle: super
        [ LVS_REPORT LVS_SHOWSELALWAYS OR LVS_SORTASCENDING or LVS_SINGLESEL or ] literal or
        ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

;object

\ ------------------------------------------------------------------------
\ Define the left part of the splitter window.
\ ------------------------------------------------------------------------
:Object LeftPane        <Super Child-Window

int SelectedItemLeft
0 value oldobj

:M ExWindowStyle:    ( -- style )
        ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_Size:     ( -- )
        gethandle: ListViewLeft
        if   1 ( repaint flag )
             tempRect.AddrOf GetClientRect: Self
             Bottom: tempRect Right: tempRect   0 0
             gethandle: ListViewLeft Call MoveWindow drop
        then ;M

: GetParmsItem  ( nItem  - Z$text Lparm flNew )
        >r LVIF_TEXT LVIF_PARAM or SetMask: LvItem
        r@ SetiItem: LvItem
        GetlParam: LvItem r@ 1+
        SelectedItemLeft <>
        if   r> 1+ to SelectedItemLeft true
        else r>drop false
        then ;


: HandleListViewLeft   ( msg - )
     inhandling not if
        true to inhandling
        LVNI_FOCUSED -1 GetNextItem:  ListViewLeft dup  -1 =
        if   drop
        else
         SetSpcPrms: Splab-Window
         GetParmsItem
         selectedItemLeft obj @ = not if
\           SelectedItemLeft chgDdir
           SelectedItemLeft SetSelectedLeft: Data-Window
           SetListEdit: Splab-Window
           SetDataEdit: Splab-Window
           SetCtrl: Splab-Window
           pnt_ptr curdir.npts > if curdir.npts to pnt_ptr then
           pnt_ptr 0 = if 1 to pnt_ptr then
           last-obj 0 > not if Replot-It else $ plot then
        then

       then
       false to inhandling
     then
    ;

:M WM_NOTIFY    ( h m w l -- f )
        dup @ GetHandle: ListViewLeft = if
           dup 2 cells+ @  NM_DBLCLK  = if
             $ to last-obj
             StkClr $ plot
           else
            dup 2 cells+ @  NM_RCLICK	= if
             Sel2Chk: Splab-Window
             last-obj 0> not if replot-it then
            then
           then
           HandleListViewLeft
        then false
        ;M

:M Start:       ( parent -- )
        start: super
       $ to SelectedItemLeft
        Self start: ListViewLeft
        ;M


;Object


\ ------------------------------------------------------------------------
\ Define the right part of the splitter window.
\ ------------------------------------------------------------------------
:Object RightPane        <Super Child-Window

int SelectedItemRight

:M ExWindowStyle:       ( -- style )
        ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_Size:     ( -- )
        gethandle: ListViewRight
        if   1 ( repaint flag )
             tempRect.AddrOf GetClientRect: Self
             Bottom: tempRect Right: tempRect   0 0
             gethandle: ListViewRight Call MoveWindow drop
        then ;M

: GetParmsItem  ( nItem  - Z$text Lparm flNew )
        >r LVIF_TEXT LVIF_PARAM or SetMask: LvItem
        r@ SetiItem: LvItem
        GetlParam: LvItem r@ 1+
        SelectedItemRight <>
        if   r> 1+ to SelectedItemRight true
        else r>drop false
        then ;

: HandleListViewRight   ( msg - )
        LVNI_SELECTED -1 GetNextItem:  ListViewRight dup  -1 =
        if   drop
        else
        GetParmsItem
           selectedItemRight pnt_ptr = not if
           pnt_ptr false ShowStatusRight: Data-Window
           SelectedItemRight to pnt_ptr
           SetSelectedRight: Data-Window
           SetDataEdit: Splab-Window
           CursorOn if replot-it then
        then
       then
       ;

:M WM_NOTIFY    ( h m w l -- f )
        dup @ GetHandle: ListViewRight = if \ EnableNotify? and
           dup 2 cells+ @  NM_DBLCLK  = if
             CursorOn not if Cursor2Toggle: Splab-Window then
           then
           HandleListViewRight
        then false
        ;M


:M Start:       ( parent -- )
        start: super
        pnt_ptr to SelectedItemRight
        Self start: ListViewRight
        ;M


;Object
\ *P \b The top pane of the main window\d (Splab-Controls pane) contains:
\ *B The main toolbar of the application
\ *B The commandline edit box with "Exec" button, which is used for executing user-defined commands formed with
\ ** the use of the Forth-based scripting language (most of the available operations are also accessible through
\ ** the menu-driven interface).
\ *B The "Axes" block used for editing the scaling, X- and Y-axes legends and the comment line for data
\ ** plot shown in the Chart window. It also contains a "Replot" button and a "Plot-All" switch check-box.
\ *B The "Data set" block with the means for editing the header and display parameters of the focused data set
\ *B The "Data point" block with the means for editing the selected data pair in the focused data set
\ ** (see below).

:OBJECT Splab-Controls <Super Child-Window
int lparmLeft
String: Out$

0     VALUE InProcess
0     Value Last-Chk
0     Value Last-Edt
0     value SC-WDTH
0     value SC-HGHT
3     value inix
3     value iniy
0     value isnotedit


' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND

Label X-Linhed
Label Y-Linhed
Label FootTxt
Label MIN-COLHED
Label MAX-COLHED
Label AUTO-COLHED
Label LBL-COLHED
Label Hed-Hed
Label DATA-Pair-Lbl
Label X-Value-Lbl
Label Y-Value-Lbl
Label X-Hed
Label Y-Hed
Label Z-Hed

PushButton Clr-Spc-Bttn
PushButton Set-Spc-Bttn
PushButton Set-Data-Bttn
PushButton Clr-Data-Bttn
PushButton Add-Data-Bttn
PushButton Exec-Button
PushButton Plot-Button
Pushbutton Focus-UP
Pushbutton Focus-DOWN
Pushbutton Focus-Bgn
Pushbutton Focus-End
Pushbutton Cursor-UP
Pushbutton Cursor-DOWN
Pushbutton Cursor-Bgn
Pushbutton Cursor-End

CheckBox X-Auto
CheckBox Y-Auto
CheckBox Int-ON
CheckBox Lin-ON
CheckBox Sel-Chk
CheckBox Show-cursor
CheckBox Plot-All-Chk

GroupBox Plot_Axes
GroupBox Group_List
GroupBox Group_Data
GroupBox Group_Focus

VertScroll ScrollDataSet
VertScroll ScrollCurveList

TextBox X-Edit
TextBox Y-Edit
TextBox Cmd-Line
TextBox X-Labl-Edit
TextBox Y-Labl-Edit
TextBox X-Min-Edit
TextBox Y-Min-Edit
TextBox X-Max-Edit
TextBox Y-Max-Edit
TextBox Hed-Edit
TextBox Z-Edit
TextBox Color-Edit
TextBox Symbl-Edit
TextBox Comment-Edit

:M ExWindowStyle:    ( -- style )
        ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_size:     ( -- )
        \ need to repaint in this child-window as the position of the
        \ text depends on its size
        Paint: self ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M




:M WindowStyle: ( -- style )            \ return the window style
                WindowStyle: super
                ;M

:M StartSize:   ( -- width height )
                splab-width dup to SC-WDTH splab-height dup to SC-HGHT
                ;M

:M MinSize:     ( -- width height )     \ minimum window size
                min-splab-width min-splab-height ;M

:M MaxSize:
    maxwidth 4 - maxheight 4 -
    ;M

:M StartPos:    ( -- x y )
                inix iniy ;M


:M Close:        ( -- )
                Close: super
                ;M

\ :M WindowHasMenu: True ;M

:M Draw_win:
                135 74 38 16 Move: MAX-COLHED
                74  74 38 16 Move: MIN-COLHED
                46 74 25 16 Move: AUTO-COLHED
                194 74 54 16 Move: LBL-COLHED
                194 91 SC-WDTH 360 - 18            Move: X-Labl-Edit
                194 114 SC-WDTH 360 - 18            Move:   Y-Labl-Edit
                50 86 16 26 Move: X-Auto   \ 175
                50 109 16 26 Move: Y-Auto  \ 175
                74 91 56 18 Move: X-Min-Edit \ 54
                74 114 56 18 Move: Y-Min-Edit \ 54
                135 91 56 18 Move: X-Max-Edit  \ 114
                135 114 56 18 Move: Y-Max-Edit  \ 114

                5 91 38 16 Move: X-Linhed
                5 114 38 16 Move: Y-Linhed
                54 138 SC-WDTH 60 - 18   Move:   Comment-Edit
                5 138 48 18 Move: FootTxt
                1 64 SC-WDTH 3 - 101     Move: Plot_Axes
                1 164 SC-WDTH 123 - 56     Move: Group_List
                7 194 46 16 Move: Sel-Chk
                8 236 44 16 Move: Data-Pair-Lbl
                60 236 24 16 Move: X-hed
                74 236 80 18 Move: X-edit
                180 236 80 18 Move: Y-edit
                164 236 80 16 Move: Y-hed
                278 236 35 18 Move: Set-Data-Bttn
                318 236 35 18 Move: Clr-Data-Bttn
                358 236 35 18 Move: Add-Data-Bttn
                3 220 400  40     Move: Group_Data
                54 194 SC-WDTH 355 - 18 Move: Hed-Edit \ 235
                SC-WDTH 240 - 194 16 16 Move: Lin-ON
                SC-WDTH 257 - 194 16 16 Move: Int-ON
                SC-WDTH 297 - 194 36 18 Move: Z-Edit
                SC-WDTH 222 - 194 24 18 Move: Symbl-Edit
                SC-WDTH 193  - 194 24 18 Move: Color-Edit
                SC-WDTH 106 - 164 100 100 Move: Group_Focus
                SC-WDTH 92  - 179 35 18 Move: Focus-BGN
                SC-WDTH 92  - 198 35 18 Move: Focus-Up
                SC-WDTH 52  - 198 35 18 Move: Focus-Down
                SC-WDTH  52  - 179 35 18 Move: Focus-END
                SC-WDTH 92  - 223 35 18 Move: Cursor-BGN
                SC-WDTH 92  - 242 35 18 Move: Cursor-Up
                SC-WDTH 52  - 242 35 18 Move: Cursor-Down
                SC-WDTH  52  - 223 35 18 Move: cursor-END
                Sc-Wdth 162 - 238 50 16  Move: Show-cursor
                 54 179 64 14            Move:     Hed-Hed
                SC-WDTH 297 - 179 140 14 Move:     Z-Hed
                SC-WDTH 162 - 173 35 16 Move: Clr-Spc-Bttn
                SC-WDTH 162 - 192 35 19 Move: Set-Spc-Bttn
                54 46 SC-WDTH 60 - 18 Move: Cmd-Line
                3 46 40 18 Move: Exec-Button
                SC-Wdth 162 - 93 48 36            Move: Plot-Button
                SC-Wdth 100 - 93 90 36            Move: Plot-All-Chk

;M

:M SetDataEdit:
     true to InProcess
     s" # " put: tmpstr
     pnt_ptr str$
     4 over -
     begin
      dup 0 > while
      1-
      48 +CHAR: TMPSTR
     repeat
     drop
     Append: tmpstr
     get: tmpstr  SetText: DATA-Pair-Lbl
     curdir.npts 0 = if
       s" "
       SetText: X-edit
       s" "
       SetText: Y-Edit
     else
       pnt_ptr 1- pullx: curdir
       flo2str
       SetText: X-edit
       pnt_ptr 1- pully: curdir
       flo2str
       SetText: Y-Edit
     then
     false to inprocess
;M

:M SetListEdit:
    true to Inprocess
    false to MainPrmSet
     s" # " put: tmpstr
     obj @ str$
     3 over -
     begin
      dup 0 > while
      1-
      48 +CHAR: TMPSTR
     repeat
     drop
     Append: tmpstr
     get: tmpstr
     SetText: Sel-Chk
     @header: curdir     SetText:  Hed-Edit
     curdir.zz dup
     IsNAN4 NOT IF
        S2F
        flo2str
     else
        drop
        S"  "
     then
     SetText: Z-Edit
     curdir.plotcolor 0X7F and
     str$
     SetText: Color-Edit
     curdir.symbol
     str$
     SetText: Symbl-Edit
     SetDataList: Data-Window
   true to MainPrmSet
   false to inprocess
;M

:M ClearListEdit:
            NAN4 !NZ: curdir
            s" " !Header: curdir
            SetListEdit: self
;M

:M SetPlotChk:
               last-obj 0 > not IF 1 ELSE 0 THEN GetID: Plot-All-Chk CheckDlgButton: self
;M

:M SetCtrl:
   true to inprocess
   @token: xaxis    SEtText: X-Labl-Edit
   @token: yaxis    SEtText: Y-Labl-Edit
   @footnote: xaxis     SetText: Comment-Edit
   XAXIS.AUTO IF 1 ELSE 0 THEN GetID: X-Auto CheckDlgButton: self
   YAXIS.AUTO IF 1 ELSE 0 THEN GetID: Y-Auto CheckDlgButton: self
   last-obj 0 > not IF 1 ELSE 0 THEN GetID: Plot-All-Chk CheckDlgButton: self
   XMIN F@ FLO2STR SetText: X-Min-Edit
   XMAX F@ FLO2STR SetText: X-Max-Edit
   YMIN F@ FLO2STR SetText: Y-Min-Edit
   YMAX F@ FLO2STR SetText: Y-Max-Edit
   CURDIR.INTER if 1 else 0 then GetID: INT-ON CheckDlgButton: self
   CURDIR.CONNECT if 1 else 0 then GetID: LIN-ON CheckDlgButton: self
   ?SEL if 1 else 0 then GetID: Sel-Chk CheckDlgButton: self
   SetPlotChk: self
   TRUE to MainPrmSet
   false to inprocess
;M

:M SetSpcPrms:
                   true to inprocess
                    GetText: Z-Edit
                     STR2FLO if
                       !FZ: curdir
                     else
                      NAN4 !NZ: curdir
                     then
                     GetText: Hed-Edit
                     HeadLen 1 - Min !Header: curdir
                     GETID: INT-ON IsDlgButtonChecked: self
                     0= not !INTER: CURDIR
                     GETID: LIN-ON IsDlgButtonChecked: self
                     0= not !CONNECT: CURDIR
                     GetText: Color-Edit
                     STR2FLO if
                       F2I
                       dup 1 COLOR-MAX within if !color: curdir else drop then
                     then
                     GetText: Symbl-Edit
                     STR2FLO if
                       F2I
                       dup 0 SYMBOL-MAX within if !symbol: curdir else drop then
                     then
                     GETID: Sel-Chk IsDlgButtonChecked: self
                     0= if #SEL else !SEL then
                   false to inprocess
;M
:M SetDataPoint:
                   true to inprocess
                    GetText: Y-Edit
                    STR2FLO
                    GetText: X-Edit
                    STR2FLO
                    AND
                    if
                     if curdir.npts 1+ to pnt_ptr then
                     pnt_ptr 1 - dup pushx: curdir pushy: curdir
                     $ putddir
                     $ pnt_ptr call sort to pnt_ptr
                    else drop then
                    false to inprocess
;M


:M On_Init:     ( -- )
                On_Init: super
                1    SetId: Splab-Tool-Bar       \ then the next child window
                self Start: Splab-Tool-Bar       \ then startup toolbar window


                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont drop

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor

                0 0 StartSize: Splab-Tool-Bar Move: Splab-Tool-Bar

                self Start: X-Min-Edit
                Handle: Winfont SetFont: X-Min-Edit

                self Start: Y-Min-Edit
                Handle: Winfont SetFont: Y-Min-Edit

                self Start: X-Max-Edit
                Handle: Winfont SetFont: X-Max-Edit

                self Start: Y-Max-Edit
                Handle: Winfont SetFont: Y-Max-Edit

                self Start: X-Labl-Edit
                Handle: Winfont SetFont: X-Labl-Edit
                @token: xaxis    SEtText: X-Labl-Edit

                self Start: Y-Labl-Edit
                Handle: Winfont SetFont: Y-Labl-Edit
                @token: yaxis    SEtText: Y-Labl-Edit

                self Start: X-hed
                Handle: Winfont SetFont: X-hed
                s" X:" SetText: X-hed

                self Start: Y-hed
                Handle: Winfont SetFont: Y-hed
                s" Y:" SetText: Y-hed

                self Start: Comment-Edit
                Handle: Winfont SetFont: Comment-Edit
                @footnote: xaxis     SetText: Comment-Edit

                self Start: X-Linhed
                Handle: Winfont SetFont: X-Linhed
                s" X-Axis" SetText: X-Linhed

                self Start: Y-Linhed
                Handle: Winfont SetFont: Y-Linhed
                s" Y-Axis" SetText: Y-Linhed

                self Start: FootTxt
                Handle: Winfont SetFont: FootTxt
                s" Comment" SetText: FootTxt

                self Start: MIN-COLHED
                Handle: Winfont SetFont: MIN-COLHED
                s" Min." SetText: MIN-COLHED

                self Start: MAX-COLHED
                Handle: Winfont SetFont: MAX-COLHED
                s" Max." SetText: MAX-COLHED

                self Start: AUTO-COLHED
                Handle: Winfont SetFont: AUTO-COLHED
                s" Auto" SetText: AUTO-COLHED


                self Start: Group_List
                Handle: Winfont SetFont: Group_List
                s" Data set" SetText: Group_List

                self Start: Group_Data
                Handle: Winfont SetFont: Group_Data
                s" Data point" SetText: Group_Data

                self Start: Group_Focus
                Handle: Winfont SetFont: Group_Focus
                s" Navigate" SetText: Group_Focus

                self Start: X-Auto
                Handle: Winfont SetFont: X-Auto
                s" " SetText: X-Auto

                self Start: Y-Auto
                Handle: Winfont SetFont: Y-Auto
                s" " SetText: Y-Auto

                self Start: Plot_Axes
                Handle: Winfont SetFont: Plot_Axes
                s" Axes" SetText: Plot_Axes

                self Start: LBL-COLHED
                Handle: Winfont SetFont: LBL-COLHED
                s" Axis Label" SetText: LBL-COLHED

                self Start: Hed-Edit
                Handle: Winfont SetFont: Hed-Edit
                @header: curdir     SetText:  Hed-Edit

                self Start: Z-Edit
                Handle: Winfont SetFont: Z-Edit

                self Start: Sel-Chk
                Handle: Winfont SetFont: Sel-Chk

                self Start: DATA-Pair-Lbl
                Handle: Winfont SetFont: DATA-Pair-Lbl

                ES_WantReturn AddStyle: X-Edit
                self Start: X-Edit
                Handle: Winfont SetFont: X-Edit

                ES_WantReturn AddStyle: Y-Edit
                self Start: Y-Edit
                Handle: Winfont SetFont: Y-Edit

                self Start: Int-ON
                Handle: Winfont SetFont: Int-ON
                s" " SetText: Int-ON

                self Start: Lin-ON
                Handle: Winfont SetFont: Lin-ON
                s" " SetText: Lin-ON


                ES_Number AddStyle: Symbl-Edit
                self Start: Symbl-Edit
                Handle: Winfont SetFont: Symbl-Edit

                ES_Number AddStyle: Color-Edit
                self Start: Color-Edit
                Handle: Winfont SetFont: Color-Edit

                self Start: Hed-Hed
                Handle: Winfont SetFont: Hed-Hed
                s" Header " SetText: Hed-Hed

                self Start: Z-Hed
                Handle: Winfont SetFont: Z-Hed
                s" Z           Int Cn  Symbl Color" SetText: Z-Hed

                self Start: Clr-Spc-Bttn
                Handle: Winfont SetFont: Clr-Spc-Bttn
                s" Clear" SetText: Clr-Spc-Bttn

                self Start: Set-Spc-Bttn
                Handle: Winfont SetFont: Set-Spc-Bttn
                s" Set" SetText: Set-Spc-Bttn

                self Start: Clr-Data-Bttn
                Handle: Winfont SetFont: Clr-Data-Bttn
                s" Clear" SetText: Clr-Data-Bttn

                self Start: Set-Data-Bttn
                Handle: Winfont SetFont: Set-Data-Bttn
                s" Set" SetText: Set-Data-Bttn

                self Start: Add-Data-Bttn
                Handle: Winfont SetFont: Add-Data-Bttn
                s" Add" SetText: Add-Data-Bttn

                 self Start: Focus-up
                Handle: Winfont SetFont: Focus-up
                s" «« " SetText: Focus-up

                self Start: Focus-down
                Handle: Winfont SetFont: Focus-down
                s" »» " SetText: Focus-down

                self Start: Focus-BGN
                Handle: Winfont SetFont: Focus-BGN
                s" ||« " SetText: Focus-BGN

                self Start: Focus-END
                Handle: Winfont SetFont: Focus-END
                s" »|| " SetText: Focus-End

                self Start: Cursor-up
                Handle: Winfont SetFont: Focus-up
                s" «« " SetText: Cursor-up

                self Start: Cursor-down
                Handle: Winfont SetFont: Focus-down
                s" »» " SetText: Cursor-down

                self Start: Cursor-BGN
                Handle: Winfont SetFont: Focus-BGN
                s" ||« " SetText: Cursor-BGN

                self Start: Cursor-END
                Handle: Winfont SetFont: Focus-END
                s" »|| " SetText: Cursor-End

                self Start: Show-cursor
                Handle: Winfont SetFont: Show-cursor
                s" Cursor" SetText: Show-cursor

                self Start: Cmd-Line
                Handle: Winfont SetFont: Cmd-Line

                self Start: Exec-Button
                Handle: Winfont SetFont: Exec-Button
                s" Exec" SetText: Exec-Button

                self Start: Plot-Button
                Handle: Winfont SetFont: Plot-Button
                s" Replot" SetText: Plot-Button

                self Start: Plot-All-Chk
                Handle: Winfont SetFont: Plot-All-Chk
                s" Show multiple " SetText: Plot-All-Chk

                obj @ getddir
                SetListEdit: self
                SetDataEdit: self
                ;M

:M Isn't_Edit?: GETID: X-Labl-Edit > ;M

:M Edit-Chk:  { \ done_with_edit CurrentID -- }

         MainPrmSet
         if
             dup last-chk = not last-edt and to done_with_edit
             to CurrentID
             isnotedit not to last-Edt
             last-chk
             CurrentID to last-chk
             done_with_edit
           else false then
;M



:M GETCTRLS:
  true to inprocess
  MainPrmSet if
   GetID: X-Auto IsDlgButtonChecked: self  0= if
          XMIN F@ !OFFS: XAXIS
          XMAX F@ !LIM:  XAXIS
          FALSE
   else   TRUE then
   !Auto: XAXIS
   GetID: Y-Auto IsDlgButtonChecked: self  0= if
          YMIN F@ !OFFS: YAXIS
          YMAX F@ !LIM:  YAXIS
          FALSE
   else   TRUE then
   !Auto: YAXIS
  then
  false to inprocess
;M

:M GETEDITS:
 true to inprocess
 MainPrmSet if
    case
      GetID: X-MAX-Edit of
                  GetText: X-MAX-Edit
                  STR2FLO if
                    FDUP XMIN F@ F<
                    if fdrop then
                  then
                  fdepth 0> if
                    FDUP
                    XMAX F!
                    xaxis.auto not if FDUP !LIM: XAXIS then
                  else
                    XMAX F@
                  then
                  FLO2STR
                  dup 4 > if drop 4 then  \ Cut to no more than 4 char
                  SetText: X-MAX-Edit
             endof
      GetID: X-MIN-Edit of
                  GetText: X-MIN-Edit
                  STR2FLO if
                    FDUP XMAX F@ F>
                    if fdrop then
                  then
                  fdepth 0> if
                    FDUP
                    XMIN F!
                    xaxis.auto not if FDUP !OFFS: XAXIS then
                  else
                    XMIN F@
                  then
                  FLO2STR
                  dup 4 > if drop 4 then  \ Cut to no more than 4 char
                  SetText: X-MIN-Edit
             endof
      GetID: Y-MAX-Edit of
                  GetText: Y-MAX-Edit
                  STR2FLO if
                    FDUP YMIN F@ F<
                    if fdrop then
                  then
                  fdepth 0> if
                    FDUP
                    YMAX F!
                    yaxis.auto not if FDUP !LIM: YAXIS then
                  else
                    YMAX F@
                  then
                  FLO2STR
                  dup 4 > if drop 4 then  \ Cut to no more than 4 char
                  SetText: Y-MAX-Edit
             endof
      GetID: Y-MIN-Edit of
                  GetText: Y-MIN-Edit
                  STR2FLO if
                    FDUP YMAX F@ F>
                    if fdrop then
                  then
                  fdepth 0> if
                    FDUP
                    YMIN F!
                    yaxis.auto not if FDUP !OFFS: YAXIS then
                  else
                    YMIN F@
                  then
                  FLO2STR
                  dup 4 > if drop 4 then  \ Cut to no more than 4 char
                  SetText: Y-MIN-Edit
             endof
      GetID: X-Labl-Edit of
                  GetText: X-Labl-Edit
                  !Token: xaxis
             endof
      GetID: Y-Labl-Edit of
                  GetText: y-Labl-Edit
                  !Token: yaxis
             endof
      GetID: Comment-Edit of
                  GetText: Comment-Edit
                  !Footnote: xaxis
             endof
           SetSpcPrms: self
\          obj @ dup SetLine: Data-Window
          last-obj 0 < if Replot-It else StkClr $ plot then
     endcase
 then
 false to MainPrmSet
 false to inprocess
;M

:M DO-EXEC:
          true to inprocess
          FALSE TO STOP-EXEC
          GetTEXT: CMD-Line
          EXEC-IT
          false to inprocess
;M

: MoveFocus { newobj \ -- }
        SetSpcPrms: Self
        newobj ChgDDir
        SetCurveList: Data-Window
        SetListEdit: Self
        SetDataEdit: Splab-Window
        SetCtrl: SELF
        last-obj 0 < if Replot-It else StkClr $ plot then
;


: MoveCursor { Newpos \ -- }
     NewPos to pnt_ptr
     SetDataEdit: Splab-Window
     SetDataList: Data-Window
     Replot-It
;

:M Add_or_Modify:
        dup
        SetDataPoint: self
        SetDataEdit: self
        SetDataList: Data-Window
        if
          obj @ dup SetLine: Data-Window
        then
        replot-it
;M

:M Cursor2Left:  curdir.npts 0 = not pnt_ptr 1 > and if pnt_ptr 1 - MoveCursor then ;M
:M Cursor2BGN:  curdir.npts 0 = not if 1 MoveCursor then ;M
:M Cursor2END:  curdir.npts 0 = not if curdir.npts MoveCursor then ;M
:M Cursor2Right:  pnt_ptr curdir.npts < if  pnt_ptr 1 + movecursor  then ;M
:M Cursor2PGDOWN: curdir.npts 0 = not if pnt_ptr PG-INC + curdir.npts min moveCursor then ;M
:M Cursor2PGUP:  curdir.npts 0 = not if pnt_ptr PG-INC - 1 max MoveCursor then ;M
:M Focus2BGN: 1 MoveFocus ;M
:M Focus2END: maxcur MoveFocus ;M
:M Focus2UP: $ 1 - MoveFocus ;M
:M Focus2Down: $ 1 + MoveFocus ;M
:M Focus2PGUP: $ PG-INC - 1 Max MoveFocus ;M
:M Focus2PGDown:  $ PG-INC + MaxCur Min MoveFocus ;M

:M Exec2Button:
                         DO-EXEC: Self
;M

:M Replot2Current:      GetText: Comment-Edit
                        !Footnote: xaxis
                        Refresh: Splab-Window
                        StkClr
                        $ Plot
;M

:M Replot2All:          GetText: Comment-Edit
                        !Footnote: xaxis
                        Refresh: Splab-Window
                        StkClr TRUE PLOT
;M

:M Clr-Spc2Bttn:
                          confirm 1 = if
                            $ clear
                            SetListEdit: Self
                            SetDataEdit: Splab-Window
                            obj @ dup SetLine: Data-Window
                            1 to pnt_ptr
                            last-obj 0> if StkClr $ plot else replot-it then
                          then
;M

:M Set-Spc2Bttn:     GetText: Comment-Edit
                     !Footnote: xaxis
                     SetSpcPrms: self
                     SetListEdit: self
                     obj @ dup SetLine: Data-Window
                     replot-it
;M

:M Toggle-Spc2Bttn:
                     MainPrmSet if
                       SetSpcPrms: self
                       obj @ dup SetLine: Data-Window
                       replot-it
                     then
;M

:M Clr-Data2Bttn:
                     pnt_ptr Delete_Point
                     if
                       SetDataEdit: self
                       SetDataList: Data-Window
                       obj @ dup SetLine: Data-Window
                       replot-it
                     then
;M

:M Show2Cursor:

                     GetID: Show-Cursor IsDlgButtonChecked: self  0= not to CursorON
                     Replot-It
;M

:M Cursor2Toggle:
     CURSORON not dup to CursorON
     if 1 else 0 then GetID: Show-cursor CheckDlgButton: self
     Replot-It
;M

:M Sel2Chk:
                     MainPrmSet if
                       ?SEL if #SEL else !SEL then
                        false to MainPrmSet
                        SetListEdit: Self
                        SetCtrl: SELF
                        true $ call getsel $ refnum = ShowStatusLeft: Data-Window
                     then
;M

:M        WM_COMMAND   { hwnd msg wparam lparam  \ currentid -- res }
              @work @scan or not if
                InProcess not if
                 true to InProcess
                 hwnd msg wparam lparam WM_COMMAND WM: Super
                 wparam LOWORD ( ID )
                 dup   to currentid
                 dup Isn't_Edit?: Self to isnotedit
                 Edit-Chk: self if
                   GetEdits: self
                   SetListEdit: self
                 else drop then
                 isnotedit
                 MainPrmSet
                 and if
                  currentid
                  case
                    GETID: Exec-Button of Exec2Button: Self endof
                    GETID: Set-Spc-Bttn of Set-Spc2Bttn: Self endof
                    GETID: Sel-Chk of Toggle-Spc2Bttn: Self endof
                    GETID: INT-ON of Toggle-Spc2Bttn: Self endof
                    GETID: LIN-ON of Toggle-Spc2Bttn: Self endof
                    GETID: Clr-Spc-Bttn of Clr-Spc2Bttn: Self endof
                    GETID: Set-Data-Bttn of curdir.npts 0 = Add_or_Modify: self endof
                    GETID: Add-Data-Bttn of true Add_or_Modify: self endof
                    GETID: Clr-Data-Bttn of Clr-Data2Bttn: self endof
                    GetID: Focus-BGN of Focus2BGN: self endof
                    GetID: Focus-END of Focus2End: self endof
                    GetID: Focus-UP of Focus2Up: self endof
                    GetID: Focus-Down of Focus2Down: Self endof
                    GetID: Cursor-BGN of CURSORON not if Cursor2Toggle: self then Cursor2BGN: self endof
                    GetID: Cursor-END of CURSORON not if Cursor2Toggle: self then Cursor2End: self endof
                    GetID: Cursor-UP of CURSORON not if Cursor2Toggle: self then Cursor2Left: self endof
                    GetID: Cursor-Down of CURSORON not if Cursor2Toggle: self then Cursor2Right: Self endof
                    GETID: Plot-Button of last-obj 0 > if  Replot2Current: Self else Replot2All: Self then endof
                    GETID: Plot-All-Chk of last-obj 0 > if Replot2All: Self else Replot2Current: Self then endof
                    GETID: Show-Cursor of Show2Cursor: self endof
                   endcase
                  then
                 false to InProcess
                else drop then
              else drop then
    0
;M


:M WM_SYSCOMMAND ( hwnd msg wparam lparam -- res )
                over 0xF000 and 0xF000 <>
                IF      over LOWORD
                        0
                ELSE    DefWindowProc: [ self ]
                THEN    ;M



:M Refresh:
                         SetListEdit: self
                         GetCtrls: self
                         SetCtrl: self
;M

:M ClassInit:   ( -- )
                ClassInit: Super
                 Self to SPLAB-WINDOW
               ;M


:M On_Size:     ( h m w -- )                  \ handle resize message
                  Width  dup to SC-WDTH thickness  dup +  + to Splab-Width
                  Height dup to SC-HGHT to Splab-Height
                  draw_win: self
                  SetCtrl: self
                ;M

:M On_Done:     ( h m w l -- res )
                CloseMenu: CurrentMenu          \ discard the menubar
                Delete: WinFont
                0 call PostQuitMessage drop     \ terminate application
                On_Done: super                  \ cleanup the super class
                0 ;M


:M WM_CLOSE     ( h m w l -- res )
                close: super
                0 ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Splitter window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Splitter <Super child-window

:M WindowStyle: ( -- style )   \ return the window style
        WindowStyle: super
        [ WS_DISABLED WS_CLIPSIBLINGS or ] literal or
        ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_Paint: ( -- )            \ screen redraw method
        0 0 Width Height LTGRAY FillArea: dc
        ;M

;Object



\ ------------------------------------------------------------------------
\ Define the the splitter window (this is the main window).
\ ------------------------------------------------------------------------
\ *P \bThe left bottom pane\d of the main splitter window contains 132 lines corresponding to 132 slots for
\ ** the individual datasets (traces) available in the program. Each line contains:
\ *B Number of the data set (1-132)
\ *B Indicator of trace selection for display and processing. Here the selected traces are marked with a \b»\d symbol.
\ ** In addition, the focused trace (current position of trace selection cursor) is marked with a middle dot (\b·\d) mark.
\ *B A set-specific header (trace title or comment)
\ *B A set-specific "Z-value". This is the "third coordinate" value used in global data analysis.
\ ** It corresponds to the parameter that changes during the experiment: time for a time-dependent series,
\ ** temperature for temperature dependencies, concentration of titrant in spectral titrations, etc.
\ *B Number of data points in the trace (this field is empty for empty slots)
\ *B ON/OFF position of set-specific interpolation switch (for plot display)
\ *B ON/OFF position of set-specific line connection switch (for plot display)
\ *B Numeric code (0 -7) of the chart symbol (for plot display)
\ *B Numeric code (0 - 15) of the trace color (for plot display)
\ *P The values of these parameters and position of the switches for the focused trace can be modified
\ ** through the "Data set" block in the control pane. Clicking on any line in the left pane results in selection of the
\ ** respective dataset as a "focused trace". Selection of focused trace may be also achieved using a cobination of
\ ** "Shift" with the "up", "down", "pg-up", "pg-down", "bgn" and "end" keys of the keybord.
\ *P \bThe right bottom pane\d shows the data pairs (X,Y-pairs) of the focused dataset. This window also contains a
\ ** column ("Y calc") for calculated (fitting) value of Y, which appears there after non-linear regression (data
\ ** fitting) procedure. Clicking on any line of this pane results in positioning the data point cursor on the
\ ** respective data pair. The X and Y values for this pair may be modified using the "Data point" block in the
\ ** control pane. This control block may also be used for deleting the point and adding new data points to the trace.

:Object Splab-Main        <Super Window

 int dragging?
 int mousedown?
 int obj_

: LeftHeight            ( -- n )
        tableheight ;

: RightHeight     ( -- n )
        tableheight ;

: position-windows ( -- )
        height min-splab-height - toolbarheight - min-table-height max to tableheight
        width RightWidth - thickness - leftwidth max width min-right-width - thickness - min to leftwidth
        0 height tableheight - LeftWidth  TableHeight  Move: LeftPane
        LeftWidth thickness +  height tableheight - Width LeftWidth thickness + -  dup to RightWidth TableHeight  Move: RightPane
        0 ToolBarHeight  Width height tableheight - toolbarheight - Move: Splab-Controls
        LeftWidth  height tableheight -  thickness  tableheight  Move: Splitter
        SetHeaderWidth: Data-Window
      ;

: InSplitter?   ( -- f1 )   \ is cursor on splitter window
        hWnd get-mouse-xy
        0 height within
        swap  LeftWidth dup thickness + within  and ;

\ mouse click routines for Main Window to track the Splitter movement

: DoSizing      ( -- )
      mousedown? dragging? or 0= ?EXIT
        mousex ( 1+ ) width min  thickness 2/ -  to LeftWidth
        width leftwidth thickness + - min-right-width max to RightWidth
        position-windows
        WINPAUSE
;

: On_clicked    ( -- )
        mousedown? 0= IF  hWnd Call SetCapture drop  THEN
        true to mousedown?
        InSplitter? to dragging?
        DoSizing ;

: On_unclicked ( -- )
        mousedown? IF  Call ReleaseCapture drop  THEN
        false to mousedown?
        false to dragging? ;
: On_DblClick ( -- )
        false to mousedown?
        InSplitter? 0= ?EXIT
        LeftWidth 8 >
        IF      0 thickness 2/ - to LeftWidth
        ELSE    132 Width 2/ min to LeftWidth
        THEN
        position-windows
;

:M WM_SETCURSOR ( h m w l -- )
        hWnd get-mouse-xy
        height tableheight - height within
        swap  0 width within and
        IF  InSplitter? IF  SIZEWE-CURSOR   ELSE  arrow-cursor  THEN  1
        ELSE  DefWindowProc: self
        THEN
        ;M

:M ClassInit:   ( -- )
                Self to DATA-WINDOW
                ClassInit: Super
                Splab-Menu-Bar  to CurrentMenu   \ set the menubar
                ['] On_clicked     SetClickFunc: self
                ['] On_unclicked   SetUnClickFunc: self
                ['] DoSizing       SetTrackFunc: self
                ['] On_DblClick    SetDblClickFunc: self
        ;M

:M WindowHasMenu: ( -- f )
                true ;M

:M WindowStyle: ( -- style )
                WindowStyle: Super
                WS_CLIPCHILDREN or ;M

:M WndClassStyle: ( -- style )
                \ CS_DBLCLKS only to prevent flicker in window on sizing.
                CS_DBLCLKS
                ;M

:M WindowTitle: ( -- title )
                z" Splab-32" ;M


:M StartSize:   ( -- width height )
                splab-width splab-height tableheight (( thickness dup  + + )) + ;M

:M MinSize:     ( -- width height )     \ minimum window size
                min-splab-width min-splab-height min-table-height +
                ;M

:M MaxSize:
                maxwidth 4 - maxheight 4 -
    ;M

:M StartPos:    ( -- x y )
                inix iniy ;M

:M Close:        ( -- )
                Close: super
                ;M

:M On_Size:     ( -- )
                width RightWidth - thickness - to LeftWidth
                position-windows

;M

:M WindowHasMenu: True ;M

:M OnWmCommand:  ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
        @work not if
        over LOWORD ( Command ID )
        case
\ *S Shortcut Keys:
( *L |c||l|                                                                    )
( *| Key combination | Effect                                    |             )
( *| Alt_ADD         | add spcectrum                             |             )
( *| Alt_SUBTRACT    | subtract spectrum                         |             )
( *| Alt_MULTIPLY    | Multiply spectrum by a constant           |             )
( *| Alt_DIVIDE      | Divide spectrum by a constant             |             )
\ *| Shift_DOWN      | Shift focus down (in the list of traces)  |
\ *| Shift_UP        | Shift Focus up (in the list of traces)    |
\ *| Shift_HOME      | Focus on the first trace                  |
\ *| Shift_END       | Focus on the last (#132) trace            |
\ *| Shift_PGDN      | Shift focus 8 traces down                 |
( *| Shift_PGUP      | Shift focus 8 traces up                   |
( *| INSERT          | Toggle trace selection and shift down     |             )
\ *| Alt_RETURN      | Accept all changes (trace,point,comment)  |
\ *| RETURN          | Execute command line(= EXEC button)       |             )
( *| Ctrl_DOWN       | Move cursor one point right               |             )
( *| Ctrl_UP         | Move cursor one point left                |             )
( *| Ctrl_HOME       | Move cursor to the first point            |             )
( *| Ctrl_END        | Move cursor to the last point             |             )
( *| Ctrl_PGDN       | Move cursor 8 points right                |             )
( *| Ctrl_PGUP       | Move cursor 8 points left                 |             )
\ *| Ctrl_RETURN     | Accept changes to the data point(add new) |             )
( *| Ctrl_ADD        | Add a constant to the current trace       |             )
( *| Ctrl_SUBTRACT   | Subtract a constant from the current trace|             )
( *| Ctrl_MULTIPLY   | Multiply the current trace by a constant  |             )
( *| Ctrl_INSERT     | Add new data point                        |             )
( *| Ctrl_DELETE     | Delete data point                         |             )
( *| Shift_RETURN    | Accept changes to the trace parameters    |             )
\ *| Shift_ADD       | (Re)plot all selected traces              |
\ *| Shift_SUBTRACT  | (Re)plot the current trace only           |
\ *| Shift_DELETE    | Delete cuttent trace (with warning)       |
( *| Alt_INSERT      | Toggle selection of the current trace     |             )
( *| Ctrl_C          | Stop execution of the ongoing process     |             )
\ *| Alt_Y           | Delete current trace (no warning)         |             )
\ *| Alt_S           | Invoke recursive subtraction (SUB) script |

          ALT_ADD of  add-spc endof
          ALT_SUBTRACT of subtract-spc endof
          ALT_Multiply of Multiply-const endof
          ALT_Divide of Divide-const endof
          SHIFT_DOWN of Focus2Down: Splab-Controls endof
          SHIFT_UP of   Focus2UP: Splab-Controls endof
          SHIFT_HOME of Focus2Bgn: Splab-Controls endof
          SHIFT_END of  Focus2End: Splab-Controls endof
          SHIFT_PGDN of Focus2PGDown: Splab-Controls endof
          SHIFT_PGUP of Focus2PGUP: Splab-Controls endof
          _Ins of Sel2Chk: Splab-Controls Focus2Down: Splab-Controls endof
          ALT_RETURN of Set-Spc2Bttn: Splab-Controls FALSE Add_or_Modify: Splab-Controls endof
          _RETURN of Exec2Button: Splab-Controls endof
          Ctrl_DOWN of CursorOn not if Cursor2Toggle: Splab-Controls then Cursor2Right: Splab-Controls endof
          Ctrl_UP of CursorOn not if Cursor2Toggle: Splab-Controls then Cursor2Left: Splab-Controls endof
          Ctrl_HOME of  CursorOn not if Cursor2Toggle: Splab-Controls then Cursor2Bgn: Splab-Controls endof
          Ctrl_END of   CursorOn not if Cursor2Toggle: Splab-Controls then Cursor2End: Splab-Controls endof
          Ctrl_PGDN of  CursorOn not if Cursor2Toggle: Splab-Controls then Cursor2PGDown: Splab-Controls endof
          Ctrl_PGUP of  CursorOn not if Cursor2Toggle: Splab-Controls then Cursor2PGUP: Splab-Controls endof
          Ctrl_RETURN of curdir.npts 0 = Add_or_Modify: Splab-Controls endof
          Ctrl_ADD of add-const endof
          Ctrl_SUBTRACT of subtract-const endof
          Ctrl_Multiply of Multiply-const endof
          Ctrl_Ins of true Add_or_Modify: Splab-Controls endof
          Ctrl_Del of Clr-Data2Bttn: Splab-Controls endof
          Shift_RETURN of Set-Spc2Bttn: Splab-Controls endof
          Shift_ADD of  Replot2All: Splab-Controls endof
          Shift_SUBTRACT of Replot2Current: Splab-Controls endof
          Shift_Del of Clr-Spc2Bttn: Splab-Controls endof
          ALT_Ins of Sel2Chk: Splab-Controls endof
          CTRL_C of TRUE to STOP-EXEC endof
          Alt_Y of
              ClearListEdit: Splab-Controls
              $ clear
              Focus2Down: Splab-Controls
           endof
          Alt_S of Sub-dialog endof
       endcase
         then
         OnWmCommand: Super
        ;M



:M On_Init:     ( -- )
                On_Init: super
                self Start: LeftPane
                self Start: Splab-Controls
                self Start: RightPane
                self Start: Splitter
                ;M

:M On_Done:     ( h m w l -- res )
                Save_State
                close-plugins
                ControlKeys DisableAccelerators
                0 call PostQuitMessage drop     \ terminate application
                On_Done: super                   \ cleanup the super class
                bye
                0 ;M

LV_COLUMN lvc

: headerwidth LeftWidth 300 - min-header-width max ;

:M SetHeaderWidth:
        headerwidth 2 SetColumnWidth: ListViewLeft
;M

:M InitListViewColumns: ( -- )
        LVCF_FMT LVCF_WIDTH LVCF_TEXT LVCF_SUBITEM or or or   Setmask: lvc
        LVCFMT_LEFT                                            Setfmt: lvc
        32                                                    Setcx: lvc
        z" ¹"                    SetpszText: lvc
        Addr: lvc 0           InsertColumn: ListViewLeft

        24                                                    Setcx: lvc
        z" ‡"                    SetpszText: lvc
        Addr: lvc swap 1+  InsertColumn: ListViewLeft
        headerwidth                                           Setcx: lvc
        z" Header"                 SetpszText: lvc
        Addr: lvc swap 1+  InsertColumn: ListViewLeft
        60                                                      Setcx: lvc
        z"   Z"               SetpszText: lvc
        Addr: lvc swap 1+        InsertColumn: ListViewLeft
        32                                                     Setcx: lvc
        z" Npt"               SetpszText: lvc
        Addr: lvc swap 1+        InsertColumn: ListViewLeft
        z" Int"               SetpszText: lvc
        Addr: lvc swap 1+        InsertColumn: ListViewLeft
        z" Cn"               SetpszText: lvc
        Addr: lvc swap 1+        InsertColumn: ListViewLeft
        z" Sym"               SetpszText: lvc
        Addr: lvc swap 1+        InsertColumn: ListViewLeft
        z" Col"               SetpszText: lvc
        Addr: lvc swap 1+        InsertColumn: ListViewLeft



        LVCF_FMT LVCF_WIDTH LVCF_TEXT LVCF_SUBITEM or or or   Setmask: lvc
        LVCFMT_LEFT                                            Setfmt: lvc
        36                                                     Setcx: lvc

        z" #"                    SetpszText: lvc
        Addr: lvc 0               InsertColumn: ListViewRight
        21                                                     Setcx: lvc
        z" ‡"                    SetpszText: lvc
        Addr: lvc swap 1 +       InsertColumn: ListViewRight

        64                                                     Setcx: lvc
        z"      X"                SetpszText: lvc
        Addr: lvc swap 1+         InsertColumn: ListViewRight

        z"      Y"                SetpszText: lvc
        Addr: lvc swap 1+         InsertColumn: ListViewRight

        z"      Y Calc."                 SetpszText: lvc
        Addr: lvc swap 1+         InsertColumn: ListViewRight
        ;M

:M   ShowStatusLeft: { #cur #sel #ref \ -- }
     #cur #sel #ref          SetLVString1
     obj @ 1- >r             SetiItem:    LvItem
     1                       SetiSubItem: LvItem
     lstring  1+             SetpszText:  LvItem
     Addr: LvItem  r>        SetItemText: ListViewLeft
;M

:M SetLine: { idx obj_ \ -- }

       idx 1- >r               SetiItem:    LvItem
       1                       SetiSubItem: LvItem
       idx obj_ =  idx call getsel false  SetLVString1
       lstring  1+             SetpszText:  LvItem
       Addr: LvItem  r>        SetItemText: ListViewLeft


       LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
       idx 1- >r               SetiItem:    LvItem
       2                       SetiSubItem: LvItem
       @H                      put: LSTRING
       lstring  1+             SetpszText:  LvItem
       Addr: LvItem  r>        SetItemText: ListViewLeft

       LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
       idx 1 - >r              SetiItem:    LvItem
       3                       SetiSubItem: LvItem
       SetLVString3
       lstring  1+             SetpszText:  LvItem
       Addr: LvItem  r>        SetItemText: ListViewLeft

       LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
       idx 1- >r               SetiItem:    LvItem
       4                       SetiSubItem: LvItem
       curdir.npts             str$
       put: LSTRING
       lstring  1+             SetpszText:  LvItem
       Addr: LvItem  r>        SetItemText: ListViewLeft

       LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
       idx 1- >r               SetiItem:    LvItem
       5                       SetiSubItem: LvItem
       @intr if s"  ON" else s" OFF" then put: LSTRING
       lstring  1+             SetpszText:  LvItem
       Addr: LvItem  r>        SetItemText: ListViewLeft

       LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
       idx 1- >r               SetiItem:    LvItem
       6                       SetiSubItem: LvItem
       @cnct if s"  ON" else s" OFF" then put: LSTRING
       lstring  1+             SetpszText:  LvItem
       Addr: LvItem  r>        SetItemText: ListViewLeft

       LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
       idx 1- >r               SetiItem:    LvItem
       7                       SetiSubItem: LvItem
       @M                      str$
       put: LSTRING
       lstring  1+             SetpszText:  LvItem
       Addr: LvItem  r>        SetItemText: ListViewLeft

       LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
       idx 1- >r               SetiItem:    LvItem
       8                       SetiSubItem: LvItem
       @C 127 and              str$
       put: LSTRING
       lstring  1+             SetpszText:  LvItem
       Addr: LvItem  r>        SetItemText: ListViewLeft
;M

:M SetSelectedLeft:   { newobj \ -- }

     obj @ newobj setline: self

     newobj chgDdir

     FALSE newobj 1-                 EnsureVisible:     ListViewLeft
     LVIF_STATE                      SetMask:     LvItem
     LVIS_FOCUSED LVIS_SELECTED OR   Setstate:     LvItem
     Addr: LvItem newobj 1-            SetItemState: ListViewLeft
     true newobj call getsel refnum obj @ = ShowStatusLeft: self

;M

:M InitListViewItems: { \ idx -- }
   obj @ to obj_
   0 to idx
   begin
       1 +to idx
       idx MAXCUR > NOT WHILE
       idx GetDdir

       LVIF_TEXT LVIF_PARAM or SetMask:    LvItem  \ SetMask: Also erases old parameters
       idx 1- >r               SetiItem:   LvItem
                               SetLVString0
       lstring  1+             SetpszText: LvItem
       Addr: LvItem            InsertItem: ListViewLeft

       idx obj_ setline: self
   repeat
   obj_ SetSelectedLeft: self
;M

:M   ShowStatusRight: { #curpos #sel  \ -- }
     #sel if s" •" else s" " then put: lstring
     #curpos 1- >r           SetiItem:    LvItem
     1                       SetiSubItem: LvItem
     lstring  1+             SetpszText:  LvItem
     Addr: LvItem  r>        SetItemText: ListViewRight
;M

:M  SetSelectedRight:
     FALSE pnt_ptr 1-         EnsureVisible:     ListViewRight drop
     LVIF_STATE                      SetMask:     LvItem
     LVIS_FOCUSED LVIS_SELECTED OR   Setstate:    LvItem
     Addr: LvItem pnt_ptr 1-        SetItemState: ListViewRight drop
     pnt_ptr true ShowStatusRight: self
;M

:M InitListViewItemsRight: { \ idx -- }
   pnt_ptr curdir.npts > if curdir.npts to pnt_ptr then
   pnt_ptr 1 < if 1 to pnt_ptr then
   0 to idx
   begin
       1 +to idx
       idx dup 768 > swap curdir.npts > or NOT WHILE
       LVIF_TEXT LVIF_PARAM or SetMask:    LvItem  \ SetMask: Also erases old parameters

       idx 1- >r               SetiItem:   LvItem
       idx                     SetXYString0
       lstring  1+             SetpszText: LvItem
       Addr: LvItem            InsertItem: ListViewRight
       idx dup pnt_ptr =       ShowStatusRight: self
       LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
       2                       SetiSubItem: LvItem
       idx 1- pullx: curdir
       flo2str                 put: LSTRING
       lstring 1+              SetpszText:  LvItem
       Addr: LvItem  r>        SetItemText: ListViewRight drop \ WHY "DROP"??? I REALY DON'T KNOW!! BUT IT IS NEEDED!
       LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
       idx 1- >r               SetiItem:    LvItem
       3                       SetiSubItem: LvItem
       idx 1-                  pully: curdir
       flo2str     put: LSTRING
       lstring  1+             SetpszText:  LvItem

       Addr: LvItem  r>        SetItemText: ListViewRight
       curdir call _PrmReady if
         0 @P isnan10 not
         fitpath @ 0 >
         and if
           LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
           idx 1- >r               SetiItem:    LvItem
           4                       SetiSubItem: LvItem
           idx 1- pullx: curdir
           FUN DROP
             flo2str
             put: LSTRING
             lstring  1+             SetpszText:  LvItem
             Addr: LvItem  r>        SetItemText: ListViewRight
         then
       then
     repeat
    SetSelectedRight: self
 ;M


:M SetCurveList:
   DeleteAllItems: ListViewLeft
   InitListViewItems: self
;M

:M SetDataList:
   DeleteAllItems: ListViewRight
   InitListViewItemsRight: self
;M

;Object

ControlKeys table
\   Flags            Key Code      Command ID
     FCONTROL         VK_RETURN     Ctrl_RETURN    AccelEntry
     FSHIFT           VK_RETURN     Shift_RETURN   AccelEntry
     FALT             VK_RETURN     ALT_RETURN     AccelEntry
     FALT             VK_ADD        ALT_ADD        AccelEntry
     FCONTROL         VK_ADD        Ctrl_ADD       AccelEntry
     FSHIFT           VK_ADD        Shift_ADD      AccelEntry
     FALT             VK_SUBTRACT   ALT_SUBTRACT   AccelEntry
     FCONTROL         VK_SUBTRACT   Ctrl_SUBTRACT  AccelEntry
     FSHIFT           VK_SUBTRACT   Shift_SUBTRACT AccelEntry
     0                VK_RETURN     _RETURN        AccelEntry
\     0                VK_DOWN       _DOWN         AccelEntry
     FCONTROL         VK_DOWN       Ctrl_DOWN      AccelEntry
     FSHIFT           VK_DOWN       Shift_DOWN     AccelEntry
\     0                VK_UP         _UP            AccelEntry
     FCONTROL         VK_UP         CTRL_UP        AccelEntry
     FSHIFT           VK_UP         Shift_UP       AccelEntry
     0                VK_Insert     _INS           AccelEntry
     FCONTROL         VK_Insert     CTRL_INS       AccelEntry
     FALT             VK_Insert     ALT_INS        AccelEntry
     FCONTROL         VK_Delete     CTRL_DEL       AccelEntry
     FSHIFT           VK_Delete     Shift_DEL      AccelEntry
\     0                VK_Next       _PgDN          AccelEntry
\     0                VK_Prior      _PgUp          AccelEntry
     FCONTROL         VK_Next       Ctrl_PgDN      AccelEntry
     FCONTROL         VK_Prior      Ctrl_PgUp      AccelEntry
     FSHIFT           VK_Next       Shift_PgDN     AccelEntry
     FSHIFT           VK_Prior      Shift_PgUp     AccelEntry
\     0                VK_End       _End            AccelEntry
\     0                VK_Home      _Home           AccelEntry
     FCONTROL         VK_End       Ctrl_End        AccelEntry
     FCONTROL         VK_Home      Ctrl_Home       AccelEntry
     FSHIFT           VK_End       Shift_End       AccelEntry
     FSHIFT           VK_Home      Shift_Home      AccelEntry
     FALT             VK_Multiply  ALT_Multiply    AccelEntry
     FCONTROL         VK_Multiply  Ctrl_Multiply   AccelEntry
     FSHIFT           VK_Multiply  Shift_Multiply  AccelEntry
     FALT             VK_Divide    ALT_Divide      AccelEntry
     FCONTROL         'C'          CTRL_C          AccelEntry
     FALT             'Y'          ALT_Y           AccelEntry
     FALT             'S'          ALT_S           AccelEntry
Splab-Main HandlesThem


: unload-chart  ( -- )
                DestroyWindow: SCHART ;


: SPLAB-LOOP  ( -- ) \ Do all messages until WM_QUIT
            Begin
  \              depth 0 < depthreported not and
  \               if S" Depth is negative" PUT: TMP$ TMP$ call SplabErrorMessage  drop true to depthreported then
  \              Fdepth 0 <  fdepthreported not and
  \               if S" FDepth is negative" PUT: TMP$ TMP$ call SplabErrorMessage  drop true to fdepthreported then
                0 0 0 messagebuffer Call GetMessage
                While
               messagebuffer handlemessages drop
  \                Red-Button? if  DO-EXEC: Splab-controls then
                SetPlotChk: Splab-controls
             Repeat ;

: cmd2Fname
   cmdline put: TMP$
   LEN: TMP$ 0= not if
     FNAME TMP$ 32 call NEXTSTR
     0= not
     len: FNAME 0=                        \ process cmdline only if there is only ONE parameter
     or
     if  TRUE else
       34 FNAME Call TRIM drop \ cut off double quotes (ord('"') = 34)
       FNAME call UPNDOT
       0
       begin
         swap 1+
         dup dup 1 > swap len: fname > not and while
         swap over
         getchar: fname +
       repeat
       drop
       TRUE swap
       case
        0   of drop 1 endof   \ no extention
        156 of drop 1 endof   \ ".DX"
        215 of drop 3 endof   \ ".ASC"
        236 of drop 3 endof   \ ".CSV"
        230 of drop 2 endof   \ ".SPC"
       endcase
     then
     dup
     TRUE = if drop 2 FBACKUP$ put: FNAME then
      to formatcode
  else
    FBACKUP$ put: FNAME
 then
 get: FNAME
 put: FNAME0
;

: file-exists? ( adr len -- true-if-file-exist )
   find-first-file not dup>r
      if    find-close 2drop
      else  drop
      then
   r> ;

: Splab32init
  started not if
    init_splab32
    curfit-init
    cmd2Fname
    sp@ to ZeroStack
    formatcode case
       1 of FNAME obj @ TRUE call DX_load \ drop
            obj @ getddir
         endof
       2 of
           FNAME call ReadSPC  \ drop
           @offs: xaxis XMIN F!
           @lim: xaxis  XMAX F!
           @offs: yaxis YMIN F!
           @lim:  yaxis YMAX F!
           obj @ getddir
         endof
       3 of FNAME call ReadInAsc \ drop
            obj @ getddir
         endof
    endcase
    init-plugins
    ControlKeys EnableAccelerators
   s" STARTUP.F" append-fname 2DUP
   file-exists? if included else 2drop then
    TRUE to started
  then
;

: Splb32
  MAXHEIGHT 40 - 1200 min to graph-mheight
  MAXWIDTH 8 - 1600 min to graph-mwidth
  graph-start-width 8 - npixel !
  graph-start-height 8 - npixel cell + !
  maxwidth 520 - maxheight 250 - SetXYpos: CurfitWindow
  Start: Splab-Main
  InitListViewColumns: Splab-Main
  true       LVS_EX_FULLROWSELECT SetExtendedStyle: ListViewLeft
  InitListViewItems: Splab-Main
  true       LVS_EX_FULLROWSELECT SetExtendedStyle: ListViewRight
  SetDataList: Splab-Main
  $ to last-obj
  $ plot
  Splab-Loop
  bye
;


: Splab32
  Splab32init
  Splb32
;

turnkey? [if]
        NoConsoleBoot ' splab32 save splab-mmx
        s" SPLAB32.ICO" s" splab-mmx.exe" AddAppIcon
        bye
[then]
