\ SURFITFRM.F
\- textbox needs excontrols.f

FileOpenDialog SpanStandards "Select spectral standards" "ASC Files|*.ASC|"


:Object SurfitForm                <Super DialogWindow

Font WinFont                    \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color

Label LBL-POLYORDER
Label LBL-DestFit
Label LBL-DestPoly
Label LBL-LISTSTD
Label LBL-Weight
TextBox OrdrPoly
TextBox DestFit
TextBox DestPoly
TextBox ListStd
TextBox LocWeight
PushButton FileButton
PushButton RunButton
PushButton CancelButton

0 Value Surfit_In_Progress

:M ClassInit:   ( -- )
                ClassInit: super
                NOCRT
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" SurFit"
                ;M

:M StartSize:   ( -- width height )
                360 220
                ;M

:M StartPos:    ( -- x y )
                maxwidth 2 / 135 - dup 1 < if drop 1 then
                maxheight 2 / 142 - dup 1 < if drop 1 then
;M

:M Close:        ( -- )
                call CRTCLRSCR depth if DROP then
                NOCRT
                Close: super
                ;M
:M Set-Values:
                polyorder str$  SetText: OrdrPoly
                FitDest str$  SetText: DestFit
                PolyDest str$  SetText: DestPoly
                WeightLoc str$  SetText: LocWeight
                get: std$ put: TMP$
                TMP$  call TruncStdFname drop
                get: TMP$ SetText: ListStd
;M

:M Get-Values:
                TRUE
                GetText: OrdrPoly
                str2flo not if drop false else
                  F2I
                  dup
                  0 < not
                  over 10 > not
                  and
                  if to PolyOrder else drop drop false then
                then
                GetText: DestFit
                str2flo not if drop false else
                  F2I
                  dup
                  0 < not
                  over maxcur > not
                  and
                  if to FitDest else drop drop false then
                then
                GetText: DestPoly
                str2flo not if drop false else
                  F2I
                  dup
                  0 < not
                  over maxcur > not
                  and
                  over FitDest = not
                  and
                  if to PolyDest else drop drop false then
                then
                GetText: LocWeight
                str2flo not if drop false else
                  F2I
                  dup 0 < not
                  over maxcur > not
                  and
                  if
                    dup to WeightLoc
                    dup dup 0= swap maxcur > or
                    if
                      drop mincur 1 -
                    then
                    0 !LISTA
                  else drop drop false then
                then
                GetText: ListStd put: std$
                32 std$ call TRIM drop
                len: std$ 0= not if
                  lista std$ call input_list
                  dup to nstd
                  0 > not to FILEFIT
                else
                  0 to NSTD
                  FALSE to FILEFIT
                then
;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: LBL-POLYORDER
                20 20 100 18 Move: LBL-POLYORDER
                Handle: Winfont SetFont: LBL-POLYORDER
                s" Order of polynomial" SetText: LBL-POLYORDER

                self Start: LBL-DestFit
                20 50 160 18 Move: LBL-DestFit
                Handle: Winfont SetFont: LBL-DestFit
                s" Destination for the fitting curve" SetText: LBL-DestFit

                self Start: LBL-DestPoly
                20 80 200 18 Move: LBL-DestPoly
                Handle: Winfont SetFont: LBL-DestPoly
                s" Destination for the polynomial component" SetText: LBL-DestPoly

                self Start: LBL-LISTSTD
                20 110 200 18 Move: LBL-LISTSTD
                Handle: Winfont SetFont: LBL-LISTSTD
                s" Standards (list of spectra or file name)" SetText: LBL-LISTSTD

                self Start: LBL-Weight
                20 140 140 18 Move: LBL-Weight
                Handle: Winfont SetFont: LBL-Weight
                s" Location of weighting table" SetText: LBL-Weight

                self Start: OrdrPoly
                304 20 40 18 Move: OrdrPoly
                Handle: Winfont SetFont: OrdrPoly

                self Start: DestFit
                304 50 40 18 Move: DestFit
                Handle: Winfont SetFont: DestFit

                self Start: DestPoly
                304 80 40 18 Move: DestPoly
                Handle: Winfont SetFont: DestPoly

                self Start: ListStd
                200 110 144 18 Move: ListStd
                Handle: Winfont SetFont: ListStd

                self Start: LocWeight
                304 140 40 18 Move: LocWeight
                Handle: Winfont SetFont: LocWeight

                self Start: FileButton
                20 180 72 20 Move: FileButton
                Handle: Winfont SetFont: FileButton
                s" Select File" SetText: FileButton

                self Start: RunButton
                200 180 64 20 Move: RunButton
                Handle: Winfont SetFont: RunButton
                s" Run" SetText: RunButton

                self Start: CancelButton
                280 180 64 20 Move: CancelButton
                Handle: Winfont SetFont: CancelButton
                s" Cancel" SetText: CancelButton

                Set-Values: self

                ;M
:M Select-Std-file:     ( -- )
                 get: SPLABDIR$ put: tmpstr
                 s" \STANDARDS" append: tmpstr
                 get: tmpstr SetDir: SpanStandards
                 GetHandle: self Start: SpanStandards dup c@
                 if  count
                     put: std$
                     Set-Values: self
                 else  drop
                 then
;M



:M WM_COMMAND   ( h m w l -- res )
                 over LOWORD ( ID ) \ object address on stack
                 case
                  GETID: FileButton of
                    select-std-file: self
                  endof
 \                 CRT_IS_ON if NOCRT then
                  GETID: RunButton of
                     Get-Values: self if
                       CRT
                       FILEFIT if
                         Surfit-by-File
                       else
                         Surfit-by-list
                       then
                       if
                         $ 1 !lista
                         fitdest 2 !lista
                         polydest 3 !lista
                         0 4 !lista
                         plot-list
                         SetCurveList: DATA-WINDOW
                       then
                     else
                      s" Invalid parameters. Please, check."
                      put: tmpstr
                      tmpstr call SplabErrorMessage
                     then
                  endof
                  GetId: CancelButton of
                     Close: self
                  endof
                 endcase
                0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here
                On_Done: super
                ;M

;Object

: Surfit-Dialog
   Start: SurfitForm
;

