{$H-}
unit spl32_06;

interface
uses Spl32def,
     SPL32BASE,
     SPL32STR,
     SPL32_01,
     SPL32_06G,
     OOIHSD,
     Link2opti,
     optidef,
     matrix,
     Math;

function _dsave(nm:longint; var dfname:string ):longint; export; stdcall;
function SaveInAsc(var fname:string):longint; export; stdcall;
function ReadInAsc(var fname:string):longint;export;stdcall;
function DX_save(nm:longint;var dfname:string):longint; export; stdcall ;
function DX_load(keeploc,n:longint;var dfname:string):longint; export; stdcall ;
function input_chain(inputstr:string;var outrow:datatype;var n_in_row:integer):boolean;
function SaveSPC(var dfname:string):longint;export;stdcall;
function ReadSPC(var dfname:string):longint;export;stdcall;
function ndload(var dfname:string):longint;export;stdcall;


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
Type Axis48=record
      auto_            :byte;
      token_           :string[48];
      nscaling_        :smallint;
      scaling_         :array10r;
      scs_             :array10s;
      off_             :b6;
      lim_             :b6;
      factor_          :b6;
      scale_           :b6;
      bottom_          :b6;
  end;

var ext:boolean;
    ss,convstr,endstri:string;
    realbuf: array[1..64,false..true] of real48;
(*    DsBuf:DirBufType; *)
    ds83:byte83;
    fds:file;
    fspc:file;
    bitbuf:byte768;
    newformat:boolean;


function _dsave(nm:longint; var dfname:string ):longint; export; stdcall;
var i,n:integer;ax:boolean;tmp:single;
    dfile:text;
    rpt:boolean;
label ds_exit;
begin
  assign(dfile,dfname);
  rewrite(dfile);
  if ioresult<>0 then goto ds_exit;
  if nm=0 then begin rpt:=true; inc(nm) end else rpt:=false;
  n:=nm;
  repeat
    while rpt and((Spectra.dir(n)^.npts=0)or((Spectra.dir(n)^.plotcolor and $80)<>0))and(n<maxcur) do n:=n+1;
    if n>=maxcur then rpt:=false;
    if Spectra.dir(n)^.npts<>0 then with Spectra.dir(n)^ do begin
      writeln(dfile,head);
      if ioresult<>0 then goto ds_exit;
      write(dfile,npts:4);
      if Not(IsNAN(z)) then write(dfile,' ',z:12);
      writeln(dfile);
      if ioresult<>0 then goto ds_exit;
      for i:=1 to npts do begin
       for ax:=false to true do begin
         pull(tmp,n,ax,i);
         write(dfile,tmp:12:-1);
         if not(ax) then write(dfile,',')
       end;
       writeln(dfile);
       if ioresult<>0 then goto ds_exit;
     end
    end;
    n:=n+1;
  until not(rpt);
   close(dfile);
  _dsave:=-1;
  exit;
ds_exit:close(dfile);
  _dsave:=0;
end;


function iorpt(i:integer):boolean;
begin
 iorpt:=i<>0
end;

function SaveInAsc(var fname:string):longint; export; stdcall;
type t1max=1..maxcur;
var i,n:integer;
    k:t1max;
    csv:boolean;
    currx,x,tmp:single;
    ss,ss1:string;
    setofcur,setoffits:set of t1max;
    ipos:array [1..maxcur] of integer;
    fnd:partype;
    nselected:integer;
    dfile:text;
    fitmode:rmoderecord;
begin
  SaveInAsc:=0;
  nselected:=0;
  ss:=fname;
  csv:=(pos('.CSV',ss)<>0);
  if n_locations_used<>0 then for i:=1 to MaxCur do
    if (Spectra.dir(i)^.npts>0)and(((Spectra.dir(i)^.plotcolor)and($F0))=0) then inc(nselected);
  if nselected=0 then exit;
  if pos('.',ss)=0 then ss:=ss+'.ASC';
  assign(dfile,ss);
  rewrite(dfile);
  if iorpt(ioresult) then exit;
  setofcur:=[]; setoffits:=[];
  i:=0;
  for k:=1 to maxcur do
   if (Spectra.dir(k)^.npts>0)and(((Spectra.dir(k)^.plotcolor and $F0)=0)) then
     with Spectra.dir(k)^ do begin
       if setofcur=[] then begin
           ss:=xyaxis[false].token;
           write(dfile,'"'+next(ss,',')+'"')
       end;
       if not(csv) then
         if not(isnan(z)) then begin
            str(z:9:-1,ss);
            ss:=',"'+ss+'"';
         end else ss:=',""'
       else begin
          ss:=',"'+head+'"';
          if not(isnan(z)) then inc(i)
       end;
       write(dfile,ss);
       if not(csv)and(fitparam<>NIL) then with fitparam^ do
          if ((mode<>0)and(fitting_path<>0)and(EstimatesReady(fitparam))) then begin
            write(dfile,ss);
            setoffits:=setoffits+[k]
          end;
       setofcur:=setofcur+[k];
     end;
  if setofcur=[] then begin close(dfile); exit end else writeln(dfile);
  if (csv)and(i>0) then begin
    write(dfile,'"Z="');
    for k:=1 to maxcur do
     if k in setofcur then begin
         if not(isnan(Spectra.dir(k)^.z)) then begin
            str(Spectra.dir(k)^.z:9:-1,ss);
            ss:=',"'+ss+'"';
         end else ss:=',""';
         write(dfile,ss)
     end;
    writeln(dfile)
  end;
  for i:=1 to maxcur do ipos[i]:=1;
  repeat
    i:=1;
    while (not(i in setofcur)) or (Spectra.dir(i)^.npts<ipos[i]) do inc(i);
    pull(currx,i,false,ipos[i]);
    for i:=1 to maxcur do if (i in setofcur)and(Spectra.dir(i)^.npts>=ipos[i]) then
     if (pull(tmp,i,false,ipos[i]))and(tmp<currx) then currx:=tmp;
    write(dfile,currx:9:4);
    n:=0;
    for k:=1 to maxcur do if k in setofcur then
     with Spectra.dir(k)^ do begin
        i:=ipos[k];
        write(dfile,',');
        pull(x,k,false,i);
        if (i<=npts)and(abs(x-currx)<=1e-6) then begin
         pull(tmp,k,true,i);
         write(dfile,tmp:9:4);
         ipos[k]:=ipos[k]+1;
         if (not(csv)) and (k in setoffits) then with fitparam^ do begin
           fun(prm,fnd,x,z,u_prm,false,mode,submode);
           write(dfile,',',fnd[0]:9:4);
         end;
        end else if (not(csv)) and (k in setoffits) then write(dfile,',');
        if ipos[k]>Spectra.dir(k)^.npts then inc(n)
     end;
     writeln(dfile);
     if iorpt(ioresult) then exit
  until n>=nselected;
  if not(csv) then
   for k:=1 to maxcur do if (k in setofcur) then  begin
    writeln(dfile,','+Spectra.dir(k)^.head);
    if k in setoffits then begin
      fitmode:=getmode(Spectra.dir(k)^.fitparam^.mode);
      ss:=fitmode^.mn;
      writeln(dfile,',Fitting by ',fitmode^.mn);
    end
   end;
  SaveInAsc:=-1;
  close(dfile);
