\ SetPrm-FRM
\- textbox needs excontrols.f

:Object SetPrm-frm                <Super DialogWindow

Font WinFont           \ default font
Font Emphasize           \ title font
ColorObject FrmColor      \ the background color

Label MaxN-L
TextBox MaxN-T
Label Accu-L
TextBox Accu-T
Label R2Max-L
TextBox R2Max-T
Label Lambda-L
TextBox Lambda-T
Label Nu-L
TextBox Nu-T
Label Alpha-L
TextBox Alpha-T
Label AtoChk-L
CheckBox AutoChk
PushButton SetButton


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
                z" Get Estimates"
                ;M

:M StartSize:   ( -- width height )
                300 258
                ;M

:M StartPos:    ( -- x y )
                2 graph-start-height 32 +
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M SetControls:
                18 18 132 18 Move: Maxn-L
                s" Max. number of iterations " SetText: Maxn-L
                nitmax @ str$  SetText: Maxn-T
                170 14 114 20 Move: Maxn-T

                s" Relative accuracy "  SetText: Accu-L
                18 48 132 18 Move: Accu-L
                accur F@
                fdup IsNAN10 if Fdrop s" " else Flo2Str then
                SetText: Accu-T
                170 44 114 20 Move: Accu-T


                s" Max. correlation coef. "   SetText: R2Max-L
                18 78 132 18 Move: R2MAx-L
                smin F@
                fdup IsNAN10 if Fdrop s" " else -1E0 F* 1E0 F+ Flo2Str then
                SetText: R2Max-T
                170 74 114 20 Move: R2Max-T

                s" Marquardt dumping factor"  SetText: Lambda-L
                18 108 132 18 Move: Lambda-L
                Lambda F@
                fdup IsNAN10 if Fdrop s" " else Flo2Str then
                SetText: Lambda-T
                170 104 114 20 Move: Lambda-T

                s" Dumping increase factor"  SetText: Nu-L
                18 138 132 18 Move: Nu-L
                nu F@
                fdup IsNAN10 if Fdrop s" " else Flo2Str then
                SetText: Nu-T
                170 134 114 20 Move: Nu-T

                s" Simplex size"  SetText: Alpha-L
                18 168 132 18 Move: Alpha-L
                alpha F@
                fdup IsNAN10 if Fdrop s" " else Flo2Str then
                SetText: Alpha-T
                170 164 114 20 Move: Alpha-T


                s" Marquardt auto-set " SetText: AutoChk
                18 198 132 18 Move: AutoChk
                autolambda @ IF 1 ELSE 0 THEN GetID: AutoChk CheckDlgButton: self

                18 228 266 20 Move: SetButton
          ;M

:M On_Init:     ( -- )
             s" MS Sans Serif" SetFaceName: WinFont
             8 Width: WinFont
             Create: WinFont

             \ set form color to system color
             COLOR_BTNFACE Call GetSysColor NewColor: FrmColor

            self Start: MaxN-L
            Handle: WinFont SetFont: MaxN-L
            self Start: MaxN-T
            Handle: Emphasize SetFont: MaxN-T

            self Start: Accu-L
            Handle: WinFont SetFont: Accu-L
            self Start: Accu-T
            Handle: Emphasize SetFont: Accu-T

            self Start: R2Max-L
            Handle: WinFont SetFont: R2Max-L
            self Start: R2Max-T
            Handle: Emphasize R2Max-T

            self Start: Lambda-L
            Handle: WinFont SetFont: Lambda-L
            self Start: Lambda-T
            Handle: Emphasize SetFont: Lambda-T

            self Start: Nu-L
            Handle: WinFont SetFont: Nu-L
            self Start: Nu-T
            Handle: Emphasize SetFont: Nu-T

            self Start: Alpha-L
            Handle: WinFont SetFont: Alpha-L
            self Start: Alpha-T
            Handle: Emphasize SetFont: Alpha-T

            self Start: AutoChk
            Handle: WinFont SetFont: AutoChk
            self Start: SetButton

            Handle: Winfont SetFont: SetButton
            s" Apply " SetText: SetButton

            SetControls: self
            ;M

:M GetValues:       ( -- res )
       TRUE

       GetText: MaxN-T
       str2flo not if drop false 0 else F2I then nitmax !

       GetText: Accu-T
       str2flo not if NAN10 F@ drop false else
        fdup 1E0 F> if fdrop 1E0 then
        fdup 0e0 F< if fdrop 0e0 then
       then accur F!

       GetText: R2MAX-T
       str2flo not if NAN10 F@ drop false else
        -1E0 F* 1E0 F+
        fdup 1E0 F> if fdrop 1E0 then
        fdup 0e0 F< if fdrop 0e0 then
       then smin F!

       GetText: Lambda-T
       str2flo not if NAN10 F@ drop false else
        fdup 1E2 F> if fdrop 1E2 then
        fdup 1e0 F< if fdrop 1e0 then
       then lambda F!

       GetText: Nu-T
       str2flo not if NAN10 F@ drop false else
        fdup 1E2 F> if fdrop 1E2 then
        fdup 1e0 F< if fdrop 1e0 then
       then nu F!

       GetText: Alpha-T
       str2flo not if NAN10 F@ drop false else
        fdup 1E0 F> if fdrop 1E0 then
        fdup 1e-3 F< if fdrop 1e-3 then
       then Alpha F!

       GetID: AutoChk IsDlgButtonChecked: self autolambda !
       autolambda @ GetID: AutoChk CheckDlgButton: self

;M

:M WM_COMMAND   ( h m w l -- res )
\                over LOWORD ( ID ) \ object address on stack
                 over LOWORD ( ID )
                 case
                  GETID: SetButton of
                     GetValues: self if
                     ^splabdir$ @ call write_optiprm
                     CLOSE: SELF
                    else
                     SetControls: self
                   then
                 endof
                endcase
                0 ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here
                On_Done: super
                ;M

;Object


