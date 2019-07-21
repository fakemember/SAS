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










  **forest macro**;

data adtte;
input 
Obsnum 
aval
cnsr
Sexn  
Racen 
Age;
cards;
   1        1       0      1       1      46
   2        5       0      1       1      51
   3        7       1      1       1      55
   4        9       0      1       1      57
   5       13       0      1       1      45
   6       13       0      1       1      43
   7       17       1      1       1      47
   8       20       0      1       1      65
   9       26       1      1       1      55
  10       26       1      1       1      44
  11       28       1      1       1      49
  12       32       0      1       1      52
  13       32       0      1       1      31
  14       43       0      1       1      63
  15       43       1      1       1      55
  16       44       1      1       1      50
  17       51       0      1       1      49
  18       51       0      1       1      35
  19       51       0      1       1      23
  20       56       1      1       1      57
  21       57       1      1       1      45
  22       59       1      1       1      41
  23       62       1      1       1      38
  24       66       0      1       1      55
  25       66       0      1       1      45
  26       67       0      1       1      44
  27       68       1      1       1      45
  28       69       1      1       1      65
  29       79       0      1       1      66
  30       79       1      1       1      57
  31       79       0      1       1      52
  32       87       0      1       1      38
  33       88       1      1       1      49
  34       91       1      1       1      44
  35       93       0      1       1      28
  36       98       1      1       1      64
  37       98       1      1       1      43
  38      104       0      1       1      11
  39      105       0      1       1      45
  40      106       1      1       1      59
  41      112       0      1       1      40
  42      116       0      1       1      65
  43      116       0      1       1      33
  44      118       0      1       1      53
  45      119       1      1       1      42
  46      121       0      1       1      51
  47      121       0      1       1      25
  48      135       1      1       1      33
  49      144       0      1       1      65
  50      150       1      1       1      42
  51      150       0      1       1      41
  52      162       1      1       1      68
  53      162       0      1       1      61
  54      167       0      1       1      19
  55      183       0      1       1      61
  56      186       0      1       1      42
  57      190       1      1       1      54
  58      198       0      1       1      43
  59      198       0      1       1      42
  60      200       0      1       1      37
  61      211       0      1       1      46
  62      215       0      1       1      42
  63      223       0      1       1      45
  64      224       0      1       1      28
  65      228       1      1       1      52
  66      236       0      1       1      32
  67      238       0      1       1      38
  68      242       1      1       1      35
  69      243       0      1       1      24
  70      248       1      1       1      46
  71      249       1      1       1      49
  72      251       0      1       1      49
  73      252       1      1       1      48
  74      253       0      1       1      62
  75      256       0      1       1      65
  76      257       0      1       1      38
  77      259       0      1       1      75
  78      261       0      1       1      48
  79      271       0      1       1      68
  80      271       0      1       1      39
  81      277       0      1       1      42
  82      283       0      1       1      37
  83      284       0      1       1      45
  84      289       0      1       1      33
  85      291       1      1       1      66
  86      311       1      1       1      66
  87      312       0      1       1      53
  88      316       0      1       1      52
  89      316       0      1       1      51
  90      331       0      1       1      58
  91      334       1      1       1      63
  92      338       0      1       1      27
  93      340       0      1       1      48
  94      340       1      1       1      41
  95      341       0      1       1      28
  96      346       1      1       1      49
  97      347       0      1       1      42
  98      354       1      1       1      45
  99      361       0      1       1      44
 100      367       0      1       1      37
 101      370       0      1       1      56
 102      370       0      1       1      55
 103      386       0      1       1      42
 104      391       1      1       1      60
 105      392       0      1       1      66
 106      403       0      1       1      61
 107      406       0      1       1      57
 108      410       0      1       1      44
 109      421       1      1       1      67
 110      428       0      1       1      62
 111      432       0      1       1      54
 112      432       0      1       1      26
 113      439       1      1       1      57
 114      452       0      1       1      55
 115      478       1      1       1      54
 116      481       1      1       1      58
 117      485       0      1       1      56
 118      486       0      1       1      23
 119      490       0      1       1      21
 120      494       0      1       1      58
 121      495       1      1       1      47
 122      512       0      1       1      60
 123      512       0      1       1      55
 124      535       0      1       1      44
 125      543       0      1       1      50
 126      545       0      1       1      58
 127      545       0      1       1      53
 128      545       0      1       1      43
 129      563       0      1       1      40
 130      570       0      1       1      65
 131      570       1      1       1      34
 132      572       0      1       1      52
 133      579       0      1       1      62
 134      582       0      1       1      11
 135      583       1      1       1      70
 136      590       0      1       1      59
 137      596       0      1       1      53
 138      615       1      1       1      48
 139      621       1      1       1      25
 140      630       0      1       1      62
 141      631       0      1       1      17
 142      633       0      1       1      53
 143      652       1      1       1      57
 144      654       0      1       1      43
 145      655       0      1       1      45
 146      659       0      1       1      49
 147      670       0      1       1      24
 148      670       0      1       1      62
 149      692       0      1       1      48
 150      697       1      1       1      41
 151      701       0      1       1      42
 152      719       0      1       1      35
 153      723       0      1       1      46
 154      725       0      1       1      23
 155      730       1      1       1      56
 156      734       0      1       1      51
 157      753       0      1       1      45
 158      757       0      1       1      20
 159      773       1      1       1      34
 160      776       1      1       1      43
 161      790       1      1       1      62
 162      806       1      1       1      64
 163      834       0      1       1      18
 164      835       0      1       1      63
 165      864       0      1       1      54
 166      864       0      1       1      40
 167      875       1      1       1      51
 168      888       0      1       1      67
 169      890       0      1       1      40
 170      903       0      1       1      59
 171      909       0      1       1      46
 172      915       0      1       1      46
 173      932       0      1       1      36
 174      939       1      1       1      54
 175      945       1      1       1      42
 176      945       1      1       1      41
 177      946       1      1       1      67
 178      951       0      1       1      61
 179      961       0      1       1      38
 180      965       0      1       1      19
 181      968       0      1       1      27
 182     1016       0      1       1      54
 183     1028       0      1       1      26
 184     1050       0      1       1      42
 185     1058       0      1       1      58
 186     1058       0      1       1      54
 187     1092       0      1       1      45
 188     1092       0      1       1      40
 189     1105       1      1       1      57
 190     1110       0      1       1      46
 191     1110       0      1       1      37
 192     1114       0      1       1      41
 193     1115       0      1       1      51
 194     1118       0      1       1      34
 195     1124       0      1       1      53
 196     1124       0      1       1      40
 197     1125       0      1       1      38
 198     1128       0      1       1      23
 199     1128       0      1       1      21
 200     1145       0      1       1      43
 201     1149       0      1       1      40
 202     1154       0      1       1      67
 203     1154       0      1       1      36
 204     1165       0      1       1      52
 205     1186       1      1       1      37
 206     1191       1      1       1      44
 207     1196       0      1       1      33
 208     1208       0      1       1      38
 209     1208       0      1       1      25
 210     1210       1      1       1      66
 211     1224       0      1       1      49
 212     1224       0      1       1      39
 213     1229       0      1       1      45
 214     1230       0      1       1      48
 215     1252       0      1       1      58
 216     1256       0      1       1      40
 217     1274       0      1       1      48
 218     1291       0      1       1      31
 219     1297       0      1       1      45
 220     1297       0      1       1      44
 221     1302       0      1       1      33
 222     1313       0      1       1      63
 223     1316       0      1       1      33
 224     1350       0      1       1      46
 225     1357       1      1       1      64
 226     1383       0      1       1      56
 227     1383       0      1       1      56
 228     1383       0      1       1      53
 229     1383       0      1       1      30
 230     1386       0      1       1      68
 231     1388       1      1       1      48
 232     1395       0      1       1       3
 233     1418       1      1       1      67
 234     1428       0      1       1      27
 235     1429       0      1       1      33
 236     1435       0      1       1      58
 237     1449       0      1       1      61
 238     1449       0      1       1      42
 239     1450       0      1       1      41
 240     1457       0      1       1      37
 241     1463       0      1       1      38
 242     1470       0      1       1      63
 243     1497       0      1       1      46
 244     1497       0      1       1      35
 245     1500       0      1       1      22
 246     1509       1      1       1      57
 247     1522       0      1       1      49
 248     1527       0      1       1      54
 249     1527       0      1       1      30
 250     1541       0      1       1      39
 251     1567       0      1       1      28
 252     1571       0      1       1      38
 253     1578       0      1       1      46
 254     1586       0      1       1      43
 255     1594       0      1       1      35
 256     1610       0      1       1      67
 257     1610       0      1       1      60
 258     1611       0      1       1      62
 259     1617       0      1       1      53
 260     1624       0      1       1      24
 261     1638       0      1       1      34
 262     1641       0      1       1      38
 263     1655       0      1       1      31
 264     1668       0      1       1      31
 265     1674       0      1       1      34
 266     1699       0      1       1      38
 267     1700       0      1       1      49
 268     1700       0      1       1      34
 269     1707       0      1       1      41
 270     1717       0      1       1      31
 271     1717       0      1       1      31
 272     1718       0      1       1      54
 273     1718       0      1       1      40
 274     1734       1      1       1      55
 275     1736       0      1       1      42
 276     1736       0      1       1      42
 277     1739       0      1       1      34
 278     1739       0      1       1      27
 279     1739       0      1       1      25
 280     1745       0      1       1      64
 281     1745       0      1       1      52
 282     1746       0      1       1      53
 283     1749       0      1       1      55
 284     1770       0      1       1      45
 285     1770       0      1       1      32
 286     1795       0      1       1      30
 287     1802       0      1       1      56
 288     1802       0      1       1      31
 289     1803       0      1       1      38
 290     1808       0      1       1      43
 291     1808       0      1       1      41
 292     1815       0      1       1      57
 293     1820       1      1       1      44
 294     1839       0      1       1      31
 295     1861       0      1       1      38
 296     1861       0      1       1      20
 297     1893       0      1       1      20
 298     1900       0      1       1      48
 299     1920       0      1       1      40
 300     1937       0      1       1      31
 301     1947       0      1       1      61
 302     1947       0      1       1      37
 303     1959       0      1       1      41
 304     1959       0      1       1      30
 305     1975       0      1       1      31
 306     1988       0      1       1      55
 307     1988       0      1       1      32
 308     1995       0      1       1      59
 309     1995       0      1       1      57
 310     2001       0      1       1      55
 311     2016       0      1       1      52
 312     2025       0      1       1      23
 313     2032       0      1       1      59
 314     2035       0      1       1      30
 315     2038       0      1       1      25
 316     2041       0      1       1      29
 317     2043       0      1       1      30
 318     2048       0      1       1      44
 319     2049       0      1       1      40
 320     2056       1      1       1      62
 321     2060       0      1       1      32
 322     2090       0      1       1      41
 323     2090       0      1       1      38
 324     2095       0      1       1      44
 325     2096       0      1       1      47
 326     2096       0      1       1      41
 327     2098       0      1       1      38
 328     2102       0      1       1      44
 329     2109       0      1       1      11
 330     2135       0      1       1      42
 331     2135       0      1       1      31
 332     2147       0      1       1      18
 333     2190       0      1       1      38
 334     2211       0      1       1      36
 335     2221       0      1       1      47
 336     2223       0      1       1      24
 337     2253       0      1       1      45
 338     2253       0      1       1      18
 339     2264       0      1       1      28
 340     2267       0      1       1      36
 341     2270       0      1       1      55
 342     2291       1      1       1      56
 343     2291       0      1       1      20
 344     2313       1      1       1      55
 345     2313       0      1       1      47
 346     2313       0      1       1      30
 347     2330       0      1       1      37
 348     2332       0      1       1      26
 349     2335       0      1       1      61
 350     2356       0      1       1      33
 351     2367       0      1       1      38
 352     2384       0      1       1      31
 353     2418       0      1       1      34
 354     2421       0      1       1      55
 355     2421       1      1       1      40
 356     2430       0      1       1      35
 357     2433       0      1       1      36
 358     2434       0      1       1      59
 359     2462       0      1       1      40
 360     2462       0      1       1      35
 361     2488       0      1       1      12
 362     2489       1      1       1      61
 363     2497       0      1       1      44
 364     2516       0      1       1      32
 365     2531       0      1       1      12
 366     2533       0      1       1      63
 367     2575       0      1       1      32
 368     2585       0      1       1      61
 369     2589       0      1       1      35
 370     2601       0      1       1      38
 371     2607       0      1       1      55
 372     2625       0      1       1      56
 373     2630       0      1       1      38
 374     2646       0      1       1      50
 375     2654       0      1       1       2
 376     2690       0      1       1      23
 377     2696       0      1       1      51
 378     2700       0      1       1      35
 379     2712       0      1       1      38
 380     2714       0      1       1      36
 381     2716       0      1       1      25
 382     2716       0      1       1      20
 383     2740       0      1       1      36
 384     2761       0      1       1      51
 385     2762       0      1       1      51
 386     2765       0      1       1      42
 387     2789       0      1       1      39
 388     2789       0      1       1      35
 389     2812       0      1       1      24
 390     2815       0      1       1      34
 391     2827       0      1       1      37
 392     2831       0      1       1      56
 393     2846       0      1       1      25
 394     2867       0      1       1      38
 395     2871       0      1       1      41
 396     2889       0      1       1      48
 397     2909       0      1       1      25
 398     2922       0      1       1      28
 399     2936       0      1       1      56
 400     2948       0      1       1      58
 401     2955       0      1       1      45
 402     2957       0      1       1      41
 403     2994       0      1       1      47
 404     2994       0      1       1      26
 405     2999       0      1       1      65
 406     3007       0      1       1      54
 407     3045       0      1       1      51
 408     3060       0      1       1      33
 409     3078       0      1       1      53
 410     3078       0      1       1      44
 411     3084       0      1       1      55
 412     3084       0      1       1      35
 413     3110       0      1       1      59
 414     3130       0      1       1      23
 415     3131       0      1       1      39
 416     3146       1      1       1      37
 417     3147       0      1       1      45
 418     3172       0      1       1      61
 419     3179       0      1       1      44
 420     3187       0      1       1      36
 421     3187       0      1       1      26
 422     3255       0      1       1      46
 423     3260       0      1       1      30
 424     3287       0      1       1      42
 425     3289       0      1       1      22
 426     3300       0      1       1      41
 427     3301       0      1       1       6
 428     3319       0      1       1      29
 429     3361       0      1       1      42
 430     3402       0      1       1      40
 431     3425       0      1       1      48
 432     3434       0      1       1      31
 433       37       1      1       2      44
 434       43       1      1       2      58
 435       57       1      1       2      47
 436       80       0      1       2      55
 437       82       0      1       2      30
 438       93       0      1       2      47
 439      114       0      1       2      65
 440      116       0      1       2      45
 441      116       0      1       2      38
 442      119       0      1       2      27
 443      152       0      1       2      63
 444      158       1      1       2      55
 445      172       0      1       2      25
 446      200       0      1       2      36
 447      206       1      1       2      66
 448      211       0      1       2      57
 449      231       0      1       2      52
 450      280       0      1       2      60
 451      311       1      1       2      39
 452      312       0      1       2      51
 453      402       1      1       2      64
 454      414       0      1       2      46
 455      443       0      1       2      59
 456      450       1      1       2      23
 457      452       0      1       2      55
 458      479       0      1       2      43
 459      499       0      1       2      37
 460      535       0      1       2      22
 461      642       0      1       2      64
 462      646       0      1       2      59
 463      661       0      1       2      62
 464      663       0      1       2      48
 465      663       0      1       2      28
 466      671       0      1       2      59
 467      750       0      1       2      55
 468      777       0      1       2      66
 469      863       0      1       2      55
 470      863       0      1       2      52
 471      864       0      1       2      54
 472      868       0      1       2      38
 473      934       0      1       2      21
 474      951       0      1       2      48
 475      992       0      1       2      53
 476     1001       1      1       2      30
 477     1002       0      1       2      31
 478     1109       0      1       2      54
 479     1122       0      1       2      47
 480     1124       0      1       2      32
 481     1149       0      1       2      36
 482     1178       0      1       2      57
 483     1230       0      1       2      56
 484     1232       0      1       2      45
 485     1242       0      1       2      38
 486     1275       1      1       2      47
 487     1352       0      1       2      60
 488     1384       1      1       2      65
 489     1450       0      1       2      27
 490     1586       0      1       2      55
 491     1624       0      1       2      33
 492     1668       0      1       2      46
 493     1681       0      1       2      28
 494     1778       0      1       2      56
 495     1795       0      1       2      51
 496     1795       0      1       2      22
 497     1877       0      1       2      58
 498     1989       0      1       2      28
 499     2049       0      1       2      42
 500     2094       0      1       2      28
 501     2095       0      1       2      26
 502     2264       0      1       2      32
 503     2291       0      1       2      45
 504     2369       0      1       2      53
 505     2369       1      1       2      40
 506     2414       1      1       2      45
 507     2425       0      1       2      24
 508     2451       0      1       2      51
 509     2455       0      1       2      45
 510     2557       1      1       2      52
 511     2598       0      1       2      33
 512     2625       0      1       2      47
 513     2659       0      1       2      45
 514     2688       0      1       2      41
 515     2726       0      1       2      49
 516     2741       0      1       2      54
 517     2750       0      1       2      22
 518     2909       0      1       2      39
 519     2961       0      1       2       7
 520     2994       0      1       2      50
 521     3019       0      1       2      56
 522     3255       0      1       2      49
 523     3281       0      1       2      47
 524     3430       0      1       2      28
 525        1       0      2       1      41
 526        2       1      2       1      60
 527        3       1      2       1      18
 528        5       0      2       1      41
 529        7       1      2       1      37
 530        9       0      2       1      71
 531       10       1      2       1      60
 532       10       1      2       1      42
 533       17       0      2       1      24
 534       20       0      2       1      56
 535       21       1      2       1      65
 536       26       0      2       1      31
 537       33       0      2       1      53
 538       43       0      2       1      56
 539       43       0      2       1      24
 540       48       0      2       1      30
 541       50       1      2       1      55
 542       51       0      2       1      55
 543       52       1      2       1      61
 544       62       1      2       1      60
 545       62       0      2       1      42
 546       68       1      2       1      52
 547       78       1      2       1      60
 548       79       0      2       1      55
 549       82       0      2       1      21
 550       97       1      2       1      62
 551      104       1      2       1      52
 552      105       0      2       1      40
 553      112       0      2       1      42
 554      115       0      2       1      35
 555      124       0      2       1      40
 556      141       0      2       1      62
 557      142       0      2       1      59
 558      143       1      2       1      31
 559      150       0      2       1      35
 560      154       1      2       1      51
 561      162       0      2       1      51
 562      162       0      2       1      14
 563      167       0      2       1      60
 564      173       0      2       1      68
 565      193       0      2       1      65
 566      205       0      2       1      31
 567      209       1      2       1      24
 568      231       0      2       1      48
 569      238       0      2       1      50
 570      239       0      2       1      42
 571      246       0      2       1      45
 572      246       0      2       1      37
 573      250       0      2       1      33
 574      253       0      2       1      54
 575      260       0      2       1      58
 576      269       0      2       1      64
 577      271       0      2       1      51
 578      273       1      2       1      41
 579      280       0      2       1      48
 580      297       1      2       1      51
 581      306       0      2       1      53
 582      331       0      2       1      23
 583      337       0      2       1      36
 584      341       0      2       1      41
 585      341       0      2       1      41
 586      347       0      2       1      42
 587      366       1      2       1      27
 588      377       0      2       1      59
 589      387       0      2       1      71
 590      388       0      2       1      60
 591      399       0      2       1      45
 592      417       0      2       1      22
 593      424       0      2       1      45
 594      428       0      2       1      53
 595      448       0      2       1      56
 596      448       0      2       1      52
 597      448       0      2       1      51
 598      459       0      2       1      31
 599      470       1      2       1      43
 600      490       1      2       1      56
 601      507       0      2       1      42
 602      512       0      2       1      55
 603      549       0      2       1      22
 604      593       0      2       1      65
 605      604       0      2       1      47
 606      614       1      2       1      49
 607      642       0      2       1      61
 608      652       0      2       1      51
 609      654       0      2       1      58
 610      660       0      2       1      44
 611      670       0      2       1      66
 612      675       0      2       1      48
 613      678       0      2       1      31
 614      693       0      2       1      44
 615      715       0      2       1      60
 616      731       0      2       1      28
 617      750       0      2       1      62
 618      753       0      2       1      40
 619      757       0      2       1      32
 620      759       0      2       1      62
 621      762       0      2       1      54
 622      772       0      2       1      53
 623      772       0      2       1      42
 624      777       0      2       1      51
 625      777       0      2       1      27
 626      793       1      2       1      36
 627      840       1      2       1      41
 628      852       1      2       1      24
 629      900       0      2       1      17
 630      907       0      2       1      59
 631      907       0      2       1      28
 632      909       0      2       1      30
 633      915       0      2       1      33
 634      963       0      2       1      23
 635      995       0      2       1      42
 636      995       0      2       1      26
 637     1012       0      2       1      37
 638     1013       1      2       1      68
 639     1051       0      2       1      58
 640     1072       0      2       1      24
 641     1086       0      2       1      61
 642     1114       0      2       1      37
 643     1125       0      2       1      45
 644     1164       1      2       1      48
 645     1196       0      2       1      46
 646     1229       0      2       1      36
 647     1242       0      2       1      43
 648     1252       0      2       1      29
 649     1254       0      2       1      63
 650     1254       0      2       1      48
 651     1269       0      2       1      64
 652     1291       0      2       1      32
 653     1291       0      2       1      30
 654     1299       0      2       1      39
 655     1304       0      2       1      17
 656     1309       0      2       1      31
 657     1315       0      2       1      23
 658     1326       1      2       1      48
 659     1331       1      2       1      40
 660     1350       0      2       1      43
 661     1365       0      2       1      25
 662     1368       0      2       1      48
 663     1368       0      2       1      35
 664     1427       0      2       1      32
 665     1435       0      2       1      60
 666     1449       0      2       1      21
 667     1473       1      2       1      41
 668     1497       0      2       1      39
 669     1594       0      2       1      28
 670     1605       0      2       1      55
 671     1606       0      2       1      22
 672     1611       0      2       1      61
 673     1623       0      2       1      38
 674     1638       0      2       1      32
 675     1673       0      2       1      46
 676     1681       0      2       1      33
 677     1698       0      2       1      37
 678     1699       0      2       1      37
 679     1702       0      2       1      45
 680     1702       0      2       1      27
 681     1707       0      2       1      54
 682     1732       0      2       1      33
 683     1736       0      2       1      27
 684     1746       0      2       1      67
 685     1777       1      2       1      46
 686     1778       0      2       1      40
 687     1785       0      2       1      48
 688     1786       0      2       1      57
 689     1786       0      2       1      45
 690     1791       0      2       1      45
 691     1795       0      2       1      38
 692     1815       0      2       1      32
 693     1835       1      2       1      47
 694     1875       0      2       1      49
 695     1877       1      2       1      37
 696     1893       0      2       1      39
 697     1914       0      2       1      41
 698     1939       0      2       1      24
 699     1940       1      2       1      40
 700     1942       0      2       1      67
 701     1962       0      2       1       5
 702     1966       0      2       1      35
 703     1973       0      2       1      23
 704     1980       0      2       1      52
 705     2001       0      2       1      25
 706     2014       0      2       1      51
 707     2014       0      2       1      47
 708     2025       0      2       1      34
 709     2034       0      2       1      59
 710     2034       1      2       1      50
 711     2034       0      2       1      35
 712     2038       0      2       1      47
 713     2048       0      2       1      13
 714     2060       0      2       1      27
 715     2083       0      2       1      51
 716     2094       0      2       1      57
 717     2102       0      2       1      28
 718     2108       1      2       1      27
 719     2129       0      2       1      50
 720     2193       0      2       1      17
 721     2211       0      2       1      41
 722     2221       0      2       1      45
 723     2223       0      2       1      55
 724     2233       0      2       1      41
 725     2236       0      2       1      49
 726     2252       0      2       1      44
 727     2252       0      2       1      21
 728     2271       0      2       1      21
 729     2301       1      2       1      42
 730     2312       0      2       1      58
 731     2332       0      2       1      47
 732     2335       0      2       1      25
 733     2356       0      2       1      28
 734     2392       0      2       1      28
 735     2405       0      2       1      17
 736     2405       0      2       1       1
 737     2421       0      2       1      61
 738     2433       0      2       1      23
 739     2462       0      2       1      32
 740     2486       0      2       1      64
 741     2488       0      2       1       8
 742     2504       0      2       1      31
 743     2529       0      2       1      41
 744     2529       0      2       1      26
 745     2531       0      2       1      30
 746     2556       0      2       1      47
 747     2567       1      2       1      48
 748     2632       0      2       1      43
 749     2638       0      2       1      39
 750     2638       0      2       1      31
 751     2654       0      2       1      22
 752     2659       0      2       1      24
 753     2663       0      2       1      51
 754     2670       0      2       1      53
 755     2680       0      2       1      59
 756     2700       0      2       1      52
 757     2701       0      2       1      33
 758     2705       0      2       1      46
 759     2726       0      2       1      29
 760     2750       0      2       1      23
 761     2759       0      2       1      51
 762     2768       0      2       1      21
 763     2783       0      2       1      24
 764     2795       1      2       1      52
 765     2870       0      2       1      12
 766     2871       0      2       1      49
 767     2876       0      2       1      24
 768     2900       0      2       1      23
 769     2906       0      2       1      44
 770     2918       0      2       1      27
 771     2948       0      2       1      33
 772     2993       0      2       1      61
 773     3028       0      2       1      40
 774     3042       0      2       1      42
 775     3063       0      2       1      53
 776     3063       0      2       1      14
 777     3072       0      2       1      23
 778     3077       0      2       1      22
 779     3084       0      2       1      36
 780     3086       0      2       1      39
 781     3096       0      2       1      26
 782     3102       0      2       1      32
 783     3106       0      2       1      48
 784     3116       0      2       1      63
 785     3124       0      2       1      38
 786     3142       0      2       1      27
 787     3145       0      2       1      32
 788     3145       0      2       1      25
 789     3172       0      2       1      47
 790     3173       0      2       1      28
 791     3175       0      2       1      20
 792     3186       0      2       1      38
 793     3202       0      2       1      23
 794     3215       0      2       1      41
 795     3224       0      2       1      33
 796     3229       0      2       1      34
 797     3265       0      2       1      20
 798     3300       0      2       1      16
 799     3325       0      2       1      40
 800     3360       0      2       1      23
 801     3372       0      2       1      30
 802     3379       0      2       1      22
 803     3412       0      2       1      43
 804     3420       0      2       1      29
 805       14       0      2       2      39
 806       40       1      2       2      48
 807       45       1      2       2      66
 808       93       0      2       2      56
 809      106       1      2       2      40
 810      116       0      2       2      57
 811      116       0      2       2      39
 812      121       1      2       2      54
 813      229       1      2       2      25
 814      250       0      2       2      64
 815      259       0      2       2      57
 816      261       0      2       2      27
 817      306       0      2       2      59
 818      312       0      2       2      44
 819      344       1      2       2      54
 820      392       0      2       2      36
 821      442       0      2       2      55
 822      512       0      2       2      43
 823      625       0      2       2      35
 824      673       0      2       2      33
 825      731       0      2       2      38
 826      777       0      2       2      31
 827      864       1      2       2      59
 828      879       0      2       2      46
 829      887       0      2       2      41
 830      899       0      2       2      64
 831      899       0      2       2      41
 832      903       0      2       2      55
 833      920       0      2       2      37
 834      929       1      2       2      50
 835      943       1      2       2      44
 836      953       0      2       2      42
 837      953       0      2       2      42
 838     1016       1      2       2      48
 839     1151       0      2       2      13
 840     1196       1      2       2      23
 841     1291       0      2       2      55
 842     1291       0      2       2      41
 843     1457       0      2       2      43
 844     1508       0      2       2      25
 845     1567       0      2       2      41
 846     1674       0      2       2      44
 847     1736       0      2       2      39
 848     1739       0      2       2      52
 849     1942       0      2       2      48
 850     2026       0      2       2      52
 851     2171       1      2       2      61
 852     2268       0      2       2      49
 853     2276       1      2       2      54
 854     2413       0      2       2      45
 855     2434       0      2       2      21
 856     2463       0      2       2      20
 857     2650       1      2       2      48
 858     2680       0      2       2      54
 859     2935       0      2       2      20
 860     3072       0      2       2      55
 861     3161       0      2       2      56
 862     3211       0      2       2      43
 863     3304       0      2       2      52
 ;


 proc format;
   value effect
      1 = "Age (years)"
      2 = "Male vs. Female"
      3 = "White vs. Black";
