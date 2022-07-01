: .STR$ ( value -- Str-addr len )
        DUP 0< NOT IF 0 <# # # S" ." "HOLD # # # # S"  " "HOLD #> ELSE
          0XFFFFFFFF XOR 1+ 0 <# # S" ." "HOLD # # # # # S" -" "HOLD  #>  THEN
;

: STR$ ( value -- Str-addr len )
        DUP 0< NOT IF 0 <# #S #> ELSE
          0XFFFFFFFF XOR 1+ 0 <# #S S" -" "HOLD  #>  THEN
;

: X-VAL ( Str-addr len -- value )
0 swap
0 DO
  over i + c@
  dup 96 > if 32 - then
  dup 48 < if drop 48 then
  dup 57 > if 55 - else 48 - then
  swap 16 * +
loop
nip
;


