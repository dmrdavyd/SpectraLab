unit Link2splab;
interface
uses spl32def;

var obj: ^longint;
    prmblk: r_splab_param_block;
    dir,curdef: rDataSpec;
    XYaxis: BiAxis;
    RSpectra:rarrayofdir;

function push(v:single;n:integer;ax:boolean;var i:integer):boolean;
function pull(var a:single;n:integer;ax:boolean;i:integer):boolean;
function getn(curnum:integer): integer;
function getz(curnum:integer): single;
function GetRef2Spec(n:integer):pointer;
procedure ClearLocation(n:integer);
function GetRef2Axis(Ax:boolean):pointer;
function n_locations_used: integer;
function GetDirAddr(memno:longint): pointer; 
procedure minimaXY(curno:integer; ax,takeall :boolean);
procedure Connect2Splab;

implementation

function GetRef2Axis(Ax:boolean):pointer; register;external 'SplabDll.DLL' name 'GetRef2Axis';
function ptr2obj: pointer; register; external 'SplabDLL.DLL' name 'ptr2obj' ;
function ptr2prmblock: pointer; register; external 'SplabDLL.DLL' name 'ptr2prmblock' ;
function GetDirAddr(memno:longint): pointer; register; external 'SplabDLL.DLL' name 'GetDirAddr' ;
procedure minimaXY(curno:integer; ax,takeall :boolean); register; external 'SplabDLL.DLL' name 'minimaXY' ;

procedure Connect2Splab;
begin
  obj:=ptr2obj;
  prmblk:=ptr2prmblock;
  rSpectra:=GetDirAddr(-32768);
  dir:=rSpectra.GetDirPtr(obj^);
  XYAxis[false]:=GetRef2Axis(false);
  XYAxis[true]:=GetRef2Axis(true);
end;

function n_locations_used: integer;
begin
 result:=rSpectra^.NLocUsed
end;

function push(v:single;n:integer;ax:boolean;var i:integer):boolean;
begin
  result:=rSpectra^.PushPnt(v,n,ax,i)
end;

function pull(var a:single;n:integer;ax:boolean;i:integer):boolean;
begin
  result:=rSpectra^.pullPnt(a,n,ax,i)
end;

function getn(curnum:integer):integer;
begin
  result:=rSpectra^.GetNpts(curnum)
end;

function getz(curnum:integer): single;
begin
  result:=rSpectra^.GetZValue(curnum)
end;

function GetRef2Spec(n:integer):pointer;
begin
  result:=rSpectra^.GetDirPtr(n)
end;

procedure ClearLocation(n:integer);
begin
  rSpectra^.ClearLoc(n)
end;

end.
