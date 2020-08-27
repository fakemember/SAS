************************************************************************************************;
* Project           : 
*
* Program name      : km dpfs.sas
*
* Author            : Chao
*
* Date created      : 16April2020
*
* SAS version       : SAS 9.4
*
* Purpose           : 
*
* Input files       : 
*
* Output files      : 
*
* Program included  :
*
* Macro variables   : 
*
* Macros            : 
*
* Revision History  :
*
* Date        Author      Ref    Revision 
* 
*
**********************************************************************************************;
/*DPFS is defined as the time from the end of SMART treatment to event of distant progression or death from any cause. */

/****************************************************************/
/*          S A S   S A M P L E   L I B R A R Y                 */
/*                                                              */
/*    NAME: TEMPLFT                                             */
/*   TITLE: PROC LIFETEST Template                              */
/* PRODUCT: STAT                                                */
/*  SYSTEM: ALL                                                 */
/*    KEYS: graphics, ods, survival analysis, Kaplan-Meier      */
/*   PROCS:                                                     */
/*    DATA:                                                     */
/*                                                              */
/* SUPPORT: saswfk                UPDATE: July 25, 2013         */
/*     REF: ods graphics                                        */
/*    MISC:                                                     */
/*   NOTES: This sample provides templates for the PROC         */
/*          LIFETEST survival plot that are modular and         */
/*          easier to modify than the default templates.        */
/****************************************************************/

