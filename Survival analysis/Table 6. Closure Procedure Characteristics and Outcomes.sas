************************************************************************************************;
* Project           : Terumo Cross-Seal
*
* Program name      : Table 6. Closure Procedure Characteristics and Outcomes.sas
*
* Author            : pk
*
* Date created      : 2019DEC04
*
* Purpose           : procedural outcomes table
*
* Revision History  :
*
* Date        Author      Ref    Revision 
* 2020FEB21		nf			1		Added Medians and IQR to all continuous variables
*
**********************************************************************************************;


data Rollin;
	set analytic_data;
	if pop= 'Roll-in';
run;

data Pivotal;
	set analytic_data;
	if pop= 'Pivotal';
run;

data suball;
	set analytic_data;
	pop = 'Suball';
run;

data table5;
	set Rollin Pivotal suball;
run;

data table5;
	set table5;
	Time_hemostasis = (sum((PROC_TTH_MM *60) ,PROC_TTH_SS))/60;
	if proc_hemostasis_achieved ='No' then Time_hemostasis=.; 
	Procedure_Time = (PROC_TIME_HEMO - PROC_START_TIME)/60;
	if procedure_time < 0 then procedure_time = .; *until data can be corrected;
	if PROC_EST_BLOOD_LOSS < 0 then PROC_EST_BLOOD_LOSS = .; *until data can be corrected;
	*keep subjectid Time_hemostasis PROC_TTH_MM  PROC_TTH_SS;
	rename PROC_HEMOSTASIS_ACHIEVED_NO_SURG = Intervention_SURG;
	rename PROC_HEMOSTASIS_ACHIEVED_NO_ENDO = Intervention_ENDO;
	rename PROC_HEMOSTASIS_ACHIEVED_NO_OTHE = Intervention_OTHE;
run;

/*proc univariate data=table5 plot;
var time_hemostasis;
run;

proc print data=table5;
var Time_hemostasis PROC_TTH_MM PROC_TTH_SS; *HEAVY skew on time to hemostasis;
run;*/

*******************************************************************************;

%macro part1(a,b);

proc means data= table5 noprint;
	var &a;
	class pop;
	output out= &a.1(drop= _TYPE_ _FREQ_) N=N Mean=Mean Median=Median Q1=Q1 Q3=Q3 Min=Min Max=Max std=std;
run;

data &a.1;
	set &a.1;
	if pop ^= '';
	length N1 MeanStd MedIQR MinMax $41.;
	N1 = put(round(N,.1),8.);
	MeanStd = compbl(put(round(Mean,.1),8.1) || ' ^{00B1} ' || put(round(std,.01),8.2));
	/*MinMax = compbl('(' || put(round(Min,.1),8.1) || ' -  ' || put(round(Max,.1),8.1) ||')');*/
	MedIQR = compbl(compress(round(Median,0.001)) || ' (' || compress(round(Q1,0.001)) || '  -  ' || round(Q3,0.001) || ')');
	MinMax = compbl(compress(Min) || ', ' || round(Max,0.01));
run;

proc transpose data=&a.1 out=&a(drop= _NAME_);
	var N1 MeanStd MedIQR MinMax;
	id pop;
run;

data dump1;
	length Characteristic $120.;
	Characteristic = "&b";
run;

data dump2;
	length Characteristic $120.;
	Characteristic = 'N';
	output;
	Characteristic = 'Mean ^{00B1} SD';
	output;
	Characteristic = 'Median (IQR)';
	output;
	Characteristic = 'Min, Max';
	output;	
run;

data &a;
	merge dump2 &a;
run;

data &a;
	set dump1 &a;
run;

%mend;

%part1(Time_hemostasis, Primary Effectiveness Endpoint - Time-to-Hemostasis (min));  
%part1(PROC_EST_BLOOD_LOSS, Estimated Blood Loss (mL));  *minimum of -971, need to query;
%part1(Procedure_Time, Overall Procedure Time (min));  *minimum of -688, queried;
%part1(PROC_ACT, ACT Prior to Sheath Removal (sec));
%part1(PROC_TDD, Time-to-Device-Deployment (min));     *negative values, need to query;

