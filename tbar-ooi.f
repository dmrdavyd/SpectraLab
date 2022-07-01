
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Here is the TOOLBAR for SPLAB32
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

  ToolBar Splab-Tool-Bar "SPLAB1TB.BMP"

        08 HSpace
     1 PictureButton                   false load-data
        Refresh: Splab-Window
        obj @ plot ;
        ButtonInfo"  load Data File "                \ tooltip for open text

     2 PictureButton
          Refresh: Splab-Window
          replot-it
          false save-data
       ;   \ save in .DX
        ButtonInfo"  Save Data File "                \ tooltip for open text
     3 PictureButton
          Refresh: Splab-Window
          replot-it
          8 print-chart
        ;   \ print
        ButtonInfo"  Print File "                    \ tooltip for print
        8 HSpace                                     \ a space between button

     18 PictureButton
          Refresh: Splab-Window
          Curfit ;
        ButtonInfo" Curve Fitting "

     19 PictureButton
          Refresh: Splab-Window
          Surfit-Dialog ;
        ButtonInfo" LSQ-Decomposition (SurFit) "


     20 PictureButton
             Run-SPAN
             Refresh: Splab-Window
             replot-it
             ;
        ButtonInfo" Principal Component Analysis (SPAN)  "

     8 HSpace

((
     6 PictureButton   @work @scan or not if
\                         Refresh: Splab-Window
\                         Refresh: Instrument-Controls
\                         StkClr
\                         get
\                         inc
\                         beep-beep
\                         Refresh: Splab-Window
                       then ;
        ButtonInfo" Get Spectrum"

     9 PictureButton   @work @scan or not if
\                         Refresh: Splab-Window
\                         Refresh: Instrument-Controls
\                         StkClr
\                         Fluo-ON if F-Kin else GETKIN then
\                         kinloc 0= if true cr plot then
\                         beep-beep
\                         Refresh: Splab-Window
                       then ;
       ButtonInfo" Get Kinetics"

     11 PictureButton   @work @scan or not if
\                          Refresh: Splab-Window
\                          Refresh: Instrument-Controls
\                          Getref: Splab-Window
\                          Refresh: Splab-Window
                        then ;
        ButtonInfo" Get Reference"
        8 HSpace
     23 PictureButton   @work @scan or not if
\                         Refresh: Splab-Window
\                         Refresh: Instrument-Controls
\                         FALSE TO STOP-EXEC
\                         StkClr LT-MON
\                         SetCurveList: Splab-Window
\                         SetCtrl: Splab-Window
\                         beep-beep
                        then ;
         ButtonInfo" Real Time Monitor"
      17 PictureButton   TRUE TO STOP-EXEC ;
        ButtonInfo" Stop Monitor"

        8 HSpace
))


     10 PictureButton    \ 10
                        Refresh: Splab-Window
                        StkClr TRUE PLOT ;
                        ButtonInfo" Replot"
     24 PictureButton    \ 10
                        Refresh: Splab-Window
                        StkClr plot-results ;
                        ButtonInfo" Fittig report"
      8 HSpace
     12 PictureButton
                        confirm 1 = if
                            $ clear
                        then
                        Refresh: Splab-Window
                        replot-it
                        ;
        ButtonInfo" Clear current location "

((
     8 HSpace
     13 PictureButton   FoxyOn not if oxybox then ;
        ButtonInfo" FOXY Monitor"

     14 PictureButton
                    @work @scan or not if
                         Refresh: Splab-Window
                         Refresh: Instrument-Controls
                         StkClr
                         Fluo-ON if F-KIN else OSCILLO then
                         beep-beep
                         Refresh: Splab-Window
                    then ;
        ButtonInfo" Get kinetic curve"
))
     16 HSpace

     5 PictureButton                   start: about-splab-dialog drop ;
       ButtonInfo"  About SpLab "        \ tooltip for about
     8 HSpace

              \ a smaller space at the
 ENDBAR                                    \ end of the toolbar


