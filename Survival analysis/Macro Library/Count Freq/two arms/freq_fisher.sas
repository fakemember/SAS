/* fisher exact test and freq count by group */
%macro freq_fisher(indata=, class=, label=, var=, value=,char=);
/*char to determine value type is char or num*/
	data &indata;
		set &indata;
%if &char %then %do;
		if &var in ("&value") then
			&var._=1;
		else
			&var._=0;

		if &var='' then
			&var._=.;
%end;
%else  %do;
		if &var in (&value) then
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
		set pvalue&var;
		where name1='XP2_FISH';
		pvalue=put(nvalue1, pvalue8.4);
	run;


	proc sql;
		create table freq&var
as select a.*, sum(count) as total from freq&var as a where &var._^=. group by &class;

	quit;
data freq&var;
set freq&var;
if total=count then do;
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
		id &class;
		var percent_;
	run;

	data &var.2;
		length _name_ $150;
		merge &var.1 pvalue&var;
				_name_="&label";

	run;

%mend;

*%freq_fisher(indata=adsl, class=pop, label=obesity bmi 30 , var=obesity, value=1,char=0);