*******************************************************************************;
 *use the upper limit of two sided 95% CI it's the one sided 97.5% upper limit; 

data table1;
	set table5;
	if pop= 'Pivotal';
run; 

proc means data=table1 clm alpha=0.05;
   var time_hemostasis;
   output out=New LCLM=lclm UCLM=uclm;
run;

data hemostasis_clm(keep= Characteristic Pivotal Roll_in Suball);
	length Characteristic $120. Pivotal Roll_in Suball $61.;
	set New;
	Characteristic='Upper one-sided 97.5% confidence limit for Performance Goal <15 (min)';
	Pivotal=round(uclm,.1);
	Roll_in='NA';
	Suball='NA';
run;


*******************************************************************************;

%macro part2(a,b);

proc freq data=table5 noprint ;
	table pop*&a / out=&a.1(where=(&a not in (''/*,'Not Provided','Not P'*/))) ;                       
run;

proc sql; 
	create table &a.2(drop=PERCENT) as
	select * , sum(count) as x
	from &a.1
	group by pop;
quit;

data &a.2;
	set &a.2;
	y = round(((COUNT/x)*100),.1);
	b= compbl(put(y,8.1) || '% (' || compress(COUNT || '/' || x ||')'));
run;


proc transpose data = &a.2 out= &a.3(drop=_NAME_);
	var b;
	id pop;
	by &a notsorted;
run;

proc sql;
	create table &a as
	select &a as Characteristic length 120 format $120. informat $120., max(Pivotal) as Pivotal, max(Roll_in) as Roll_in, max(Suball) as Suball
	from &a.3
	group by &a;
quit;

data dump1;
	length Characteristic $120.;
	Characteristic = "&b";
run;	

data &a(drop=Characteristic rename=(char=Characteristic));
	set &a;
	char = scan(Characteristic,1,';')||')';
run;

data &a;
	set dump1 &a;
run;

%mend;

%part2(PROC_MAN_COMP_TYPE,Manual Compression Type);  

*Use if one group is blank;

/**/
/*proc sql;*/
/*	select x into: Pivotal_x*/
/*	from PROC_MAN_COMP_TYPE2*/
/*	where pop = 'Pivotal';*/
/*run;*/
/**/
/*data PROC_MAN_COMP_TYPE;*/
/*	set PROC_MAN_COMP_TYPE;*/
/*	if Characteristic = 'Firm (occlusive; prohibiting distal blood flow)' then Characteristic = 'Firm (occlusive)';*/
/*	if Characteristic = 'Light (non-occlusive; allowing distal blood flow)' then Characteristic = 'Light (non-occlusive)';*/
/*	if Pivotal = '' and Characteristic = 'Firm (occlusive)' then Pivotal = "0.0% (0/%cmpres(&Pivotal_x))";*/
/*run;*/


*******************************************************************************;


%macro part3(a,b,c);

proc freq data=table5 noprint ;
	table pop*&a / out=&a.1(where=(&a not in ('','Unknown'))) ;                       
run;

proc sql; 
	create table &a.2(drop=PERCENT) as
	select * , sum(count) as x
	from &a.1
	group by pop;
quit;

data &a.2;
	set &a.2;
	y = round(((COUNT/x)*100),.1);
	b= compbl(put(y,8.1) || '% (' || compress(COUNT || '/' || x ||')'));
run;

data &a.2;
	set &a.2;
	if &a = "&c" then delete;
run;

proc transpose data = &a.2 out= &a.3(rename=(_NAME_=Characteristic));
	var b;
	id pop;
run;

data &a;
length Characteristic $120.;
	set &a.3;	
	Characteristic = "&b";
run;	

%mend;