%macro ProvideSurvivalMacros;

   %global atriskopts bandopts censored censorstr classopts
           graphopts groups insetopts legendopts ntitles stepopts tiplabel
           tips titletext0 titletext1 titletext2 xoptions yoptions;

   %let TitleText0 = METHOD " Survival Estimate";
   %let TitleText1 = &titletext0 " for " STRATUMID;
   %let TitleText2 = &titletext0 "s";         /* plural: Survival Estimates */
   %let nTitles    = 2;

   %let yOptions   = label="Survival Probability" shortlabel="Survival"
                     linearopts=(viewmin=0 viewmax=1
                                 tickvaluelist=(0 .2 .4 .6 .8 1.0));

   %let xOptions   = shortlabel=XNAME offsetmin=.05
                     linearopts=(viewmax=MAXTIME tickvaluelist=XTICKVALS
                                 tickvaluefitpolicy=XTICKVALFITPOL);

   %let Tips       = rolename=(_tip1= ATRISK _tip2=EVENT)
                     tiplabel=(_tip1="Number at Risk" _tip2="Observed Events")
                     tip=(x y _tip1 _tip2);
   %let TipLabel   = tiplabel=(y="Survival Probability");
   %let StepOpts   = ;

   %let Groups     = group=STRATUM index=STRATUMNUM;

   %let BandOpts   = displayTail=false &groups modelname="Survival";

   %let InsetOpts  = autoalign=(TOPRIGHT BOTTOMLEFT TOP BOTTOM)
                     border=true BackgroundColor=GraphWalls:Color Opaque=true;
   %let LegendOpts = title=GROUPNAME location=outside;

   %let AtRiskOpts = display=(label) valueattrs=(size=7pt);
   %let ClassOpts  = class=CLASSATRISK colorgroup=CLASSATRISK;

   %let Censored   = markerattrs=(symbol=plus);
   %let CensorStr  = "+ Censored";

   %let GraphOpts  = ;

   %macro StmtsBeginGraph; %mend;
   %macro StmtsTop;        %mend;
   %macro StmtsBottom;     %mend;

   %macro CompileSurvivalTemplates;
      %local outside;
      proc template;
         %do outside = 0 %to 1;
            define statgraph
               Stat.Lifetest.Graphics.ProductLimitSurvival%scan(2,2-&outside);
               dynamic NStrata xName plotAtRisk
                  %if %nrbquote(&censored) ne %then plotCensored;
                  plotCL plotHW plotEP labelCL labelHW labelEP maxTime xtickVals
                  xtickValFitPol rowWeights method StratumID classAtRisk
                  plotTest GroupName Transparency SecondTitle TestName pValue
                  _byline_ _bytitle_ _byfootnote_;
               BeginGraph %if %nrbquote(&graphopts) ne %then / &graphopts;;

               if (NSTRATA=1)
                  %if &ntitles %then %do;
                     if (EXISTS(STRATUMID)) entrytitle &titletext1;
                     else                   entrytitle &titletext0;
                     endif;
                  %end;

                  %if &ntitles gt 1 %then %do;
                     %if not &outside %then if (PLOTATRISK=1);
                        entrytitle "With Number of Subjects at Risk" /
                                   textattrs=GRAPHVALUETEXT;
                     %if not &outside %then %do; endif; %end;
                  %end;

                  %StmtsBeginGraph
                  %AtRiskLatticeStart
                  layout overlay / xaxisopts=(&xoptions) yaxisopts=(&yoptions);
                     %StmtsTop
                     %SingleStratum
                     %StmtsBottom
                  endlayout;
                  %AtRiskLatticeEnd

               else
                  %if &ntitles %then %do; entrytitle &titletext2; %end;
                  %if &ntitles gt 1 %then %do;
                     if (EXISTS(SECONDTITLE))
                        entrytitle SECONDTITLE / textattrs=GRAPHVALUETEXT;
                     endif;
                  %end;

                  %StmtsBeginGraph
                  %AtRiskLatticeStart
                  layout overlay / xaxisopts=(&xoptions) yaxisopts=(&yoptions);
                     %StmtsTop
                     %MultipleStrata
                     %StmtsBottom
                  endlayout;
                  %AtRiskLatticeEnd(class)

               endif;

               if (_BYTITLE_) entrytitle _BYLINE_ / textattrs=GRAPHVALUETEXT;
               else if (_BYFOOTNOTE_) entryfootnote halign=left _BYLINE_; endif;
               endif;
               EndGraph;
            end;
         %end;
      run;
   %mend;

   %macro pValue;
      if (PVALUE < .0001)
         entry TESTNAME " p " eval (PUT(PVALUE, PVALUE6.4));
      else
         entry TESTNAME " p=" eval (PUT(PVALUE, PVALUE6.4));
      endif;
   %mend;

   %macro SingleStratum;
      if (PLOTHW=1 AND PLOTEP=0)
         bandplot LimitUpper=HW_UCL LimitLower=HW_LCL x=TIME /
            displayTail=false modelname="Survival" fillattrs=GRAPHCONFIDENCE
            name="HW" legendlabel=LABELHW;
      endif;
      if (PLOTHW=0 AND PLOTEP=1)
         bandplot LimitUpper=EP_UCL LimitLower=EP_LCL x=TIME /
            displayTail=false modelname="Survival" fillattrs=GRAPHCONFIDENCE
            name="EP" legendlabel=LABELEP;
      endif;
      if (PLOTHW=1 AND PLOTEP=1)
         bandplot LimitUpper=HW_UCL LimitLower=HW_LCL x=TIME /
            displayTail=false modelname="Survival" fillattrs=GRAPHDATA1
            datatransparency=.55 name="HW" legendlabel=LABELHW;
         bandplot LimitUpper=EP_UCL LimitLower=EP_LCL x=TIME /
            displayTail=false modelname="Survival" fillattrs=GRAPHDATA2
            datatransparency=.55 name="EP" legendlabel=LABELEP;
      endif;
      if (PLOTCL=1)
         if (PLOTHW=1 OR PLOTEP=1)
            bandplot LimitUpper=SDF_UCL LimitLower=SDF_LCL x=TIME /
               displayTail=false modelname="Survival" display=(outline)
               outlineattrs=GRAPHPREDICTIONLIMITS name="CL" legendlabel=LABELCL;
         else
            bandplot LimitUpper=SDF_UCL LimitLower=SDF_LCL x=TIME /
               displayTail=false modelname="Survival" fillattrs=GRAPHCONFIDENCE
               name="CL" legendlabel=LABELCL;
         endif;
      endif;

      stepplot y=SURVIVAL x=TIME / name="Survival" &tips legendlabel="Survival"
               &stepopts;

      if (PLOTCENSORED=1)
         scatterplot y=CENSORED x=TIME / &censored &tiplabel
            name="Censored" legendlabel="Censored";
      endif;

      if (PLOTCL=1 OR PLOTHW=1 OR PLOTEP=1)
         discretelegend "Censored" "CL" "HW" "EP" / location=outside
            halign=center;
      else
         if (PLOTCENSORED=1)
            discretelegend "Censored" / location=inside
                                        autoalign=(topright bottomleft);
         endif;
      endif;
      %if not &outside %then %do;
         if (PLOTATRISK=1)
            innermargin / align=bottom;
               axistable x=TATRISK value=ATRISK / &atriskopts;
            endinnermargin;
         endif;
      %end;
   %mend;

   %macro MultipleStrata;
     if (PLOTHW=1)
         bandplot LimitUpper=HW_UCL LimitLower=HW_LCL x=TIME / &bandopts
                  datatransparency=Transparency;
      endif;
      if (PLOTEP=1)
         bandplot LimitUpper=EP_UCL LimitLower=EP_LCL x=TIME / &bandopts
                  datatransparency=Transparency;
      endif;
      if (PLOTCL=1)
         if (PLOTHW=1 OR PLOTEP=1)
            bandplot LimitUpper=SDF_UCL LimitLower=SDF_LCL x=TIME / &bandopts
                     display=(outline) outlineattrs=(pattern=ShortDash);
         else
            bandplot LimitUpper=SDF_UCL LimitLower=SDF_LCL x=TIME / &bandopts
                     datatransparency=Transparency;
         endif;
      endif;

      stepplot y=SURVIVAL x=TIME / &groups name="Survival" &tips &stepopts;

      if (PLOTCENSORED=1)
         scatterplot y=CENSORED x=TIME / &groups &tiplabel &censored;
      endif;

      %if not &outside %then %do;
         if (PLOTATRISK=1)
            innermargin / align=bottom;
               axistable x=TATRISK value=ATRISK / &atriskopts &classopts;
            endinnermargin;
         endif;
      %end;

      %if %nrbquote(&legendopts) ne %then %do;
         DiscreteLegend "Survival" / &legendopts;
      %end;

      %if %nrbquote(&insetopts) ne %then %do;
         if (PLOTCENSORED=1)
            if (PLOTTEST=1)
               layout gridded / rows=2 &insetopts;
                  entry &censorstr;
                  %pValue
               endlayout;
            else
               layout gridded / rows=1 &insetopts;
                  entry &censorstr;
               endlayout;
            endif;
         else
            if (PLOTTEST=1)
               layout gridded / rows=1 &insetopts;
                  %pValue
               endlayout;
            endif;
         endif;
         %end;

   %mend;

   %macro SurvTabHeader(multiple);
      %if &multiple %then %do; entry ""; %end;
      entry "";
      entry "";
      entry "";
      entry &r "Median";
      entry "";
      entry "";

      %if &multiple %then %do; entry ""; %end;
      entry &r "Subjects";
      entry &r "Event";
      entry &r "Censored";
      entry &r "Survival";
      entry &r PctMedianConfid;
      entry halign=left  "CL";
   %mend;

   %macro SurvivalTable;
      %local fmt r i t;
      %let fmt = bestd6.;
      %let r = halign = right;
      columnheaders;
         layout overlay / pad=(top=5);
            if(NSTRATA=1)
               layout gridded / columns=6 border=TRUE;
                  dynamic PctMedianConfid NObs NEvent Median
                          LowerMedian UpperMedian;
                  %SurvTabHeader(0)
                  entry &r NObs;
                  entry &r NEvent;
                  entry &r eval(NObs-NEvent);
                  entry &r eval(put(Median,&fmt));
                  entry &r eval(put(LowerMedian,&fmt));
                  entry &r eval(put(UpperMedian,&fmt));
               endlayout;
            else
               layout gridded / columns=7 border=TRUE;
                  dynamic PctMedianConfid;
                  %SurvTabHeader(1)
                  %do i = 1 %to 10;
                     %let t = / textattrs=GraphData&i;
                     dynamic StrVal&i NObs&i NEvent&i Median&i
                             LowerMedian&i UpperMedian&i;
                     if (&i <= nstrata)
                        entry &r StrVal&i &t;
                        entry &r NObs&i &t;
                        entry &r NEvent&i &t;
                        entry &r eval(NObs&i-NEvent&i) &t;
                        entry &r eval(put(Median&i,&fmt)) &t;
                        entry &r eval(put(LowerMedian&i,&fmt)) &t;
                        entry &r eval(put(UpperMedian&i,&fmt)) &t;
                     endif;
                  %end;
               endlayout;
            endif;
         endlayout;
      endcolumnheaders;
   %mend;

   %macro SurvivalSummaryTable;
      %macro AtRiskLatticeStart;
         layout lattice / columndatarange=union rowgutter=10
            rows=%if &outside %then 2 rowweights=ROWWEIGHTS;
                 %else              1;;
         %if &outside %then %do; cell; %end;
      %mend;

      %macro AtRiskLatticeEnd(useclassopts);
         %if &outside %then %do;
            endcell;
            cell;
               layout overlay / walldisplay=none xaxisopts=(display=none);
                  axistable x=TATRISK value=ATRISK / &atriskopts
                            %if &useclassopts ne %then &classopts;;
               endlayout;
            endcell;
         %end;
         %SurvivalTable
         endlayout;
      %mend;
   %mend;

   %macro AtRiskLatticeStart;
      %if &outside %then %do;
         layout lattice / rows=2 rowweights=ROWWEIGHTS
                          columndatarange=union rowgutter=10;
         cell;
      %end;
   %mend;

   %macro AtRiskLatticeEnd(useclassopts);
      %if &outside %then %do;
         endcell;
         cell;
            layout overlay / walldisplay=none xaxisopts=(display=none);
               axistable x=TATRISK value=ATRISK / &atriskopts
                         %if &useclassopts ne %then &classopts;;
            endlayout;
         endcell;
      endlayout;
      %end;
   %mend;

