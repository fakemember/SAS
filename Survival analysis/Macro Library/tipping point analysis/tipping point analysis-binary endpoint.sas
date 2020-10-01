%include 'Z:\Terumo Medical - Cross-Seal IDE - Data Sciences\Terumo Medical - Cross-Seal IDE - SAS Programming\Code\Primary\Create Analytic Datasets.sas';

data Pivotal;
	set analytic_data;
	Time_hemostasis=(sum((PROC_TTH_MM *60) , PROC_TTH_SS))/60;
	if proc_hemostasis_achieved='No' then
		Time_hemostasis=.;
	if pop='Pivotal';
run;

proc sql;
	select count(*) into :npivotal from pivotal;
quit;

proc sql;
	select count(unique(subjectid)) into :pivotal from lastcontact where 
		pop='Pivotal' and (Major_Complications_in_30d='Yes' or daystolastcon ge 23);
quit;

**************************************endpoint: freedom from.....**********************************;
**************************tipping points analysis****************************;

%macro tpa();
	%do i=0 %to %eval(&npivotal-&pivotal);*npivotal-pivotal=# Subjects with missing endpoint;

		data freedom_&i;
			length Characteristic $150;
			set all;
			group1t=put((&rollin-group1)/&rollin, 
				percent9.1)||' ('||strip(&rollin-group1)||'/'||strip(&rollin)||')';
			group2t=put((&npivotal-group2-&i)/(&npivotal), 
				percent9.1)||' ('||strip(&npivotal-group2-&i)||'/'||strip(&npivotal)||')';
			group3t=put((&suball-group3)/&suball, 
				percent9.1)||' ('||strip(&suball-group3)||'/'||strip(&suball)||')';
			;
			keep /*group1t*/
			group2t  /*group3t*/
			Characteristic;
			rename group2t=col1;
			Characteristic='Primary Safety Composite Endpoint - Freedom from Major Complications of the Target Limb Access Site within 30 Days';
		run;

		data ci_comp;
			set all;
			count=group2+&i;
			freedom=0;
			output;
			count=&npivotal-group2-&i;
			freedom=1;
			output;
			keep freedom count;
		run;

		ods output Binomial=binom_freedom;

		proc freq data=ci_comp order=freq;
			tables freedom/alpha=0.1 bin(p=0.852);
			weight count;
			exact binomial;
		run;

		data binom_freedom_&i;
			length Characteristic $150;
			set binom_freedom;

			if name1='XL_BIN' then
				do;
					col1=put(nValue1, percent9.1);
					Characteristic='Exact binomial one-sided lower 95% CI for Performance Goal test >85.2% ';
					output;
				end;
		run;

		%if &i=0 or &i=1 %then
			%do;

				data header2_&i;
					length Characteristic $150;
					Characteristic='Safety Parameter - Tipping Point Analysis';
					output;
					Characteristic="^{Style[textdecoration=underline]%cmpres(&i) Subject Considered Failure}";
					output;
				run;

			%end;
		%else
			%do;

				data header2_&i;
					length Characteristic $150;
					Characteristic="^{Style[textdecoration=underline]%cmpres(&i) Subjects Considered Failure}";
					output;
				run;

			%end;
	%end;
%mend;

%tpa();

