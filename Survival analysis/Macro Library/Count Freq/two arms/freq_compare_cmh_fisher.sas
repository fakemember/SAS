
%macro freq_compare_cmh_fisher(indata=adncvpci,label=vessel,var=ifr18,class=pop);



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

data test1;
class="&class1";
set &var._t;
positive=1;
count=input(scan(scan(&class1,1,'/'),2,'('),best12.);
output;
positive=0;

count=input(scan(scan(&class1,2,'/'),1,')'),best12.)-input(scan(scan(&class1,1,'/'),2,'('),best12.);
output;
run;

data test2;
class="&class2";
set &var._t;
positive=1;
count=input(scan(scan(&class2,1,'/'),2,'('),best12.);
output;
positive=0;
count=input(scan(scan(&class2,2,'/'),1,')'),best12.)-input(scan(scan(&class2,1,'/'),2,'('),best12.);
output;
run;

data fisher_&var;
set test1 test2;
run;
proc sort;
by &var positive;
run;

proc freq data=fisher_&var;
ods output  FishersExact=fisher&var;
tables class*positive/fisher;
weight count;
by &var;
run;

data fisher&var;
set fisher&var;
where name1='XP2_FISH';
pvalue=put(nValue1,pvalue8.4);
run;

data &var._t ;
merge &var._t fisher&var;
by &var;
_name_=&var;
run;

data &var._t;
length _name_ $150;
set pvalue&var &var._t;
run;



%mend;
*%freq_compare_cmh_fisher(indata=adncvpci,label=vessel,var=ifr19,class=pop);
