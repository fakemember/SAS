
************************************************************************************************;
* Project           : RELAY PRO-A
*
* Program name      :  Figure 6 Kaplan-Meier Plot of All cause Mortality: Pivotal Study.sas
*
* Author            : sf
*
* Date created      : 2019SEP10
*
* Purpose           : site reported, corelab and cec
*
* Revision History  :
*
* Date        Author      Ref    Revision 
*  
*
**********************************************************************************************;

%let path= Z:\Bolton Medical - Relay Pro-A - Data Sciences\Bolton Medical - Relay Pro-A - SAS Programming\Primary;
libname impdata "&path\Impdata";
libname tables "&path\Tables";

%include "&path\Code\Create Analytic Datasets.sas";
%include "&path\Code\Macro Library.sas";

*********************************************************************************************;

ods output ProductLimitEstimates=km3table;;
proc lifetest data=sitereported plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 30 180 360 540 720 900 1080 1260)
TIMELIST=0 30 180 360 540 720 900 1080 1260 maxtime=1081 reduceout outsurv=km3;
time deathfutime*death(0);
run;

proc lifetest data=sitereported plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 30 180 360 540 720 900 1080 1260)
 maxtime=1081  outsurv=km3a;
time deathfutime*death(0);
run;

proc sort data=km3;by deathfutime;run;
proc sort data=km3a;by deathfutime;run;

data km3f;
merge km3 km3a;
by deathfutime;
if survival^=. then surv2=survival;
retain surv2;
if survival=. then survival=surv2;
lagLower=lag(sdf_LCL);
lagUpper=lag(sdf_uCL);
if timelist=540 and sdf_LCL='' then sdf_LCL=lagLower;
if timelist=540 and sdf_uCL='' then sdf_uCL=lagUpper;
run;


data KMTable;
do i = 0 to 9 by 1;
if i = 0 then x = 0 and y = 0;
else x = y+1;
y=(i-1)*180;
output;
end;
rename y=timelist;
run;

data kmtable;
set kmtable;
if i = 0 then do; x = 0; timelist= 0;end;
if i=1 then do; x=1 ;timelist= 30; end;
if i=2 then do; x=31;  end;
run;

ods output LifetableEstimates=lftb3 (rename=(uppertime=timelist) drop=survival stderr);
proc lifetest data=sitereported method=life interval=1 31 181 361 541 721 901 1081 1261
		maxtime=1081 outsurv=km3lt;
time deathfutime*death(0);
run;

data lftb3;set lftb3;timelist=timelist-1;run;

proc sort data=lftb3;
by timelist;run;

data km3f;
set km3f;
if deathfutime=760 then timelist=900;
run;

data km3ftemp;
set km3f;
keep timelist sdf_lcl sdf_ucl survival stderr;
where timelist^=. AND sdf_lcl^=.;

run;

data km3ft;
keep x timelist survival Failed left Censored StdErr interval sdf_lcl sdf_ucl ci lower upper lagci;
merge KMTable km3table  lftb3 km3ftemp;
by timelist;
lagcensor=lag(Censored);
lagfail=lag(failed);
/*lagci=lag(ci);*/
/*if ci='' then ci=lag(ci);*/

if x=0 then failed=0;
if x=1 then failed=failed+lagfail;

if x=0 then n=left;
left=lag(left);
if x=0 then left=n; 
rename timelist=y;
if x>0 then interval=catx('-',x,timelist);
else interval=0;
lower=put(sdf_lcl,percent9.1);
upper=put(sdf_ucl,percent9.1);
if left>0 then ci=catx('-',lower,upper);


lagci = lag(ci);
if ci in ('.-.',' ') then ci=lagci;

if x=1 then left=left-lagcensor;
rename stderr=sd;
run;


