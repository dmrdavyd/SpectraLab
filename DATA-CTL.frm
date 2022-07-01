\ DATA-CTL.FRM
\- textbox needs excontrols.f
\- usebitmap needs bitmap.f


:Object Form2                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color

Label X-Linhed
Label Y-Linhed
Label FootTxt
Label MIN-COLHED
Label MAX-COLHED
Label AUTO-COLHED
Label LBL-COLHED
Label Z-Hed
Label DATA-Pair-Lbl
Label X-Value-Lbl
Label Y-Value-Lbl

TextBox X-Min-Edit
TextBox Y-Min-Edit
TextBox X-Max-Edit
TextBox Y-Max-Edit
TextBox X-Labl-Edit
TextBox Y-Labl-Edit
TextBox Comment-Edit
TextBox Hed-Edit
TextBox Z-Edit
TextBox Color-Edit
TextBox Symbl-Edit
TextBox X-Edit
TextBox Y-Edit
TextBox Cmd-Line


ListBox Curvelist

CheckBox X-Auto
CheckBox Y-Auto
CheckBox Sel-Chk
CheckBox Int-ON
CheckBox Lin-ON

BitmapButton Clr-Spc-Bttn
BitmapButton Set-Spc-Bttn


PushButton Set-Point-Bttn
PushButton Del-Point-Bttn
PushButton Exec-Button

VertScroll ScrollDataSet
VertScroll ScrollCurveList

GroupBox Plot_Axes
GroupBox Group_List

RadioButton Select-CurveList
RadioButton Select-DataSet

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                parent
                ;M

:M SetParent:  ( hwndparent -- ) \ set owner window
                to parent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Form2"
                ;M

