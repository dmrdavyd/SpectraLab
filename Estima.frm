\ ESTIMA.FRM
\- textbox needs excontrols.f


:Object Estima                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

Label Label1
TextBox TextBox1
PushButton Button1
PushButton Button2

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
                300 560 
                ;M

:M StartPos:    ( -- x y )
                150  175
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
                19 42 132 16 Move: Label1
                Handle: Winfont SetFont: Label1
                s" Label1" SetText: Label1

                self Start: TextBox1
                170 41 114 18 Move: TextBox1
                Handle: Winfont SetFont: TextBox1

                self Start: Button1
                21 12 264 19 Move: Button1
                Handle: Winfont SetFont: Button1
                s" Button1" SetText: Button1

                self Start: Button2
                21 523 262 21 Move: Button2
                Handle: Winfont SetFont: Button2
                s" Button2" SetText: Button2
                TRUE to Estima-Open

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
                FALSE to Estima-Open
                \ Insert your code here
                On_Done: super
                ;M

;Object
