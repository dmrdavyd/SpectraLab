: tool-bar-file s" TBAR-NOI.F " ;

: init-instrument
    0 to speccode
    0 to refnum
;

: Red-Button?
  key? if key 13 = else false then
;

: init-plugins
\ init_comctrls
\  init-instrument
\ START: Instrument-Controls
;

: close-plugins
\ bye-instrument
;