%CompileSurvivalTemplates
%mend;

%let snapshotdate = 06JUL2020;

libname import "Z:\ViewRay - SMART Pancreas - Data Sciences\ViewRay - SMART Pancreas - Statistical Programming\DSMB 1\Primary\Import";



data exit;
keep subjectid EXIT_DATE EXIT_reas;
set import.study_exit;
run;
proc sort data=exit;
by subjectid;
run;
data subject_level;
set import.Ads_subject_level;
run;
data screening;
set import.screening;
keep subjectid PATHDIADT;
run;
proc sort data=screening;
by subjectid ;
run;

*******last ca date************;
data ca;
set import.ca;
keep subjectid cadt;
run;
proc sort data=ca;
by subjectid cadt;
run;
data ca;
set ca;
by subjectid cadt;
if last.subjectid;
run;
************last visit date************;
proc sort data=import.Fu_12_months out=Fu_12m(keep=subjectid fu_date);by subjectid fu_date;run;

proc sort data=import.Fu_6_months out=Fu_6m(keep=subjectid fu_date);by subjectid fu_date;run;
proc sort data=import.Fu_3_months out=Fu_3m(keep=subjectid fu_date);by subjectid fu_date;run;
data visit;
merge fu_12m(rename=(fu_date=f12mdt))
fu_6m(rename=(fu_date=f6mdt))
fu_3m(rename=(fu_date=f3mdt));
by subjectid;
run;