%part3(PROC_ANTI_GIV, Anticoagulants/Antiplatelet Per Protocol,No); 
%part3(PROC_MAN_COMP_REQ, Adjunctive Manual Compression Used to Obtain Hemostasis ,No); 
%part3(required_adj_interv, Adjunctive Intervention Needed ,No); 
%part3(PROC_HEMOSTASIS_ACHIEVED , Technical Success ,No); 

**************************************************************************;


%macro part4(a,b,c);

proc freq data=table5 noprint ;
	table pop*&a / out=&a.1(where=(&a not in ('','false'))) ;                       
run;

proc sql; 
	create table &a.2(drop=PERCENT) as
	select * , sum(count) as x
	from &a.1
	group by pop;
quit;

proc freq data=table5 noprint ;
	table pop*&b / out=&b.1(where=(&b not in ('Yes',''))) ;                       
run;

proc sql; 
	create table &b.2(drop=PERCENT) as
	select * , sum(count) as y
	from &b.1
	group by pop;
quit;

data &c.1;
	merge &a.2(keep=pop x) &b.2(keep=pop y);
	by pop;
run;

data &c.1;
	set &c.1;
	if x ne . then do;
	z = round(((x/y)*100),.1);
	b= compbl(put(z,8.1) || '% (' || compress(x || '/' || y ||')'));
	end;
	if x = . then do;
	z = round(((0/y)*100),.1);
	b= compbl(put(z,8.1) || '% (' || compress(0 || '/' || y ||')'));
	end;
run;

proc transpose data = &c.1 out= &c.2(rename=(_NAME_=Characteristic));
	var b;
	id pop;
run;

data &c;
length Characteristic $120.;
	set &c.2;	
	Characteristic = "&c";
run;	

%mend;
	
%part4(Intervention_SURG,PROC_HEMOSTASIS_ACHIEVED,Surgical);                                            *create dummy dataset if categories are empty;
%part4(Intervention_ENDO,PROC_HEMOSTASIS_ACHIEVED,Endovascular);                                        
%part4(Intervention_OTHE,PROC_HEMOSTASIS_ACHIEVED,Other);                                               

***************dummy data for Intervention_SURG ****************;
/**/
/*proc sql;*/
/*	create table Intervention_SURG_new as*/
/*	select Characteristic as Characteristic, 'NA' as Pivotal, Roll_in as Roll_in, Suball as Suball*/
/*	from Surgical;*/
/*quit;*/
/**/
/*proc sql;*/
/*	create table Intervention_ENDO_new as*/
/*	select Characteristic as Characteristic, 'NA' as Pivotal, Roll_in as Roll_in, Suball as Suball*/
/*	from Endovascular;*/
/*quit;*/
/**/
/*proc sql;*/
/*	create table Intervention_OTHE_new as*/
/*	select Characteristic as Characteristic, 'NA' as Pivotal, Roll_in as Roll_in, Suball as Suball*/
/*	from Other;*/
/*quit;*/

data dump3;
	length Characteristic Pivotal Roll_in Suball $120.;
	Characteristic = 'Type of Intervention';
	Pivotal = '';
	Roll_in = '';
	Suball = '';
run;


****************************build final************************;

data table5_final;
	length Characteristic Pivotal Roll_in Suball $120.;
	set PROC_ANTI_GIV PROC_ACT PROC_TDD Time_hemostasis hemostasis_clm PROC_MAN_COMP_REQ PROC_MAN_COMP_TYPE  
	required_adj_interv dump3 Surgical Endovascular Other PROC_EST_BLOOD_LOSS Procedure_Time PROC_HEMOSTASIS_ACHIEVED;
run;

proc sql;
	select count(unique subjectid) into :rollin
	from table5
	where pop= 'Roll-in';
	select count(unique subjectid) into :pivotal
	from table5
	where pop= 'Pivotal';
	select count(unique subjectid) into :suball
	from table5
	where pop= 'Suball';
quit;

	**************************************Final report********************************************************;
ods escapechar='^';

