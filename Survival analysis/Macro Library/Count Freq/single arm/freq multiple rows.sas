****************************************************************************************************;
/*                                  freq multiple rows                                */
*****************************************************************************************************;
%macro freq_mulrows(indata=,label=,var=,char=);

proc freq data=&indata;
%if &char %then %do;
where &var ne '';
%end;
%else %do;
where &var ne .;
%end;
tables &var/out=&var._;
run;


proc sql;
create table &var._  as
select a.* , sum(count) as total,
put(count/calculated total,percent7.1)||' ('||strip(put(count,7.))||'/'||strip(put(calculated total,7.))||')'
as percent_
from &var._ as a
order by &var;
run;

proc transpose data=&var._ out=&var._t;
var percent_;
by &var;
run;


data &var._t ;
length _name_ $150;
set &var._t;
_name_=STRIP(&var);
run;

data &var.head;
length _name_ $150;
_name_="&label";
run;

data &var._t;
length _name_ $150;
set  &var.head &var._t ;
run;
%mend;
*%freq_mulrows(indata=analyticset,label=Wound SVS WIfI Class,var=BLSVSWCAT,char=0);