**************last treatment date************;
data treatment;
set import.treatment;
lasttrtdt=max(datepart(f1dt)
,datepart(f2dt)
,datepart(f3dt),
datepart(f4dt),datepart(f5dt));
keep subjectid lasttrtdt;
format lasttrtdt mmddyy10.; 
run;
proc sort data=treatment;
by subjectid;
run;

**************last med date************;
data med;
set import.med;
keep subjectid CM_START_DT CM_end_DT;
run;
proc sort data=med;
by subjectid CM_START_DT CM_end_DT;
run;
data med;
set med;
by subjectid CM_START_DT CM_end_DT;
if last.subjectid;
run;
***********pd date************;
data pd;
set import.pd;
keep subjectid pd_date;
run;
proc sort data=pd;
by subjectid pd_date;
run;
data pd;
set pd;
by subjectid pd_date;
if last.subjectid;
run;

**********image date*******;
data img;
set import.img;
keep subjectid imgdt;
run;
proc sort data=img;
by subjectid imgdt;
run;
data img;
set img;
by subjectid imgdt;
if last.subjectid;
run;
*****************distant progression;
data dp;
set import.img;
keep subjectid EVALTL imgdt;
where EVALTL='Distant Progressive Disease (DPD)';
rename imgdt =dpddt;
run;
proc sort data=dp;
by subjectid dpddt;
run;

