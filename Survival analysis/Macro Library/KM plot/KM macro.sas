************************************************************************************************;
* Project           : 
*
* Program name      : KM plot MACRO.sas
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

%macro km_plot(data=,strata=,censor=,TTE=,cnsrvalue=,maxtime=,interval=,xlabel=,ylabel=);

****************************************************************************************************;
/* data:         analytic dataset
strata:          strata
censor:          censor variable
TTE:             time to event variable
cnsrvalue:       censoring indicator
maxtime:         maximum of x-axis
interval:        interval
xlabel:          x-axis displayed label
ylabel:          y-axis displayed label*/
*****************************************************************************************************;





proc lifetest data=&data plots=survival(cl atrisk(atrisktick maxlen=13 outside(0.15))=0 to &maxtime by &interval)
TIMELIST=0 to &maxtime maxtime=&maxtime conftype=linear method=km reduceout outsurv=km_trtpip_ ;
time &TTE*&censor(&cnsrvalue);
%if &strata NE %then %do;
strata &strata;
%end;
run;


data km_trtpip;
set km_trtpip_;
if timelist not in (
    %do i=0 %to %eval(&maxtime-&interval) %by &interval;
&i,
%end;
&maxtime
) then do;
SDF_LCL=.;
SDF_UCL=.;
end;
run;


proc template;
define statgraph inset;
begingraph;
  layout overlay / xaxisopts=(linearopts=(viewmax=&maxtime 
tickvaluelist=(%do i=0 %to &maxtime %by &interval;
&i
%end;)) 
label="&xlabel" ) 
yaxisopts=(linearopts=(tickvaluelist=(0 .1 .2 .3 .4 .5 .6 .7 .8 .9 1)
viewmin=0 viewmax=1 tickvalueformat = percent. ) label="&ylabel");
  	stepplot x=TIMELIST y=survival/ 

%if &strata NE %then %do;
group=stratum
%end; name='Step';

scatterplot x=TIMELIST y=survival/ yerrorlower=SDF_LCL yerrorupper=SDF_UCL 

%if &strata NE %then %do;
group=stratum
%end;

markerattrs=(symbol=CircleFilled size=0.000001) name='Treatment';	

%if &strata NE %then %do;
	mergedlegend 'Step' 'Treatment';
%end;


  endlayout;
endgraph;
end;
run;

%mend;

****************************************************************************************************;
/*    TEST 1------ LIMFLOW-PROMISE 2                                                              */
*****************************************************************************************************;

%km_plot(data=analyticset,strata=,censor=death_mjamp,TTE=daystodeath_mjamp,cnsrvalue=0
,maxtime=360,interval=30,xlabel=%str(Time after Index Procedure (days)),
ylabel=%str(Amputation-free Survival));

****************************************************************************************************;
/*    TEST 2------ MERCATOR TANGO 2                                                              */
*****************************************************************************************************;
proc format;
value strafmt 1='Control'
			 2='Temsirolimus';
run;

%km_plot(data=final,strata=trt,censor=cnsr,TTE=day_to_event,cnsrvalue=1
,maxtime=360,interval=30,xlabel=%str(Time after Index Procedure (days)),
ylabel=%str(Freedom from TLF));



proc sgrender data=km_trtpip template=inset;
*format stratum strafmt.;
run;