:M StartSize:   ( -- width height )
                430 536
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
                Create: WinFont drop

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: X-Min-Edit
                46 111 63 19 Move: X-Min-Edit 
                Handle: Winfont SetFont: X-Min-Edit 

                self Start: Y-Min-Edit
                45 135 64 18 Move: Y-Min-Edit
                Handle: Winfont SetFont: Y-Min-Edit

                self Start: X-Max-Edit 
                114 111 59 19 Move: X-Max-Edit 
                Handle: Winfont SetFont: X-Max-Edit 

                self Start: Y-Max-Edit 
                114 134 59 18 Move: Y-Max-Edit 
                Handle: Winfont SetFont: Y-Max-Edit 

                self Start: X-Labl-Edit 
                193 111 223 19 Move: X-Labl-Edit 
                Handle: Winfont SetFont: X-Labl-Edit 

                self Start: Y-Labl-Edit 
                195 134 221 16 Move: Y-Labl-Edit 
                Handle: Winfont SetFont: Y-Labl-Edit 

                self Start: Comment-Edit
                44 159 372 16 Move: Comment-Edit
                Handle: Winfont SetFont: Comment-Edit

                self Start: X-Linhed
                5 116 38 14 Move: X-Linhed
                Handle: Winfont SetFont: X-Linhed
                s" Label1" SetText: X-Linhed

                self Start: Y-Linhed
                5 136 37 16 Move: Y-Linhed
                Handle: Winfont SetFont: Y-Linhed
                s" Label2" SetText: Y-Linhed

                self Start: FootTxt
                5 158 32 17 Move: FootTxt
                Handle: Winfont SetFont: FootTxt
                s" Label3" SetText: FootTxt

                self Start: MIN-COLHED
                45 94 53 13 Move: MIN-COLHED
                Handle: Winfont SetFont: MIN-COLHED
                s" Label5" SetText: MIN-COLHED

                self Start: MAX-COLHED
                114 94 37 12 Move: MAX-COLHED
                Handle: Winfont SetFont: MAX-COLHED
                s" Label6" SetText: MAX-COLHED

                self Start: AUTO-COLHED
                169 93 25 14 Move: AUTO-COLHED
                Handle: Winfont SetFont: AUTO-COLHED
                s" Label7" SetText: AUTO-COLHED

                self Start: Curvelist
                7 253 412 234 Move: Curvelist
                Handle: Winfont SetFont: Curvelist

                self Start: X-Auto
                175 108 16 27 Move: X-Auto
                Handle: Winfont SetFont: X-Auto
                s" X-Auto" SetText: X-Auto

               
                self Start: Y-Auto
                175 130 16 25 Move: Y-Auto
                Handle: Winfont SetFont: Y-Auto
                s" Y-Auto" SetText: Y-Auto

                self Start: LBL-COLHED
                197 93 54 14 Move: LBL-COLHED
                Handle: Winfont SetFont: LBL-COLHED
                s" Label8" SetText: LBL-COLHED

                self Start: Hed-Edit
                46 221 169 17 Move: Hed-Edit
                Handle: Winfont SetFont: Hed-Edit

                self Start: Z-Edit 
                224 219 37 18 Move: Z-Edit
                Handle: Winfont SetFont: Z-Edit 

                self Start: Sel-Chk
                7 216 37 26 Move: Sel-Chk
                Handle: Winfont SetFont: Sel-Chk
                s" Sel-Chk" SetText: Sel-Chk

                self Start: Int-ON
                264 213 17 28 Move: Int-ON
                Handle: Winfont SetFont: Int-ON
                s" Int-ON" SetText: Int-ON

                self Start: Lin-ON
                283 214 15 26 Move: Lin-ON
                Handle: Winfont SetFont: Lin-ON
                s" Lin-ON" SetText: Lin-ON

                self Start: Symbl-Edit
                303 218 24 18 Move: Symbl-Edit
                Handle: Winfont SetFont: Symbl-Edit

                self Start: Color-Edit
                332 218 23 18 Move: Color-Edit
                Handle: Winfont SetFont: Color-Edit

                self Start: Z-Hed
                9 199 344 16 Move: Z-Hed
                Handle: Winfont SetFont: Z-Hed
                s" Label9" SetText: Z-Hed

                self Start: Clr-Spc-Bttn
                362 198 35 16 Move: Clr-Spc-Bttn


                self Start: Set-Spc-Bttn
                362 217 35 17 Move: Set-Spc-Bttn


                self Start: DATA-Pair-Lbl
                10 504 50 17 Move: DATA-Pair-Lbl
                Handle: Winfont SetFont: DATA-Pair-Lbl
                s" Label14" SetText: DATA-Pair-Lbl

                self Start: X-Edit
                68 504 105 17 Move: X-Edit
                Handle: Winfont SetFont: X-Edit

                self Start: Y-Edit
                189 504 108 18 Move: Y-Edit
                Handle: Winfont SetFont: Y-Edit

                self Start: Set-Point-Bttn
                304 505 43 18 Move: Set-Point-Bttn
                Handle: Winfont SetFont: Set-Point-Bttn
                s" Set-Point-Bttn" SetText: Set-Point-Bttn

                self Start: Del-Point-Bttn
                353 505 41 17 Move: Del-Point-Bttn
                Handle: Winfont SetFont: Del-Point-Bttn
                s" Del-Point-Bttn" SetText: Del-Point-Bttn

                self Start: ScrollDataSet
                400 495 18 30 Move: ScrollDataSet

                self Start: X-Value-Lbl
                68 491 72 11 Move: X-Value-Lbl
                Handle: Winfont SetFont: X-Value-Lbl
                s" Label15" SetText: X-Value-Lbl

                self Start: Y-Value-Lbl
                188 491 60 12 Move: Y-Value-Lbl
                Handle: Winfont SetFont: Y-Value-Lbl
                s" Label16" SetText: Y-Value-Lbl

                self Start: ScrollCurveList
                403 198 16 36 Move: ScrollCurveList

                self Start: Plot_Axes
                1 84 423 101 Move: Plot_Axes
                Handle: Winfont SetFont: Plot_Axes
                s" Plot_Axes" SetText: Plot_Axes

                self Start: Group_List
                1 184 424 348 Move: Group_List
                Handle: Winfont SetFont: Group_List
                s" Group_List" SetText: Group_List

                self Start: Cmd-Line
                44 64 259 19 Move: Cmd-Line
                Handle: Winfont SetFont: Cmd-Line

                self Start: Exec-Button
                3 64 34 18 Move: Exec-Button
                Handle: Winfont SetFont: Exec-Button
                s" Exec-Button" SetText: Exec-Button

                self Start: Select-CurveList
                308 63 55 24 Move: Select-CurveList
                Handle: Winfont SetFont: Select-CurveList
                s" Select-CurveList" SetText: Select-CurveList

                self Start: Select-DataSet
                366 65 56 20 Move: Select-DataSet
                Handle: Winfont SetFont: Select-DataSet
                s" Select-DataSet" SetText: Select-DataSet

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
                \ Insert your code here
                On_Done: super
                ;M

;Object
