************************************************************************************************;
* Project           : 
*
* Program name      : macro library.sas
*
* Author            : Chao
*
* Date created      : 07August2020
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
%macro numeric_compare(indata=,var=,class=,label=);
proc means data=&indata n mean std max min median;
class &class;
var &var;
output out=&var.1 n=n_ mean=mean std=std median=median_ max=max min=min;
run;

data &var.1;
set &var.1;
where &class^='';
mean_std=strip(put(mean,7.1))||'^{unicode 00B1}'||strip(put(std,8.2));
min_max=strip(put(min,7.1))||', '||strip(put(max,7.1));
median=strip(put(median_,7.1));
n=strip(put(n_,5.));
run;

proc transpose data=&var.1 out=&var.2;
id &class;
var n mean_std min_max median;
run;

data header;
length _name_ $150;
_name_="&label";
run;

proc ttest data=&indata;
ods output  TTests=pvalue&var;
var &var;
class &class;
run;

data pvalue&var;
set pvalue&var;
where method='Satterthwaite';
pvalue=put(probt,pvalue8.4);
keep pvalue;
run;

data pvalue&var;
set pvalue&var;
output;
pvalue='';
output;
run;

proc sort;
by pvalue;
run;

data &var.2;
length _name_ $150;
merge &var.2 pvalue&var;
run;

data &var._;
length _name_ $150;
set header &var.2;
run;


%mend;


*%numeric_compare(indata=adsl,var=bmi,class=pop,label=%str(BMI/(kg/m^{super 2})));

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
%let class2=iFR;
%let class1=CMR;
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
%freq_compare_cmh(indata=adncvpci,label=vessel,var=ifr18,class=pop);


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
%let class2=iFR;
%let class1=CMR;
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




/* fisher exact test and freq count by group */
%macro freq_fisher(indata=, class=, label=, var=, value=,char=);
/*char to determine value type is char or num*/
	data &indata;
		set &indata;
%if &char %then %do;
		if &var="&value" then
			&var._=1;
		else
			&var._=0;

		if &var='' then
			&var._=.;
%end;
%else  %do;
		if &var=&value then
			&var._=1;
		else
			&var._=0;

		if &var=. then
			&var._=.;
%end;

	run;

	proc freq data=&indata;
		ods output FishersExact=pvalue&var;
		tables &class*&var._/fisher out=freq&var;
	run;

	data pvalue&var;
		length _name_ $150;
		set pvalue&var;
		where name1='XP2_FISH';
		pvalue=put(nvalue1, pvalue8.4);
		_name_="&label";
	run;

	proc sql;
		create table freq&var
as select a.*, sum(count) as total from freq&var as a where &var._^=. group by &class;
	quit;

	data freq&var;
		set freq&var;
		where &var._=1;
		percent_=put(count/total, 
			percent7.1)||' ('||strip(count)||'/'||strip(total)||')';
	run;

	proc transpose data=freq&var out=&var.1;
		id &class;
		var percent_;
	run;

	data &var.2;
		length _name_ $150;
		merge &var.1 pvalue&var;
	run;

%mend;

*%freq_fisher(indata=adsl, class=pop, label=obesity bmi 30 , var=obesity, value=1,char=0);



