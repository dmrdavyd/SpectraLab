needs DIALOGRC2.F

BEGIN-RESSOURCE SPLABDLG


 DS_MODALFRAME WS_POPUP OR WS_VISIBLE OR
 WS_CAPTION OR WS_SYSMENU OR
 TO STYLEFLAGS
 8  DIALOG-FONT    "MS Sans Serif"
    DIALOG-CAPTION "Text Entry Dialog Title"
 IDD_EDIT_DIALOG 105 180 240 42
 BEGIN-DIALOG
        ES_AUTOHSCROLL TO STYLEFLAGS
        IDD_EDIT_TEXT    5 23 60 12      EDITTEXT2
        IDOK             194 6 40 14   PUSHBUTTON2 "OK"
        IDCANCEL         194 23 40 14   PUSHBUTTON2 "Cancel"
        IDD_PROMPT_TEXT  6 13 178 10     LTEXT2      "Text Entry Prompt"
        IDB_OPTION       7  2 134 10     AUTOCHECKBOX2   ""
  END-DIALOG


END-RESSOURCE


