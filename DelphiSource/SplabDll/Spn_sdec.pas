unit Spn_Sdec;
interface
uses Matrix,
     SPL32BASE,
     Spl32def,
     SPL32STR,
     SplabMessages,
     Math,
     WinTypes,
     WinProcs,
     Win32crt;


var covar:mtype;
{    lista:inarr; }
    lfitparm:partype;
    lfitrho:extended;

{ function readstandards(sdest:integer;tabname:string):integer; }

function input_list(rliststr,routrow:pointer):integer; export; stdcall;
function lfit(iy,ir,ip,nstd,polyorder,offst:longint; var lista:inarr;disp:longint)
(* #mem. spec. to decompose,#mem weight,#Dest fit res,#Dest poly,nstd,polyorder*)
                                           :longint; export; stdcall;
function readstandards(sdest:longint; var tabname:string):longint; export; stdcall;

implementation

var    outrow:^inarr;
       liststring:^string;
function input_list(rliststr,routrow:pointer):integer; stdcall;
var i:integer;
    ss,inputstr:string;
    a:longint;
    n_in_row:integer;
begin
  outrow:=routrow;
  liststring:=rliststr;
  n_in_row:=0;
  cut(liststring^,#32);
  inputstr:=liststring^;
  while (inputstr<>'')and(n_in_row<MaxLista) do begin
    ss:=next(inputstr,#9);
    cut(ss,' ');
    val(ss,a,i);
    if i=0 then begin
      inc(n_in_row);
      outrow^[n_in_row]:=a
    end else begin
      result:=0;
      exit
    end
  end;
  if (n_in_row>0)and(n_in_row<MaxLista) then for i:=n_in_row+1 to maxlista do outrow^[i]:=0;
  result:=n_in_row
end;


function fread(var ss:string;var ok:boolean):extended;
var i,j,err:integer;
    ss1:string;
    a:extended;
begin
  i:=1;
  ok:=false;
  ss1:=next(ss,',');
  while not(ss1[i] in ['0'..'9','.','+','-','E'])and(i<length(ss1)) do inc(i);
  delete(ss1,1,i-1);
  i:=1;
  while (i<=length(ss1))and(ss1[i] in ['0'..'9','.','+','-','E']) do inc(i);
  ss1:=copy(ss1,1,i-1);
  val(ss1,a,err);
  fread:=a;
  ok:=(err=0)
end;

function readstandards(sdest:longint; var tabname:shortstring):longint; export; stdcall;
var i,j,n,k:integer;
    a,x,xcalc,dw:real;
    ok:boolean;
    dfile:text;
    w0,w9,sx:single;
    convstr,ss:shortstring;
    quote:boolean;
begin
  readstandards:=0;
  ss:=tabname;
  if getn(obj^)<2 then exit;
  if (sdest<mincur)or(sdest>maxcur) then exit;
  if pos('.',ss)=0 then ss:=ss+'.ASC';
  if (pos('\',ss)=0)and(pos(':',ss)=0) then
     ss:=concat(prmblk^.splabdir^,'\standards\',ss);
  assign(dfile,ss);
  reset(dfile);
  if ioresult<>0 then begin
     ss:='File not found';
     SplabErrorMessage(ss);
     exit
  end;
  pull(w9,obj^,false,2);
  pull(w0,obj^,false,1);
  dw:=w9-w0;
  dw:=dw/100;
  ss:='File of standards read error';
  readln(dfile,convstr);
  if ioresult<>0 then begin
     SplabErrorMessage(ss);
     exit
  end;
  n:=0;
  next(convstr,',');
  cut(convstr,' ');
  if pos('"',convstr)=1 then begin
   n:=1;
   while pos(',"',convstr)<>0 do begin
    i:=pos(',"',convstr);
    delete(convstr,i,1);
    inc(n)
   end;
  end;
  if (n=0)or((sdest<=0)and((sdest+n-1)>0))or((sdest+n-1)>maxcur) then begin
    close(dfile);
    SplabErrorMessage(ss);
    exit
  end;
  for i:=sdest to sdest+n-1 do Clear_Location(i);
  for i:=sdest to sdest+n-1 do begin
    cut(convstr,'"');
    Spectra.dir(i)^.head:=next(convstr,'"');
  end;
  i:=0;
  quote:=false;
  repeat
    pull(sx,obj^,false,i+1);
    xcalc:=sx;
    repeat
      readln(dfile,convstr);
       if (ioresult<>0)or(eof(dfile)) then begin
          SplabErrorMessage(ss);
         exit;
         close(dfile);
         exit
      end;
      if pos(',"',convstr)=1 then quote:=true else x:=fread(convstr,ok);
    until (ok)and(quote or (abs(x-xcalc)<=dw));
    if (not(quote))and((abs(x-xcalc))<=dw) then begin
     inc(i);
     for k:=1 to n do begin
      a:=fread(convstr,ok);
      if ok then begin
         push(a,sdest+k-1,true,i);
         push(x,sdest+k-1,false,i);
      end else i:=0;
     end;
    end;
  until (i=0)or (quote) or (i>=getn(obj^))or(EOF(dfile));
  j:=getn(obj^);
  ok:=(i=j);
  if quote then begin  (* parsing the format alternative: trailing headers *)
    i:=1;
    repeat
      cut(convstr,',');
      cut(convstr,'"');
      Spectra.dir(i)^.head:=convstr;
      inc(i);
      readln(dfile,convstr);
    until (ioresult<>0)or(EOF(dfile)) or (i>n)
  end;
  if ok then readstandards:=n else begin
    for k:=sdest to sdest+n do Clear_Location(k);
    ss:='Sampling in the file of standards does not match the original';
    SplabErrorMessage(ss);
    close(dfile)
  end
end;


function lfit(iy,ir,ip,nstd,polyorder,offst:longint; var lista:inarr;disp:longint)
(* #spectrum.to fit,#mem weight,#Dest.fit res,#Dest.poly,nstd,polyorder*)
                                           :longint; export; stdcall;

var k,j,i,ndata,mfit,iw,i0,i9,ii,iii:integer;
    my,sy,sum,sum1,wt:extended;
    ym,tmp:single;
    erro:boolean;
    powx:single;
    ss:shortstring;
    key:char;

function afunc(ix,i:integer):extended;
var j:integer;
begin
  if ((i<1)or(i>Mfit)) then
       afunc:=0
  else
   if (i<=(polyorder+1)) then
     if i=1 then
       powx:=1
     else powx:=powx*ix
  else
    pull(powx,lista[i-polyorder-1],true,ix);
  afunc:=powx
end;

begin
  result:=0;
  iw:=lista[0];
  ndata:=getn(iy);
  for i:=1 to nstd do begin
    ii:=getn(lista[i]);
    if ii<ndata then ndata:=ii;
  end;
  if ndata<2 then begin
     ss:='SURFIT: Bad set of standards (uneven sampling)';
     SplabErrorMessage(ss);
     exit
  end;
  mfit:=nstd+polyorder+1;
  for j:=1 to mfit do
    for k:=1 to mfit+1 do covar[J,K]:=0;
  i0:=1;i9:=ndata;
  if offst<0 then i0:=abs(offst)+1 else i9:=ndata-offst;
  ndata:=ndata-abs(offst);
  for i:=i0 to i9 do begin
     pull(ym,iy,true,i);
     ii:=i+offst;
     for j:=1 to mfit do begin
       wt:=afunc(ii,j);
       if iw>=mincur then begin
          pull(tmp,iw,true,ii);wt:=wt*tmp
       end;
       for k:=1 to j do covar[j,k]:=covar[j,k]+wt*afunc(ii,k);
       covar[j,mfit+1]:=covar[j,mfit+1]+ym*wt
     end
   end;
   if mfit>1 then
     for j:=2 to mfit do for k:=1 to j-1 do covar[k,j]:=covar[j,k];
   gauss(covar,mfit,lfitparm,erro);
   if erro then begin
        ss:='SURFIT: Matrix is singular';
        SplabErrorMessage(ss);
        exit
   end;
   my:=0;
   for i:=i0 to i9 do begin pull(tmp,iy,true,i);my:=my+tmp end;
   my:=my/ndata;
   sy:=0;
   lfitrho:=0;
   for i:=i0 to i9 do begin
      ii:=i+offst;
      if i0>1 then iii:=i+offst else iii:=i;
      sum:=0;
      if mfit>nstd then begin
       for j:=1 to mfit-nstd do begin
        tmp:=lfitparm[j]*afunc(ii,j);
        sum:=sum+tmp;
       end;
       if ip<>0 then begin
        pull(tmp,iy,false,i);
        push(tmp,ip,false,iii);
        push(sum,ip,true,iii)
       end
      end;
      if nstd>0 then
       for j:=mfit-nstd+1 to mfit do begin
        tmp:=lfitparm[j]*afunc(ii,j);
        sum:=sum+tmp;
       end;
      if ir<>0 then begin
         pull(tmp,iy,false,i);
         push(tmp,ir,false,iii);
         push(sum,ir,true,iii)
      end;
      pull(tmp,iy,true,i);
      tmp:=tmp-sum;
      lfitrho:=lfitrho+tmp*tmp;
      pull(tmp,iy,true,i);
      tmp:=(tmp-my);
      sy:=sy+tmp*tmp;
   end;
   if sy<>0 then lfitrho:=1-lfitrho/sy else lfitrho:=1;
   if (ip<>0)and(nstd<mfit) then with spectra.dir(ip)^ do begin
        head:='p#';
        str(obj^:2,ss);
        cut(ss,' ');
        head:=head+ss+':';
        for i:=1 to mfit-nstd do if length(head)<36 then begin
         head:=head+' ';
         tmp:=lfitparm[i];
         if abs(tmp)<1000 then
           if abs(tmp)>=1E-2 then str(tmp:8:4,ss)
             else  str(tmp:12:-3,ss)
          else
            if abs(tmp)<1000 then str(tmp:8:2,ss)
         else str(tmp:12:-3,ss);
         j:=pos('E',ss);
         if j>0 then begin
          while (j<length(ss))and(ss[j+1]='-') do inc(j);
          while (j<length(ss))and(not(ss[j+1] in ['1'..'9'])) do delete(ss,j+1,1);
         end;
         cut(ss,' ');
         head:=head+ss
        end
   end;
   if not(spectra.newfitprm(obj^)) then spectra.clearfitprm(obj^);
   with spectra.fitprm(obj^)^ do begin
     prm[0]:=lfitrho;
     dev[0]:=NAN;
     fitting_path:=0;
     mode:=0;
     submode:=0;
     for i:=1 to mfit do prm[i]:=lfitparm[i];
     n_it:=mfit;
     if (ir<>0)and(nstd<>0) then with spectra.dir(ir)^ do begin
        head:='f#';
        str(obj^:2,ss);cut(ss,' ');
        head:=head+ss+'(';
        str(lfitrho:7:4,ss);cut(ss,' ');
        head:=head+ss+'):';
        for i:=1 to nstd do if length(head)<36 then begin
         head:=head+' ';
         tmp:=lfitparm[mfit-nstd+i];
         if abs(tmp)<1000 then
           if abs(tmp)>=1E-2 then str(tmp:8:4,ss)
             else  str(tmp:12:-3,ss)
          else
            if abs(tmp)<1000 then str(tmp:8:2,ss)
         else str(tmp:12:-3,ss);
         j:=pos('E',ss);
         if j>0 then begin
          while (j<length(ss))and(ss[j+1]='-') do inc(j);
          while (j<length(ss))and(not(ss[j+1] in ['1'..'9'])) do delete(ss,j+1,1);
         end;
         cut(ss,' ');
         head:=head+ss
        end; (* for i *)
     end (* with spectra.dir *)
   end; (* with spectra.fitprm *)
   result:=round(lfitrho*1E6);
   if disp<>0 then begin
    clrscr;
    ss:=Spectra.dir(obj^)^.head;
    if length(ss)=0 then begin
        str(obj^:3,ss); cut(ss,' ');
        ss:=concat('Spectrum #',ss);
    end;
    ss:=copy(ss,1,36); cut(ss,' ');
    ss:=concat('« ',ss,' »');
    while length(ss)<40 do ss:=concat(' ',ss,' ');
    gotoxy(1,2); write(ss);
    gotoxy (1,3);
    write('________________________________________');

    for i:=1 to nstd do begin
       j:=lista[i];
       gotoxy(3,i+4);
       with  Spectra.dir(j)^ do if head<>'' then
        begin
          ss:=head;
          if length(ss)>10 then begin ss:=next(ss,#9); ss:=copy(ss,1,10) end;
          ss:=concat('[',ss,']')
        end
      else
        begin str(i:2,ss); ss:=concat('[Compound',ss,']') end;
       ss:=ss+' = ';
       write(ss);
       gotoxy(18,i+4);
       write(Spectra.fitprm(obj^)^.prm[i+1+polyorder]:16:6);
    end;
    str(Spectra.fitprm(obj^)^.prm[0]:16:6,ss);
    gotoxy(3,nstd+6);
    write('Sq.corr.coef.=');
    gotoxy(18,nstd+6);
    write(ss);
   end
end;


end.
