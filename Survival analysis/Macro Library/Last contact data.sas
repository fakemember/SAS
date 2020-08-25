libname impdata '/home/chaocheng0/Impdata';

proc sql;
	create table temp as select * from dictionary.columns where libname='IMPDATA' 
		and name not in ('DateChanged', 'DateCreated') and (upcase(name) like '%DT%' 
		or upcase(name) like '%DATE%') and type='num' and memname not in ('MEDDRA', 
		'TRACKER', 'SITELIST', 'MEDICAL_HISTORY', 'CEC');
quit;

data temp;
	set temp;

	if format='B8601DZ35.' then
		name_=compress('datepart('||name||')');
	else
		name_=name;
run;

proc sort data=temp;
	by memname name_;
run;

proc transpose data=temp out=temp_;
	by memname;
	var name_;
run;

data temp_;
	set temp_;
	varlist1=catx(' ', of col:);
	varlist2=catx(', ', of col:);
	call symputx('dataset'||compress(put(_n_, 4.)), memname);
	call symputx('varlist'||compress(put(_n_, 4.)), varlist1);
	call symputx('_varlist'||compress(put(_n_, 4.)), varlist2);
run;

%put _user_;

proc sql;
	select count(unique(memname)) into:ndataset from temp_;
quit;

%macro find_last_contact(lib=impdata, id=subjectid);
	%do i=1 %to &ndataset;

		data &&dataset&i.._;
			set &lib..&&dataset&i;
			&&dataset&i.._=max(&&_varlist&i);
			format &&dataset&i.._ mmddyy10.;
		run;

		proc sql;
			create table last&&dataset&i as select &id, max(&&dataset&i.._) as 
				last&&dataset&i  format=mmddyy10.
from &&dataset&i.._ group by &id having max(&&dataset&i.._) ^=. order by 1;
		quit;

	%end;

	data lastcontactdate;
		merge last:;
		by &id;
		lastcontactdate=max(of last:);
		format lastcontactdate mmddyy10.;
	run;

%mend;

%find_last_contact(lib=impdata, id=subjectid);

proc freq;
	tables subjectid;
run;
