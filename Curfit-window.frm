\ CURFIT-WINDOW.FRM
\- textbox needs excontrols.f


:Object CurfitWindow                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
150 175  2value XYPos  \ save screen location of form

Label Label1
Label Label3
Label Label5
TextBox TextBox1
TextBox TextBox2
PushButton Button1
PushButton Button2
PushButton Button5
PushButton Button6
PushButton Button7
PushButton Button8
PushButton Button9
PushButton Button10
ComboBox Combo1
Label Label4
CheckBox Check1

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
                z" Curve Fitting"
                ;M

:M StartSize:   ( -- width height )
                512 182 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: Label1
                29 41 100 20 Move: Label1
                Handle: Winfont SetFont: Label1
                s" Label1" SetText: Label1

                self Start: Label3
                31 77 301 15 Move: Label3
                Handle: Winfont SetFont: Label3
                s" Label3" SetText: Label3

                self Start: Label5
                29 109 129 20 Move: Label5
                WS_GROUP +Style: Label5
                Handle: Winfont SetFont: Label5
                s" Label5" SetText: Label5

                self Start: TextBox1
                349 76 47 20 Move: TextBox1
                Handle: Winfont SetFont: TextBox1

                self Start: TextBox2
                170 106 56 23 Move: TextBox2
                Handle: Winfont SetFont: TextBox2

                self Start: Button1
                415 40 78 25 Move: Button1
                Handle: Winfont SetFont: Button1
                s" Button1" SetText: Button1

                self Start: Button2
                417 81 77 40 Move: Button2
                Handle: Winfont SetFont: Button2
                s" Button2" SetText: Button2

                self Start: Button5
                17 140 62 29 Move: Button5
                Handle: Winfont SetFont: Button5
                s" Button5" SetText: Button5

                self Start: Button6
                88 140 68 30 Move: Button6
                Handle: Winfont SetFont: Button6
                s" Button6" SetText: Button6

                self Start: Button7
                169 139 69 31 Move: Button7
                Handle: Winfont SetFont: Button7
                s" Button7" SetText: Button7

                self Start: Button8
                251 140 66 30 Move: Button8
                Handle: Winfont SetFont: Button8
                s" Button8" SetText: Button8

                self Start: Button9
                333 138 73 31 Move: Button9
                Handle: Winfont SetFont: Button9
                s" Button9" SetText: Button9

                self Start: Button10
                420 138 70 31 Move: Button10
                Handle: Winfont SetFont: Button10
                s" Button10" SetText: Button10

                self Start: Combo1
                142 42 253 28 Move: Combo1
                Handle: Winfont SetFont: Combo1

                self Start: Label4
                28 16 463 13 Move: Label4
                Handle: Winfont SetFont: Label4
                s" Label4" SetText: Label4

                self Start: Check1
                255 106 149 20 Move: Check1
                Handle: Winfont SetFont: Check1
                s" Check1" SetText: Check1

                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                \ Insert your code here
                On_Done: super
                ;M

;Object