data dp;
set dp;
by subjectid dpddt;
if first.subjectid;
run;

*******subjects finish trt;
data end_trt;
set import.treatment;
where f5dt ne .;
keep subjectid;
run;
proc sort data=end_trt;
by subjectid;
run;


***********last contact date;
data ados;
merge subject_level (keep =subjectid in=a) end_trt (in=b)
screening(keep =subjectid PATHDIADT) img exit ca visit med pd treatment  dp;
by subjectid;
if EXIT_REAS='Death' or EVALTL ne ''  then cnsr=0;
else cnsr=1;
if a and b;
lastctdt=max(
CM_START_DT,
lasttrtdt,
datepart(imgdt),
datepart(EXIT_DATE),
datepart(cadt),
datepart(f6mdt),datepart(f3mdt),datepart(f12mdt),
datepart(cm_end_dt),
datepart(pd_date)
);
if EXIT_REAS='Death'  then adt=datepart(exit_date);
if EVALTL ne '' then adt=datepart(dpddt);
if cnsr=1 then adt=lastctdt;
aval=adt-lasttrtdt;
run;


proc lifetest data=ados;
time aval*cnsr(1);
run;

%ProvideSurvivalMacros

%let yOptions = label="Distant Progression Free Survival"
                linearopts=(viewmin=0.3 viewmax=1
                            tickvaluelist=(0 .25 .4 .6 .8 1.0));
%let xOptions = label="Time after end of treatment (days)"
                linearopts=(viewmin=0 viewmax=730
                            tickvaluelist=(0 90 180 270 360 450 540 630 720));
%CompileSurvivalTemplates
ods output ProductLimitEstimates=kmtable_os;
ods trace on;
proc lifetest data=ados plots=survival
TIMELIST=0 to 720 by 90 
maxtime=720 reduceout outsurv=km_os ;
time aval*cnsr(1);

run;
ods trace off;



data kmtable_os;
set kmtable_os;
timelist1=lag1(timelist)+1;
if timelist1=. then timelist1=0;
head=catx('^n',timelist1,timelist);
left1 =lag(left);
if left1=. then left1=left;
 survival1=put(survival, percent9.1);
StdErr2=put(StdErr, percent9.1);
rename  survival1=survival
StdErr2=StdErr;
drop survival StdErr;
run;

proc sort data=ados;
by aval;
run;

data cnsr;
set ados ;
if cnsr=1 ;
if aval=0 then 
col1+1;
else if 1<=aval<=90 then col2+1;
else if 91<=aval<=180 then col3+1;
else if 181<=aval<=270 then col4+1;
else if 271<=aval<=360 then col5+1;
else if 361<=aval<=450 then col6+1;
else if 451<=aval<=540 then col7+1;
else if 541<=aval<=630 then col8+1;
else if 631<=aval<=720 then col9+1;
keep col: cnsr  ;
run;
data cnsr;
set cnsr end=eof;
if eof;
run;

proc transpose data=cnsr out=transcnsr(drop=_name_ rename=(col1=censor));
by cnsr;
var col:;
run;

data transcnsr;
set transcnsr;
if censor=. then censor=0;
run;


data event;
set ados ;
if cnsr=0 ;
if aval=0 then 
col1+1;
else if 1<=aval<=90 then col2+1;
else if 91<=aval<=180 then col3+1;
else if 181<=aval<=270 then col4+1;
else if 271<=aval<=360 then col5+1;
else if 361<=aval<=450 then col6+1;
else if 451<=aval<=540 then col7+1;
else if 541<=aval<=630 then col8+1;
else if 631<=aval<=720 then col9+1;
keep col: cnsr  ;
run;
data event;
set event end=eof;
if eof;
run;

proc transpose data=event out=transevent(drop=_name_ rename=(col1=event));
by cnsr;
var col:;
run;

