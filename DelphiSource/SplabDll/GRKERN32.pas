unit GRKERN32;

interface
Type boolint=array[false..true] of longint;
     graprm=record
      axis,dest:boolint;
      color:byte;
      vcode:byte;
      vlen:longint;
      slope:byte;
      size:byte;
      font:byte;
      case boolean of
        false:(wstr:string[80]);
        true:(wl,wch:char)
    end;

const movetoxy=0;
      putdot=1;
      putvector=2;
      putline=3;
      putchar=4;
      putstr=5;
      setgramode=6;
      settxtmode=8;
      clr=9;
      clrstr=14;
      FixMaxX=640;
      FixMaxY=480;

const maxGbuff=2621440 (* (=$400 * $500) *2 *);

var grap:graprm;
    gdri,gmod:integer;
    npixel,corner,cornshift:boolint;
    ax:boolean;
    grabuf: array [0..maxGbuff] of byte;
    GBP: ^longint;
    getmaxx:integer;
    getmaxy:integer;

procedure gra(mode:integer);

function initgra(maxx,maxy:longint):longint;export;stdcall;

implementation

function initgra(maxx,maxy:longint):longint;export;stdcall;
begin
{ if (maxx>=100)and(maxy>=100)and(maxx<=1600)and(maxy<=1200) then begin }
   getmaxx:=maxx;
   getmaxy:=maxy;
   corner[false]:=48;corner[true]:=56;
   npixel[false]:=maxx-corner[false]-8; npixel[true]:=maxy-corner[true]-16;
   cornshift[false]:=0;
   cornshift[true]:=0;
   initgra:=-1
{ end else initgra:=0 }
end;

procedure gra(mode:integer);
const maxmode=17;
var dx,dy:integer;

 procedure movexy;
 begin
  if gbp^<=(maxGbuff-sizeof(grap.dest)-1) then
    with grap do  begin
      move(dest,grabuf[gbp^],sizeof(dest));
      gbp^:=gbp^+sizeof(dest);
      axis:=dest;
    end ;
 end;

 procedure drawxy;
 begin
   movexy;
   move(grap.color,grabuf[gbp^],sizeof(grap.color));
   gbp^:=gbp^+sizeof(grap.color);
 end;

begin
  if (mode<0)or(mode>maxmode) then exit;
  grabuf[gbp^]:=mode;
  inc(gbp^);
  with grap do case mode of
   0: (*move*)movexy;
   1:  drawxy;
   2:  begin
         grabuf[gbp^]:=vcode;
         gbp^:=gbp^+sizeof(vcode);
         move(color,grabuf[gbp^],sizeof(color));
         gbp^:=gbp^+sizeof(color);
         move(vlen,grabuf[gbp^],sizeof(vlen));
         gbp^:=gbp^+sizeof(vlen);
         case (vcode and 7) of
           0,4:dx:=0;
           1,2,3:dx:=1;
           5,6,7:dx:=-1
         end;
         case (vcode and 7) of
           2,6  :dy:=0;
           7,0,1:dy:=1;
           3,4,5:dy:=-1
         end;
         dest[false]:=axis[false]+dx*vlen;
         dest[true]:=axis[true]+dy*vlen;
         axis:=dest;
     end;
    3:drawxy;
    4:begin
        grabuf[gbp^]:=ord(wch); inc(gbp^);
        grabuf[gbp^]:=color; inc(gbp^) ;
        grabuf[gbp^]:=size; inc(gbp^)
      end;
    5:begin
        grabuf[gbp^]:=color; inc(gbp^) ;
        grabuf[gbp^]:=size;  inc(gbp^) ;
        grabuf[gbp^]:=slope; inc(gbp^) ;
        grabuf[gbp^]:=font;  inc(gbp^) ;
        move(wstr,grabuf[gbp^],length(wstr)+1);
        gbp^:=gbp^+length(wstr)+1;
      end;
    6,7,9:gbp^:=sizeof(longint);
    8:;
   14:begin
        grabuf[gbp^]:=color; inc(gbp^) ;
        grabuf[gbp^]:=size;  inc(gbp^) ;
      end
  end
end;

begin
  with grap do begin
      color:=1;
      vcode:=0;
      vlen:=0;
      slope:=0;
      size:=1;
      font:=0;
      wstr:='';
      gbp:=addr(grabuf);
    end;

end.



