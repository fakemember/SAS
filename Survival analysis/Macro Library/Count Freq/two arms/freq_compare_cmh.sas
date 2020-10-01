%macro freq_compare_cmh(indata=,label=,var=,class=);

proc freq data=&indata;
ods output cmh =pvalue&var;
where &var ne '';
tables &class*&var/cmh score=modridit out=&var._;
run;

data pvalue&var;
length _name_ $150;
set pvalue&var;
where AltHypothesis='Row Mean Scores Differ';
pvalue=put(Prob,pvalue8.4);
_name_="&label";
keep _name_ pvalue;
run;

proc sql;
create table &var._ as
select a.* ,sum(count) as total,
put(count/calculated total,percent7.1)||' ('||strip(put(count,7.))||'/'||strip(put(calculated total,7.))||')'
as percent_
from &var._ as a
group by &class
order by &var;
run;

proc transpose data=&var._ out=&var._t;
id &class;
var percent_;
by &var;
run;


%local class1 class2 ;
%let class2=iFR;*change here wrt study;
%let class1=CMR;*change here wrt study;
data _null_;
set &var._;
if &class="&class1" then call symput('nclass1',total);
if &class="&class2" then call symput('nclass2',total);
run;

data &var._t ;
length _name_ $150;
set &var._t;
_name_=&var;
if &class1='' then &class1='0.0%'||' (0/'|| strip(&nclass1)||')';
if &class2='' then &class2='0.0%'||' (0/'|| strip(&nclass2)||')';

run;

data &var._t;
length _name_ $150;
set pvalue&var &var._t;
run;
%mend;
*%freq_compare_cmh(indata=adncvpci,label=vessel,var=ifr18,class=pop);

