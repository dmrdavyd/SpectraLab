unit OPTIDEF;
{$H-}
interface

const nparmax=20;
      maxnmodes=32;

type  par_names = array[1..nparmax] of shortstring;
      mode_names = array[1..maxnmodes] of shortstring;

      moderecord44th=record
         modl,dummy8: longint;
         submodl,dummy9: longint;
         ip,DUMMY1:  LONGINT;
         nv,dummy2:  longint;
         CE,dummy3:  longint;
         sx,dummy4:  longint;
         mq,dummy5:  longint;
         d3,dummy6:  longint;
         np,dummy7:  longint;
         pmin: extended;
         pmax: extended;
         u:    extended;
         dummy10: longint;
         mn:  shortstring;
         dummy11: longint;
         vn:  shortstring;
         dummy12: longint;
         pn:  shortstring;
         dummy13: longint;
         pnames: par_names;
         dummy14: longint;
         parmask: longint;
         dummy15: longint;
         modename:mode_names
      end;

      shortmoderecord44th=record
         modl,dummy8: longint;
         submodl,dummy9: longint;
         ip,DUMMY1:  LONGINT;
         nv,dummy2:  longint;
         CE,dummy3:  longint;
         sx,dummy4:  longint;
         mq,dummy5:  longint;
         d3,dummy6:  longint;
         np,dummy7:  longint;
         pmin: extended;
         pmax: extended;
         u:    extended;
         dummy10: longint;
         mn:  shortstring;
         dummy11: longint;
         vn:  shortstring;
         dummy12: longint;
         pn:  shortstring;
         dummy13: longint;
         pnames: par_names;
      end;

      moderecord=record
         submodl:integer;
         ip:  integer;
         nv:  integer;
         CE:  boolean;
         sx:  boolean;
         mq:  boolean;
         d3:  boolean;
         np:  integer;
         pmin: extended;
         pmax: extended;
         u:    extended;
         mn:   shortstring;
         vn:   shortstring;
         pn:   shortstring;
         pnames: par_names;
         parmask: longint;
      end;

      rmr44th=^moderecord44th;
      srmr44th=^shortmoderecord44th;
      rmoderecord=^moderecord;

var curmode:rmr44th;
    shortcurmode:srmr44th;

implementation

end.