end;

function fread(var ss:string;var ok:boolean):real;
var i,j,err:integer;
    ss1:string;
    a:real;
begin
  ok:=false;
  cut(ss,' ');
  ss1:=next(ss,#0);
  upshift(ss1);
  cut(ss1,#128);
  val(ss1,a,err);
  fread:=a;
  ok:=(err=0)
end;

function dload(var dfname:string):longint;
(* reading of ASCII ".DAT" and ".TXT" files *)
var i,npt,n:integer;
    x,y:single;
    ax,ok,singlecolumn,first:booleAn;
    c:char;
    tmps,ss:string;
    dfile:text;
label dl_exit,skip_it;
begin
  n:=obj^;
  result:=0;
  first:=true;
  if Spectra.dir(n)^.npts<>0 then goto dl_exit;
  if pos('.',dfname)=0 then dfname:=dfname+'.DAT';
  assign(dfile,dfname);
  reset(dfile);
  if iorpt(ioresult) then exit;
  readln(dfile,tmps);
  if (pos('Module:',tmps)=1) and (pos('UV-Vis',tmps)=9) then begin (* if this is a NanoDrop ".NDV" file *)
    close(dfile);
    result:=ndload(dfname);
    exit
  end;
  val(tmps,x,i);
  singlecolumn:=(i=0);
  if singlecolumn then begin
    reset(dfile);
    npt:=0;
    while not(eof(dfile)) do begin
      readln(dfile,tmps);
      cut(tmps,#128);
      val(tmps,y,i);
      if i=0 then begin
        inc(npt);
        x:=npt;
        push(x,n,false,npt);push(y,n,true,npt);
      end;
    end;
    tmps:=dfname;
    i:=pos('.',tmps); (* dot *)
    if i>1 then tmps:=copy(tmps,1,i-1);
    i:=length(tmps);
    while(i>0)and (tmps[i]<>'\') do dec(i); (* backslash*)
    with Spectra.dir(n)^ do begin
        tmps:=copy(tmps,i+1,255);
        head:=tmps;
        inter:=0;
        connect:=0;
        symbol:=1
    end;
  end else while not(eof(dfile)) do begin
      if not(first) then readln(dfile,tmps) else first:=false;
      read(dfile,npt);
(* read z-value, if present *)
      ok:=eoln(dfile);
      if not(ok) then readln(dfile,Spectra.dir(n)^.z)
       else readln(dfile);
      if iorpt(ioresult) then exit;
(* read curve *)
      for i:=1 to npt do begin
       readln(dfile,ss);
       if iorpt(ioresult) then exit;
       x:=fread(ss,ok);y:=fread(ss,ok);
       push(x,n,false,i);push(y,n,true,i);
      end;
      with Spectra.dir(n)^ do begin
        head:=tmps;
        inter:=0;
        connect:=0;
        symbol:=1
      end;
      if n<maxcur then n:=n+1 else n:=1
  end;
  result:=-1;
dl_exit:
  close(dfile);
end;

function ndload(var dfname:string):longint;
(* reading ".NDV" file from nanodrop spectrometer *)
var i,j,npt,n:integer;
    x:single;
    trr:byte;
    ss,sss,IDS:string;
    dfile:file of char;
label ndl_exit;

    function tabread(var ss:string):byte;
    var c:char;
        eol,done:boolean;
        charcode:byte;
    begin
      ss:='';
      repeat
        if not(eof(dfile)) then begin
         read(dfile,c);
         charcode:=ord(c);
         if (charcode=10) then begin
           read(dfile,c);
           charcode:=ord(c) (* if <CR> then skip <LF> *)
         end;
         if charcode>31 then ss:=ss+c
        end else charcode:=0
      until charcode<31;
      result:=charcode
    end;

begin
  n:=obj^;
  result:=0;
  if Spectra.dir(n)^.npts<>0 then goto ndl_exit;
  if pos('.',dfname)=0 then dfname:=dfname+'.NDV';
  assign(dfile,dfname);
  reset(dfile);
  if iorpt(ioresult) then exit;
  repeat
    trr:=tabread(ss)
  until (trr=0) or (pos('Sample ID',ss)<>0);
  if (trr=0) then goto ndl_exit;
  if tabread(ss)=0 then goto ndl_exit;
  if (pos('User ID',ss)=0) then IDS:=ss else begin
    IDS:=dfname;
    i:=pos('.',IDS); (* dot *)
    if i>1 then IDS:=copy(IDS,1,i-1);
    i:=length(IDS);
    while(i>0)and (IDS[i]<>'\') do dec(i); (* backslash*)
    IDS:=copy(IDS,i+1,255);
  end;
  repeat
    trr:=tabread(ss)
  until (trr=0) or (pos('Norm Abs',ss)<>0);
  if (trr=0) then goto ndl_exit;
  npt:=0;
  repeat
    trr:=tabread(ss);
    if (length(ss)>0) then begin
      cut(ss,#128); (* cut non-numeric chars *)
      val(ss,x,i);
      if (i=0) then begin
        inc(npt);
        push(x,n,false,npt);
        push(x,n,true,npt)
      end;
    end;
  until (trr<>9);
  if (trr=0) then goto ndl_exit;
  repeat
    trr:=tabread(ss)
  until (trr=0) or (pos('Measure',ss)<>0);
  if (trr=0) then goto ndl_exit;
  j:=0;
  repeat
    trr:=tabread(sss);
    ss:=sss;
    cut(ss,#32);
    if (length(ss)=length(sss)) then begin
      if (ss='NaN') then begin
        if (j=0) then x:=0; (* if NaN then leave x unchanged *)
        i:=0                (* except for the first point, where we assume x=0 *)
      end else val(ss,x,i);
      if (i=0) then begin
        inc(j);
        push(x,n,true,j)
      end;
    end;
  until (j=npt)or(trr<>9);
  with Spectra.dir(n)^ do begin
        head:=IDS;
        inter:=1;
        connect:=0;
        symbol:=1
 end;
  result:=-1;
ndl_exit:
  close(dfile);
end;

function ReadInAsc(var fname:string):longint;export;stdcall;
(* Reading of tabular generic ASCII ".ASC" and EXEL-standard ".CSV" files *)
var i,j,k,ncur:integer;
    EI_TXT: integer;
    a,x:real;
    tmp:single;
    with_header,masspec,skipit,genesys:boolean;
    n_in_row:integer;
    inrow,zrow:datatype;
    headstring,nextstring,commntstr,headbuf,hstring,ss1:shortstring;
    quit,ok,asc:boolean;
    dfile:text;

const msthreshld=0.99;

label SPSTART;

function readnshorten:string;
var i,j,k:integer;
    fraclen:shortint;
    c:char;

    compressed,in_parenth:boolean;
    s:string;
begin
   endstri:='';
   in_parenth:=false;
   if EI_TXT>0 then inc(EI_TXT);
   fraclen:=-1;s:='';
   repeat
     read(dfile,c);
     quit:=eof(dfile) or (ioresult<>0)
   until (quit)or(c<>#10);
   while not(quit)and(not(c in [#10,#13])) and(length(s)<255) do begin
      if (fraclen<0)and(c='.') then fraclen:=0;
      if c='(' then in_parenth:=true;
      if (EI_TXT<>1)or not(in_parenth) then
       if c in ['0'..'9'] then
        case fraclen of
         -1:s:=s+c;
          0..4:begin
            s:=s+c;
            inc(fraclen)
          end;
        end
       else begin
              if c<>'.' then fraclen:=-1;
              if not(c in [#0,#10,#11]) then s:=s+c;
              if (EI_TXT=0) and (s='Labels,') then begin EI_TXT:=1; s:=',' end;
       end
      else if c=')' then in_parenth:=false;
      quit:=(eof(dfile));
      if not(quit) then begin
        read(dfile,c);
        quit:=quit or (ioresult<>0)
      end;
      if (length(s)=255)and(endstri='') then begin endstri:=s;s:='' end;
   end;
   quit:=eof(dfile);
   while (length(s)=255)and(not(quit))and(not(c in [#10,#13])) do begin
        read(dfile,c);
        quit:=eof(dfile) or (ioresult<>0)
   end;
   if endstri<>'' then begin readnshorten:=endstri; endstri:=s end else readnshorten:=s
end;

begin
  headbuf:=upshift(fname);
  i:=pos('.DAT',headbuf);
  if i<>0 then begin result:=dload(fname);exit end;
  i:=pos('.NDV',headbuf);
  if i<>0 then begin result:=ndload(fname);exit end;
  EI_TXT:=0; commntstr:=''; genesys:=false;
  Result:=0;
  if pos('.',fname)=0 then fname:=fname+'.CSV';
  i:=pos('.ASC',headbuf);
  asc:=(I<>0);
  assign(dfile,fname);
  reset(dfile);
  headstring:=readnshorten;
  if iorpt(ioresult) then exit;
  if asc then begin
     nextstring:=next(headstring,#0);
     cut(nextstring,' ');
     cut(nextstring,'"');
     cut(nextstring,' ');
     if length(nextstring)>0 then xyaxis[false].token:=nextstring;
     with_header:=true;
     convstr:=readnshorten;
     ok:=input_chain(convstr,inrow,n_in_row);
     if not(ok) or (n_in_row<2) then exit;
  end else begin
    ok:=not(input_chain(headstring,inrow,n_in_row));
    with_header:=ok;
    if with_header and (pos('TITLE "',headstring)=1) and (pos('Voyager', headstring)<>0) then begin
      masspec:=true;
      headstring:=','+copy(headstring,7,255);
      end;
    while (ok)and(not(eof(dfile))) do begin
      convstr:=readnshorten;
      if (EI_TXT>0) and (pos('Comment,',convstr)=1) then commntstr:=copy(convstr,8,255)
       else if (pos('GENESYS', convstr)<>0) then genesys:=true else
        if (genesys) and (pos('Scanning',convstr)<>0) then headstring:=copy(convstr,12,255);
      ok:=not(input_chain(convstr,inrow,n_in_row));
    end;
  end;
  ncur:=n_in_row;
  if ncur<2 then exit;
  ncur:=ncur-1;
  if eof(dfile) then exit;
  if with_header then begin
   for i:=1 to ncur do with Spectra.dir(i+obj^-1)^ do begin z:=NAN; head:='' end;
   while headstring<>'' do begin
    cut(headstring,' ');
    cut(headstring,',');
    cut(headstring,' ');
    if pos('"',headstring)=1 then ss:=',"'
        else ss:=',';
    i:=0;
    repeat
        j:=pos(ss,headstring);
        if j<>0 then headstring[j]:=#13;
        inc(i)
    until J=0;
    if i>ncur then j:=ncur else j:=i;
    for i:=1 to j do with Spectra.dir(i+obj^-1)^ do begin
      nextstring:=next(headstring,#13);
      cut(nextstring,' ');
      cut(nextstring,'"');
      cut(nextstring,',');
      headbuf:=nextstring;
      if isnan(z) then begin
       val(nextstring,a,k); ok:=(k=0);
 {      a:=fread(nextstring,ok);}
       if ok then begin
        z:=a;
        headbuf:=''
       end
      end;
      if (head<>'') and (headbuf<>'') then head:=head+';';
      head:=head+headbuf;
    end;
    headstring:=commntstr; commntstr:='';
   end
  end;
  for i:=obj^ to obj^+ncur-1 do
     if (i>maxcur) or (Spectra.dir(i)^.npts<>0) then  exit;
  quit:=false;

SPSTART:

  while not(quit) do begin
    for i:=1 to ncur do begin
      k:=Spectra.dir(i+obj^-1)^.npts+1;
      x:=inrow[1];
      if (k>1) and masspec then begin
        pull(tmp,i+obj^-1,false,k-1);
        skipit:=((x-tmp)<msthreshld);
      end else skipit:=false;
      if not(skipit) then begin
       a:=inrow[i+1];
       if not(isnan(a)) then begin
         push(x,i+obj^-1,false,k);
         push(a,i+obj^-1,true,k)
       end
     end
    end;
    if not(eof(dfile)) then begin
      convstr:=readnshorten;
      quit:= not(input_chain(convstr,inrow,n_in_row))
    end else quit:=true;
  end;
  for i:=1 to ncur do begin
    Spectra.dir(i+obj^-1)^.inter:=0;
    Spectra.dir(i+obj^-1)^.connect:=-1;
  end;
  i:=1;
  ss:=convstr;
  quit:=eof(dfile);
  while (not(quit))and(i<=ncur) do begin
      cut(ss,' ');
      if not(pos('Method Log',ss)=1)then begin
        cut(ss,',');
        cut(ss,'"');
        if ss<>'' then
           if  Spectra.dir(i+obj^-1).head='' then Spectra.dir(i+obj^-1).head:=ss
              else  Spectra.dir(i+obj^-1).head:=Spectra.dir(i+obj^-1).head+'; '+ss;
        inc(i)
      end;
      if not(quit) then repeat
          ss:=readnshorten;
          quit:=eof(dfile)
      until (quit)or(ss='');
  end;
  close(dfile);
  {ReadCSV}
  result:=-1;
end;


function DX_save(nm:longint;var dfname:string):longint; export; stdcall ;
const MaxCmp=5;
var ss,ss1:string;
    c:char;
    i,j,n,n1,n2,n2save,nconc,_lin:integer;
    ltmp:longint;
    takeall,regularx,ax:boolean;
    factor:array[false..true] of single;
    dx,ddx,tmp,tmp1:single;
    CmpName:array[1..MaxCmp] of string;
    CUN:string;
    curdataspec:rdataspec;
    dfile:text;


    procedure writetitle(ss:string);
    begin
         writeln(dfile,'##TITLE= ',ss)
    end;

    procedure writetype(ss:string);
    begin
         writeln(dfile,'##DATA TYPE= ',ss);
    end;

    procedure writeunits(ax:boolean;ss:string);
    begin
         if ax then c:='Y' else c:='X';
         writeln(dfile,'##',c,'UNITS= ',ss);
    end;

    procedure writestamp;
    begin
       writeln(dfile,'##JCAMP-DX= 4.24')
    end;

begin
  DX_save:=0;
  assign(dfile,dfname);
  rewrite(dfile);
  if ioresult<>0 then exit;
  n2save:=0;
  takeall:=(nm>=0);
  nm:=abs(nm);
  if (nm=0)or(nm>maxcur) then begin n1:=1; n2:=maxcur end else begin
   if nm<1 then nm:=1;
   n1:=nm; n2:=nm;
  end;
  for n:=n1 to n2 do with Spectra.dir(n)^ do
    if (npts>0)and(takeall or ((plotcolor and $F0)=0))then begin
      inc(n2save);
      sort(0,n);
      for ax:=false to true do minimaXY(n,ax,true);
    end;
  if n2save=0 then begin
{    cray('Nothing to Save'); }
    exit
  end;
  nconc:=0;
  if n2save>1 then begin
     writetitle(dfname);
     writestamp;
     writetype('LINK');
     writeln(dfile,'##BLOCKS= ',n2save:2);
     ss:=xyaxis[false].footnote+' '+xyaxis[true].footnote;
     while ((pos('[',ss)=1)and(nconc<MaxCmp)) do begin
      inc(nconc);
      cmpname[nconc]:=next(ss,']');
      cutstartchar(ss,',');
      cutstartchar(ss,' ');
      if pos('UN=',ss)=1 then begin
        delete(ss,1,3);
        cun:=next(ss,' ')
      end else cun:='microM';
     end;
     writeln(dfile,'##SAMPLE DESCRIPTION= ',ss);
     writeln(dfile);
  end;
  for n:=n1 to n2 do begin
    curdataspec:=Spectra.dir(n);
    with curdataspec^ do
      if (npts>0)and(takeall or ((plotcolor and $F0)=0))then begin
        writetitle(head);
        writestamp;
        regularX:=(stepx<>0);
        if regularX then begin
           if (min[false]>=190) and (max[false]<=800) then begin
             writetype('SPECTRUM');
             writeunits(false,'NANOMETERS')
           end else begin
             writetype('KINETICS');
             writeunits(false,'SECONDS')
           end;
           if (min[true]>=-3.2) and (max[true]<=3.2) then
             writeunits(true,'ABSORBANCE')
           else
             writeunits(true,'ARBITRARY UNITS');
           if stepx<>2147483647 then begin
              dx:=stepx;
              writeln(dfile,'##DELTAX= ',dx:12:6);
           end else dx:=0;
           j:=pos('):',head);
           if (nconc<>0)and (j<>0) then begin
             writeln(dfile,'##CONCENTRATIONS = (NCU)');
             ss:=copy(head,j+2,255);
             cut(ss,' ');
             for i:=1 to nconc do begin
               write(dfile,'(',cmpname[i],', ');
               ss1:=next(ss,' ');
               cut(ss1,' ');
               val(ss1,tmp,j);
               if (j<>0)or(tmp=0) then ss1:='0' else
                 if (tmp>=1E-3)and(tmp<1E4) then str(tmp:10:4,ss1) else str(tmp:13:-1,ss1);
               writeln(dfile,ss1,', ',cun,')')
             end
           end;
           for ax:=false to true do begin
              if min[ax]=max[ax] then factor[ax]:=1 else begin
               tmp:=abs(max[ax]);
               tmp1:=abs(min[ax]);
               if tmp<tmp1 then tmp:=tmp1;
               if tmp<>0 then begin
                if not(ax) and (dx<>0) then factor[false]:=1/dx else begin
                  factor[ax]:=1;
                  while (tmp/factor[ax])<999 do factor[ax]:=factor[ax]*0.1;
                  ddx:=max[ax]-min[ax];
                  if ax then dx:=ddx/2047 else dx:=ddx/(npts-1);
                  while (dx/factor[ax])<1 do factor[ax]:=factor[ax]/2;
                end;
                tmp1:=tmp/1E6; if tmp1<1E-6 then tmp1:=1E-6;
                if ddx<=9.99E8 then  begin
                 while (abs(tmp-round(tmp/factor[ax])*factor[ax])>tmp1) do factor[ax]:=factor[ax]/2
                end else
                  factor[ax]:=1
                end
               end;
               if ax then c:='Y' else c:='X';
               if (factor[ax]<>0) then
                if (tmp/factor[ax]>1E7) then factor[ax]:=0 else
                                         writeln(dfile,'##',c,'FACTOR= ',factor[ax]:13:-1);
          end;
         end else begin
           for ax:=false to true do factor[ax]:=0;
           writetype('CURVE');
           for ax:=false to true do writeunits(ax,'ARBITRARY UNITS')
        end;
        writeln(dfile,'##FIRSTX= ',min[false]:13:-1);
        writeln(dfile,'##LASTX= ',max[false]:13:-1);
        writeln(dfile,'##MINY= ',min[true]:13:-1);
        writeln(dfile,'##MAXY= ',max[true]:13:-1);
        if Not(IsNAN(z)) then writeln(dfile,'##PRESSURE= ',z:12);  {:-1}
        writeln(dfile,'##NPOINTS= ',npts:4);
        writeln(dfile,'##$LOC= ',n:3);
        if inter<>0 then _lin:=1 else _lin:=0;
        if connect<>0 then _lin:=_lin or 2;
        writeln(dfile,'##$LIN= ',_lin:3);
        writeln(dfile,'##$COL= ',plotcolor:3);
        writeln(dfile,'##$SYM= ', symbol:3);
        if not(regularX) then begin
         writeln(dfile,'##XYPOINTS= (XY..XY))');
         for i:=1 to npts do begin
           for ax:=false to true do begin
            pull(tmp,n,ax,i);
            if (abs(tmp)>=0.01)and(abs(tmp)<10000) then str(tmp:12:6,ss) else str(tmp:12:-1,ss);
            cut(ss,' ');
            write(dfile,ss);
            if not(ax) then write(dfile,',')
           end;
           if ((i mod 3)=0)or(i=npts) then writeln(dfile) else write(dfile,':')
         end;
        end else begin
         writeln(dfile,'##XYDATA= (X++(Y..Y))');
         ss:='';
         for i:=1 to npts do begin
           if (length(ss)>=76)or(i=npts) then begin
             writeln(dfile,ss);
             ss:=''
           end;
           for ax:=false to true do if (ax)or(ss='') then begin
               pull(tmp,n,ax,i);
               if factor[ax]=0 then
                 if (abs(tmp)>=0.01)and(abs(tmp)<10000) then
                                            str(tmp:12:6,ss1) else str(tmp:12:-1,ss1)
               else begin
                    ltmp:=round(tmp/factor[ax]);
                    str(ltmp:12,ss1);
               end;
               cut(ss1,' ');
               if (ax)and(ss1[1]<>'-') then ss:=ss+' ';
               ss:=ss+ss1;
           end;
         end;
         if ss<>'' then writeln(dfile,ss);
        end;
        writeln(dfile,'##END= ');
        if n2save>1 then writeln(dfile)
   end
  end;
  if n2save>1 then  writeln(dfile,'##END= ');
  DX_save:=-1;
  close(dfile);
end;

function input_chain(inputstr:string;var outrow:datatype;var n_in_row:integer):boolean;
var err:integer;
    ss:string;
    a:real;
    Last_row_empty:boolean;
label once_again;
begin
  cut(inputstr,' ');
  input_chain:=false;n_in_row:=0;
  while (inputstr<>'')and(n_in_row<MaxCur) do begin
    inc(n_in_row);
    last_row_empty:=(pos(',',inputstr)=length(inputstr));
    ss:=next(inputstr,#9);
    cut(ss,' ');
    if ss='' then begin
       outrow[n_in_row]:=NAN;
       err:=-1
    end else begin
       val(ss,outrow[n_in_row],err);
       if err>0 then exit else input_chain:=true
    end;
    if last_row_empty then begin inc(N_in_row); outrow[n_in_row]:=NAN end;
  end;
end;

function DX_load(keeploc,n:longint;var dfname:string):longint; export; stdcall ;
(* reading JCAMP ".DX" files *)
var i,l,j,_npts,locn,_colr,_lin,_sym,ninrow:integer;
    a,xcurrent,deltax,xfactor,yfactor,declared_z:single;
    rowdata:datatype;
    ax,ok:booleAn;
    readok,keycode:byte;
    c:char;
    datapairs,german: boolean;
    tmps,ss,ss1,ss2:string;
    dfile:text;
label block_start;
const DXKEY:string='FIRSTX_ LASTX__ XFACTOR YFACTOR XYDATA_ NPOINTS PRESSUR XYPOINT $LOC___ $COL___ $SYM___ $LIN___ XLABEL_ YLABEL_ BLOCKS_ ';
label dxl_exit,dx_skip_it;
begin
  DX_load:=0;
  if pos('.',dfname)=0 then dfname:=dfname+'.DX';
  assign(dfile,dfname);
  reset(dfile);
  if (ioresult<>0) then exit;
  if keeploc<>0 then n:=1;
  while not(eof(dfile)) do begin
      repeat
block_start:
       repeat
        readln(dfile,tmps);
        if ioresult<>0 then goto dxl_exit
       until (pos('##TITLE=',tmps)=1) or eof(dfile);
       if eof(dfile) then goto dxl_exit;
       delete(tmps,1,8);
       upshift(tmps);
       cut(tmps,' ');
       repeat
        readln(dfile,ss);
        if ioresult<>0 then goto dxl_exit
       until (pos('##DATA TYP',ss)=1) or eof(dfile); (*'TYP' instead of "TYPE=" to compensate for German acent in Specord files *)
       if eof(dfile) then goto dxl_exit;
       i:=pos('=',ss);
       german:=(i=11); (*German accent switch: if "DATA TYP=" *)
       delete(ss,1,i);
       upshift(ss);
       cut(ss,' ');
      until (pos('LINK',ss)=0) or eof(dfile);
      if eof(dfile) then goto dxl_exit;
      readok:=0;xfactor:=1;
      locn:=n;
      _sym:=0;
      _colr:=0;
      _lin:=4;
      declared_z:=NAN;
      repeat
        readln(dfile,ss);
        if ioresult<>0 then goto dxl_exit;
        cut(ss,' ');
        cut(ss,'#');
        ss1:=next(ss,'=');
        cut(ss1,' '); cut(ss,' ');
        ss2:=copy(ss1,1,7);
        keycode:=pos(ss2,dxkey);
        if keycode=113 then goto block_start; (* re-start if this is a german version with missing "LINK" header *)
        if not(keycode in [0,33,57,97,105]) then begin
           if german then begin
             l:=length(ss);
             if l>0 then for i:=1 to l do if ss[i]=',' then ss[i]:='.'
           end;
           val(ss,a,j);ok:=(j=0);
           if not(ok) then keycode:=0
        end;
        case keycode of
             1:begin xcurrent:=a; readok:=(readok or 1) end;
             9:begin deltax:=a; readok:=(readok or 2) end;
             17:xfactor:=a;
             25:begin yfactor:=a;  readok:=(readok or 4) end;
             41:begin _npts:=trunc(a); readok:=(readok or 8) end;
             49:declared_z:=a;
             33:datapairs:=false;
             57:begin datapairs:=true; readok:=(readok or 16) end;
             65:if (keeploc<>0) then begin l:=round(a); if (l>0) and (l<=MaxCur) then locn:=l end;
             73:_colr:=round(a);
             81:_sym:=round(a);
             89:_lin:=round(a);
             97:xyaxis[false]^.token:=ss;
            105:xyaxis[true]^.token:=ss
        end;
      until (keycode=33) or (keycode=57) or eof(dfile);
      if eof(dfile) then goto dxl_exit;
      if (readok<15) or ((readok<16)and(_npts<2)) then goto dx_skip_it;
      if keeploc=0 then begin
         while (Spectra.dir(n).npts<>0)and(n<maxcur) do inc(n);
         locn:=n
      end else if Spectra.dir(locn).npts<>0 then clearmem(locn);
      Spectra.dir(locn)^.head:=copy(tmps,1,48);
(* read curve *)
      if datapairs then begin
        l:=1;
        while (pos('##END=',ss)=0)and(not(eof(dfile))) do begin
          while pos(',',ss)<>0 do begin
            ss1:=next(ss,':');
            cut(ss1,':');
            ss2:=next(ss1,',');
            cut(ss2,' ');
            val(ss2,a,i);
            if i=0 then begin
                push(a,locn,false,l);
                cut(ss1,' ');
                val(ss1,a,i);
                push(a,locn,true,l);
                if i=0 then inc(l)
            end
          end;
          readln(dfile,ss);
        end
      end else begin
       deltax:=(deltax-xcurrent)/(_npts-1);
       if deltax=0 then goto dx_skip_it;
       repeat
        readln(dfile,ss);
        ok:=(ioresult=0);
        if ok then ok:=input_chain(ss,rowdata,ninrow)and(ninrow>1)and(Not(IsNAN(rowdata[1])));
        if ok then begin
          rowdata[1]:=rowdata[1]*xfactor;
          if abs((rowdata[1]-xcurrent)/deltax)>0.01 then xcurrent:=rowdata[1];
          j:=2;
          while (j<=ninrow)and(Not(IsNAN(rowdata[j]))) do begin
            l:=Spectra.dir(locn)^.npts+1;
            push(xcurrent,locn,false,l);push(rowdata[j]*yfactor,locn,true,l);
            inc(j);xcurrent:=xcurrent+deltax;
          end;
        end;
       until not(ok);
      end;
dx_skip_it:if Spectra.dir(locn)^.npts>0 then with Spectra.dir(locn)^ do begin
           if _lin>3 then begin
             ax:=(not(datapairs)) and (Spectra.dir(locn)^.npts>64)and(Spectra.dir(locn)^.npts<257);
             if ax then inter:=-1 else inter:=0;
             ax:=(not(ax)) or datapairs;
             if ax then connect:=-1 else connect:=0;
           end else begin
             if ((_lin and 1) <>0) then inter:=-1 else inter:=0;
             if ((_lin and 2) <>0) then connect:=-1 else connect:=0;
           end;
           symbol:=_sym;
           if _colr=0 then _colr:=((locn-1) mod 15)+1;
           plotcolor:=_colr;
           if not(IsNAN(declared_z)) then z:=declared_z;
           DX_load:=-1;
         end;
      if locn=n then if n<maxcur then n:=n+1 else n:=1;
   end; (* while not(eof(dfile) *)
dxl_exit:  close(dfile);
end;

function read_parameters(fname:string):boolean;
var i,ior,n:integer;
    axx,OK:boolean;
    xyaxis_:axis48;
    f48:real48;
    pfname:string;
begin
 result:=false; newformat:=false;
 pfname:=fname+'.SPC';
 assign(fspc,pfname);
 reset(fspc,blocksize);
 OK:=(ioresult=0);
 if not(OK) then exit;
 blockread(fspc,bitbuf,ParBlocks,ior);
 OK:=(ior>=(ParBlocks-1));
 if not OK then begin
    close(fspc);
    exit
 end;
 newformat:= (bitbuf[1]=255) and (bitbuf[3]=255) and (bitbuf[5]=255);
    (* the above is to probe if .SPC file starts with a 6-bit real number, as the
    old (3-file) format suggests *)
 if not newformat then begin
    close(fspc);
    pfname:=fname+'.PRM';
    assign(fspc,pfname);
    reset(fspc,blocksize);
    OK:=(ioresult=0);
    if not OK then exit;
    blockread(fspc,bitbuf,ParBlocks,ior);
    OK:=(ior>=(ParBlocks-1));
    if not OK then begin
      close(fspc);
      exit
    end;
 end;
 if OK then with prmblk^ do begin
    refnum.v:=bitbuf[2];
    nnorm.v:=bitbuf[4];
    move(bitbuf[108],xyaxis[false]^.footnote,81);
    move(bitbuf[222],xyaxis_,252);
    for axx:=false to true do with xyaxis[axx]^ do begin
      move(xyaxis_.off_,f48,6);off:=f48;
      move(xyaxis_.lim_,f48,6);lim:=f48;
      move(xyaxis_.factor_,f48,6);factor:=f48;
      move(xyaxis_.scale_,f48,6);scale:=round(f48);
      move(xyaxis_.bottom_,f48,6);bottom:=f48;
      if (xyaxis_.auto_<>0) then auto:=-1 else auto:=0;
      token:=xyaxis_.token_;
      n:=xyaxis_.nscaling_;
      for i:=1 to n do begin
         move(xyaxis_.scaling_[i],f48,6);
         scaling[i]:=f48
      end;
      nscaling:=n;
      for i:=1 to nscaling do scs[i]:=xyaxis_.scs_[i];
      move(bitbuf[474],xyaxis_,252);
    end;
    read_parameters:=true
 end;
 if (not(newformat) or not(OK)) then close(fspc);
 result:=OK
end;

function write_parameters(fname:string):boolean;
var i,ior:integer;
    axx,OK:boolean;
    xyaxis_:axis48;
    f48:real48;
begin
  result:=false;
  newformat:=(pos('.SPC',fname)<>0);
  assign(fspc,fname);
  rewrite(fspc,blocksize);
  if ioresult<>0 then exit;
  with prmblk^ do begin
    bitbuf[2]:=refnum.v;
    bitbuf[4]:=nnorm.v;
    bitbuf[1]:=255;
    bitbuf[3]:=255;
    bitbuf[5]:=255; {introducing a signature of new format }
    move(xyaxis[false]^.footnote,bitbuf[108],81);
    for axx:=false to true do with xyaxis[axx]^ do begin
      f48:=off;move(f48,xyaxis_.off_,6);
      f48:=lim;move(f48,xyaxis_.lim_,6);
      f48:=factor;move(f48,xyaxis_.factor_,6);
      f48:=scale;move(f48,xyaxis_.scale_,6);
      f48:=bottom;move(f48,xyaxis_.bottom_,6);
      if (auto<>0) then xyaxis_.auto_:=1 else xyaxis_.auto_:=0;
      xyaxis_.token_:=token;
      xyaxis_.nscaling_:=nscaling;
      for i:=1 to nscaling do begin
         f48:=scaling[i];
         move(f48,xyaxis_.scaling_[i],6);
      end;
      for i:=1 to nscaling do xyaxis_.scs_[i]:=scs[i];
      if axx then  move(xyaxis_,bitbuf[474],252) else  move(xyaxis_,bitbuf[222],252) ;
    end;
  end;
  BlockWrite(fspc,bitbuf,ParBlocks,ior);
  OK:=(ior=ParBlocks);
  if (not OK) or (not newformat) then
      close(fspc);
  result:=OK
end;

function SaveSPC(var dfname:string):longint;
var i,ior,j,k,reclen,lastnused,nblock,ncur:integer;
    int_buf:array[1..4] of smallint;
    a:single;
    ax:boolean;
    f48:real48;
    ss:shortstring;
label abort;
const off=45;
begin
  result:=0;
  i:=pos('.',dfname);
  if i<>0 then delete(dfname,i,255);
  if not(Write_Parameters(dfname+'.SPC')) then exit;
  lastnused:=maxcur;
  while (Spectra.dir(lastnused)^.npts=0)and(lastnused>0) do dec(lastnused);
  if lastnused=0 then exit;
  int_buf[1]:=lastnused;
  int_buf[2]:=n_locations_used;
  int_buf[3]:=obj^;
  int_buf[4]:=prmblk^.pntptr.v;
  FillChar(ds83,sizeof(ds83),0);
  move(int_buf,Ds83,8);
  blockwrite(fspc,Ds83,1);
  ior:=ioresult;
  if ior<>0 then goto abort;
  for k:=1 to maxcur do
   if Spectra.dir(k)^.npts>0 then with Spectra.dir(k)^ do begin
    ss:=head;
    if length(ss)>(42+off) then delete(ss,43+off,255);
    move(ss,ds83,43+off);
    ds83[45+off]:=npts div 256;
    ds83[44+off]:=npts mod 256;
    ds83[46+off]:=plotcolor;
    move(k,ds83[47+off],4);
    move(inter,ds83[51+off],3);
    IF (inter<>0) THEN ds83[51+off]:=255 ELSE DS83[51+off]:=0;
    IF (CONNECT<>0) then ds83[52+off]:=255 ELSE ds83[52+off]:=0;
    ds83[53+off]:=SYMBOL;
    if isNAN(z) then f48:=99999 else f48:=z; (* 99999 stays for "NAN" in SPLAB4 *)
    move(f48,ds83[54+off],6);
    move(f48,ds83[78+off],6); (* patch to comply with .dir reading error in SPLAB4 *)
    f48:=min[false];
    move(f48,ds83[60+off],6);
    f48:=min[true];
    move(f48,ds83[66+off],6);
    f48:=max[false];
    move(f48,ds83[72+off],6);
{   f48:=max[true];
    move(min,ds83[78+off],6); } (* commented to comply with .dir reading error in SPLAB4 *)
    blockwrite(fspc,ds83,1);
    if ioresult<>0 then goto abort;
    reclen:=(npts+31) div 32;
    for nblock:=0 to reclen-1 do begin
       for i:=1 to 32 do
         for ax:=false to true do begin
           pull(a,k,ax,nblock*32+i);
           realbuf[i,ax]:=a
         end;
       BlockWrite(fspc,realbuf,DataBlocks);
    end;
  end;
  result:=-1;
abort: close(fspc);
end;

function Read_my_SPC(var dfname:string):longint;
var i,j,k,l,ncur,nblock,locmaxcur,spclen,curnum,reclen,ior,off:integer;
    int_buf:array[1..4] of smallint;
    ax,thatsit:boolean;
    f48:real48;
label abort,abort1;
begin
  Result:=0;
  i:=pos('.',dfname);
  if i<>0 then delete(dfname,i,255);
  if not(Read_Parameters(dfname)) then exit;
  if not(newformat) then begin
     assign(fspc,dfname+'.SPC');
     reset(fspc);
     if ioresult<>0 then goto abort;
     assign(fds,dfname+'.DIR');
     reset(fds,83);
     if ioresult<>0 then goto abort;
     off:=0;
  end else off:=45;
  clear_all;
  Clear_Location(Not_Defined); { ClearAll}
  if not(newformat) then
      BlockRead(fds,ds83,1)
  else
      BlockRead(fspc,ds83,1);
  move(ds83,int_buf,8);
  locmaxcur:=int_buf[1];
  if locmaxcur>maxcur then locmaxcur:=maxcur;
  obj^:=int_buf[3];
  prmblk^.pntptr.v:=int_buf[4];
  i:=0; thatsit:=false;
  repeat
    inc(i);
    if not(newformat) then
       if i<=locmaxcur then begin
          BlockRead(fds,ds83,1,ior);
          if ior<>1 then goto abort
       end else thatsit:=true
   else
      if not(eof(fspc)) then begin
          BlockRead(fspc,ds83,1,ior);
          if ior<>1 then goto abort
      end else thatsit:=true;
   if newformat then move(ds83[47+off],curnum,4) else curnum:=i;
   if not(thatsit) then with Spectra.dir(curnum)^ do begin
     move(ds83,head,43+off);
     npts:=ds83[45+off]*256+ds83[44+off];
     plotcolor:=ds83[46+off] AND $0f;
     if ((DS83[46+off] AND $f0)<>0) then plotcolor:=plotcolor or $80;
     IF (ds83[51+off]<>0) THEN INTER:=-1 ELSE INTER:=0;
     IF (ds83[52+off]<>0) THEN CONNECT:=-1 ELSE connect:=0;
     SYMBOL:=DS83[53+off] AND $07;
     move(ds83[54+off],f48,6);
     if f48=99999 then z:=NAN else z:=f48;
     move(ds83[60+off],f48,6); min[false]:=f48;
     move(ds83[66+off],f48,6); min[true]:=f48;
     move(ds83[72+off],f48,6); max[false]:=f48;
     move(ds83[78+off],f48,6); max[true]:=f48;
     spclen:=npts;
     if spclen>0 then begin
       reclen:=(spclen+31) div 32;
       for nblock:=0 to reclen-1 do begin
         blockread(fspc,realbuf,DataBlocks);
         for j:=1 to 32 do begin
           l:=nblock*32+j;
           if l<=spclen then for ax:=false to true do
             push(realbuf[j,ax],curnum,ax,l);
           if l<0 then goto abort
         end
       end
     end
   end
  until thatsit;
  thatsit:=(ioresult=0);
  if thatsit then Result:=-1;
abort: if not(newformat) then close(fds);
abort1: close(fspc);
end;

function GRAMSload(var dfname:string):longint;
 var i,n,ns,nspec:integer;
     spcf:spcfile;
begin
 with spcf do begin
    gramsload:=0;n:=obj^;
    nspec:=ouvrir(dfname);
    if nspec=0  then exit;
    for ns:=1 to nspec do begin
        if not(readnextblock) then exit;
        while (n<maxcur) and (Spectra.dir(n)^.npts<>0) do inc(n);
        if Spectra.dir(n)^.npts<>0 then exit;
        if ns=1 then begin
          Spectra.dir(n)^.head:=copy(scmnt,1,44);
          if nspec>1 then Spectra.dir(n)^.head:=Spectra.dir(n)^.head+'(#01)'
        end else begin
         str(ns:2,Spectra.dir(n)^.head);
         if Spectra.dir(n)^.head[1]=' ' then Spectra.dir(n)^.head[1]:='0';
         Spectra.dir(n)^.head:='#'+Spectra.dir(n)^.head
        end;
        for i:=1 to curnpts do begin
          push(xvalue(i),n,false,i);
          push(yvalue(i),n,true,i)
	      end;
        Spectra.dir(n)^.inter:=0;
        Spectra.dir(n)^.connect:=-1;
        Spectra.dir(n)^.symbol:=0;
        Spectra.dir(n)^.z:=zvalue;
    end;(* for ns *)
    fermer;
    gramsload:=-1;
 end (* with bww *)
end;

function readSPC(var dfname:string):longint;
var bfile:file of byte;
    i:integer;
    b1,b2:byte;
begin
 result:=0;
 i:=pos('.',dfname);
 if i<>0 then delete(dfname,i,255);
 assign(bfile,dfname+'.SPC');
 reset(bfile);
 if ioresult<>0 then exit;
 read(bfile,b1,b2);
 close(bfile);
 if b2<>$4B then result:=read_my_spc(dfname) else result:=gramsload(dfname);
 result:=-1
end;

end.

