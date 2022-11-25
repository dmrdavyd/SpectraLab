{$H-}
unit SPL32_06G;
interface
TYPE
 SPCHDR=record
   ftflgs:   byte; { Flag bits defined below }
   fversn:   byte; { 0x4B=> new LSB 1st, 0x4C=> new MSB 1st, 0x4D=> old format }
   fexper:   byte; { Instrument technique code (see below) }
   fexp:     byte ;  { Fraction scaling exponent integer (80h=>float) }
   fnpts:    Longint; { Integer number of points (or TXYXYS directory position) }
   ffirst:   double ; { Floating X coordinate of first point }
   flast:    double ; { Floating X coordinate of last point }
   fnsub:    longint; { Integer number of subfiles (1 if not TMULTI) }
   fxtype:   byte; { Type of X axis units (see definitions below) }
   fytype:   byte; { Type of Y axis units (see definitions below) }
   fztype:   byte ; { Type of Z axis units (see definitions below) }
   fpost:    byte ; { Posting disposition (see GRAMSDDE.H) }
   fdate:    longint ; { Date/Time LSB: min=6b,hour=5b,day=5b,month=4b,year=12b }
   fres:     array [0..8] of char ; { Resolution description text (null terminated) }
   fsource:  array [0..8] of char ; { Source instrument description text (null terminated) }
   fpeakpt:  word; { Peak point number for interferograms (0=not known) }
   fspare:   array [0..7] of single ; { Used for Array Basic storage }
   fcmnt:    array [0..129] of char ; { Null terminated comment ASCII text string }
   fcatxt:   array [0..29] of char ; { X,Y,Z axis label strings if ftflgs=TALABS }
   flogoff:  longint ; { File offset to log block or 0 (see above) }
   fmods:    longint  ; { File Modification Flags (see below: 1=A,2=B,4=C,8=D..) }
   fprocs:   byte ; { Processing code (see GRAMSDDE.H) }
   flevel:   byte ; { Calibration level plus one (1 = not calibration data) }
   fsampin:  word ; { Sub-method sample injection number (1 = first or only ) }
   ffactor:  single ; { Floating data multiplier concentration factor (IEEE-32) }
   fmethod:  array [0..47] of char ; { Method/program/data filename w/extensions comma list }
   fzinc:    single ; { Z subfile increment (0 = use 1st subnext-subfirst) }
   fwplanes: longint; { Number of planes for 4D with W dimension (0=normal) }
   fwinc:    single ; { W plane increment (only if fwplanes is not 0) }
   fwtype:   byte ; { Type of W axis units (see definitions below) }
   freserv:  array [0..186] of char ; { Reserved (must be set to zero) }
 END;  { SPCHDR }

 type lsingle = record
 case boolean of
    true:  (l:longint) ;
    false: (r:single)  ;
 end;

 TYPE SUBHDR=RECORD
 case boolean of
  true: (dummy:array [1..8] of lsingle);
  false:
        (subflgs:byte     ; { Flags as defined above }
         subexp: byte     ; { Exponent for sub-file's Y values (80h=>float) }
         subindx: word    ; { Integer index number of trace subfile (0=first) }
         subtime: single  ; { Floating time for trace (Z axis corrdinate) }
         subnext: single  ; { Floating time for next trace (May be same as beg) }
         subnois: single  ; { Floating peak pick noise level if high byte nonzero }
         subnpts: longint ; { Integer number of subfile points for TXYXYS type }
         subscan: longint ; { Integer number of co-added scans or 0 (for collect) }
         subwlevel: single; { Floating W axis value (if fwplanes non-zero) }
         subresv: array[1..4] of char) ; { Reserved area (must be set to zero) }
 END;  (* SUBHDR *)


 type SPCFILE = object
   mainhead:spchdr;
   subhead:subhdr;
   xyfile,multifile,multixfile:boolean;
   dx,zvalue:real;
   yexp: word;
   fname,scmnt: string;
   curcur:byte;
   curnpts:integer;
   ypos,foffset:word;
   function ouvrir(name:string):integer;
   function readnextblock:boolean;
   procedure fermer;
   function xvalue(n:integer):real;
   function yvalue(n:integer):real;
  end (* SPCFILE *);

implementation

const TSPREC=1;	 (* Single precision (16 bit) Y data if set. *)
      TCGRAM=2;	 (* Enables fexper in older software (CGM if fexper=0) *)
      TMULTI=4;	 (* Multiple traces format (set if more than one subfile) *)
      TRANDM=8;	 (* If TMULTI and TRANDM=1 then arbitrary time (Z) values *)
      TORDRD=16; (* If TMULTI abd TORDRD=1 then ordered but uneven subtimes *)
      TALABS=32; (* Set if should use fcatxt axis labels, not fxtype etc.  *)
      TXYXYS=64; (* If TXVALS and multifile, then each subfile has own X's *)
      TXVALS=128;(* Floating X value array preceeds Y's  (New format only) *)
      B32=4294967296.0;

  type xarray=array [1..4096] of single;
  type pxarray=^xarray;

var    spchfile: file of spchdr;
       spcdfile: file of lsingle;
       ps:pchar;
       xdata:pxarray;
       xdatasize:integer;

function spcfile.readnextblock:boolean;
var w:word;i:integer;l:lsingle;

 function readsubh:boolean;
 var i:integer;
 begin
    with subhead do begin
      readsubh:=false;
      for i:=1 to 8 do read(spcdfile,dummy[i]);
      foffset:=foffset+8;
      if subindx<>(curcur-1) then exit;
      if subnpts<>0 then curnpts:=subnpts;
      if subexp>15 then yexp:=0 else yexp:=1 shl subexp;
      zvalue:=subtime;
    end;
    readsubh:=true;
 end;

 procedure readxdata;
 var i:integer;
 begin
   if (xdatasize<>0) then freemem(xdata,xdatasize);
   xdatasize:=curnpts*4;
   getmem(xdata,xdatasize);
   for i:=1 to curnpts do begin
      read(spcdfile,l);
      xdata^[i]:=l.r;
   end;
   foffset:=foffset+curnpts
 end;

begin
 with mainhead do begin
  readnextblock:=false;
  if curcur>=fnsub then exit;
  inc(curcur);
  ypos:=0;
  foffset:=foffset+curnpts;
  seek(spcdfile,foffset);
  curnpts:=fnpts;
  if (not(multixfile)) and (xyfile)and(curcur=1) then readxdata;
  if xyfile then if not(readsubh) then exit;
  if (multixfile) then readxdata;
  readnextblock:=true;
 end
end;

function spcfile.ouvrir(name:string):integer;
  begin
    ouvrir:=0;
    curcur:=0;
    curnpts:=0;
    zvalue:=99999;
    fname:='';
    assign(spchfile,name+'.SPC');
    reset(spchfile);
    if ioresult<>0 then begin close(spchfile); exit end;
    fname:=name;
    read(spchfile,mainhead);
    with mainhead do begin
       ps:=addr(fcmnt);
       scmnt:=ShortString(ps);
       if (fnpts<>0)and(fnsub=0) then fnsub:=1;
       ouvrir:=fnsub;
       if fexp>15 then yexp:=0 else yexp:=1 shl fexp;
       close(spchfile);
       multifile:=((ftflgs and tmulti)<>0);
       xyfile:=((ftflgs and TXVALS)<>0);
       multixfile:=((ftflgs and TXYXYS)<>0);
       xyfile:=xyfile or multixfile;
       multixfile:=multixfile and multifile;
       curcur:=0;xdatasize:=0;
       if not(xyfile) then dx:=(flast-ffirst)/(fnpts-1);
       assign(spcdfile,fname+'.SPC');
       reset(spcdfile);
       foffset:=128;
   end
 end;

 procedure spcfile.fermer;
 begin
   close(spcdfile);
   if xdatasize<>0 then freemem(xdata,xdatasize);
   fname:='';
   curcur:=0;
 end;

 function spcfile.xvalue(n:integer):real;
 begin
  if (n>curnpts) or (n<0) then begin xvalue:=0; exit end;
  if xyfile then xvalue:=xdata^[n] else
  xvalue:=mainhead.ffirst+dx*(n-1)
 end;

 function spcfile.yvalue(n:integer):real;
 var l:lsingle;a:double;
 begin
  if (n-1)<>ypos then seek(spcdfile,foffset+(n-1));
  read(spcdfile,l);
  if yexp=0 then yvalue:=l.r else begin
    a:=l.l;
    a:=a*yexp/B32;
    yvalue:=a
  end;
  ypos:=n;
 end;
END.
