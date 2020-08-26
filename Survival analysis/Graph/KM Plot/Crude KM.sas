************************************************************************************************;
* Project           : 
*
* Program name      : Propensity score analysis.sas
*
* Author            : Chao 
*
* Date created      : 13July2020
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
%let path=Z:\Veryan Medical - 3D MIMICS - Data Sciences\Veryan Medical - 3D MIMICS - Statistical Programming\CSR n\Primary;
libname import "&path.\Import";
proc sort data=import.subject_level  out=subject_level(rename=(subject=subjectid));
by subject;
run;

 proc import datafile= "Z:\Veryan Medical - 3D MIMICS - Data Sciences\Veryan Medical - 3D MIMICS - Statistical Programming\CSR n\Primary\Raw\M3D_15May2020-PP(N=463).xlsx"
  out=analytic_data
replace
  dbms=xlsx;
  sheet='Master';
RUN;

proc sort data=analytic_data;
by subjectid;
where subjectid ^='';
run;


data analytic_data;
merge analytic_data(in=a) subject_level;
by subjectid;
if a;
days_to_event=CDTLR_T;
if dcb_any='Y' then dcb_=1;
else dcb_=0;
run;


ods trace on;
ods output ProductLimitEstimates=kmstrata
  HomTests=logranktest
 SurvivalPlot=survplot;
proc lifetest data=analytic_data
plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 to 360 by 30)
TIMELIST=0 to 360 maxtime=360 conftype=linear method=km reduceout outsurv=km_trtpip ;
time days_to_event*cdtlr(0);
strata dcb_  ;
run;


data kmoverall;
set km_trtpip;
if timelist not in (0,30,60,90,120,150,180,210,240,270,300,330,360) then do;
SDF_LCL=.;
SDF_UCL=.;
end;
if SDF_UCL>1 then SDF_UCL=1;
run;

proc sql;
create table kmoverall as
select a.*,b.atrisk,b.StratumNum,b.tAtRisk
from kmoverall as a left join survplot(where=(tAtRisk ne .)) as b 
on a.timelist =b.tAtRisk and a.stratum=b.StratumNum;
run;

data _null_;
set logranktest;
if test='Log-Rank' then call symputx('pvalue',put(ProbChiSq,pvalue6.4));
run;

 %SGANNO; 
 
DATA anno;
%SGTEXT(         X1 = 200,        
Y1 =0.1,     
ANCHOR = "LEFT",  
WIDTHUNIT = "DATA",    
DRAWSPACE = "DATAVALUE",     
LABEL = "MIMIC 3D Stent vs MIMIC 3D Stent+DCB",width=230)  
%SGTEXT(        X1 = 200,        
Y1 =0.065,     
ANCHOR = "LEFT",  
WIDTHUNIT = "DATA",    
DRAWSPACE = "DATAVALUE",     LABEL = "Log-Rank p-Value = &pvalue",width=230) 
run;
 

proc template;
define statgraph inset;
begingraph;*/DATACONTRASTCOLORS=(red blue);
  layout overlay / xaxisopts=(linearopts=(viewmax=360 tickvaluelist=(0 30 60 90 120 150 180 210 240 270 300 330 360)) 
label="Time after Index Procedure (days)" ) yaxisopts=(linearopts=(tickvaluelist=(0 .1 .2 .3 .4 .5 .6 .7 .8 .9 1) viewmin=0 viewmax=1 tickvalueformat = percent. ) label="Freedom from CD-TLR");
  	stepplot x=TIMELIST y=survival/group=stratum name='Step';
	scatterplot x=TIMELIST y=survival/ yerrorlower=SDF_LCL yerrorupper=SDF_UCL  group=stratum  markerattrs=(symbol=CircleFilled size=0.000001) name='Treatment';
	annotate;
	mergedlegend 'Step' 'Treatment';
	innermargin;
blockplot x=TIMELIST block=atrisk / display=(label values) class=stratum valuehalign=start;
endinnermargin;
  endlayout;
endgraph;
end;
run;



proc format;
value strafmt 1='MIMIC 3D Stent'
			 2='MIMIC 3D Stent+DCB';
run;




data km360;
set kmoverall;
where timelist=360;
ci=put(survival*100,5.1)||'%'||'^n('||put(SDF_LCL*100,5.1)||'%'||','||put(SDF_UCL*100,5.1)||'%'||')';

run;
proc transpose data=km360 out=km360_;
id dcb_;
var ci;
run;
data km360_;
set km360_;
label='Freedom From CD-TLR at Day 360';
statistic='KM% (95% CI)';
run;


	**************************************Final report********************************************************;
ods escapechar='^';

%let Lheader1= VARYEN Medical;
%let Lheader2= MIMICS 3D;
%let Cheader2= Requested Analysis;
%let Rheader1= CONFIDENTIAL;
%let Rheader2= Page ^{pageof};

%let tabttl1= %str(Figure 1. Crude Kaplan-Meier - Freedom from CD-TLR);
%let title1txt= %str(Figure 1. Crude Kaplan-Meier - Freedom from CD-TLR);

%let footer1 = Prepared by Syntactx, LLC ;
%let footer2 = CONFIDENTIAL;
%let footer3 = 04OCT2019;


options orientation = portrait
nodate
nonumber
topmargin = 1.0in
bottommargin =1.0in
leftmargin = 0.50in
rightmargin = 0.50in
missing='';

ods listing close;
ods rtf body = "Z:\Veryan Medical - 3D MIMICS - Data Sciences\Veryan Medical - 3D MIMICS - Statistical Programming\CSR n\Primary\TLFs\Tables\&tabttl1..rtf" style=custom ;

title1 j=l "&Lheader1" j=r "&Rheader1";
title2 j=l "&Lheader2" j=c "&Cheader2" j=r "&Rheader2";
title3 " " ;
title4 j=l "&title1txt" ;

footnote1 j=l "&footer1"  j=r "Created on:"  "%cmpres(%sysfunc(datetime(),datetime18.))";
footnote2  j=r "Database snapshot:"  "&footer3";

ods graphics / width=700px;
proc sgrender data=kmoverall template=inset sganno=anno;
format stratum strafmt.;
run;


proc report data = km360_ nowindows   headline headskip wrap  SPLIT='|';

	column label statistic _0 _1;

	define label / '' style(column) = [CELLWIDTH=125pt just =l];
	define  statistic/ "Statistic" style(column) = [CELLWIDTH=75pt just = c] style(header) = [just = c];

define  _0/ "MIMIC 3D Stent" style(column) = [CELLWIDTH=90pt just = c] style(header) = [just = c];
 	define  _1/ "MIMIC 3D Stent+DCB" style(column) = [CELLWIDTH=90pt just = c] style(header) = [just = c];
run;
ods rtf text="";
ods rtf close;
ods listing;
