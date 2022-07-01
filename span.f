\- textbox needs excontrols.f

 FileOpenDialog LoadSpanStandards "Select spectral standards" "ASC Files|*.ASC|"

:Object SpanPar        <Super Object

Record: AddrOf
      256 bytes tabname
      int rrd
      int rho2thresh
      int MaxNr
      int elimibad
      int polyorder
;RecordSize: SIZEOFSPANPAR

:M Reset:       ( -- )
                AddrOf SIZEOFSPANPAR erase
                ;M

:M ClassInit:   ( -- )
                ClassInit: super
                Reset: self             \ create structure as Reset
                ;M
:M @tabname: tabname 1+ tabname C@ ;M

:M !tabname:  255 min put: tmpstr tmpstr tabname len: tmpstr 2 + move ;M

;Object

\ ============================
: Run-SPAN  { \ npts daddr }
      1 $ = not if
         $ putddir
         1 getddir
         SetCurveList: DATA-WINDOW
         SetListEdit: Splab-Window
      then
      1 call getn to npts
      npts 0= if exit then
      1 to daddr
      begin
         1 +to daddr
         daddr call getn npts = not
         TMP$ daddr call gethead drop
         tmp$ 1+ @ 1852404304 = \ Longint value for the first four bytes of "Principal vector"
         or
         daddr maxcur =
         or
      until
      daddr 2 > maxcur daddr - 5 > and if
        maxcur 1 + daddr do
          i clear
        loop
        s" SPLAB.SPC" append-fname put: FNAME
        FNAME call SaveSPC drop
        s" WINSPAN " append-fname put: pname$
        get: fname append: pname$
        pname$ $EXEC-WAIT DROP
        FNAME call ReadSPC drop
        daddr chgddir
        @tabname: spanpar
        0 = not if
             s" SPANOUT.TXT" append-fname put: FNAME
             s" WINBROWS.EXE " append-fname put: pname$
             get: fname append: pname$
             pname$ $EXEC
        then
        DROP
        SetCurveList: DATA-WINDOW
        SetListEdit: Splab-Window
        SetCtrl:     Splab-Window
        $ plot
     then
;

:Object SpanForm                <Super DialogWindow

Font WinFont                    \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color

Label LBL-Cthresh
Label LBL-Sthresh
Label LBL-Ncomp
Label LBL-Tabnam$
Label LBL-polyorder
TextBox Cthresh
TextBox Sthresh
TextBox Ncomp
TextBox polyordr
TextBox Tabnam$
CheckBox BadBox
PushButton FileButton
PushButton RunButton
PushButton CancelButton

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
                z" SpAn"
                ;M

:M StartSize:   ( -- width height )
                360 250
                ;M

:M StartPos:    ( -- x y )
                maxwidth 2 / 135 - dup 1 < if drop 1 then
                maxheight 2 / 142 - dup 1 < if drop 1 then
;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M
:M Set-Values:
                spanpar.rho2thresh X2F 1E3 F/ FLO2STR  SetText: Cthresh
                spanpar.rrd  X2F 1E3 F/ FLO2STR  SetText: Sthresh
                spanpar.MaxNr str$  SetText: Ncomp
                spanpar.polyorder str$  SetText: polyordr
                spanpar.elimibad GetID: BadBox CheckDlgButton: self
                @tabname: spanpar
                put: TMP$
                TMP$  call TruncStdFname drop
                get: TMP$ SetText: Tabnam$
;M

:M Get-Values:
                TRUE
                GetText: Cthresh
                str2flo not if drop false else
                  1E3 F*
                  F2X
                  dup
                  0 < not
                  over 1000000 > not
                  and
                  if put: spanpar.rho2thresh else drop drop false then
                then
                GetText: Sthresh
                str2flo not if drop false else
                  1E3 F*
                  F2X
                  dup
                  0 < not
                  over 1000000 > not
                  and
                  if put: spanpar.rrd else drop drop false then
                then
                GetText: Ncomp
                str2flo not if drop false else
                  F2I
                  dup
                  0 < not
                  over 10 > not
                  and
                  if put: spanpar.MaxNr else drop drop false then
                then
                GetText: polyordr
                str2flo not if drop false else
                  F2I
                  dup
                  0 < not
                  over 3 > not
                  and
                  if put: spanpar.polyorder else drop drop false then
                then

                GetID: BadBox IsDlgButtonChecked: self if 1 else 0 then put: spanpar.elimibad
                GetText: Tabnam$
                !tabname: spanpar