********************************plots;
proc template;
define statgraph inset;
begingraph;
  layout overlay / xaxisopts=(linearopts=(viewmax=1080 tickvaluelist=(0 30 180 360 540 720 900 1080 1260)) label="Days" ) yaxisopts=(linearopts=(viewmin=0 viewmax=1 tickvalueformat = percent. ) label="Event Free");
  	stepplot x=deathfutime y=survival;
	scatterplot x=TIMELIST y=survival/ yerrorlower=SDF_LCL yerrorupper=SDF_UCL;
  layout gridded / width=375px height=250px halign=left valign=bottom;
  layout overlay  / xaxisopts=(linearopts=(viewmax=1080 tickvaluelist=(0 30 180 360 540 720 900 1080 1260)) label="Days") yaxisopts=(linearopts=(viewmin=0.60 viewmax=1 tickvalueformat = percent.) label="Event Free");
  	stepplot x=deathfutime y=survival;
	scatterplot x=TIMELIST y=survival/ yerrorlower=SDF_LCL yerrorupper=SDF_UCL;
  endlayout;
  endlayout;
  endlayout;
endgraph;
end;
run;

	**************************************Final report********************************************************;
ods escapechar='^';

%let Lheader1= Bolton Medical;
%let Lheader2= RelayPro-A;
%let Cheader2= Analysis for CSR;
%let Rheader1= CONFIDENTIAL;
%let Rheader2= Page ^{pageof};

%let tabttl1= %str(Figure 6. Kaplan-Meier Freedom from All-Cause Mortality);
%let title1txt= %str(Kaplan-Meier Freedom from All-Cause Mortality);

%let footer1 = Prepared by Syntactx, LLC ;
%let footer2 = CONFIDENTIAL;
%let footer3 = &dbexportdate;


options orientation = portrait
papersize = letter
nodate
nonumber
topmargin = 1.0in
bottommargin =1.0in
leftmargin = 0.50in
rightmargin = 0.50in;

ods listing close;
ods rtf body = "&path\Tables\&tabttl1..rtf" style=relayproA ;

title1 j=l "&Lheader1" j=r "&Rheader1";
title2 j=l "&Lheader2" j=c "&Cheader2" j=r "&Rheader2";
title3 " " ;
title4 j=l "&title1txt" ;

footnote1 j=l "&footer1"  j=r "Created on:"  "%cmpres(%sysfunc(datetime(),datetime18.))";
footnote2 /*j=l "Program:" "&protdir1"*/  j=r "Database snapshot:"  "&footer3";

ods text="^S={just=l fontweight=bold }&title1txt";

/*proc sgplot data=km3f;*/
/*step x=deathfutime y=survival;*/
/*scatter x=TIMELIST y=survival/ yerrorlower=SDF_LCL yerrorupper=SDF_UCL;*/
/*xaxis label='Time-to-Major Adverse Event (Days)' min=0 values=(0 30 180 360 540 720 900 1080) max=540;*/
/*yaxis label='Survival Function' values=(0.65 to 1 by 0.05);*/
/*run;*/

proc sgrender data=km3f template=inset;
title1 "Kaplan-Meier Freedom from All-Cause Mortality"; 
run;

*produces survival summary table;
/*proc print data=km3ft (obs=7 firstobs=2) label noobs;*/
/*	var interval left censored failed survival stderr ci;*/
/*	label x = 'From Day'*/
/*		  y = 'To Day' */
/*		  interval = 'From Day X - To Day Y'*/
/*		  left = '# Entered'*/
/*		  censored = '# Censored'*/
/*		  failed = '# Events'*/
/*		  survival = 'Event-free [%]'*/
/*  		  stderr =  'Greenwood SE [%]' */
/*		  ci = '95% Confidence Interval';*/
/*	format survival percent9.1 stderr percent9.1;*/
/*run;*/


proc report data=km3ft (obs=8 firstobs=2);
	column interval left censored failed survival sd ci;
	define	  interval / 'From Day X - Day Y' style(column) = [CELLWIDTH=100pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c];
	define	  left / '# Entered' style(column) = [CELLWIDTH=40pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c];
	define	  censored / '# Censored' style(column) = [CELLWIDTH=50pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c];
	define	  failed / '# Events' style(column) = [CELLWIDTH=40pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c];
	define	  survival / 'Event-free [%]' style(column) = [CELLWIDTH=60pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c];
  	define	  sd / 'Greenwood SE' style(column) = [CELLWIDTH=60pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c];
	define	  ci /'95% Confidence Interval' style(column) = [CELLWIDTH=100pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c];
	format survival percent9.1 stderr percent9.1;
run;

ods rtf close;
ods listing;