run;

%macro forest(indata=,invar=Age Sexn Racen);
ods output parameterestimates=est;
proc phreg
   data = adtte;

   model aval*cnsr(0) = &invar / rl; 
run; 
ods output close;

***** RECATEGORIZE EFFECT FOR Y AXIS FORMATING PURPOSES.; 
data est;
   set est;
   select(parameter);
      when("%scan(&invar,1)") y = 1;
      when("%scan(&invar,2)")     y = 2;
      when("%scan(&invar,3)")    y = 3;
      otherwise;
   end;
run;

ods listing;


**** FORMAT FOR EFFECT ON Y AXIS;



**** CLOSE ODS DESTINATIONS SO ONLY ONE GRAPH IS PRODUCED;

**** PRODUCE ODDS RATIO PLOT;
proc sgplot 
  data=est
  noautolegend;
                                         
   scatter y=y x=hazardratio / xerrorupper=hruppercl xerrorlower=hrlowercl 
           errorbarattrs=(thickness=2.5 color=black)
           markerattrs=graphdata1(size=0);             
   scatter y=y x=hazardratio /  
           markerattrs=graphdata1(symbol=circlefilled color=black size=8); 
                                                                                
   refline 1 / axis=x;                                                                                                               
   yaxis values=(1 to 3 by 1)  
         display=(noticks nolabel);     
                                                           
   xaxis type=log logbase=2 values=(0.125 0.25 0.5 1 2 4 8 16) 
         label='Odds Ratio and 95% Confidence Interval' ;                                               

   format y effect.;

   title1 "Odds Ratios for Clinical Success";                                         
run;    
%mend;
options mprint mlogic symbolgen;
%forest(indata=adtte,invar=Age Sexn Racen);
