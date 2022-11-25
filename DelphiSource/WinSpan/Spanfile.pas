{$I-}
{$R-}
{$H-}
unit Spanfile;

interface

uses SpanDef,SpanLib,Win32CRT,spanio;


function SaveAll(dfname:string):boolean;
function readall(dfname:string):boolean;

implementation

const BlockSize=128;
      parbufsize=768;
      DataBufSize=384;
      DataBlocks=(DataBufSize+BlockSize-1) div BlockSize;
      ParBlocks= (parbufsize+BlockSize-1) div BlockSize;
TYPE
  byte128=array[1..BlockSize] of byte;
  byte768=array[1..parbufsize] of byte;
  byte83=array[1..BlockSize] of byte;
  b6=array[1..6] of byte;
  string48=string[48];
  array10r=array[1..10] of b6;
  array10s=array[1..10] of string[10];

var ext:boolean;
    ss:string;
    realbuf:array[1..62,false..true] of real48;
    ds83:byte128;
    fspc:file;
    parbuf:byte768;

function read_parameters(fname:string):boolean;
var ior:integer;
    OK:boolean;
    pfname:shortstring;
begin
 result:=false;
 pfname:=fname+'.SPC';
 assign(fspc,pfname);
 reset(fspc,blocksize);
 if not(ioresult=0) then exit;
 blockread(fspc,parbuf,ParBlocks,ior);
 OK:=(ior>=(ParBlocks-1));
 if (not OK) then close(fspc);
 result:=OK
end;

function write_parameters(fname:string):boolean;
var ior:integer;
    OK:boolean;
    pfname:shortstring;
begin
  result:=false;
  pfname:=fname+'.SPC';
  assign(fspc,pfname);
  rewrite(fspc,blocksize);
  if ioresult<>0 then exit;
  BlockWrite(fspc,parbuf,ParBlocks,ior);
  OK:=(ior=ParBlocks);
  if (not OK) then close(fspc);
  result:=OK
end;

function SaveAll(dfname:string):boolean;
var i,ior,j,k,reclen,lastnused,nblock:integer;
    int_buf:array[1..4] of smallint;
    ax:boolean;
label abort;
const off=45;
begin
  result:=false;
  i:=pos('.',dfname);
  if i<>0 then delete(dfname,i,255);
  if not(Write_Parameters(dfname)) then exit;
  lastnused:=0;
  while (lastnused<maxcur) and (ddir[lastnused+1].npts<>0) do inc(lastnused);
  if lastnused=0 then exit;
  int_buf[1]:=lastnused;
  int_buf[2]:=n_locations_used;
  int_buf[3]:=obj;
  int_buf[4]:=firstdisp;
  FillChar(ds83,sizeof(ds83),0);
  move(int_buf,Ds83,8);
  blockwrite(fspc,Ds83,1,ior);
  if ior<>1 then goto abort;
  for k:=1 to lastnused do
    if ddir[k].npts>0 then with ddir[k] do begin
     move(ddir[k],ds83,43+off);
     ds83[45+off]:=npts div 256;
     ds83[44+off]:=npts mod 256;
     ds83[46+off]:=plotcolor;
     move(k,ds83[47+off],4);
     move(inter,ds83[51+off],3);
     move(z,ds83[54+off],6);
     move(min,ds83[60+off],12);
     move(max,ds83[72+off],12);
     move(z,ds83[78+off],6); (* patch to comply with .dir reading error in SPLAB4 *)
     blockwrite(fspc,ds83,1,ior);
     if ior<>1 then goto abort;
     if ioresult<>0 then goto abort;
     reclen:=(npts+31) div 32;
     for nblock:=0 to reclen-1 do begin
       for i:=1 to 32 do
         for ax:=false to true do realbuf[i,ax]:=pull(k,ax,nblock*32+i);
       BlockWrite(fspc,realbuf,DataBlocks,ior);
       if ior<>DataBlocks then goto abort
     end;
  end;
  result:=true;
abort: close(fspc);
end;

function readall(dfname:string):boolean;
var i,j,k,l,ncur,nblock,spclen,curnum,reclen,ior:integer;
    int_buf:array[1..4] of smallint;
    ax,thatsit:boolean;
label abort,abort1;
const off=45;
begin
  result:=false;
  i:=pos('.',dfname);
  if i<>0 then delete(dfname,i,255);
  if not(Read_Parameters(dfname)) then begin
     cray('Error reading data file');
     exit
  end;
  BlockRead(fspc,ds83,1);
  move(ds83,int_buf,8);
  obj:=int_buf[3];
  firstdisp:=int_buf[4];
  i:=0; thatsit:=false;
  repeat
    inc(i);
    if not(eof(fspc)) then begin
          BlockRead(fspc,ds83,1,ior);
          if ior<>1 then goto abort
    end else thatsit:=true;
    move(ds83[47+off],curnum,4);
    spclen:=ds83[45+off]*256+ds83[44+off];
    thatsit:=not((curnum=i) and (spclen>0));(* read untill thr first empty location *)
    if not(thatsit) then with ddir[curnum] do begin
       npts:=spclen;
       move(ds83,head,43+off);
       plotcolor:=ds83[46+off];
       move(ds83[51+off],inter,3);
       move(ds83[54+off],z,6);
       move(ds83[60+off],min,12);
       move(ds83[72+off],max,12);
       reclen:=(spclen+31) div 32;
       for nblock:=0 to reclen-1 do begin
         blockread(fspc,realbuf,DataBlocks, ior);
         if ior<>Datablocks then begin
            cray('Error reading data file');
            exit
         end;
         for j:=1 to 32 do begin
           l:=nblock*32+j;
           if l<=spclen then for ax:=false to true do
             push(realbuf[j,ax],curnum,ax,l);
           if l<0 then goto abort
         end
       end
    end
  until (i=maxcur) or thatsit;
  Result:=true;
abort: close(fspc);
end;

END.

