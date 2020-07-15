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
ods output summary=impute;
proc means data=analytic_data mean median;
class BASE_GEND;
var BASE_PHYS_HEI	BASE_PHYS_WEI		BASE_PHYS_RUTH;
run;

data impute;
set impute;
if BASE_GEND='F' then do ;
call symputx('femalehei',BASE_PHYS_HEI_Mean);
call symputx('femalewei',BASE_PHYS_WEI_Mean);
call symputx('femaleruth',BASE_PHYS_RUTH_Median);
end;
if BASE_GEND='M' then do ;
call symputx('malehei',BASE_PHYS_HEI_Mean);
call symputx('malewei',BASE_PHYS_WEI_Mean);
call symputx('maleruth',BASE_PHYS_RUTH_Median);
end;
run;

data analytic_data;
set analytic_data;
if BASE_PHYS_HEI=. and BASE_GEND='F' then BASE_PHYS_HEI=&femalehei;
if BASE_PHYS_WEI=. and BASE_GEND='F' then BASE_PHYS_WEI=&femalewei;

if BASE_PHYS_Ruth=. and BASE_GEND='F' then BASE_PHYS_ruth=&femaleruth;

if BASE_PHYS_HEI=. and BASE_GEND='M' then BASE_PHYS_HEI=&malehei;
if BASE_PHYS_WEI=. and BASE_GEND='M' then BASE_PHYS_WEI=&malewei;

if BASE_PHYS_Ruth=. and BASE_GEND='M' then BASE_PHYS_ruth=&maleruth;
if BASE_PHYS_BMI=. then BASE_PHYS_BMI=BASE_PHYS_WEI/(BASE_PHYS_HEI/100)**2;
run;

proc psmatch data=analytic_data region=allobs;
   class  DCB_ BASE_BLEED BASE_CONTRA BASE_CONTRA BASE_CVA BASE_DM
BASE_DYS
BASE_GEND
BASE_HEAL
BASE_HYPER BASE_PHYS_RUTH BASE_PREHIS
BASE_RACE
BASE_RENAL
BASE_SMOKE;
   psmodel DCB_(Treated='1')= BASE_AGE 
BASE_BLEED
BASE_CONTRA
BASE_CVA
BASE_DM
BASE_DYS
BASE_GEND
BASE_HEAL
BASE_HYPER
BASE_PHYS_BMI
BASE_PHYS_HEI
BASE_PHYS_RUTH
BASE_PHYS_WEI
BASE_PREHIS
BASE_RACE
BASE_RENAL
BASE_SMOKE;

   strata nstrata=5 key=treated stratumwgt=total;
   assess ps var=(
 BASE_BLEED BASE_CONTRA BASE_CONTRA BASE_CVA BASE_DM
BASE_DYS
BASE_GEND
BASE_HEAL
BASE_HYPER BASE_PHYS_RUTH BASE_PREHIS
BASE_RACE
BASE_RENAL
BASE_SMOKE)
          / varinfo plots=(barchart cdfplot);
   output out(obs=all)=OutKM;
run;



data outKM ;
set outKM;
keep subjectid _STRATA_ dcb_ days_to_event cdtlr _ps_ BASE_AGE
BASE_BLEED
BASE_CONTRA
BASE_CVA
BASE_DM
BASE_DYS
BASE_GEND
BASE_HEAL
BASE_HYPER
BASE_PHYS_BMI
BASE_PHYS_HEI
BASE_PHYS_RUTH
BASE_PHYS_WEI
BASE_PREHIS
BASE_RACE
BASE_RENAL
BASE_SMOKE;
rename subjectid= subject;
run;

ods output SurvivalPlot=survplot;
proc lifetest data=outKM(where=( _strata_ ^= .)) 
plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 to 360 by 30)
TIMELIST=0 to 360 maxtime=360 conftype=linear method=km reduceout outsurv=km_trtpip ;
time days_to_event*cdtlr(0);
strata dcb_  ;
run;

ods output ProductLimitEstimates=kmstrata1;
proc lifetest data=outKM(where=( _strata_=1)) 
plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 to 360 by 30)
TIMELIST=0 to 360 maxtime=360 conftype=linear method=km reduceout outsurv=km_trtpip_1 ;
time days_to_event*cdtlr(0);
strata dcb_  ;
run;

