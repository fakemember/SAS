



**********************************************windowing macro*******************************************************
************************************************macro variable *****************************************************
indata :                          dataset used 
start   :                       should be date format,use datepart to exact if not              
end   :                      should be date format,use datepart to exact if not 
visits :                     visits delimited by comma                 
points :                   timepoints delimited by comma   
*******************************************************************************************************************
*******************************************************************************************************************
*******************************************************************************************************************
*******************************************************************************************************************
;



%macro windowing (indata=,start=,end=,visits=,points=);
%let nvisit=%sysfunc(countw(&visits,','));
data &indata._1;
length timepoint $50;
set &indata;
delta_1=&end-&start;
%do i=1 %to  %eval(&nvisit);

if (delta_1 >=   %SYSFUNC(INPUTC(  %scan(   &points,%eval(2*&i-1)   ) , $5.)) ) and 
(delta_1 <= %SYSFUNC(INPUTC(  %scan(   &points,%eval(2*&i)   )  , $5.)))      then  do ;
timepoint="%scan(&visits,&i,',')";
timepointn=&i;
end;


%end;
run;

%mend windowing;







*****************************************************************************************************************
*******************************************test on branch corelab data*******************************************
*****************************************************************************************************************;
/*options symbolgen mlogic mprint;*/
/*proc import out=FOLLOWUPCT*/
/*datafile="Z:\Bolton Medical - Relay Branch - Data Sciences\Bolton Medical - Relay Branch - SAS Programming\Primary\rawdata\relaybranch_corelab_datatransfer_20200108.xlsx"*/
/*dbms=xlsx replace;*/
/*getnames=yes;*/
/*sheet='FOLLOWUPCT';*/
/*run;*/
/**/
/*data FOLLOWUPCT;*/
/*length subjectid $11;*/
/*set FOLLOWUPCT;*/
/*if scan(subjectid,4) ='' then subjectid=scan(subjectid,1)||'-'||scan(subjectid,2)||'/'||scan(subjectid,3);*/
/*else subjectid=scan(subjectid,1)||'-'||scan(subjectid,2)||'/'||scan(subjectid,3)||'-'||scan(subjectid,4);*/
/*run;*/
/*proc sql;*/
/*create table FOLLOWUPCT1 as */
/*select a.* ,datepart(b.TRT1) as pdate format=mmddyy10.*/
/*from FOLLOWUPCT  as a left join analytic_set as b  on*/
/*scan(a.subjectid,1,'/')=scan(b.subjectid,1,'/');*/
/*quit;*/
/**/
/*%windowing(indata=FOLLOWUPCT1,start=pdate,end=studydate,visits=%str(30 Day,6 Month,1 Year,2 Year,3 Year,4 Year,5 Year),*/
/*points=%str(0,90,91,270,271,545,546,910,911,1275,1276,1640,1641,2005));*/



*********************************************************************************************************************
**********************************test on branch safety data*****************************************************************
***********************************************************************************************************************;
/*options symbolgen mprint mlogic;*/
/*data tracker;*/
/*set tracker;*/
/*proceduredate1=datepart(proceduredate);*/
/*startdate1=datepart(startdate);*/
/*format proceduredate1 startdate1 mmddyy10.;*/
/*if _n_<50;*/
/*run;*/
/**/
/*%windowing(indata=tracker,start=proceduredate1,end=startdate1,*/
/*visits=%str(30 Day,6 Month,1 Year,2 Year,3 Year,4 Year,5 Year),*/
/*points=%str(0,90,91,270,271,545,546,910,911,1275,1276,1640,1641,2005) );*/
