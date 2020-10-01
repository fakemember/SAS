****************************************************************************************************;
/*                                       freq one row                           */
*****************************************************************************************************;
%macro freq_one_row(indata=, class=, label=, var=, value=,char=);
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
		tables &var._/ out=freq&var;
	run;


	proc sql;
		create table freq&var
as select a.*, sum(count) as total from freq&var as a where &var._^=. ;
	quit;

data freq&var;
set freq&var;
if total=count and &var._=0 then do;
count=0;
&var._=1;
end;
run;

	data freq&var;
		set freq&var;
		where &var._=1;
		percent_=put(count/total, 
			percent7.1)||' ('||strip(count)||'/'||strip(total)||')';
	run;

	proc transpose data=freq&var out=&var.1;
		var percent_;
	run;

	data &var.2;
		length _name_ $150;
		set &var.1 ;
		_name_="&label";
	run;

%mend;

*%freq_one_row(indata=analyticset,label=History of Obesity , var=obese, value=Yes,char=1);
