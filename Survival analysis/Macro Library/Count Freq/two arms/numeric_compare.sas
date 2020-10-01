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
var n mean_std median min_max ;
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







