needs fdlg.f

ZSTRING QSTR
ZSTRING PSTR
ZSTRING OSTR

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Edit text dialog Class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class EditDialog    <Super  dialog

IDD_EDIT_DIALOG SPLABDLG find-dialog-id constant template

int szText
int szTitle
int szPrompt
int szDoit
int szCancel
int szOption
int OptionState

:M ClassInit:   ( -- )
                ClassInit: super
                here to szText    0 ,            \ null text string
                here to szTitle  ,"text"
                here to szPrompt ,"text"
                here to szDoit   ,"text"
                here to szCancel ,"text"
                here to szOption ,"text"
                ;M

:M On_Init:     ( hWnd-focus -- f )

                szTitle  count                          SetText: self
                szText   count IDD_EDIT_TEXT            SetDlgItemText: self
                szPrompt count IDD_PROMPT_TEXT          SetDlgItemText: self
                szOption c@
                if      szOption count IDB_OPTION       SetDlgItemText: self
                        OptionState    IDB_OPTION       CheckDlgButton: self
                        TRUE
                else    FALSE
                then                   IDB_OPTION       ShowDlgItem: self
                szDoit   count dup
                if       2dup  IDOK                     SetDlgItemText: self
                then     2drop
                szCancel count dup
                if       2dup  IDCANCEL                 SetDlgItemText: self
                then     2drop
                1 ;M

:M Start:       ( prompt_zstring option_zstring counted_text_buffer parent -- f )
                swap to szText
                swap to szOption
                swap to szPrompt
                template run-dialog
                ;M

:M On_Command:  ( hCtrl code ID -- f1 ) \ returns 0=cancel,
                                        \ returns 1=option-off
                                        \ returns 2=option-on
                case
                IDOK     of     szText 1+ max-handle 2 - IDD_EDIT_TEXT GetDlgItemText: self
                                szText c!
                                IDB_OPTION IsDlgButtonChecked: self
                                dup to OptionState
                                1
                                and 1+
                                end-dialog    endof
                IDCANCEL of     0        end-dialog    endof
                                false swap ( default result )
                endcase ;M

;Class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ definer      name         title       prompt        ok     cancel   Option
\                            text        text        text     text     text
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

EditDialog QueryDlg  "Query" "" "" "" ""

: getreal  \ value in floating stack, prompt in stack
    FDUP FLO2STR PUT: QSTR
    PUT: OSTR
    PUT: PSTR
    PSTR OSTR QSTR DATA-WINDOW start: QueryDlg
    dup
    if
      QSTR FBUF call STRING2EXT
      if FBUF F@ FSWAP FDROP then
    then
;

: getinteger { ival \ -- }
      PUT: OSTR
      PUT: PSTR
      ival s>d (D.)           \ integer to string conversion
      PUT: QSTR
      PSTR OSTR QSTR DATA-WINDOW start: QueryDlg
      dup
      if
       VAL: QSTR
       not if drop ival then
      else
       ival
      then
      swap
;