data transevent;
set transevent;
if event=. then event=0;
run;

data kmtable_os;
format censor event 3.;
merge kmtable_os transcnsr transevent;
run;

run;
proc transpose data=kmtable_os out=transkmtable_os ;
var  left1 censor event survival stderr ;
run;






data transkmtable_os;
length interval $32.;
set transkmtable_os;		
		if _NAME_='left1' then Interval='# Entered'; 
 		if _NAME_='censor' then Interval = '# Censored';
		if _NAME_= 'event'  then Interval = '# Events';
		if _NAME_=  'survival'  then Interval = 'Event-free [%]';
  		if _NAME_=  'StdErr'   then Interval =  'Greenwood SE [%]' ;
		run;

proc report data = transkmtable_os nowindows split='|' headline headskip wrap;

	column  interval col1 col2 col3 col4 col5 col6 col7 col8     ;
	define  interval / "From day X To day Y" style(column) = [CELLWIDTH=150pt just=l VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
 	define  col1 / "0|0" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col2 / "1|90" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col3 / "91|180" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col4 / "181|270" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col5 / "271|360" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col6 / "361|540" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col7 / "541|630" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col8 / "631|720" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	
run;

ods escapechar='^';

%let Lheader1= ViewRay;
%let Lheader2= SMART;
%let Cheader2= %str( );
%let Rheader1= CONFIDENTIAL;
%let Rheader2= Page ^{pageof};

%let tabttl1= %str(Figure 2. Distant Progression Free Survival by Kaplan Meier);
%let title1txt= %str(Figure 2. Distant Progression Free Survival by Kaplan Meier);

%let footer1 = Prepared by Syntactx, LLC ;
%let footer2 = CONFIDENTIAL;
%let footer3 = &snapshotdate;

options orientation = landscape
papersize = letter
nodate
nonumber
topmargin = 1.0in
bottommargin =1.0in
leftmargin = 0.50in
rightmargin = 0.50in;

ods listing close;
ods rtf body = "Z:\ViewRay - SMART Pancreas - Data Sciences\ViewRay - SMART Pancreas - Statistical Programming\DSMB 1\Primary\TLFs\Figures\&tabttl1..rtf"
 style=styles.custom ;

title1 j=l "&Lheader1" j=r "&Rheader1";
title2 j=l "&Lheader2" j=c "&Cheader2" j=r "&Rheader2";
title3 " " ;
title4 j=l "&title1txt" ;

footnote1 j=l "&footer1"  j=r "Created on:"  "%cmpres(%sysfunc(datetime(),datetime18.))";
footnote2 j=l /*"Program:" "&protdir1"*/  j=r "Database snapshot:"  "&footer3";

%ProvideSurvivalMacros

%let yOptions = label="Distant Progression Free Survival"
                linearopts=(viewmin=0.0 viewmax=1
                            tickvaluelist=(0 .2 .4 .6 .8 1.0));
%let xOptions = label="Time after end of treatment (days)"
                linearopts=(viewmin=0 viewmax=730
                            tickvaluelist=(0 90 180 270 360 450 540 630 720));
%let TitleText0 = "";

%CompileSurvivalTemplates
ods select SurvivalPlot;
ods noproctitle;
proc lifetest data=ados plots=survival
TIMELIST=0 to 720 by 90 
maxtime=720 reduceout  ;
time aval*cnsr(1);

run;

proc report data = transkmtable_os nowindows split='|' headline headskip wrap;

	column  interval col1 col2 col3 col4 col5 col6 col7 col8     ;
	define  interval / "From day X To day Y" style(column) = [CELLWIDTH=150pt just=l VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
 	define  col1 / "0|0" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col2 / "1|90" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col3 / "91|180" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col4 / "181|270" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col5 / "271|360" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col6 / "361|540" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col7 / "541|630" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  col8 / "631|720" style(column) = [CELLWIDTH=35pt just=c VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
run;

ods rtf text="";

ods rtf close;
ods listing;


proc template;
   delete Stat.Lifetest.Graphics.ProductLimitSurvival  /
          store=sasuser.templat;
   delete Stat.Lifetest.Graphics.ProductLimitSurvival2 /
          store=sasuser.templat;
run;