NEEDS ZSTRINGS
NEEDS STRING$
NEEDS FLO2INT
NEEDS SPN_DEF
NEEDS NANS

\- textbox needs excontrols.f

20 constant max_par
32 constant max_models
FALSE value curfitopen

create nitmax 4 allot
create autolambda 4 allot
create lambda 10 allot
create accur 10 allot
create smin 10 allot
create nu 10 allot
create alpha 10 allot
create sm 10 allot
create lim 10 allot
create spsi 10 allot
create nit 4 allot
create way 4 allot
create fitglobal 4 allot
CREATE UU 10 ALLOT
CREATE ZZ 10 ALLOT
CREATE XX 10 ALLOT
0 value nmodes
\ * beginning of mode parameter block * \
create  modl cell allot
create  submodl cell allot
variable   ip
variable   nv
variable   CE
variable   sx
variable   mq
variable   D3
variable   np
create     pmin 10 allot
create     pmax 10 allot
create     u_prm 10 allot
create model_name$ MaxStringLength allot
create variant$   MaxStringLength allot
create modifier$   MaxStringLength allot
create par_name$  MaxStringLength max_par * allot
variable parmask
create models$  MaxStringLength max_models * allot
\ * end of mode parameter block * \


FALSE VALUE DER_

zstring pname$
1 value model_dd
1 value submodel_dd
create u_dd 10 Allot
0E0 u_dd F!

: par_name 1 - dup 0 < not over max_par < and if 256 * else drop 0 then par_name$ + ;
: modl_name 1 - dup 0 < not over max_models < and if 256 * else drop 0 then models$ + ;

: @p dup 0 < not over max_par > not and if 10 * else drop 0 then psi + F@ ;
: !p dup 0 < not over max_par > not and if 10 * else drop 0 then psi + F! ;
: @f dup 0 < not over max_par > not and if 10 * else drop 0 then fnd + F@ ;
: !f dup 0 < not over max_par > not and if 10 * else drop 0 then fnd + F! ;

: clearprm curdir.fitrec @ call clearfitprm ;

: prmvalid  \  ---  parameters_are_valid
    True
     np @ 1 + 1 do
      i @p IsNAN10 if drop false leave then
     loop
;

: FUN
\ function opti_fun(mode_,submode_,der_:longint; var x_,z_,u_:extended;
\             var psi,fnd:partype):longint; export; stdcall;
   xx F!
   fnd
   psi
   u_prm
   @FZ: curdir
   ZZ
   F!
   ZZ
   xx
   FALSE
   submodl @
   modl @
   call opti_fun dup if 0 @f then
;

: refresh-data-table
    curdir call _PrmReady if
      SetDataList: Data-Window
    then
;

: curfit-init
  100 nitmax !
  -1 autolambda !
   1E0 lambda F!
   1E-2 accur F!
   2E-2 smin F!
   2E0 nu F!
   5E-2 alpha F!
   1E-1 sm F!
   2E-1 lim F!
   0E0 spsi F!
   0 nit !
   0 way !
   0 fitglobal !
   splabdir$ nitmax
   call read_optiprm drop
   2 modl !
   2 submodl !
   0 ip !
   0 nv !
   -1 CE !
   0 sx !
   1 mq !
   0 d3 !
   3 np !
   0e0  pmin F!
   0e0  pmax F!
   0e0  u_prm F!
   splabdir$ modl
   call optini to nmodes
   modl call CurfitInit drop
;

: setmodel
    0 call setmode drop
    submodl @ 0 = if 1 submodl ! then
    modl @ to model_dd
    submodl @ to submodel_dd
    curdir call newfitprm44 not if clearprm then
    obj @ PutDdir
;

: build   { npts locn -- }
  Ftmp F!
  Ftmp1 F!
  curdir.fitrec @ Ftmp1 Ftmp  locn npts
   call _build
;

: build-dlg  { \ keepmodl -- }
    modl @ to keepmodl
    s" Min. X-axis value:" s" " xmin F@ getreal
    not if exit then
    s" Max. x-axis value:" s" " xmax F@ getreal
    not if exit then
    s" Number of data points:" s" " 256 getinteger
    not if drop exit then
    dup 1 > not if drop exit then
    dup maxpoints > if drop maxpoints then
    keepmodl modl !
    $ build
    $ getddir
    SetCurveList: Data-Window
    SetListEdit: Splab-Window
    1 to pnt_ptr
    SetDataEdit: Splab-Window
    $ to last-obj
    $ plot
