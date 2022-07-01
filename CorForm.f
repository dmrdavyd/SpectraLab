\ CorForm.F
\- textbox needs excontrols.f

:Object CorForm                <Super DialogWindow

Font WinFont                    \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color

Label LBL-POLYORDER
Label LBL-FILE1
Label LBL-File2
Label LBL-File3
Label LBL-Ncomp
Label LBL-Weight
TextBox OrdrPoly
TextBox FILE1
TextBox FILE2
TextBox FILE3
TextBox NComp
TextBox LocWeight
PushButton File1Button
PushButton File2Button
PushButton File3Button
PushButton RunButton
PushButton CancelButton
1 value %nspc
0 value %dynaddress
5 value %maxcomponents
0 value %compaddress
0 value %nstd

:M ClassInit:   ( -- )
                ClassInit: super
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
                z" PolyCor"
                ;M

:M StartSize:   ( -- width height )
                360 220
                ;M

:M StartPos:    ( -- x y )
                MAXX INIX - 2 / INIX + 150 + MAXY 2 / 100 -
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M
:M Set-Values:
                polyorder str$  SetText: OrdrPoly
                ncomponents str$  SetText: NComp
                get: std$1 put: TMP$
                TMP$  call TruncStdFname drop
                get: TMP$ SetText: FILE1
                get: std$2  put: TMP$
                TMP$  call TruncStdFname drop
                get: TMP$ SetText: FILE2
                get: std$ put: TMP$
                TMP$  call TruncStdFname drop
                get: TMP$ SetText: FILE3
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
                GetText: NComp
                str2flo not if drop false else
                  F2I
                  dup
                  0 < not
                  over %maxcomponents > not
                  and
                  if to NComponents else drop drop false then
                then
                GetText: File1 put: std$1
                32 std$1 call TRIM drop
                GetText: File2 put: std$2
                32 std$2 call TRIM drop
                GetText: File3 put: std$
                32 std$ call TRIM drop
;M

:M On_Init:    ( -- )
               FindCompLoc
               to %maxcomponents
               to %dynaddress
               dup to %nspc
               1 + to %compaddress
               %maxcomponents 0= %dynaddress 0= or %nspc 0= or if
                  close: self
               else
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: LBL-POLYORDER
                8 20 100 18 Move: LBL-POLYORDER
                Handle: Winfont SetFont: LBL-POLYORDER
                s" Order of polynomial" SetText: LBL-POLYORDER

                self Start: LBL-Ncomp
                8 50 240 18 Move: LBL-Ncomp
                Handle: Winfont SetFont: LBL-NComp
                s" Number of principal components to consider" SetText: LBL-NComp

                self Start: LBL-FILE1
                8 80 200 18 Move: LBL-FILE1
                Handle: Winfont SetFont: LBL-FILE1
                s" Dynamic Target Stdandards" SetText: LBL-FILE1

                self Start: LBL-FILE2
                8 110 200 18 Move: LBL-FILE2
                Handle: Winfont SetFont: LBL-FILE2
                s" Background Standards" SetText: LBL-FILE2

                self Start: LBL-FILE3
                8 140 200 18 Move: LBL-FILE3
                Handle: Winfont SetFont: LBL-FILE3
                s" Static Target Standards" SetText: LBL-FILE3

\                self Start: LBL-Weight
\                20 140 140 18 Move: LBL-Weight
\                Handle: Winfont SetFont: LBL-Weight
\                s" Location of weighting table" SetText: LBL-Weight

                self Start: OrdrPoly
                316 20 38 18 Move: OrdrPoly
                Handle: Winfont SetFont: OrdrPoly

                self Start: NComp
                316 50 38 18 Move: NComp
                Handle: Winfont SetFont: NComp

                self Start: FILE1
                148 80 164 18 Move: FILE1
                Handle: Winfont SetFont: FILE1

                self Start: FILE2
                148 110 164 18 Move: FILE2
                Handle: Winfont SetFont: FILE2

                self Start: FILE3
                148 140 164 18 Move: FILE3
                Handle: Winfont SetFont: FILE3

\                self Start: LocWeight
\                304 140 40 18 Move: LocWeight
\                Handle: Winfont SetFont: LocWeight

                self Start: File1Button
                316 80 38 20 Move: File1Button
                Handle: Winfont SetFont: File1Button
                s" Select" SetText: File1Button

                self Start: File2Button
                316 110 38 20 Move: File2Button
                Handle: Winfont SetFont: File2Button
                s" Select" SetText: File2Button

                self Start: File3Button
                316 140 38 20 Move: File3Button
                Handle: Winfont SetFont: File3Button
                s" Select" SetText: File3Button

                self Start: RunButton
                8 180 64 20 Move: RunButton
                Handle: Winfont SetFont: RunButton
                s" Run" SetText: RunButton

                self Start: CancelButton
                280 180 64 20 Move: CancelButton
                Handle: Winfont SetFont: CancelButton
                s" Cancel" SetText: CancelButton

                Set-Values: self
               then
               ;M

: Select-Std-file
                 get: SPLABDIR$ put: tmpstr
                 s" \STANDARDS" append: tmpstr
                 get: tmpstr SetDir: SpanStandards
                 GetHandle: self Start: SpanStandards dup c@
;

:M Select-Std-file1:     ( -- )
                 Get-Values: self
                 Select-Std-File
                 if  count
                     put: std$1  \ Dynamic target
                     Set-Values: self
                 else drop then
;M

:M Select-Std-file2:     ( -- )
                 Get-Values: self
                 Select-Std-File
                 if  count
                     put: std$2  \ background
                     Set-Values: self
                 else  drop then
;M

:M Select-Std-file3:     ( -- )
                 Get-Values: self
                 Select-Std-File
                 if  count
                     put: std$    \ Static
                     Set-Values: self
                 else  drop then
;M

:M WM_COMMAND   ( h m w l -- res )
                 over LOWORD ( ID )
                 case
                  GETID: File1Button of
                    select-std-file1: self
                  endof
                  GETID: File2Button of
                    select-std-file2: self
                  endof
                  GETID: File3Button of
                    select-std-file3: self
                  endof
                  GETID: RunButton of
                     Get-Values: self if
                      ncomponents 1 + 1 do
                        i %compaddress + 1 -
                        CHGDDIR
                        polyorder
                        %nspc
                        %dynaddress i 1 - +
                        polycor
                      loop
                      1 ChgDdir
                      len: std$ 0= if get: std$1 put: std$ then
                      130 to fitdest
                      131 to polydest
                      0 to weightloc
                      SURFIT-BY-FILE
                      stkclr
                      %nspc 0 131 sub
                      130 clear
                      131 clear
                      1 ChgDdir
                      %nspc select
                      maxcur %nspc deselect
                      1 ChgDdir
                      true plot
                      SetCurveList: DATA-WINDOW
                      SetListEdit: Splab-Window
                      SetDataEdit: Splab-Window
                      $ to last-obj
                      stkclr
                      close: self
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

: PolyCor-Dialog
   Start: CorForm
;

