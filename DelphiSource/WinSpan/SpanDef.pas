 {$H-}
 {$I-}
unit SpanDef;
interface
uses (*Windos,Wincrt,*) matrix;

CONST
      Mincur=-5;
      MaxCur=160;
      OX=FALSE;OY=TRUE;
      MaxP=10;
      MaxDepth=2;
      Ilen=29;Ihigh=8;
      DataMax=64;
      MaxBlock=16;
      MaxPar=10;
      MaxReal=1e38;
      MaxValues=50;
      MinReal=1e-999;
      N_MENU=13;
      N_KEYS=14;

      ERR_INPAR='Invalid parameters';
      ERR_FILEIN='Can''t read file';
      ERR_FILEOUT='Can''t save data';
      ERR_NOFILE='File not found';
      ERR_EMPTY='Memory location is empty';
      ERR_CHAIN='Chaining error';
      ERR_PRESS='Pressure control error';
      ERR_CALC='Calculation syntax error';
      ERR_STACK='Calculation stack overflow';
      ERR_EMPTYSTACK='Calculation stack is empty';
      LPTERR='Printer is not ready';
TYPE
   XYdata=array [1..datamax] of single;
   rdata=^xydata;
   DataSet=array[false..true] of xydata;
   RDataSet=^dataset;
   reftype=array [1..MaxBlock] of rdataset;

   DataSpec=record
    head              :string[42];
    npts              :smallint;
    plotcolor         :byte;
    spare             :pointer;
    inter,connect     :boolean;
    symbol            :char;
    z                 :real48;
    min:array [false..true] of real48;
    max:array [false..true] of real48;
    ref               :reftype;
  end;

  DirBufType=record
    head:string[42];
    npts:smallint;
    plotcolor:byte;
    Ref:pointer;
    inter,connect:boolean;
    symbol:char;
    z:real48;
    min:array [false..true] of real48;
    max:array [false..true] of real48;
  end;

  b6=array[1..6] of byte;
  string48=string[48];
  array10r=array[1..10] of b6;
  array10s=array[1..10] of string[10];

  AxisBuf=record
      auto            :boolean;
      token           :string48;
      nscaling        :smallint; (*52*)
      scaling         :array10r;
      scs             :array[1..10] of string[10];
      off,lim,factor,
      scale,bottom    :real48
  end;

  AxisType=record
      auto            :boolean;
      token           :string48;
      nscaling        :smallint;
      scaling         :array [1..10] of real48;
      scs             :array [1..10] of string[10];
      off,lim,factor,
      scale,bottom    :real48
  end;

  BIAxis=array[false..true] of axistype;
  BIAxisBuf=array[false..true] of axisbuf;

  RString=^string;
  c2=array[1..2] of char;

  StorType=record
       b_           :array[1..5] of byte;
       i_           :array[1..3] of smallint;
       r_           :array[1..16] of b6;
       cs           :string[80];
       fs           :string[32];
       axbuf        :biaxisbuf
     end;

var

    auto_corr, scan_on, ax, converting,regx, scc, ext :boolean;
    cmd,b                                             :byte;
    obj, firstdisp, n_locations_used, dir,
    nex,cornum,nptoget, refnum, tchp                  :smallint;
    li                                                :integer;
    x, dx, y, temp, temp1, temp2, mini, maxi,
    start_w, end_w, correct_w, meas_w, ref_w,
    scan_step, scan_rate, corval, dt1, dt2            :single;
    dir_str,cmdr                                      :rstring;
    wptr                                              :pointer;
    comandline,convstr,parameters,edstr,ss            :string;
    comment                                           :string[80];
    sysname,fname                                     :string;
    dfile                                             :text;
    ddir                                              :array [mincur..maxcur] of dataspec;
    xyaxis                                            :biaxis;

implementation

end.