;

: GET_ESTIMATES
       clearprm
       fitpath call _get_estimates
       obj @ getddir
;

INCLUDE Estima-frm
INCLUDE SetPrm-Frm

: Check_PRM_Alloc
     curdir call newfitprm44 drop
     obj @ putddir
;

: SET_ESTIMATES
    Check_PRM_Alloc
    Start: estima-frm
;

: Wait-For-Estimates { untildone \  hwnd mess wparm lparm time pt.x pt.y -- }
      SET_ESTIMATES
      Begin
        0 0 0 &of hwnd call GetMessage
        if &of hwnd handlemessages drop then
        untildone if
          estimates-done 0 > not
        else
          estimates-done 0=
        then
      While
      Repeat ;


: Run_Build
      Check_PRM_Alloc
      False to allow-get-estimates
      FALSE Wait-for-estimates
      estimates-done 1 = not if build-dlg then
      True to allow-get-estimates
;

: PREPARE-OPTI
     Check_PRM_Alloc
     curdir call _PrmReady
     NOT
     if
       TRUE Wait-For-Estimates
       estimates-done 1 > if
         call compute_average
         TRUE
       else
         FALSE
       then
     else
       call compute_average
       TRUE
     then
;



: RUN_SIMPLEX
    PREPARE-OPTI if
     SPSI FND PSI call simplex
     SPSI F@ ISNAN10 not if
       obj @ getddir
       Plot-results
     then
    then
;

: RUN_MARQUARDT
    PREPARE-OPTI if
     SPSI FND PSI call marquar
     SPSI F@ ISNAN10 not if
       obj @ getddir
       Plot-results
     then
    then
;

: RUN_OPTI
     TRUE Wait-For-Estimates
     estimates-done 1 > if
       call compute_average
       SPSI FND PSI call optimize
       SPSI F@ ISNAN10 not if
         obj @ getddir
         Plot-results
       then
     then
;

:Object CurfitWindow                <Super DialogWindow

Font WinFont           \ default font
Font Emphasize           \ title font
ColorObject FrmColor      \ the background color
FALSE value Lock
label LblFittingModel
label LblModels  \ Label
label LblCase
label LblPrm
TextBox TextCase  \ TextBox
TextBox TextPrm
PushButton ApplyChanges
PushButton BttnRun
PushButton BttnEstimates
PushButton BttnSimplex
PushButton BttnMarqrdt
PushButton BttnBuild
PushButton BttnSetup
ComboBox ListOfModels
CheckBox GlobalCheck
175 value ypos
150 value xpos

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

\ :M WindowStyle:  ( -- style )
\                WS_POPUPWINDOW WS_DLGFRAME or
\                ;M

:M SetXYpos:
    to ypos
    to xpos
;M

:M ExWindowStyle: ( -- style )
                ExWindowStyle: SUPER
                ;M

:M WindowStyle: ( -- style )
                WindowStyle: SUPER
                WS_BORDER OR
                WS_OVERLAPPED OR
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
                XPos YPos
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M SetListOfModels:
0 0 CB_RESETCONTENT GetID: ListOfModels SendDlgItemMessage: self drop
   0 begin
       1+
       dup nmodes > NOT WHILE
       dup modl_name 1+ 0 CB_ADDSTRING GetID: ListOfModels SendDlgItemMessage: self drop
     repeat
     drop
     0 modl @ 1- CB_SETCURSEL GETID: ListOfModels SendDlgItemMessage: self
;M

