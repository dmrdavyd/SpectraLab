\ *! Splab-CRT
\ *T Screen Output of Numerical Data and Textual Strings from SpectraLab Scripts
\ *S General Information
\ *P If necessary, SpectraLab scripts may display numerical and textual information in a special window,
\ ** so-called WinCRT window, which opens automaticaly upon executing any of display functions specified below.
\ ** Besides its specific WinCRT functions, SpectraLab also redefines the standard Forth \b.\d (dot), \bF.\d (F-dot)
\ ** and \bCR\d operators for output in WinCRT window instead of Forth console (which is hidden while runing SpectraLab).
\ ** It is done, in a part, for compatibility with programming examples found in Forth tutorials.
\ ** However, the words  \b."\d and  \b.(\d are not redefined and should not be used from SpectraLab.
\ ** Use TYPE$ operator instead.
\ *S Basics of Using Textual Strings in Forth
\ *P According to ANS Forth standard, textual strings are transfered to standard text output and processing
\ ** functions through the stack of integers as two numbers specifying the address in the memory where
\ ** the actual string is located and the length of this string. The standard word \bs"\d may be used to create
\ ** such a string. This word must be followed by a space, the string itself and a double-quote character (\b"\d),
\ ** which closes the string. Thus, the script \bs" Hello, World!" TYPE$"\d prints "Hello, World!" in the WinCRT
\ ** window. Upon executing this script, the operator \bs"\d allocates space in the memory, places the string there,
\ ** and then puts its address and length at the top of the stack. Then the operator TYPE$
\ ** (see its definition below) takes this information from the stack and prints the string in WinCRT window.
\ ** More information on operations with strings may be found in Forth tutorials and Win32Forth documentation
\ ** (see the respective sections of this Help).
\

NEEDS ZSTRINGS

ZSTRING &TMP$
CREATE &FTMP 10 ALLOT

: CRT_CLOSED ( -- / -- )
\ *G Checks the status of WinCRT window - returns TRUE if it is closed and FALSE othervise
   CRT_IS_ON -1 = not
;

: CRT ( -- / -- )
\ *G Opens WinCRT window
    CRT_IS_ON 1 = if call CRTCLRSCR depth if DROP then then
    call CRT_ON to CRT_IS_ON
;

: NOCRT ( -- / -- )
\ *G Closes WinCRT window
    call CRT_OFF not to CRT_IS_ON depth if DROP then
;


: ?i_ ( n1 / -- )
\ *G Types an integer in WinCRT window. The value is taken from the stack of integers.
    CRT_CLOSED if CRT then
    CALL CRTIWRITE depth if DROP then
;

: ?f_ ( F1 / -- )
( *G Types a floating point value in WinCRT window. The walue is taken from F-stack )
\ SpectraLab uses 10-byte reals (for compatibility with some instrument software )
    CRT_CLOSED if CRT then
    &FTMP F! &FTMP call CRTFWRITE depth if DROP then
;

: TYPE$ ( addr len / -- )
\ *G Types a string in WinCRT window. The string is in the stack (addr len)
    CRT_CLOSED if CRT then
    PUT: &TMP$  &TMP$ call CRTTYPE depth if DROP then
;

: XYTYPE$  ( addr len n1 n2 \ -- )
( *G Typees a string in WinCRT window at x and y coordinates given by n1 and n2)
   { ix iy \ -- }
   PUT: &TMP$
   CRT_CLOSED if CRT then
   &TMP$ ix iy call CRTTEXTOUT depth if DROP then
;

: CCR ( -- / -- )
\ *G Sends <Carriage Return> to WinCRT window (goes to the next line)
    CRT_CLOSED not if
     call CRTCR depth if DROP then
    then
;

: ?F ( F1 / -- )
\ *G Types a floating point value and goes to the next line
  ?f_ CCR ;

: ?I ( n1 / -- )
\ *G Writes an integer and goes to the next line
  ?i_ CCR ;

: ?S ( addr len / -- )
\ *G Types a string and goes to the next line
  TYPE$ CCR ;

: CLEARCRT ( -- / -- )
\ *G Clears WinCRT window
     CRT_CLOSED not if call CRTCLRSCR depth if DROP then then
;

Redefine ALSO DEFINITIONS
: . ( n1 / -- )
\ *G Synonim of ?i_ - redefines the standard "." function of WinForth
 ?i_ ;

: F. ( F1 / -- )
\ *G Synonim of ?i_ - redefines the standard "F." function of WinForth
  ?F_ ;

: CR ( -- / -- )
\ *G Equivalent of CCR - redefines the standart CR function of WinForth
   CCR ;





