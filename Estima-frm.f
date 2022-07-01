NEEDS ZSTRINGS
NEEDS STRING$
NEEDS FLO2INT
NEEDS SPN_DEF

TRUE value allow-get-estimates
FALSE value estimates-done

\ ESTIMA-FRM
\- textbox needs excontrols.f



:Object Estima-frm                <Super DialogWindow

ZSTRING PNAMES$
ZSTRING PVALUE$
ZSTRING Rhovalue$

Font WinFont           \ default font
Font Emphasize           \ title font
ColorObject FrmColor      \ the background color

Label Label1
TextBox TextBox1
Label Label2
TextBox TextBox2
Label Label3
TextBox TextBox3
Label Label4
TextBox TextBox4
Label Label5
TextBox TextBox5
Label Label6
TextBox TextBox6
Label Label7
TextBox TextBox7
Label Label8
TextBox TextBox8
Label Label9
TextBox TextBox9
Label Label10
TextBox TextBox10
PushButton SetButton
PushButton GetButton
Label Rho2Label
PushButton DoneButton
label LblMask
TextBox TextMask
FALSE value Calculated
FALSE value SettingValues

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
                300 30 np @ 2 + * 66 +
                ;M
:M StartPos:    ( -- x y )
                maxwidth 300 - 8 -
                maxheight 30 np @ 2 + * 132 + -
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M SetControls:
         TRUE to SettingValues
         0
         np @ 1 + 1 do
          i
          dup par_name count put: PNAMES$
          @P FDUP IsNAN10 if FDROP s" " else FLO2STR then put: pvalue$
          i
          case
           1 of
                18 50 132 18 Move: Label1
                get: PNAMES$ SetText: Label1
                get: pvalue$  SetText: Textbox1
                170 44 114 20 Move: TextBox1
             endof

           2 of
                get: PNAMES$  SetText: Label2
                18 80 132 18 Move: Label2
                get: pvalue$  SetText: Textbox2
                170 74 114 20 Move: TextBox2
             endof

           3 of
                get: PNAMES$  SetText: Label3
                18 110 132 18 Move: Label3
                get: pvalue$  SetText: Textbox3
                170 104 114 20 Move: TextBox3
             endof

           4 of
                get: PNAMES$  SetText: Label4
                18 140 132 18 Move: Label4
                get: pvalue$  SetText: Textbox4
                170 134 114 20 Move: TextBox4
             endof

           5 of
                get: PNAMES$  SetText: Label5
                18 170 132 18 Move: Label5
                get: pvalue$  SetText: Textbox5
                170 164 114 20 Move: TextBox5
             endof

           6 of
                get: PNAMES$  SetText: Label6
                18 200 132 18 Move: Label6
                get: pvalue$  SetText: Textbox6
                170 194 114 20 Move: TextBox6
             endof

           7 of
                get: PNAMES$ SetText: Label7
                18 230 132 18 Move: Label7
                get: pvalue$  SetText: Textbox7
                170 224 114 20 Move: TextBox7
             endof

           8 of
                get: PNAMES$ SetText: Label8
                18 260 132 18 Move: Label8
                get: pvalue$  SetText: Textbox8
                170 254 114 20 Move: TextBox8
             endof

           9 of
                get: PNAMES$ SetText: Label9
                18 290 132 18 Move: Label9
                get: pvalue$  SetText: Textbox9
                170 284 114 20 Move: TextBox9
             endof

           10 of
                get: PNAMES$ SetText: Label10
                18 320 132 18 Move: Label10
                get: pvalue$  SetText: Textbox10
                170 314 114 20 Move: TextBox10
             endof
          endcase
          loop
          allow-get-estimates
          if
           PSI F@ IsNAN10 if
             0 0 0 0 Move: DoneButton
             s" " Put: RhoValue$
           else
             188 30 np @ 3 + * 12 + 96 20 Move: DoneButton
             s" Sq.corr.coef.:      " Put: RhoValue$
             PSI F@
             FLO2STR Append: RhoValue$
           then
           Get: RhoValue$ SetText: Rho2Label
           18 30 np @ 3 + * 14 + 266 20 Move: Rho2Label
           18 30 np @ 1 + * 24 + 132 20 Move: LblMask
           parmask @ str$ SetText: TextMask
           252 30 np @ 1 + * 20 + 32 20 Move: TextMask
          then
          18 12  266 20 Move: GetButton
          18 30 np @ 2 + * 16 + 266 20 Move: SetButton
          FALSE to settingvalues
          ;M