:M Set_Controls:
                28 16 463 16 Move: LblFittingModel
                model_name$ count SetText: LblFittingModel
                28 80 301 15 Move: LblCase
                ip @ 0 = not if modifier$ else variant$ then count
                SetText: LblCase
                28 110 144 16 Move: LblPrm
                ip @ 0 = if modifier$ count else s" " then SetText: LblPrm
                ip @ 0 = not nv @ 0 = not or if
                  374 77 20 20 Move: TextCase
                  submodl @
                  nv @ 0 = not if abs then
                  str$ SetText: TextCase
                 else
                   0 0 0 0 Move: TextCase
                then
                ip @ 0 = modifier$ count swap drop 0 = not and if
                  322 106 72 20  Move: TextPrm
                  u_prm F@ FDUP isnan10 if fdrop F1.0 fdup u_prm F! then
                  FLO2STR SetText: TextPrm
                else
                  0 0 0 0 Move: TextPrm
                then
                SetListOfModels: self
                142 42 253 142 Move: ListOfModels
                415 44  75 20 Move: GlobalCheck
                s" Global fit" SetText: GlobalCheck
                FitGlobal @ IF 1 ELSE 0 THEN GetID: GlobalCheck CheckDlgButton: self
;M

:M Toggle_Global:
   FitGlobal @ NOT FitGlobal !
   FitGlobal @ GetID: GlobalCheck CheckDlgButton: self
;M


:M Get_Values:
               ip @ 0 = modifier$ count swap drop 0 = not and if
                 GetText: TextPrm
                 STR2FLO if
                    FDUP PMIN F@ F<
                    FDUP PMAX F@ F>
                    OR
                    if
                      fdrop U_dd F@
                    then
                  else U_dd F@ then
                  FDUP u_dd F!
                  FLO2STR
                  SetText: TextPrm
                then
                ip @ 0 = not nv @ 0 = not or if
                 GetText: TextCase
                    STR2FLO if
                    F2I
                    nv @ 0 = not if
                      dup 1 <
                      dup nv @ >
                      or
                    else
                      dup pmin F@ F2I <
                      over dup pmax F@ F2I >
                      swap 0=
                      or or
                    then
                    if
                      drop submodel_dd
                    then
                  else submodel_dd then
                  dup to submodel_dd
                  STR$
                  SetText: TextCase
                then
\                GetID: GlobalCheck IsDlgButtonChecked: self FitGlobal !
                ;M

:M On_Init:     ( -- )
                FALSE to Lock
                s" Microsoft Sans Serif" SetFaceName: WinFont
                7 Width: WinFont
                Create: WinFont drop

                s" System" SetFaceName: Emphasize
                10 Width: Emphasize
                Create: Emphasize drop

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor

                self Start: LblFittingModel
                Handle: Emphasize SetFont: LblFittingModel

                self Start: LblModels
                Handle: Winfont SetFont: LblModels
                28 48 100 20 Move: LblModels
                s" Fitting model:" SetText: LblModels

                self Start: LblCase
                Handle: Winfont SetFont: LblCase

                self Start: LblPrm
                Handle: Winfont SetFont: LblPrm

                self Start: TextCase
                Handle: Emphasize  SetFont: TextCase

                self Start: TextPrm
                Handle: Emphasize SetFont: TextPrm

                CBS_DROPDOWNLIST CBS_NOINTEGRALHEIGHT or AddStyle: ListOfModels
                self Start: ListOfModels

                self Start: ApplyChanges
                Handle: Winfont SetFont: ApplyChanges
                417 80 77 40 Move: ApplyChanges
                s" Apply" SetText: ApplyChanges

                self Start: BttnRun
                16 140 72 30 Move: BttnRun
                Handle: Winfont SetFont: BttnRun
                s" Run" SetText: BttnRun

                self Start: BttnEstimates
                96 140 72 30 Move: BttnEstimates
                Handle: Winfont SetFont: BttnEstimates
                s" Estimates" SetText: BttnEstimates

                self Start: BttnSimplex
                176 140 72 30 Move: BttnSimplex
                Handle: Winfont SetFont: BttnSimplex
                s" Simplex" SetText: BttnSimplex

                self Start: BttnMarqrdt
                256 140 72 30 Move: BttnMarqrdt
                Handle: Winfont SetFont: BttnMarqrdt
                s" Marquardt" SetText: BttnMarqrdt

                self Start: BttnBuild
                336 140 72 30 Move: BttnBuild
                Handle: Winfont SetFont: BttnBuild
                s" Build" SetText: BttnBuild

                self Start: BttnSetup
                416 140 72 30 Move: BttnSetup
                Handle: Winfont SetFont: BttnSetup
                s" Setup" SetText: BttnSetup

                self Start: GlobalCheck
                Handle: Winfont SetFont: GlobalCheck

                Set_Controls: self

                ;M


