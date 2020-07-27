proc template;
   delete Stat.Lifetest.Graphics.ProductLimitSurvival2 / store=sasuser.templat;
   delete Stat.Lifetest.Graphics.ProductLimitFailure   / store=sasuser.templat;
   source Stat.Lifetest.Graphics.ProductLimitFailure   / file='t';
   source Stat.Lifetest.Graphics.ProductLimitSurvival2 / file='t2';
quit;


data _null_;
   infile 't';
   input;
   if _n_ = 1 then call execute('proc template;');
   _infile_ = tranwrd(_infile_, 'discretelegend "Censored"',
                      'discretelegend "skipit"');
   _infile_ = tranwrd(_infile_, 'discretelegend "Failure"',
                      'discretelegend "skipit2"');
   _infile_ = tranwrd(_infile_, 'DiscreteLegend "Failure"',
                      'discretelegend "skipit2"');
   _infile_ = tranwrd(_infile_, 'entry "+ Censored"', ' ');
   call execute(_infile_);
run;


data _null_;
   infile 't2';
   input;
   if _n_ = 1 then call execute('proc template;');
   if find(_infile_, 'layout overlay / xaxisopts') then lo + 1;
   if lo and index(_infile_, ';') then do;
      lo = 0;
      call execute(_infile_);
      _infile_ = 'drawimage "InsetI2.png" / width=38 x=99 y=99 anchor=topright
                  drawspace=wallpercent;';
      end;
   call execute(_infile_);
run;


ods graphics on / imagename="InsetI2" height=300px width=300px border=off;
ods listing style=htmlblue;
ods html exclude all;
proc lifetest data=sashelp.bmt plots=survival(failure);
   time T * Status(0);
   strata Group;
run;
ods html exclude none;
ods listing close;

ods graphics on / reset=imagename reset=border height=640px width=640px;
proc lifetest data=sashelp.bmt plots=survival(outside atrisk(maxlen=13));
   ods select survivalplot;
   time T * Status(0);
   strata Group;
run;


proc template;
   delete Stat.Lifetest.Graphics.ProductLimitSurvival2 / store=sasuser.templat;
   delete Stat.Lifetest.Graphics.ProductLimitFailure   / store=sasuser.templat;
quit;


ods graphics on / reset=all imagename='SurvivalI1' noborder;
ods listing style=htmlblue;
ods html exclude all;
proc lifetest data=sashelp.bmt plots=survival(outside atrisk(maxlen=13));
   ods select survivalplot;
   time T * Status(0);
   strata Group;
run;


ods graphics on / reset=all imagename='SurvivalI2' 
                  width=320px height=240px legendareamax=1;
proc lifetest data=sashelp.bmt plots=survival;
   ods select survivalplot;
   time T * Status(0);
   strata Group;
run;
ods html exclude none;
ods listing close;


data anno;
   retain function "image" anchor "topleft" drawspace "wallpercent";
   length image $ 20;
   input x1 y1 width image $;
   datalines;
 0 100 101 SurvivalI1.png
74  89  25 SurvivalI2.png
;


data corners;
   input x y @;
   datalines;
1 1 -1 -1 
;

ods graphics on / reset=all imagename='SurvivalBoth';
proc sgplot data=corners sganno=anno noautolegend noborder;
   scatter y=y x=x / markerattrs=(size=0);
   yaxis display=none;
   xaxis display=none;
run;