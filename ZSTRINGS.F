\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\               Define data type class for strings
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
256 constant MaxStringLength

:Class ZString   <Super Object

MAXSTRING bytes theBuffer
(( : deletechar (n -- )
    thebuffer count ))
:M Get:         ( -- a1 n1 ) theBuffer  count ;M
:M Put:         ( a1 n1 -- ) theBuffer  place thebuffer +null ;M
:M Put$:        ( a1 n1 -- ) count theBuffer  place thebuffer +null ;M
:M LEN:                      thebuffer count swap drop ;M
:M Add:         ( a1 n1 -- ) theBuffer +place thebuffer +null ;M
:M Append:      ( a1 n1 -- ) theBuffer +place thebuffer +null ;M
:M +Char:       ( n1 -- )    SP@ 1 theBuffer +place thebuffer +null drop ;M
:M -CHAR:        ( n1 -- )   len: [ self ]
                             over - dup 0< not if
                                over
                                thebuffer 1+ swap 1- thebuffer place thebuffer +null
                                dup 0> if
                                  thebuffer rot 1+ + swap
                                  theBuffer +place thebuffer +null
                                else drop drop then
                             else
                                drop drop
                             then ;M
:M POS:         ( n1 -- )  thebuffer count
                           0
                           begin
                                2 pick over + swap 1+ swap
                                c@ 4 pick = if
                                swap drop swap drop swap drop true else
                                 over over = if drop drop drop drop 0 true
                                  else false then then
                           until ;M
:M GETCHAR:      ( n1 -- ) thebuffer count 2 pick < 2 pick 0> not or if
                                drop drop 0 else
                                + 1- C@ then ;M
:M DIGONLY:      ( -- -- ) len: [ self ]
                           begin
                                dup 0> while
                                dup thebuffer + C@
                                DUP DUP 48 < SWAP 57 > OR
                                SWAP 45 = NOT AND
                                if dup -char: [ self ] then
                                1-
                           repeat
                           drop
       ;M
:M VAL:         ( -- n1 )  digonly: [ self ]
                           len: [ self ] 0= not if
                              1
                              thebuffer count 0 swap
                              0 DO
                                over c@
                                dup 45 = if
                                   drop
                                   rot -1 * rot rot
                                else
                                  swap 10 * + 48 -
                                then
                                swap 1+ swap
                             loop
                             swap drop * true
                           else 0 false then    ;M

;Class

: Get$ dup 1+ swap c@ ;
\ : Type$ Get$ type cr ;

