\ *! SpecArithm
\ *T SpectraLab Scripting Language
\ *S General overview
\ *W </i></h3><p>The user interface of SpectraLab is written in Forth (<a href="http://win32forth.sourceforge.net/">Win32Forth</a>),
\ ** an extensible interactive stack-based language, which allows
\ ** the user to write and execute custom pieces of code "on the fly". To do so in SpectraLab, one should write a sequence of Forth commands
\ ** in the command line edit box found below the main toolbar in the Splab-Controls pane. Pressing the <Enter> key on the keyboard or
\ ** clicking on the "Exec" button next to the command line box will cause the entered command to execute.
\ *P The commands (scripts) should be written according to the general rules of the Forth programming language with the use of either standard
\ ** operators of Win32Forth or SpecrtraLab-specific operators (to be described below). The very basics of organizing Forth expressions
\ ** will be described below.
\ *P More detailed information on Forth programming including several Forth tutorials, Win32Forth reference, and a description of
\ ** ANS Forth standard may be found in "Forth and its use in SpectraLab" section of this Help.
\ *S The basic information about the principles of Forth Programming
\ ** Below is what SpectraLab user has to know in order to write their own Forth-based scripts:
\ *B Forth is a stack-based language. There are two separate data stacks in the basic WinForth: the stack of integer (natural) numbers
\ ** and the stack of the floating-point (real) numbers.
\ ** When Forth interpreter encounters a number in the command line, it places it into the stack that corresponds to the type of the number:
\ ** integers (entered as "-1", "0", "1", "100", "999", etc.) are placed into the stack of integers and the real numbers
\ ** (entered as "0.0" or "0.", "3.1415926", or "6.0221408E23", etc.) will be placed into the floating-point stack.
\ *B If necessary, the real numbers can be converted into integers and vice versa. For this purpose, we use "f2i" and "i2f" commands, respectively.
\ ** Thus, the command \b2.1 f2i\d is equivalent to simply \b2\d: the real number 2.1 will be placed into the
\ ** stack of real numbers, but upon executing the operator "f2i", it will be rounded to 2 and moved into the stack of integers.
\ ** Similarly, \b2 i2f\d will result in placing 2.0 into the stack of real numbers, thus being an equivalent of \b2.0\d.
\ *B Arithmetic expressions in Forth are written in so-called "Reverse Polish Notation". It means that the operands of any mathematical operation
\ ** \iprecede\d the operator (i.e., a sign of an arithmetic operation or a name of a mathematical function). In practice, when the Forth interpreter
\ ** encounters an arithmetic operator ("+", "-", "/" or "*"),
\ ** it takes the two uppermost values from the data stack and performs the requested operation on them. These former operands are now removed from
\ ** the stack and the result is placed at the top instead.
\ *B Note, that the operators "+", "-", "/" and "*" are applied to the stack of integers (and the result is also placed in the same stack).
\ ** For operations with real numbers, the operators "F+", "F-", "F/" and "F*" are used instead. In this case, the operands will be taken from
\ ** the stack of real numbers, and the result will be found in the same (floating-point) stack.
\ *B To display numeric results of the computation in SpectraLab, we use "?I" and "?F" operators (for more details about text output in SpectraLab,
\ ** see "CRT commands in SpectraLab" page).
\ ** Thus, entering\n \b2 6 + 2 / ?I\d will display 4 ( (2+6)/2=4) in the CRT window (a separate window that will be opened automatically).
\ ** Entering \b2.0 5.0 F* 3E0 F/ ?F\d will result in displaying "3.333333" \n (2*5/3=3.333333) in the CRT window.
\ *P Besides arithmetic operators mentioned above, there are several operators on the stacks useful in writing mathematic expressions.
\ ** The pairs of operators listed in the first and the second columns of the table below operate on the stacks of natural and floating-point numbers,
\ ** respectively:
( *L |c||c|l|                                                                                                  )
( *| \bStack of integers\d | \bFloating-point stack\d | \bPerformed operation\d                           |    )
( *| SWAP                | FSWAP                | Swaps the top two layers of the stack: n1 n2 -> n2 n1   |    )
( *| DROP                | FDROP                | Drops the top layer: n1 n2 -> n1                        |    )
( *| DUP                 | FDUP                 | Duplicates the top layer: n1 -> n1 n1                   |    )
( *| 2DUP                | F2DUP                | Duplicates the two topmost layers: n1 n2 -> n1 n2 n1 n2 |    )
( *| OVER                | FOVER                | Copies the second layer to the top: n1 n2 -> n1 n2 n1   |    )
( *| ROT                 | FROT                 | Rotates the three top layers: n1 n2 n3 -> n2 n3 n1      |    )
\ *P Similar operators (#SWAP, #DUP, etc.) are also defined for the operations on the stack of traces (see below).
\ ** Note that attempts to apply floating-point operations to integers and vice versa will result in a "Stack underflow" error.
\ *S SpectraLab-specific stack of traces and its use
\ *P In addition to the Forth-native stacks of integers and floating-point numbers, SpectraLab also uses its customary-defined stack of traces (spectra)
\ ** for operations on the whole traces.
\ *B The SpectraLab-specific stack of traces is used for mathematical operations on traces (spectra, kinetic traces, or other two-dimensional datasets).
\ ** All trace-specific operators start with the pound sign (like "#+", #-", etc.). To place a trace into the stack, we use " \in\d #:" notation,
\ ** where "\in\d" is the number of
\ ** the trace. To put a trace from the stack to the desired location one should enter "\in\d #!", where \in\d is the desired destination.
\ ** Thus, entering
\ ** \b1 #: 5 #!\d  will copy trace #1 into location #5. In these expressions, the dollar sign ("$") can be used as the number of the current position
\ ** of the cursor line in the SpectraLab data window.
\ ** Thus, the script \b$ #: $ 1 + #!\d will copy the trace under the cursor to the next location (i.e., if the line-cursor is at line 1,
\ ** the trace #1 will be copied to location #2).
\ *B To move the trace cursor up and down, we use "inc" and "dec" operations. "Inc" moves the line-cursor one line down, and "dec" moves it one line up. .
\ *B Arithmetic operations with abscissa and ordinate of traces are invoked by operators "#X+", "#X-", "#X*", "#X/" and "#Y+", "#Y-", "#Y*", "#Y/",
\ ** respectively.
\ ** In the case of operations on the ordinate, the letter "Y" may be omitted: "#+", "#-", #*" and "#/" are equivalents of "#Y+", "#Y-", "#Y*", "#Y/".
\ ** The same operators are used for both the operations on two traces and those on a trace and a real number:
\ ** if the stack of real numbers is empty, these operations are applied to the two topmost traces in the trace stack. However,
\ ** if there is a number in the stack of reals, these operations will be applied to the topmost trace in the stack of traces and a topmost number
\ ** in the stack of reals.
\ ** For example, the command \b1 #: 2 #: #+ 3 #!\d will summarize the traces #1 and #2 and place the result into location #3. Upon execution of
\ ** the command
\ ** \b1 #: 2 #: 2.0 #* #+ 3 #!\d , the trace #2 will be first multiplied by 2, and than trace #1 will be added to the result of multiplication.
\ ** The resulting sum of two traces #2 and one trace #1 will be placed at location #3.
\ *B To access individual data points in the traces (spectra) we use "\in1 n2\d X::" and "\in1 n2\d Y::" notations. Here \in1\d and \in2\d are
\ ** the number of the trace and the number of a specific point in it.
\ ** Upon the execution of "X::" and "Y::" operators, the respective values of abscissa ("X::") or ordinate("Y::) of the point specified by \in1\d
\ ** and \in2\d will be placed into the stack of reals. Thus, the command \n\b$ 1 X:: ?F $ 1 Y:: ?F\d will display the values of the abscissa
\ ** and ordinate of the trace under the cursor line in the CRT window.
\ *B To repeat the execution of a sequence of commands entered in the command line, one should start it with the operator "do(\in\d)", where \in\d
\ ** is the number of desired repeats. Thus, the command \bdo(20) inc\d will move the cursor line 20 position down.
\ ** Note that \in\d in the cycle operator should be an explicitly written integer number. In other words, arithmetic operations or the names
\ ** of variables inside parentheses in the cycle operator are not allowed. The construct "do(\in\d)" is command-line-specific -
\ ** it can be used only at the beginning of the Spectralab command line. It is not applicable in multi-line scripts (user-defined Forth words).
\ *S Glossary of SpectraLab-specific operators that can be used in command-line scripts
\ *B Each glossary entry below is followed by three expressions separated by semicolons and placed in parentheses.
\ ** These expressions stand for the contents of the integer, floating-point, and trace stacks (respectively) before and after executing
\ ** the respective command. Expression to the left of the slash shows the initial content of the stack. The content of the stack
\ ** after executing the operator is shown after the slash. Double dash sign stays for no parameters in the stack required
\ ** at input or returned at output. Parameters shown in the angle brackets (<>) are optional and may be omitted
\ ** in some cases (see descriptions of the respective glossray entries).

NEEDS FLO2INT
CREATE XSTART 10 ALLOT
CREATE XEND 10 ALLOT
CREATE XDELTA 10 ALLOT
0 VALUE &K
0 VALUE &J
0 VALUE &I
0 VALUE &NP
0 VALUE &UU
0 VALUE &ZZ

: #: ( n / -- ; -- / -- ; -- / #n)
\ *G Places the  trace #n into the stack of traces
     depth 0= not if call _push_ drop then ;
: #! ( n / -- ; -- / -- ; #A / -- )
\ *G Places the trace from the top of the stack of traces into location #n
     depth 0= not if call _pull_ drop then ;
: Y:: ( n1 n2 / -- ; -- / Y[n1,n2] ; -- / -- )
\ *G Returns the ordinate value of the point \in2\d from the trace \in1\d. The result is placed at the top of the stack of reals.
    call gety S2E
;
: X:: ( n1 n2 / -- ; -- / X[n1,n2] ; -- / -- )
\ *G Returns the abscissa value of the point \in2\d from the trace \in1\d. The result is placed at the top of the stack of reals.
    call getx S2E
;
: !Y:: ( n1 n2 / -- ; NEWY / -- ; -- / -- )
    { \ curloc# pt# }
    to pt#
    $ to curloc#
    chgddir
    pt# 1 - pushy: curdir
    curloc# chgddir
;
: !X:: ( n1 n2 / -- ; NEWY / -- ; -- / -- )
    { \ curloc# pt# mem# }
    to pt#
    $ to curloc#
    chgddir
    pt# 1 - pushX: curdir
    curloc# chgddir
;
: Z: ( n1 / -- ; -- / Z ; -- / -- )
\ *G Returns the "Z-value" associated with the trace \in1\d. The result is placed at the top of the stack of reals.
    call getz S2E
;
: !Z: ( n1 / -- ; -- / Z ; -- / -- )
\ *G Assigns the topmost value from the stack of reals to the "Z-value" associated with the trace \in1\d.
   E2S
   call putz
;
: @Z ( -- / -- ; -- / Z ; -- / -- )
\ *G Returns the "Z-value" associated with the current trace (trace under the cursor-line). The result is placed at the top of the stack of reals.
   obj @ getddir @FZ: curdir ;
: !Z ( -- / -- ; Z / -- ; -- / -- )
\ *G Assigns the topmost value from the stack of reals to the "Z-value" associated with the current trace (trace under the cursor-line).
   !FZ: curdir obj @ putddir ;
: #X+ ( -- / -- ; <F1> / -- ; #A <#B> / #C)
\ *G If the stack of reals is empty, this operation adds the abscissa of trace #A to the abscissa of trace #B.
\ ** Otherwise, it adds the value taken from the stack of reals (F1) to the abscissa of the trace at the top of the stack.
     FDEPTH 0= if NAN10 F@ then E2S 0 call _plus_  drop ;
: #Y+ ( -- / -- ; <F1> / -- ; #A <#B> / #C )
\ *G If the stack of reals is empty, this operation adds the ordinate of trace #A to the ordinate of trace #B.
\ ** Otherwise, it adds the value taken from the stack of reals (F1) to the ordinate of the trace at the top of the stack.
     FDEPTH 0= if NAN10 F@ then E2S -1 call _plus_ drop ;
: #X- ( -- / -- ; <F1> / -- ; #A <#B> / #C )
\ *G If the stack of reals is empty, this operation subtracts the abscissa of trace #A from the abscissa of trace #B.
\ ** Otherwise, it subtracts the value taken from the stack of reals (F1) from the abscissa of the trace at the top of the stack.
     FDEPTH 0= if NAN10 F@ then E2S 0 call _minus_ drop ;
: #Y- ( -- / -- ; <F1> / -- ; #A <#B> / #C )
\ *G If the stack of reals is empty, this operation subtracts the ordinate of trace #A from the ordinate of trace #B.
\ ** Otherwise, it subtracts the value taken from the stack of reals (F1) from the ordinate of the trace at the top of the stack.
     FDEPTH 0= if NAN10 F@ then E2S -1 call _minus_ drop ;
: #X* ( -- / -- ; <F1> / -- ; #A <#B> / #C )
\ *G If the stack of reals is empty, this operation multiples the abscisses of traces #A and #B.
\ ** Otherwise, it multiplies the abscissa of the trace at the top of the stack by the value taken from the stack of reals (F1)
    FDEPTH 0= if NAN10 F@ then E2S 0 call _multiply_ drop ;
: #Y* ( -- / -- ; <F1> / -- ; #A <#B> / #C )
\ *G If the stack of reals is empty, this operation multiples the ordinates of traces #A and #B.
\ ** Otherwise, it multiplies the ordinate of the trace at the top of the stack by the value taken from the stack of reals (F1)
     FDEPTH 0= if NAN10 F@ then E2S -1 call _multiply_ drop ;
: #X/ ( -- / -- ; <F1> / -- ; #A <#B> / #C )
\ *G If the stack of reals is empty, this operation divides the abscissa of trace #B by the abscissa of trace #A.
\ ** Otherwise, it divides the abscissa of the trace at the top of the stack by the value taken from the stack of reals (F1)
     FDEPTH 0= if NAN10 F@ then E2S 0 call _divide_ drop ;
: #Y/ ( -- / -- ; <F1> / -- ; #A <#B> / #C )
\ *G If the stack of reals is empty, this operation multiplies the ordinata of trace #B by the ordinata of trace #A.
\ ** Otherwise, it multiplies the ordinata of trace at the top of the stack by the value taken from the stack of reals (F1)
     FDEPTH 0= if NAN10 F@ then E2S -1 call _divide_ drop ;
: #+
\ *G An equivalent of #Y+
  #Y+ ;
: #-
\ *G An equivalent of #Y-
  #Y- ;
: #*
\ *G An equivalent of #Y*
  #Y*  ;
: #/
\ *G An equivalent of #Y/
  #Y/ ;

: #SWAP ( -- / -- ; -- / -- ; #A #B / #B #A )
\ *G Swaps two traces at the top of the stack of traces
     call _swap_ drop ;
: #ROT  ( -- / -- ; -- / -- ; #A #B #C / #B #C #A)
\ *G Rotates three traces at the top of the stack of traces
     call _rot_ drop ;
: #DROP ( -- / -- ; -- / -- ; #A / -- )
\ *G Drops the topmost trace in the stack of traces
     call _drop_ drop ;
: #DUP ( -- / -- ; -- / -- ; #A / #A #A )
\ *G Duplicates the trace at top of the stack of traces
     call _dup_ drop ;
: #OVER ( -- / -- ; -- / -- ; #A #B / #A #B #A )
\ *G Copies the second trace from the top to the top of the stack
     call _over_ drop ;
: #LOGX ( -- / -- ; -- / -- ; #A / #LOGX[#A] )
\ *G Calculates the natural logarithm of abscissa of the trace at the top of the stack of traces (the original trace is not changed).
\ ** The result is placed at the top of the stack.
     FALSE call _log_ drop ;
: #LOGY ( -- / -- ; -- / -- ; #A / #LOGY[#A] )
\ *G Calculates the natural logarithm of ordinate of the trace at the top of the stack of traces (the original trace is not changed).
\ ** The result is placed at the top of the stack.
      TRUE call _log_ drop ;
: #ABSX ( -- / -- ; -- / -- ; #A / #ABSX[#A] )
\ *G Calculates the absolute value of abscissa of the trace at the top of the stack of traces (the original trace is not changed).
\ ** The result is placed at the top of the stack.
     FALSE call _abs_ drop ;
: #ABSY ( -- / -- ; -- / -- ; #A / #ABSY[#A] )
\ *G Calculates the absolute value of ordinate of the trace at the top of the stack of traces (the original trace is not changed).
\ ** The result is placed at the top of the stack.
     TRUE call _abs_ drop ;
: #EXPX ( -- / -- ; -- / -- ; #A / #EXPX[#A] )
\ *G Calculates the exponential function of abscissa of the trace at the top of the stack of traces (the original trace is not changed).
\ ** The result is placed at the top of the stack.
     FALSE call _exp_ drop ;
: #EXPY ( -- / -- ; -- / -- ; #A / #EXPY[#A] )
\ *G Calculates the exponential function of ordinate of the trace at the top of the stack of traces (the original trace is not changed).
\ ** The result is placed at the top of the stack.
     TRUE call _exp_ drop ;
: #SMO ( <n> -- / -- ; -- / -- ; #A / #SMO[#A] )
\ *G Performs polynomial smoothing of the trace at the top of the stack (the original trace is not changed).
\ ** The size of the moving window is taken from the stack of integers.
\ ** The window size may vary from 3 to 21 points. For the 3-points window, a second-order polynomial is used. In all other cases,
\ ** the smoothing is with a 3-rd order polynomial.
\ ** If the width of the smoothing window is not specified (the stack of integers is empty), the 5-point smoothing is applied.
\ ** The result is placed at the top of the stack.
     depth 0= if 5 then
    2 / dup 0= if
       drop 1
    else
       dup 9 > if drop 9 then
    then
  call _smo_ drop ;
: #TRI ( <n> -- / -- ; -- / -- ; #A / #TRI[#A] )
\ *G Performs "triadic" (Tukey) smoothing of the trace at the top of the stack (the original trace is not changed).
\ ** The size of the moving window is taken from the stack of integers. The window size may vary from 3 to 7 points.
\ ** If the width of the smoothing window is not specified (the stack of integers is empty), the window of three points is used.
\ ** The result is placed at the top of the stack.
    depth 0= if 1 else 2 / dup 0= if drop 1 then then call _tri_  drop ;
: #DER1 ( -- / -- ; -- / -- ; #A / #DER1[#A] )
\ *G Calculates the first derivative of the trace at the top of the stack of traces (the original trace is not changed).
\ ** The result is placed at the top of the stack.
    1 call _der_ drop ;
: #DER2 ( -- / -- ; -- / -- ; #A / #DER1[#A] )
\ *G Calculates the second derivative of the trace at the top of the stack of traces (the original trace is not changed).
\ ** The result is placed at the top of the stack.
    2 call _der_ drop ;
: #DER
\ *G DER is a synonym of #DER2
  #DER2 ;
: #MEAN ( -- / -- ; -- / MEAN[#A] ; #A / -- )
\ *G Calculates the arithmetic mean of ordinate values of a trace. The result is placed at the top of the stack of reals.
    FTMP call ave_  drop FTMP F@ ;
: #AREA ( -- / -- ; -- / AREA[#A] ; #A / -- )
\ *G Calculates the area under the curve for a given trace. The result is placed at the top of the stack of reals.
    FTMP call area_  drop FTMP F@ ;
: #MINX ( -- / -- ; -- / MINX[#A] ; #A / -- )
\ *G Returns the minimal of all abscissa values of a given trace. The result is placed at the top of the stack of reals.
    FTMP FALSE call min_  drop FTMP F@ ;
: #MINY ( -- / -- ; -- / MINY[#A] ; #A / -- )
\ *G Returns the minimal of all ordinate values of a given trace. The result is placed at the top of the stack of reals.
    FTMP TRUE call min_  drop FTMP F@ ;
: #MAXX ( -- / -- ; -- / MAXX[#A] ; #A / -- )
\ *G Returns the maximal of all abscissa values of a given trace. The result is placed at the top of the stack of reals.
    FTMP FALSE call max_  drop FTMP F@ ;
: #MAXY ( -- / -- ; -- / MAXY[#A] ; #A / -- )
\ *G Returns the maximal of all ordinate values of a given trace. The result is placed at the top of the stack of reals.
    FTMP TRUE call max_  drop FTMP F@ ;
: #INVERT call matrix_invert
   0= if
      s" Error inverting matrix: check dimensions"
       put: ss$ ss$ call SplabErrorMessage
   then
;

: #TRUNC ( -- / -- ; FA / -- ; #A / #TRUNCY[#A,FA] )
\ *G "Truncates" the ordinata of trace #A at the value taken from the stack of reals (FA) in the meaning that
\ ** all values larger than FA will be replaced by FA
    FDEPTH 0= not if FBUF F! FBUF call _trunc_ drop then ;

\ *N The following words do not operate with the stacks of reals and traces. Hence, the expression in parentheses shows the content of the stack of natural numbers only:

: #DEPTH ( -- / n )
\ *G Returns the depth of the stack of traces (a number of traces in the stack)
     call _depth_ ;
: LOGX ( -- / -- )
\ *G Calculates the natural logarithm of abscissa of the current trace and REPLACES it with the result.
    $ #: #LOGX $ #! ;
: LOGY ( -- / -- )
\ *G Calculates the natural logarithm of ordinata of the current trace and REPLACES it with the result.
    $ #: #LOGY $ #! ;
: EXPX ( -- / -- )
\ *G Exponentiates the abscissa of the current trace and REPLACES it with the result.
  $ #: #EXPX $ #! ;
: EXPY ( -- / -- )
\ *G Exponentiates the ordinata of the current trace and REPLACES it with the result.
  $ #: #EXPY $ #! ;

: DER1 ( -- / -- )
\ *G Calculates the first derivative of the current trace and REPLACES it with the result.
  $ #: #DER1 $ #! ;

: DER2 ( -- / -- )
\ *G Calculates the second derivative of the current trace and REPLACES it with the result.
  $ #: #DER2 $ #! ;

: DER  ( -- / -- )
\ *G DER is a synonym of DER2
 DER2 ;

: @H ( -- / addr len )
\ *G Returns the header string of the current trace (the trace under line-cursor) as a pair of its
\ ** address and length
  obj @ getddir @header: curdir  ;
: !H ( addr len / -- )
\ *G Replaces the Header of the current trace (the thrace under line-cursor) with the string
\ ** taken from the stack. Example of usage: \bs" New title" @H\d
  !header: curdir obj @ putddir ;
: !comment ( addr len / -- )
\ *G Replaces the Comment string with the string taken from the stack. Example of usage: \bs" New comment" @H\d
  !footnote: xaxis ;
: @C ( n1 / --)
\ *G Sets the color of the current trace to that specified by the value taken from the stack (n1)
  obj @ getddir curdir.plotcolor ;
: !C ( -- / n1)
\ *G Returns the color of the current trace
  !color: curdir obj @ putddir ;
: !INTR ( n1 / -- )
\ *G Turns ON (n1<>0, or n1=TRUE) or OFF (n1=0 or n1=FALSE) interpolation between the points of the current trace
\ ** in the SpectraLab graph window.
  !inter: curdir obj @ putddir ;
: @INTR ( -- / n1 )
\ *G Returns the current settings of interpolation between the points of the current trace (0 if false, -1 if true).
\ ** in the SpectraLab graph window.
  obj @ getddir curdir.inter ;
: @CNCT ( -- / n1 )
\ *G Returns the current settings of interpolation between the points of the current trace (0 if false, -1 if true).
\ ** in the SpectraLab graph window.
  obj @ getddir curdir.connect ;
: !CNCT ( n1 / -- )
\ *G Turns ON (n1<>0, or n1=TRUE) or OFF (n1=0 or n1=FALSE) linear connection between the points of the current trace
\ ** in the SpectraLab graph window.
  !connect: curdir obj @ putddir ;
: ?SEL ( -- / n1 )
\ *G Returns TRUE (-1) if the current trace is selected for graphical display and FALSE (0) otherwise
  obj @ getddir curdir.plotcolor 0X80 and 0= ;
: !SEL ( -- / -- )
\ *G Marks the current trace as selected for graphical display
  curdir.plotcolor 0X7F and !color: curdir obj @ putddir ;
: #SEL ( -- / -- )
\ *G Marks the current trace as deselected for graphical display (hidden on the graph)
  curdir.plotcolor 0X80 or !color: curdir obj @ putddir ;
: DESELECT ( n1 / -- )
\ *G Marks n1 traces starting at the current position as deselected for graphical display (hidden in the graph)
  depth 0= if 1 then 0 do #sel inc loop ;
: SELECT ( n1 / -- )
\ *G Marks n1 traces starting at the current position as selected for graphical display
  depth 0= if 1 then 0 do !sel inc loop ;
: @M ( n1 / --)
\ *G Sets the graphical display symbol of the current trace to that specified by the value taken from the stack (n1)
  obj @ getddir curdir.symbol ;
: !M ( -- / n1 )
\ *G Returns the graphical display symbol of the current trace
  !symbol: curdir obj @ putddir ;
: !$ ( n --; --; -- / -- )
\ *G Moves the cursor-line to location n ( making it the "current location" )
     dup 1 < if drop 1 then
     dup Maxcur > if drop Maxcur then
     ChgDdir
  ;
\ : @$  !$ ;

: CLEAR ( n --; --; -- / -- )
\ *G Deletes the current trace (the trace under the cursor-line) )
   depth 0= if $ then
   dup
   call clearmem drop
   $ = if $ GetDdir then
;

: clear&keepz ( -- \ -- )
\ Clears the current trace, but keeps the Z-value associated with it
   @Z
   @H
   $ call clearmem drop
   $ GetDdir
   !H
   FDUP isnan10 if FDROP else !Z then
;

: DELETE_POINT ( pnt-num \ boolean )
\ deletes the point specified by pnt-num from the curren trace. Returns TRUE if successful,
\ FALSE otherwise (if the specified point does not exist)
   depth 0= if pnt_ptr then
   $ call delpnt
   dup if
     $ GetDdir
     $ call getn dup pnt_ptr < if to pnt_ptr else drop then
   then
;

: ?CLEARUP  { clrref \ l }
\ Deletes the current trace and all traces upwards of it. If "clrref" is FALSE (=0), the trace set as the
\ spectral reference is not deleted.
  $ to l
  begin
    l 0 > while
    l refnum <> clrref or if l clear then
    -1 +to l
  repeat
  1 GetDdir
;

: CLEARUP ( -- \ -- )
\ *G Deletes the current trace and all traces upwards of it
  true ?CLEARUP
;

: ~clearup ( -- \ -- )
\ Deletes the current trace and all traces upwards of it
\ except the trace set as the spectral reference.
  false ?clearup
;

: clearall ( -- \ -- )
\ *G Deletes all traces in the memory
  maxcur ChgDdir
  clearup
;

: ~clearall ( -- \ -- )
\ *G Deletes all traces in the memory
\ except the trace set as the spectral reference.
   maxcur ChgDdir
   ~clearup
;

\ *S Some examples of command-line scripts:
\ *B The following script calculates the average of three consecutive spectra starting at the current location, smooths the result
\ ** with 7-point polynomial smoothing, deletes the original spectra, and places the result at the current location (i.e., replaces the original):\n
\ ** \b            $ #: $ 1 + #: $ 2 + #: #Y+ #Y+ 3.0 #Y/ 7 #SMO $ #! $ 1 + clear $ 2 + clear\d\n
\ ** Note that in this script, "#Y+" and "#Y/" can be substituted with "#+" and #/" (they are equivalent). Below is another variant
\ ** of a script performing the same operations:\n
\ ** \b            $ #: inc $ #: inc $ #: #+ #+ $ clear dec $ clear dec 3.0 #/ 7 #SMO $ #!\d\n
\ *B Suppose that the line cursor is at trace #1 and the memory contains 20 consecutive spectra taken
\ ** during some process, and the Z-value of each spectrum is the time passed from the start of registration.
\ ** In this case, the following script will produce a kinetic curve of the changes at a wavelength corresponding to point #50 of the spectra.
\ ** The resulting curve will be placed at location #21 \n
\ ** \b            do(20) $ 50 Y:: 21 $ !Y:: @Z 21 $ !X:: inc\d\n
\ ** Another variant of the same script, where we use 2DUP operator (ANSI Forth standard word, which duplicates the two tompost layers
\ ** of the stack of integers):\n
\ ** \b            do(20) @Z $ 50 Y:: 21 $ 2DUP !Y:: !X:: inc\d\n
\ *B The following script converts the current trace (the one under the cursor line) into its double-reciprocal
\ ** (Lineweaver-Burk) transform and places the result into the location next to the current:\n
\ ** \b            $ #: #LOGY -1.0 #Y* #EXPY #LOGX -1.0 #X* #EXPX $ 1 + #!\d\n
\ ** Note that in this example, in order to obtain reciprocal values of the trace's points, we calculated a logarithm of each axis,
\ ** multiplied it by -1 (should be entered as a real number: -1., -1.0 or -1E0), and exponentiated the result back.
\ ** This is the only way to calculate reciprocal values of a trace (since there is no operator that divides a number by a trace defined in SpectraLab).


INCLUDE CIPSUBSTITUTES