:M On_Init:     ( -- )
             0 to Estimates-done
             s" MS Sans Serif" SetFaceName: WinFont
             8 Width: WinFont
             Create: WinFont
             COLOR_BTNFACE Call GetSysColor NewColor: FrmColor
             np @ 1 + 1 do
             i
             case
             1 of
                self Start: Label1
                Handle: WinFont SetFont: Label1
                self Start: TextBox1
                Handle: Emphasize SetFont: TextBox1
             endof
             2 of
                self Start: Label2
                Handle: WinFont SetFont: Label2
                self Start: TextBox2
                Handle: Emphasize SetFont: TextBox2
             endof

             3 of
                self Start: Label3
                Handle: WinFont SetFont: Label3
                self Start: TextBox3
                Handle: Emphasize SetFont: TextBox3
             endof

             4 of
                self Start: Label4
                Handle: WinFont SetFont: Label4
                self Start: TextBox4
                Handle: Emphasize SetFont: TextBox4
             endof

             5 of
                self Start: Label5
                Handle: WinFont SetFont: Label5
                self Start: TextBox5
                Handle: Emphasize SetFont: TextBox5
             endof

             6 of
                self Start: Label6
                Handle: WinFont SetFont: Label6
                self Start: TextBox6
                Handle: Emphasize SetFont: TextBox6
             endof

             7 of
                self Start: Label7
                Handle: WinFont SetFont: Label7
                self Start: TextBox7
                Handle: Emphasize SetFont: TextBox7
             endof

             8 of
                self Start: Label8
                Handle: WinFont SetFont: Label8
                self Start: TextBox8
                Handle: Emphasize SetFont: TextBox8
             endof

             9 of
                self Start: Label9
                Handle: WinFont SetFont: Label9
                self Start: TextBox9
                Handle: Emphasize SetFont: TextBox9
             endof

             10 of
                self Start: Label10
                Handle: WinFont SetFont: Label10
                self Start: TextBox10
                Handle: Emphasize SetFont: TextBox10
             endof
            endcase
            loop

            allow-get-estimates if
              self Start: GetButton
              Handle: Winfont SetFont: GetButton
              s" Get Estimates" SetText: GetButton
            then

            self Start: Rho2Label
            Handle: Winfont SetFont: SetButton

            self Start: SetButton
            Handle: Winfont SetFont: SetButton
            allow-get-Estimates if
               s" Apply "    SetText: SetButton
               self Start:  DoneButton
               Handle: Winfont SetFont: DoneButton
               s" Done " SetText: DoneButton
               self Start:  LblMask
               Handle: Winfont SetFont: Lblmask
               s" Optimization mask:" SetText: LblMask
               self Start:  TextMask
               Handle: Emphasize SetFont: TextMask
               s" " SetText: TextMask
            else
              s" Done " SetText: SetButton
            then
            FitPath @ 0 > to calculated
            FALSE to settingvalues
            SetControls: self
            ;M

:M GetValues:
         0
         np @ 1 + 1 do
         i
         case
            1 of
                GetText: Textbox1
             endof
            2 of
                GetText: Textbox2
             endof
            3 of
                GetText: Textbox3
             endof
            4 of
                GetText: Textbox4
             endof
            5 of
                GetText: Textbox5
             endof
            6 of
                GetText: Textbox6
             endof
            7 of
                GetText: Textbox7
             endof
            8 of
                GetText: Textbox8
             endof
            9 of
                GetText: Textbox9
             endof
            10 of
                GetText: Textbox10
             endof
           endcase
           str2flo not if NAN10 F@ i !p drop i else i !p then
         loop
;M

:M SET_ESTIMATES:
   GetValues: self
   0 =
   ;M
:M OnGetButton:
    GET_ESTIMATES
    if
     -1 to estimates-done
     $ to last-obj
     $ plot
     SetControls: self
     TRUE to calculated
    then
;M

:M WM_COMMAND   ( h m w l -- res )
\                over LOWORD ( ID ) \ object address on stack
                 over LOWORD ( ID )
                 settingvalues if drop else
                 case
                  GETID: GetButton of
                    allow-get-estimates if
                      OnGetButton: self
                    then
                  endof
                  GETID: SetButton of
                    allow-get-Estimates if
                         GetText: TextMask
                         STR2FLO
                         if F2I else 0 then
                         parmask !
                     then
                     calculated not if SET_ESTIMATES: self else true then
                     if
                       -1 to estimates-done
                       allow-get-estimates if
                         3 call putfit if $ to last-obj $ plot then
                         SetControls: self
                         TRUE to calculated
                       else
                         CLOSE: SELF
                       then
                     then
                  endof
                  GETID: DoneButton of
                     allow-get-Estimates if
                         GetText: TextMask
                         STR2FLO
                         if F2I else 0 then
                         parmask !
                     then
                     calculated not if SET_ESTIMATES: self else true then
                     if
                      -1 to estimates-done
                      3 call putfit if $ to last-obj $ plot then
                      CLOSE: SELF
                   then
                 endof
                 dup GETID: SetButton > if FALSE to calculated then
                endcase
                then
                0 ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M
:M Close:       ( -- )
                Delete: WinFont
                estimates-done if 2 else 1 then to estimates-done
                close: super
                ;M
:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here
                estimates-done if 2 else 1 then to estimates-done
                On_Done: super
                ;M

;Object


