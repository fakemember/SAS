************************************************************************************************;
* Project           : 
*
* Program name      : KM table MACRO.sas
*
* Author            : Chao
*
* Date created      : 30September2020
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
%macro km_table(data=,censor=,TTE=,cnsrvalue=,maxtime=,interval=);

****************************************************************************************************;
/* data:         analytic dataset
censor:          censor variable
TTE:             time to event variable
cnsrvalue:       censoring indicator
maxtime:         maximum of x-axis
interval:        interval*/
*****************************************************************************************************;

proc sql;
	select  count(*) into: subcount from &data
quit;

proc lifetest data=&data maxtime=&maxtime timelist=0.0001 &interval to &maxtime by &interval
		plots=survival(atrisk(outside maxlen=13 atrisktickonly)=0.0001 &interval to &maxtime by &interval test 
		cb=hw) reduceout outsurv=bmtsurv;
time &TTE*&censor(&cnsrvalue);
	ods output ProductLimitEstimates=plestbmt;
run;

data plestbmt;
merge plestbmt  bmtsurv;
subcount=&subcount;
run;


data plestbmt1;
	set plestbmt;
	failed1=lag(failed);
	event=failed-failed1;
	cnsrplusevent=subcount-left;
	cnsrplusevent1=lag(cnsrplusevent);
	cnsr=cnsrplusevent-cnsrplusevent1-event;
left1=lag(left);
	if _n_=1 then
		do;
			event=failed;
			cnsr=subcount-left-failed;
			left1=subcount;
		end;
	lower=put(sdf_lcl,percent9.1);
upper=put(sdf_ucl,percent9.1);
if stderr>0 then ci=catx('-',lower,upper);
 survival1=put(survival, percent9.1);
sd=put(StdErr, percent9.1);
run;
proc transpose out=transples;
var left1 cnsr event  survival1 sd;
run;


data transples;
length interval $32.;
set transples;		
		if _NAME_='left1' then Interval='# Entered'; 
 		if _NAME_='cnsr' then Interval = '# Censored';
		if _NAME_= 'event'  then Interval = '# Events';
		if _NAME_=  'survival1'  then Interval = 'Event-free [%]';
  		if _NAME_=  'sd'   then Interval =  'Greenwood SE [%]' ;
run;



%mend;

****************************************************************************************************;
/*    TEST 1------ LIMFLOW-PROMISE 2                                                              */
*****************************************************************************************************;

%km_table(data=analyticset,censor=death_mjamp,TTE=daystodeath_mjamp,cnsrvalue=0
,maxtime=360,interval=30);

****************************************************************************************************;
/*    TEST 2------ MERCATOR TANGO 2                                                              */
*****************************************************************************************************;
proc format;
value strafmt 1='Control'
			 2='Temsirolimus';
run;

%km_table(data=final(where=(trt=1)),censor=cnsr,TTE=day_to_event,cnsrvalue=1
,maxtime=360,interval=30);
