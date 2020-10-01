****************************************************************************************************;
/*                                       numeric descriptive analysis                           */
*****************************************************************************************************;
%macro numeric_freq(indata=,var=,label=);
proc means data=&indata n mean std max min ;
var &var;
output out=&var.1 n=n_ mean=mean std=std  max=max min=min;
run;

data &var.1;
set &var.1;
mean_std=strip(put(mean,7.1))||'^{unicode 00B1}'||strip(put(std,8.2));
if std=. then mean_std=strip(put(mean,7.1))||'^{unicode 00B1}'||"NA";

min_max=strip(put(min,7.1))||', '||strip(put(max,7.1));
n=strip(put(n_,5.));
run;

proc transpose data=&var.1 out=&var.2;
var n mean_std min_max;
run;

data header;
length _name_ $150;
_name_="&label";
run;


data &var._;
length _name_ $150;
set header &var.2;
run;


%mend;

*%numeric_freq(indata=analyticset,var=bmi,label=%str(BMI/(kg/m^{super 2})));