%let Lheader1= Terumo Medical;
%let Lheader2= Cross-Seal IDE;
%let Cheader2= Not for regulatory use, data has not been subject to QC; *Analysis for CSR;
%let Rheader1= CONFIDENTIAL;
%let Rheader2= Page ^{pageof};

%let tabttl1= %str(Table 6. Closure Procedure Characteristics and Outcomes);
%let title1txt= %str(Table 6. Closure Procedure Characteristics and Outcomes);

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
ods rtf body = "Z:\Terumo Medical - Cross-Seal IDE - Data Sciences\Terumo Medical - Cross-Seal IDE - SAS Programming\Tables\CSR\&tabttl1..rtf" style=custom ;

title1 j=l "&Lheader1" j=r "&Rheader1";
title2 j=l "&Lheader2" j=c "&Cheader2" j=r "&Rheader2";
title3 " " ;
title4 j=l "&title1txt" ;

footnote1 j=l "&footer1"  j=r "Created on:"  "%cmpres(%sysfunc(datetime(),datetime18.))";
footnote2 /*j=l "Program:" "&protdir1"*/  j=r "Database snapshot:"  "&footer3";


proc report data = table5_final nowindows split='/' headline headskip wrap;

	column Characteristic Roll_in Pivotal Suball;

	define  Characteristic / "Characteristic" style(column) = [CELLWIDTH=210pt just =l VERTICALALIGN=C] style(header) = [just = l VERTICALALIGN=C];
	define  Roll_in / "Roll-in /(N=%cmpres(&rollin) Subjects)" style(column) = [CELLWIDTH=100pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  Pivotal / "Pivotal /(N=%cmpres(&pivotal) Subjects)" style(column) = [CELLWIDTH=100pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];
	define  Suball / "All Subjects /(N=%cmpres(&suball) Subjects)" style(column) = [CELLWIDTH=100pt just = c TEXTALIGN=C VERTICALALIGN=C] style(header) = [just = c VERTICALALIGN=C];

	compute Characteristic;
     if Characteristic='N' or Characteristic='Mean ^{00B1} SD' or Characteristic='Min, Max' or Characteristic='Median (IQR)' or 
		Characteristic='Light (non-occlusive)' or Characteristic='Firm (occlusive)' or
		Characteristic='Surgical' or Characteristic='Endovascular' or Characteristic='Other' 		
	then
             call define(_col_, "style",
                  "style=[leftmargin=0.3in]");
   endcomp;

run;



ods rtf text="Overall procedure time values for subjects 03-011 and 07-012 were omitted due to being outside of possible value range. ^n
Endpoint definitions:^n
Time-to-Device Deployment defined as time of guidewire removal during device insertion to time guidewire reinsertion during device removal.^n
Primary Effectiveness Endpoint - Time-to-Hemostasis (TTH) defined as the time from procedural sheath (or introducer sheath) removal to first observed cessation of CFA bleeding in the target limb for subjects not requiring adjunctive intervention.^n
Adjunctive Manual Compression defined as receiving adjunctive manual compression following use of the investigational device to achieve hemostasis of the access site (target limb only).^n
Adjunctive Surgical or Endovascular Intervention defined as requiring adjunctive surgical of endovascular intervention to achieve hemostasis of the access site (target limb only).^n
Overall procedure time defined as time of first skin nick/incision to achievement of hemostasis in the access site (target limb only)^n
Technical Success defined as achievement of hemostasis with the investigational device without the need for any access-site-related adjunctive surgical or endovascular intervention (target limb only).^n
Statistical references:^n
Numbers are % (counts/sample size) unless otherwise stated.^n
Analysis sets: Effectiveness - all enrolled subjects (signed informed consent form and meet all protocol eligibility criteria) who were treated without adjunctive therapy.^n
Performance Goal testing - Primary Effectiveness is one-sided upper 97.5% confidence limit (based on t-distribution) required.^n
Data sources:^n
All events were adjudicated by the independent Clinical Events Committee, all duplex ultrasounds were reviewed by the independent core laboratory, and all other data were site reported.^n
";  

ods rtf close;
ods listing;
