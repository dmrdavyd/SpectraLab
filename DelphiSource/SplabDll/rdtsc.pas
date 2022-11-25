{ -----------------------------------------------------------------------------}
{ Copyright 2000-2001, Zloba Alexander.  All Rights Reserved.                  }
{ This unit can be freely used and distributed in commercial and private       }
{ environments, provided this notice is not modified in any way.               }
{ -----------------------------------------------------------------------------}
{ Feel free to contact me if you have any questions, comments or suggestions at}
{     zal@specosoft.com (Zloba Alexander)                                      }
{ You can always find the latest version of this unit at:                      }
{   http://www.specosoft.com                                                   }
{ -----------------------------------------------------------------------------}
{ Date last modified:  29/11/2001                                              }
{ -----------------------------------------------------------------------------}
{ Description:                                                                 }
{   This unit include function to work with RDTSC instruction of pentium       }
{    processors                                                                }
{  Example 1:                                                                  }
{     var ticks:int64;                                                         }
{     ...                                                                      }
{     ticks := cpugettick;                                                     }
{      dosomething;                                                            }
{     label1.caption := format('"dosomething" time = %d ms',[cpugetms(ticks)]) }
{  Example 2:                                                                  }
{     var tick1,tick2:int64;                                                   }
{     ...                                                                      }
{     tick1 := cpugettick;                                                     }
{      dosomething;                                                            }
{     tick2 := cpugettick;                                                     }
{      ... // do other work                                                    }
{     label1.caption := format('"dosomething" time = %d ms',                   }
{                              [cpucalcms(tick2,tick1)])                       }
{                                                                              }
{------------------------------------------------------------------------------}
{ Revision History:                                                            }
{ 1.00:  + First public release                                                }
{ 1.10:  + Change const SleepTime   to 200 for better work under win95-98      }
{ 1.20:  + Added function to calculate nanoseconds interval                    }
{ 1.30:  - Remove unit Dialogs from unit clause                                }
{------------------------------------------------------------------------------}


unit rdtsc;

interface

uses windows;

//
//  Used when determine the CPU frequency
const SleepTime:dword = 200;

Var
//
//  CPU frequency MHz
   CPUFrequency : dword = 0;

//
//  _1CPUFrequencyMS := 0.001/CPUFrequency
  _1CPUFrequencyMS : extended;
  _1CPUFrequencyMKS : extended;
  _1CPUFrequencyNS : extended;

//
// Measure CPU frequency
//
  function cpuGetSpeed: WORD;
  function CPUgetspeedaccurate(const SleepTime:integer):double;

  function cpuGetTick:int64; export; register;
  function cpuGetms( Tick:int64 ):dword; export; register;
  function cpuGetmks( Tick:int64 ):dword; export; register;
  function cpugetns( Tick:int64 ):dword;  export; register;

  function cpumstotick( Value:dword ):int64;
  function cpumkstotick( Value:dword ):int64;
  function cpunstotick( Value:dword ):int64;


  function cpucalcms(const Tick1,Tick2:int64 ):int64;
  function cpucalcmks(const Tick1,Tick2:int64 ):int64;
  function cpucalcns(const Tick1,Tick2:int64 ):int64;

implementation

var inited:boolean=false;

function cpugettick:int64;
asm
    dw 310Fh // rdtsc
end;


Function cpugetms( Tick:int64 ):dword;
begin
  asm
    dw 310Fh // rdtsc
    sub eax, dword [Tick]
    sbb edx, dword [Tick+4]
    mov dword[Tick], eax
    mov dword[Tick+4], edx
  end;
  if not inited then cpugetspeed;
  result:=round(Tick*_1CPUFrequencyMS);
end;

Function cpugetmks( Tick:int64 ):dword;
begin
  asm
    dw 310Fh // rdtsc
    sub eax, dword [Tick]
    sbb edx, dword [Tick+4]
    mov dword[Tick], eax
    mov dword[Tick+4], edx
  end;
  if not inited then cpugetspeed;
  result:=round(Tick*_1CPUFrequencyMKS);
end;

Function cpugetns( Tick:int64 ):dword;
begin
  asm
    dw 310Fh // rdtsc
    sub eax, dword [Tick]
    sbb edx, dword [Tick+4]
    mov dword[Tick], eax
    mov dword[Tick+4], edx
  end;
  if not inited then cpugetspeed;
  result:=round(Tick*_1CPUFrequencyNS);
end;

function cpucalcns(const Tick1,Tick2:int64 ):int64;
begin
  if not inited then cpugetspeed;
  result:=round(abs(Tick2-Tick1)*_1CPUFrequencyNS);
end;

function cpucalcmks(const Tick1,Tick2:int64 ):int64;
begin
  if not inited then cpugetspeed;
  result:=round(abs(Tick2-Tick1)*_1CPUFrequencyMKS);
end;

function cpucalcms(const Tick1,Tick2:int64 ):int64;
begin
  if not inited then cpugetspeed;
  result:=round(abs(Tick2-Tick1)*_1CPUFrequencyMS);
end;


function cpumstotick( Value:dword ):int64;
begin
  if not inited then cpugetspeed;
  result:=round(Value/_1CPUFrequencyMS);
end;

function cpumkstotick( Value:dword ):int64;
begin
  if not inited then cpugetspeed;
  result:=round(Value/_1CPUFrequencyMkS);
end;

function cpunstotick( Value:dword ):int64;
begin
  if not inited then cpugetspeed;
  result:=round(Value/_1CPUFrequencyNS);
end;



function CPUGetSpeed: WORD;
var _cpufreq: dword;
    len:integer;
    rh:HKEY;
    pr:dword;
begin
  result := 0;
  if CPUFrequency <> 0 then begin
   Result := CPUFrequency;
   exit;
  end;
   if regOpenKeyEx(HKEY_LOCAL_MACHINE,
                   'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
                   0, KEY_READ, rh) = ERROR_SUCCESS
   then begin
    if RegQueryValueEx(rh,'~MHz', nil,@pr, @_cpufreq, @len) = ERROR_SUCCESS then begin
     Result := _cpufreq;
     CPUFrequency := _cpufreq;
    end
    else begin
      Result := trunc(cpugetspeedAccurate(SleepTime)+0.5);
      CPUFrequency := Result;
    end;
    RegCloseKey( rh );
   end;
  _1CPUFrequencyMS := 0.001/CPUFrequency;
  _1CPUFrequencyMKS := 1/CPUFrequency;
  _1CPUFrequencyNS := 1000/CPUFrequency;
   inited := true;
end;

function CPUgetspeedaccurate(const SleepTime:integer):double;
var
    i1,i2,t:int64;
    pr:dword;
begin
  pr := GetThreadPriority(GetCurrentThread );
  SetThreadPriority(GetCurrentThread,THREAD_PRIORITY_TIME_CRITICAL);
  QueryPerformanceCounter( i1 );
  t := cpugettick;
  Sleep(SleepTime);
  asm
    dw 310Fh // rdtsc
    sub eax, dword[t]
    sbb edx, dword[t+4]
    mov dword[t], eax
    mov dword[t+4], edx
  end;
  QueryPerformanceCounter( i2 );
  i2 := i2-i1;
  QueryPerformanceFrequency( i1 );
  i2 := i2*1000000 div i1;
  Result := t/(i2);
  SetThreadPriority(GetCurrentThread,pr);
end;

end.
