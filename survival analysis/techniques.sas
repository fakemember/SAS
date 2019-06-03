*** creat macro  ;
%let name=alice;


proc sql noprint;
select name into :name1- 
from sashelp.class;
quit;
%put _user_;


*** debugging macro;
options symbolgen mprint mlogic;

**date and time function;
data _null_;
d1=mdy(7,8,2011);
d2=dhms('07aug2014'd,7,12,3);
d3=hms(7,12,3);
d4=today();
d5=datetime();
d6=time();
put d1= d2= d3= d4= d5= d6=;

data _null_;
d1=weekday('07aug2014'd);
d2=qtr('07aug2014'd);
d3=month('07aug2014'd);
d4=year('07aug2014'd);
d5=day('07aug2014'd);
d6=week('07aug2014'd);
put d1= d2= d3= d4= d5= d6=;

data _null_;