ods output ProductLimitEstimates=kmstrata2;
proc lifetest data=outKM(where=( _strata_=2)) 
plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 to 360 by 30)
TIMELIST=0 to 360 maxtime=360 conftype=linear method=km reduceout outsurv=km_trtpip_2 ;
time days_to_event*cdtlr(0);
strata dcb_  ;
run;


ods output ProductLimitEstimates=kmstrata3;
proc lifetest data=outKM(where=( _strata_=3)) 
plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 to 360 by 30)
TIMELIST=0 to 360 maxtime=360 conftype=linear method=km reduceout outsurv=km_trtpip_3 ;
time days_to_event*cdtlr(0);
strata dcb_  ;
run;


ods output ProductLimitEstimates=kmstrata4;
proc lifetest data=outKM(where=( _strata_=4)) 
plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 to 360 by 30)
TIMELIST=0 to 360 maxtime=360 conftype=linear method=km reduceout outsurv=km_trtpip_4 ;
time days_to_event*cdtlr(0);
strata dcb_  ;
run;


ods output ProductLimitEstimates=kmstrata5;
proc lifetest data=outKM(where=( _strata_=5)) 
plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 to 360 by 30)
TIMELIST=0 to 360 maxtime=360 conftype=linear method=km reduceout outsurv=km_trtpip_5 ;
time days_to_event*cdtlr(0);
strata dcb_  ;
run;



data kmstrata1;
set kmstrata1;
weight=0.2;
Survival1=weight*Survival;
var1=StdErr*StdErr*weight*weight;
run;

data kmstrata2;
set kmstrata2;
weight=0.2;
Survival2=weight*Survival;
var2=StdErr*StdErr*weight*weight;
run;

data kmstrata3;
set kmstrata3;
weight=0.2;
Survival3=weight*Survival;
var3=StdErr*StdErr*weight*weight;
run;

data kmstrata4;
set kmstrata4;
weight=0.2;
Survival4=weight*Survival;
var4=StdErr*StdErr*weight*weight;
run;

data kmstrata5;
set kmstrata5;
weight=0.2;
Survival5=weight*Survival;
var5=StdErr*StdErr*weight*weight;
run;

data kmoverall;
merge kmstrata1-kmstrata5;
surv=sum(survival1,survival2,survival3,survival4,survival5);
variance=sum(var1,var2,var3,var4,var5);
std=sqrt(variance);
SDF_LCL=surv-1.96*std;
SDF_UCL=surv+1.96*std;
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

ods output   GlobalTests=logranktest;
proc phreg data=outkm;
model days_to_event*cdtlr(0)=dcb_;
strata _strata_  ;
run;

data _null_;
set logranktest;
if test='Score' then call symputx('pvalue',put(ProbChiSq,pvalue6.4));
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
  	stepplot x=TIMELIST y=surv/group=stratum name='Step';
	scatterplot x=TIMELIST y=surv/ yerrorlower=SDF_LCL yerrorupper=SDF_UCL  group=stratum  markerattrs=(symbol=CircleFilled size=0.000001) name='Treatment';
annotate;
	mergedlegend 'Step' 'Treatment';

innermargin;
blockplot x=TIMELIST block=atrisk / display=(label values) class=stratum valuehalign=start;
endinnermargin;
/*  layout gridded / width=375px height=250px halign=left valign=bottom;*/
/*  layout overlay  / xaxisopts=(linearopts=(viewmax=1080 tickvaluelist=(0 60 120 180 240 300 360 420 480 540 600 660 720 780 840 900 960 1020 1080)) label="Time after Index Procedure (days)") yaxisopts=(linearopts=(tickvalueformat = percent.) label="Freedom from Clinically-driven TLR");*/
/*  	stepplot x=TIMELIST y=survival/group=stratum;*/
/*	scatterplot x=TIMELIST y=survival/ yerrorlower=SDF_LCL yerrorupper=SDF_UCL group=stratum;* name='Treatment';*/
/*	endlayout;*/
/*  endlayout;*/
	
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
ci=put(surv*100,5.1)||'%'||'^n('||put(surv*100-1.96*std*100,5.1)||'%'||','||put(surv*100+1.96*std*100,5.1)||'%'||')';

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

%let tabttl1= %str(Figure 1. Kaplan-Meier - Freedom from CD-TLR - Propensity Score Analysis);
%let title1txt= %str(Figure 1. Kaplan-Meier - Freedom from CD-TLR - Propensity Score Analysis);

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
format stratum  strafmt.;
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
