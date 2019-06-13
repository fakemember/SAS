**how to customize the legend;
https://blogs.sas.com/content/iml/2018/12/03/tips-customize-legends-proc-sgplot.html
**What is the difference between categories and groups in PROC SGPLOT? ;
https://blogs.sas.com/content/iml/2012/08/22/categories-vs-groups-in-proc-sgplot.html
**Tips and Tricks for Clinical Graphs using ODS Graphics;
https://support.sas.com/resources/papers/proceedings11/281-2011.pdf


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
vbar position /response=response group=recist;
xaxis label='Patient Number' fitpolicy=thin;
yaxis label='Change from baseline (%)' values=(-1 to 1 by 0.2) valueshint;
keylegend /location=inside down=2;
run;











** DESCRIPTION   :code for K-M plot
** MACRO USED    :kmplot 
** INPUT         :the dataset in book
** OUTPUT        :km plot figure
** ASSUMPTIONS   :
**
** MODIFICATION HISTORY:
** MODIFIED BY:
*********************************************************;
 

**get dataset**;
data km1;   
   set ADTTE;
   if TRTA = "A" then trtpn = 1;
   if TRTA = "B" then trtpn = 2;
   if TRTA = "C" then delete;
      pfs_mon = AVAL/30.4375;
run;



     *-----------------------------------------------------*;
     *--Run KM lifetest------------------------------------*;
     *-----------------------------------------------------*;
     **create timelist for patients at risk**;
     proc sort data=km1; by PFS_MON; run;
     data maxpfs_mon; 
        set km1(keep=PFS_MON) end=eof;
        if eof then do;
           do time = 0 to ceil(PFS_MON/2)*2 by 2;
              *put timelist into macro variable for axis**;
              call symputx("_axisy", ceil(PFS_MON/2)*2);
              call symputx("_axisby", 2);
              output;
           end;
        end;
     run; 

     proc sql noprint; 
       select put(max(0,time-0.0000000001),15.10) into: _timelist separated by " "
       from maxpfs_mon
        ;
     quit; 

     **run lifetest**;
     proc sort data=km1; by trtpn ; run;
     ods listing close;
     ods output ProductLimitEstimates = kmptrisk /*use for get atrisk table*/
                Quartiles=kmmed /*use for get lifetest medians*/
                censoredsummary=censinfo; /*use for get censor information*/   
     proc lifetest data=km1 method=KM timelist=&_timelist conftype=loglog outsurv=kmsurv;/*use for get curv*/
         time PFS_MON*CNSR(1);
         strata trtpn;
     run;


	 *-----------------------------------------------------------*;
     *--------------Caculate all the required stats--------------*;
     *-----------------------------------------------------------*;

      /**Hazard Ratio**/
	  **calculate HR using proc phreg**;
	  proc sort data=km1; by trtpn; run;
      options validvarname=V7; 
      ods output parameterestimates=hratio;
      ods listing close;
          proc phreg data=km1;
             model PFS_MON*CNSR(1)=trtpn / ties=exact alpha=0.05 risklimits; 
          run;
	
      ods listing;

      **format HR as the same with the shell**;
      data hratio2(keep=hratio );
         set hratio(where=(upcase(PARAMETER)="TRTPN"));
         length hratio $200;
         hratio= strip(put(trtpn,trtpn.))||" = "||strip(coalescec(put(hazardratio,6.3),"NE"))||
			                 " ["||coalescec(strip(put(HRLowerCL,6.3)),"NE")||" ; "||
                                   coalescec(strip(put(HRUpperCL,6.3)),"NE")||"]"; 
       run;
 

     /**K-M Medians**/
	**calculate the medians using lifetest**;
     ods listing close;
     ods output Quartiles=kmmed2;    
     proc lifetest data=km1 method=KM conftype=loglog;
         time PFS_MON*CNSR(1);
         strata trtpn;
     run;

     **format the medians as the same with the shell**;
     data perc1(keep=trt subgrp trtpn kmmed );
        merge kmmed2(where=(percent = 50 ))
              _trt;
        by subgrp trtpn;
        length kmmed $200;         
        if trt ne "0" then 
                        kmmed=strip(put(trt,trt.))||" : "||strip(coalescec(put(estimate,5.2),"NE"))||
						" ["||coalescec(strip(put(LowerLimit,6.2)),"NE")||"; "||
                             coalescec(strip(put(UpperLimit,6.2)),"NE")||"]"; 
        else if trt eq "0" then kmmed="Kaplan-Meier Medians [95% C.I.]";
     run;

     /**Censoring Times**/
     proc sort data=censinfo; by subgrp trtpn; run;
     data censinfo2(keep=trt subgrp trtpn centime);
        merge censinfo
              _trt;
        by subgrp trtpn;
		if trt in (0 1 2 3 4 );
        if trt ne "0" then centime="    "||strip(put(trt,trt.))||" (N = "||strip(put(total,3.))||")";
        else centime="Censoring Times ";
     run;

	  /**Number of Events**/
     data events (keep=trt subgrp trtpn evetime);
        merge censinfo
              _trt;
        by subgrp trtpn;
		if trt in (0 1 2 3 4 );
        if trt ne "0" then evetime=strip(put(trt,trt.))||" (N = "||strip(put(Failed,3.))||")";
        else evetime="No. of events ";
     run;     



     *-----------------------------------------------------------*;
     *--Create annotation dataset Combine all stats information--*;
     *-----------------------------------------------------------*;
     data annotate1(keep=trt subgrp trtpn function text x y xsys ysys position angle size line color) ;
         set censinfo2(in=a)
		     events   (in=b)
             hratio3  (in=c)
             perc1    (in=d) 
             kmsurv2  (where=(_censor_=1)
                       in=e);
		  by trt;
         length function $8 text $200;
          
         /**censor times*/;
         if a then do;
            ***text**;
            xsys="1"; ysys="1"; position="3"; angle=0; size=1; line=1; x=6; function="label";
            text=centime;
            y=100-30-(input(trt,best.)*3);
            output;
            **line**;
			if trt ne "0" then do
               function='MOVE'; line=input(trt,3.); y=y+3; x=x; 
                 if trt=1 then color="black";
                 if trt=2 then color="red";
                 if trt=3 then color="blue";
                 if trt=4 then color="green";
               output;
               x = x-5;
               function='DRAW' ;
               output;
			end;
            **symbol**;
            if trt ne "0" then do i = 2.5;
               function='SYMBOL'; text="triangle";
               color="black";
               x=x+i;
               output;
            end;
         end;

         /**Number of Events**/;
         if b then do;
            ***text**;
            xsys="1"; ysys="1"; position="3"; angle=0; size=1; line=1; x=6; function="label";
            text=evetime;
            y=100-30-20-(input(trt,best.)*3);
            output;
         end;

         /**Hazard ratio**/;
         if c then do;
            **text**;
             xsys="1"; ysys="1"; position="3"; angle=0; size=1; line=1; x=6; function="label";

             text=hratio;
             y=100-30-20-20-(input(subgrp,best.)*3 );
             output;
         end;

         /**K-M medians**/;
         if d then do;
            ***text**;
            xsys="1"; ysys="1"; position="3"; angle=0; size=1; line=1; x=6; function="label";
            text=kmmed;
            y=100-30-20-10-25-(input(trt,best.)*3);
            output;
         end;

         /**censoring marks**/;
         if e then do;
            ***symbol**;
            xsys="2"; ysys="2"; position="3"; angle=0; size=1; line=1; function="symbol";
            y=surv;
            x=PFS_MON;
            text="triangle";
            output;
         end;
     run; 
    

	 *-----------------------------------------------------------*;
     *--------------create atrisk table -------------------------*;
     *-----------------------------------------------------------*;

	 **time**;
     proc sql noprint;
        create table incpfs_mon as
        select a.time, b.*
        from maxpfs_mon as a
        cross join _trt as b
        order by trt, time;
     quit;
     
    data atrisk(keep=trt function text x y xsys ysys position angle size line newtrt);   
        set kmptrisk2(in=a)
            incpfs_mon  (in=b)
            _trt(in=c) end=eof;
        by trt;
        **flip treament to show Trt A first**;
        newtrt=6-trt*2;
        length function $8 text $200;
        if a then do;
           xsys="2"; ysys="3"; position="2"; angle=0; size=1.3; line=1; function="label"; x=timelist;
           y=newtrt+(&nbfoot+6);
           text=put(left,3.);
           output;
        end;
        if b then do;
           xsys="2"; ysys="3"; position="2"; angle=0; size=1.3; line=1; function="label";
           x=time;
           y=6+(&nbfoot+6);
           text=put(time,3.);
           output;
        end;     
        if c then do;
           xsys="3"; ysys="3"; position="3"; angle=0; size=1.3; line=1; function="label";
           x=0;
           if trt ne "0" then do;
              y=newtrt+(&nbfoot+6);
              text=strip(put(trt,trt.));
              output;
           end;
           else do;            
              y=8+(&nbfoot+6);
              text="Number of patients still at risk";
              output;
              y=6+(&nbfoot+6);
              text="Time (Months)";
              output;
           end;
        end;     
     run;

     data annotate;
        set annotate1
            atrisk
            footnote;
        by trt;
        length subgrpc $50;

          subgrpc=subgrp;
     run;





    *------------------------------------------------------------------*;
    *------------Create plot by using goption---------------------------*;
    *------------------------------------------------------------------*; 
    %let sizetitle=0.35; 
    %let sizetext=2;

    ***use goption to set up the graph***;
    options orientation=landscape papersize='ISO A4' nodate nonumber nobyline; 
    goptions  device= SASEMF  
            hsize = 25cm
            vsize = 17cm
            xmax=25cm
            horigin=1.3cm
            horigin=1.3cm
            vorigin=1.3cm
            gunit     = pct
            colors    = (black)  
            ftext="Albany AMT" 
            htext=2;

  **set up the axis**;
      axis1 label  = (h = 2  j = c "Time (Months)")
            offset = (2,2)
            minor  = none
            order  = (0 to &_axisy by &_axisby)
            length = 90
            value  = (h = 2 );
            
      axis2 label  = (h = 2  A = 90 R = 0 " Event- free Probability (%) ")
            offset = (2,2)
            value  = (h = 2 )
            major  = (h = 1 w = 2)
            minor  = none
            order  = ( 0  to 1 by 0.2);

      

  **set up the curve**;
  symbol1 interpol = steplj h = 1 width=2 line=1 color = black value= none;
  symbol2 interpol = steplj h = 1 width=2 line=1 color = red value=none;
  symbol3 interpol = steplj h = 1 width=2 line=1 color = blue value=none;
  symbol4 interpol = steplj h = 1 width=2 line=1 color = green value=none;

  **generate the plot**;
        proc gplot data = kmsurv2;
          plot surv * PFS_MON = trt / frame 
                haxis  = axis1
                vaxis  = axis2
                anno=annotate
                nolegend;
         run;
        quit;

    ods rtf close;
