{$H-}
unit curfit_ini;
interface
uses IniFiles,curfit_def,optidef,Link2Splab,spl32def;

procedure read_optiprm(var nitmax_:longint;  rsplabdir:pointer); export; stdcall;
procedure write_optiprm(var splabdir:shortstring); export; stdcall;
function mode2curfit(var modl:longint):longint; export; stdcall;
function CurfitInit (var modl:longint):longint; export; stdcall;

implementation

procedure read_optiprm(var nitmax_:longint; rsplabdir:pointer); export; stdcall;
var IniFile: TIniFile;
    splabdir:^string;
    ss:string;


begin
  optiprm:=addr(nitmax_);
  splabdir:=rsplabdir;
  ss:=splabdir^+'\'+'curfit.ini';
  with optiprm^ do begin
     IniFile:=TIniFile.Create(ss);
     nitmax:=IniFile.ReadInteger('Curfit','MaxIterations',1000);
     accur:=IniFile.ReadInteger('Curfit','Accuracy*1E6',1000)*1E-6;
     smin:=1-IniFile.ReadInteger('Curfit','RhoSquareMax*1E6',995000)*1E-6;
     FitGlobal:=IniFile.ReadInteger('Curfit','FitGlobal',0);
     lambda:=IniFile.ReadInteger('Marquardt','ShiftFactor*1E6',1000000)*1E-6;
     nu:=IniFile.ReadInteger('Marquardt','DescFactor*1E6',2000000)*1E-6;
     autolambda:=IniFile.ReadInteger('Marquardt','AutoShift',-1);
     alpha:=IniFile.ReadInteger('Simplex','SimplexSize*1000',5000)*1E-6;
  end;
  IniFile.Free ;
end;

procedure write_optiprm(var splabdir:shortstring); export; stdcall;
var IniFile: TIniFile;

begin
  with optiprm^ do begin
     IniFile:=TIniFile.Create(splabdir+'\'+'curfit.ini');
     IniFile.WriteInteger('Curfit','MaxIterations',nitmax);
     IniFile.WriteInteger('Curfit','Accuracy*1E6',round(accur*1E6));
     IniFile.WriteInteger('Curfit','RhoSquareMax*1E6',round((1-smin)*1E6));
     IniFile.WriteInteger('Curfit','FitGlobal',FitGlobal);
     IniFile.WriteInteger('Marquardt','ShiftFactor*1E6',round(lambda*1e6));
     IniFile.WriteInteger('Marquardt','DescFactor*1E6',round(nu*1e6));
     IniFile.WriteInteger('Marquardt','AutoShift',autolambda);
     IniFile.WriteInteger('Simplex','SimplexSize*1E6',round(alpha*1e6));
  end;
  IniFile.Free ;
end;

function mode2curfit(var modl:longint):longint; export; stdcall;
begin
  curmode:=addr(modl);
  result:=-1;
end;

function CurfitInit (var modl:longint):longint; export; stdcall;
begin
  curmode:=addr(modl);
  Connect2Splab;
  result:=-1
end;

end.