;M

:M On_Init:     ( -- )

s" Standard.asc " !tabname: spanpar
500000 put: spanpar.rrd
980000 put: spanpar.rho2thresh
-1 put: spanpar.elimibad

                spanpar call ReadSpanPar drop

                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: LBL-Cthresh
                20 20 240 18 Move: LBL-Cthresh
                Handle: Winfont SetFont: LBL-Cthresh
                s" Threshold for principal components" SetText: LBL-Cthresh

                self Start: LBL-Sthresh
                20 50 240 18 Move: LBL-Sthresh
                Handle: Winfont SetFont: LBL-Sthresh
                s" Threshold for generated standards" SetText: LBL-Sthresh

                self Start: LBL-Ncomp
                20 80 240 18 Move: LBL-Ncomp
                Handle: Winfont SetFont: LBL-Ncomp
                s" Max. number of principal components" SetText: LBL-Ncomp

                self Start: LBL-Tabnam$
                20 140 200 18 Move: LBL-Tabnam$
                Handle: Winfont SetFont: LBL-Tabnam$
                s" File of standards " SetText: LBL-Tabnam$

                self Start: LBL-polyorder
                20 110 200 18 Move: LBL-polyorder
                Handle: Winfont SetFont: LBL-polyorder
                s" Order of background correction polynomial" SetText: LBL-polyorder

                self Start: Cthresh
                304 20 40 18 Move: Cthresh
                Handle: Winfont SetFont: Cthresh

                self Start: Sthresh
                304 50 40 18 Move: Sthresh
                Handle: Winfont SetFont: Sthresh

                self Start: Ncomp
                304 80 40 18 Move: Ncomp
                Handle: Winfont SetFont: Ncomp

                self Start: polyordr
                304 110 40 18 Move: polyordr
                Handle: Winfont SetFont: polyordr

                self Start: Tabnam$
                110 140 234 18 Move: Tabnam$
                Handle: Winfont SetFont: Tabnam$

                self Start: BadBox
                200 170 240 18 Move: BadBox
                Handle: Winfont SetFont: BadBox
                s" Eliminate bad standards" SetText: BadBox

                self Start: FileButton
                20 210 72 20 Move: FileButton
                Handle: Winfont SetFont: FileButton
                s" Select File" SetText: FileButton

                self Start: RunButton
                200 210 64 20 Move: RunButton
                Handle: Winfont SetFont: RunButton
                s" Run" SetText: RunButton

                self Start: CancelButton
                280 210 64 20 Move: CancelButton
                Handle: Winfont SetFont: CancelButton
                s" Cancel" SetText: CancelButton

                Set-Values: self

                ;M

:M Select-Std-file:     ( -- )
                 get: SPLABDIR$ put: tmpstr
                 s" \STANDARDS" append: tmpstr
                 get: tmpstr SetDir: LoadSpanStandards
                 GetHandle: self Start: LoadSpanStandards dup c@
                 if  count
                     !tabname: spanpar
                     Set-Values: self
                 else  drop
                 then
;M

:M WM_COMMAND   ( h m w l -- res )
                 over LOWORD ( ID )
                 case
                  GETID: FileButton of
                    select-std-file: self
                  endof
                  GETID: RunButton of
                     Get-Values: self if
                       spanpar call WriteSpanPar
                       Run-Span
                       Close: self
                     else
                       s" Invalid parameters"
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

: Span-Dialog
   Start: SpanForm
;


\ ============================

: s2s  spanpar call ReadSpanPar ;