:M Accept_Values:
          GET_Values: self
          submodl @ submodel_dd = not
          U_dd F@ u_prm F@ F- 1e6 F*
          F2I 0= not
          or
          if
            submodel_dd submodl !
            U_dd F@ u_prm F!
            setmodel drop
          then
          D3 @ FITGLOBAL @ NOT and if Toggle_Global: Self then
          Set_Controls: self
;M

:M OnEstimates:
                  lock not if
                   TRUE to lock
                   Accept_Values: self
                   SET_ESTIMATES
                   refresh-data-table
                   FALSE to lock
                  then
;M

:M ChkModel:
                    0 0 CB_GETCURSEL GETID: ListOfModels SendDlgItemMessage: self
                    1+ dup to model_dd
                    modl @ = not if
                     curdir.fitrec @ call clearfitprm
                     model_dd modl !
                     0 submodl !
                     setmodel
                     D3 @ FITGLOBAL NOT and if Toggle_Global: Self then
                     Set_Controls: self
                    then
;M

:M SetModelList:
                  modl @ to model_dd
                  0 modl @ 1- CB_SETCURSEL GETID: ListOfModels SendDlgItemMessage: self
;M

:M WM_COMMAND  ( h m w l -- res )
                over LOWORD ( ID )
                case
                 GETID: ApplyChanges of
                   lock not if
                    TRUE to lock
                    modl @ model_dd = not if
                       curdir.fitrec @ call clearfitprm
                       model_dd modl !
                       0 submodl !
                       setmodel
                       D3 @ FITGLOBAL NOT and if Toggle_Global: Self then
                       Set_Controls: self
                    else
                       Accept_Values: self
                    then
                    FALSE to lock
                   then
                 endof
                 GETID: BttnRun  of
                   lock not if
                    TRUE to lock
                    Accept_Values: self
                    RUN_OPTI
                    refresh-data-table
                    FALSE to lock
                    Close: Self
                   then
                 endof
                 GETID: BttnEstimates of
                    OnEstimates: self
                 endof
                 GETID: BttnSimplex of
                   lock not if
                    TRUE to lock
                    Accept_Values: self
                    Run_Simplex
                    refresh-data-table
                    FALSE to lock
                    Close: Self
                   then
                 endof
                 GETID: BttnMarqrdt of
                   lock not if
                    TRUE to lock
                    Accept_Values: self
                    Run_Marquardt
                    refresh-data-table
                    FALSE to lock
                    Close: Self
                   then
                 endof
                 GETID: BttnBuild of
                   lock not if
                    TRUE to lock
                    curdir.npts 0 > if
                       call confirm
                       1 = if
                         clear&keepz
                       else
                         FALSE to lock
                      then
                    then
                    lock if
                      Accept_Values: self
                      Run_Build
                      FALSE to lock
                    then
                    Close: Self
                   then
                 endof
                 GETID: BttnSetup of
                    Start: SetPrm-Frm
                 endof
                 GETID: ListOfModels of
                   lock not if
                    TRUE to lock
                    chkmodel: self
                    FALSE to lock
                   then
                 endof
                 GETID: GlobalCheck of
                    Toggle_Global: Self
                 endof
                endcase
                over LOWORD
                dup GETID: ListOFModels =
                swap GETID: ApplyChanges =
                or not if SetModelList: self then
0 ;M


\ :M WM_SYSCOMMAND ( hwnd msg wparam lparam -- res )
\                over 0xF000 and 0xF000 <>
\                IF      over LOWORD
\                        DoMenu: CurrentMenu
\                        0
\                ELSE    DefWindowProc: [ self ]
\                THEN    ;M


:M Refresh:
                         Set_Controls: self
;M


:M SetCommand:  ( cfa -- )  \ set WMCommand function
                drop
\                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
     begin depth 0 > while drop repeat
     Delete: WinFont
     Delete: Emphasize
     originx to xpos
     originy to YPos
     ^splabdir$ @ call write_optiprm
     On_Done: super
;M

;Object

: Curfit
 false to curfitopen
 start: curfitwindow
 begin key? drop curfitopen not until
;


\ Curfit

