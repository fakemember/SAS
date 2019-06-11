**how to customize the legend;
https://blogs.sas.com/content/iml/2018/12/03/tips-customize-legends-proc-sgplot.html
**What is the difference between categories and groups in PROC SGPLOT? ;
https://blogs.sas.com/content/iml/2012/08/22/categories-vs-groups-in-proc-sgplot.html



**use inset in sgplot;
proc sgplot data=sashelp.class;
 scatter x=weight y=height;
 inset "This is some important information"
 "in the bottom-right corner" /
 position=BottomRight;
 inset ("A"="37" "B"="209" "C"="Value") /
 position=TopLeft border;
run;



ods escapechar='\';
proc sgplot data=sashelp.class;
 reg x=weight y=height / clm cli;
 inset ("Y\{unicode bar}"="62.34"
 "R\{sup '2'}"="0.94"
 "\{unicode alpha}"=".05") /
 position=TopLeft border;
run;


**** CREATE SCATTER PLOT;
proc sgplot
  data=adlb;
  scatter x = aval
          y = base / group=trtp;
  xaxis values = (30 35 40 45) minorcount=4;
  yaxis values = (30 35 40 45) minorcount=4;
  lineparm x=30 y=30 slope=1;
title1 "Hematocrit (%) Scatter Plot";
title2 "At Visit 3";
run;
**** PRODUCE LINE PLOT;
proc sgplot 
  data=adeff;
                                         
   series x=avisitn y=aval / group=trtpn markers 
          name="customlegend" legendlabel="Treatment";
                                                                                
   refline 1 / axis=x;                                                                                                               
   yaxis values=(0 to 10 by 1)  
         display=(noticks)
         label='Mean Clinical Response';     
                                                           
   xaxis values=(0 to 10 by 1) 
         label='Visit';               

   keylegend "customlegend" / location=inside position=topright;                                

   format avisitn avisitn.
          trtpn trtpn.;

   title1 "Mean Clinical Response by Visit";                                         
run;    

****  PRODUCE THE VERTICAL BAR CHART;
proc sgpanel
  data=freqout
  cycleattrs
  noautolegend;

  **** PANEL BY TREATMENT;  
  panelby trtpn /layout=columnlattice novarname onepanel colheaderpos=bottom;
  styleattrs  
     datacolors=(white gray black) ;

  **** CREATE VERICAL BARS;
  vbarparm category=avalcat1 response=percent / datalabel group=trtpn;

  rowaxis values=(0 to 50 by 10) label="Percentage of Patients";   
                                                            
  colaxis label="Pain Score" labelpos=right;            

  format percent newpct. trtpn trtpn. avalcat1 avalcat.;

  title1 "Summary of Pain Score by Treatment";         
run;    
**** CREATE BOX PLOT;
proc sgplot
  data=adseiz;

  vbox aval /category=avisitn group=trtpn 
             nofill capshape=line connect=median 
             grouporder=ascending extreme nooutliers;

  xaxis label='Visit';
  yaxis values = (1 to 4 by 1) minorcount=3 label='Seizures per Hour';        

  format trtpn trtpn. avisitn avisitn.;
  label trtpn = "Treatment";

  title1 "Seizures Per Hour by Treatment";  
  footnote1 j=l "Box extends to 25th and 75th percentile. Whiskers extend to"
                " minimum and maximum values. Mean values are represented by"
                " a dot while medians are connected by the line.";   
run;    


**** PRODUCE ODDS RATIO PLOT;
proc sgplot 
  data=odds
  noautolegend;
                                         
   scatter y=y x=oddsratioest / xerrorupper=uppercl xerrorlower=lowercl 
           errorbarattrs=(thickness=2.5 color=black)
           markerattrs=graphdata1(size=0);             
   scatter y=y x=oddsratioest /  
           markerattrs=graphdata1(symbol=circlefilled color=black size=8); 
                                                                                
   refline 1 / axis=x;                                                                                                               
   yaxis values=(1 to 4 by 1)  
         display=(noticks nolabel);     
                                                           
   xaxis type=log logbase=2 values=(0.125 0.25 0.5 1 2 4 8 16) 
         label='Odds Ratio and 95% Confidence Interval' ;                                               

   format y effect.;

   title1 "Odds Ratios for Clinical Success";                                         
run;    



**** PRODUCE KAPLAN MEIER PLOT;
ods output survivalplot=survivalplot;
proc lifetest
   data=addeath plots=(survival);
    
   time aval * cnsr(1);
   strata trtp;
run;
ods output close;

proc sgplot
  data=survivalplot;

  step x=month y=survival /group=stratum;
  
  xaxis values = (0 to 48 by 6) minorcount=1 label='Months from Randomization';
  yaxis values = (0 to 1 by 0.1) minorcount=1 label='Survival Probability';

label stratum = "Treatment";
format stratum $trtp.;
title1 "Kaplan-Meier Survival Estimates for Death";
run;

**waterfall plot;
proc sgplot data=waterfall;
refline -0.3 /axis=y lineattrs=(pattern=shortdash);
vbar position /response =response group=recist;
xaxis label='Patient Number' fitpolicy=thin;
yaxis label='Change from baseline (%)' values=(-1 to 1 by 0.2) valueshint;
keylegend /location=inside down=2;
run;

