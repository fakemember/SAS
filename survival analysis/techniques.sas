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














*** creat macro  ;
%let name=alice;


proc sql noprint;
select name into :name1- 
from sashelp.class;
quit;
%put _user_;

%let ins= nike sports;
data _null_;
dd='forever21';
call symput('ins1',dd);

%put &ins1;


data _null_;
call symput('titl', 'Some students are taller than 63 inches'); 
%put macro variable titl: &titl


data ntr;
length name $10;
input name $ nb;
cards;
dad 12
mom 12
sister3123 31
;




data _null_;
set ntr;
call symput(name,nb);


%put dad: &dad;
%put mom: &mom;
%put sister3123: &sister3123;



%macro st;
data class;
set
%do i= 1 %to 3;
dsn&i
%end; 
;
run;
%mend;

%st
data dsn1;
input wt;
cards;
1
2
;
data dsn2;
input wt;
cards;
1
2
;
data dsn3;
input wt;
cards;
1
2
;




%put _automatic_;

data class ;
set sashelp.class;


%put &syslast;
%put &sysday;
%put &sysdate;
%put &sysdate9;
%put &systime;
%put &sysscp;
%put &sysver;



%put _user_;


%put "today is &sysdate9 &sysday"


%let x=9;
%let y=10;
%let z=%eval(&x*&y);



data _null_;
set class;
call symput(name,weight);


proc sql;
select name into :name1- 
from class;
quit;
%put _user_;

options mprint;
options symbolgen;
options mlogic;

%macro prt;
%do i=1 %to 19;
%put &&name&i;
%end;
%mend;
%prt;


%let indvars=write math female socst;
%let newind=%upcase(&indvars);
%put &newind;
%let word2=%scan(&indvars,2);
%put &word2;
%let subword=%substr(&indvars,5,3);
%put &subword;



%let k=1;
%let tot=&k+1;
%put &tot;


%let index=%index(&indvars,ma);
%put &index;
*** debugging macro;
options symbolgen mprint mlogic;

**date and time function;
data _null_;
d1=mdy(7,8,2011);
d2=dhms('07aug2014'd,7,12,3);
d3=hms(7,12,3);
d4=today();
d5=datetime();
d6=time();
put d1= d2= d3= d4= d5= d6=;

data _null_;
d1=weekday('07aug2014'd);
d2=qtr('07aug2014'd);
d3=month('07aug2014'd);
d4=year('07aug2014'd);
d5=day('07aug2014'd);
d6=week('07aug2014'd);
put d1= d2= d3= d4= d5= d6=;

data _null_;
d1=hour('14:45:32'T);
d2=minute('14:45:32'T);
d3=second('14:45:32'T);
d4=hour('17OCT1991:14:45:32'DT);
d5=minute('17OCT1991:14:45:32'DT);
d6=second('17OCT1991:14:45:32'DT);
d7=datepart('17OCT1991:14:45:32'DT);
d8=timepart('17OCT1991:14:45:32'DT);
put d1= d2= d3= d4= d5= d6= d7= d8=;


data b;
   WeddingDay='14feb2000'd;
   Today=today();
   YearsMarried=INTCK('YEAR',WeddingDay,today(),'C');
   format WeddingDay Today date9.;
run;
proc print data=b;
run;

data _null_;
   days=intck('dtday', '01aug2011:00:10:48'dt, '01feb2012:00:10:48'dt);
   put days=;
run;

%put &systime;


***transpose ;
data class;
input num dx1 dx2 dx3;
format num z3.;
cards;
1 12 32 42
2 43 31 .
3 12 43 12
4 21 . 32
;

data long;
set class;
array dx[3];
do visit=1 to 3;
diag=dx[visit];
output;
end;
keep num diag visit;

proc transpose data=class out=c1(rename=(col1=diagnosis));
by num;
var dx1 -dx3;


data c2;
set c1;
visit=input(substr(_name_,3,1),1.);
drop _name_;
if diagnosis ne . ;


proc print data=c2;
var num visit diagnosis;
run;



proc transpose  data=c2 out=c3 prefix=dx ;
by num;
var diagnosis;
id visit;

*** full join;
data staff;
input id lname  $ fname $ city & $ state $ hphone: $12.;
cards;
  1919  ADAMS            GERALD           STAMFORD         CT     203/781-1255
  1653  ALIBRANDI        MARIA            BRIDGEPORT       CT     203/675-7715
  1400  ALHERTANI        ABDULLAH         NEW YORK         NY     212/586-0808
  1350  ALVAREZ          MERCEDES         NEW YORK         NY     718/383-1549
  1401  ALVAREZ          CARLOS           PATERSON         NJ     201/732-8787
  1499  BAREFOOT         JOSEPH           PRINCETON        NJ     201/812-5665
  1101  BAUCOM           WALTER           NEW YORK         NY     212/586-8060
  1333  BANADYGA         JUSTIN           STAMFORD         CT     203/781-1777
  1402  BLALOCK          RALPH            NEW YORK         NY     718/384-2849
  1479  BALLETTI         MARIE            NEW YORK         NY     718/384-8816
  2333  BRUCE            LEE              PISCATAWAY       NJ     123/435-0941  
  ;
  
  data payroll;
  input id sex $ jobcode $ salary birth : date. hired : date. ;
  format birth hired date. ;
  cards;
1919    M       TA2         34376  12SEP60  04JUN87
1653    F       ME2         35108  15OCT64  09AUG90
1400    M       ME1         29769  05NOV67  16OCT90
1350    F       FA3         32886  31AUG65  29JUL90
1401    M       TA3         38822  13DEC50  17NOV85
1499    M       ME3         43025  26APR54  07JUN80
1101    M       SCP         18723  06JUN62  01OCT90
1333    M       PT2         88606  30MAR61  10FEB81
1402    M       TA2         32615  17JAN63  02DEC90
1479    F       TA3         38785  22DEC68  05OCT89
6666    F       TA1         62341  23JAN76  01OCT99
    ;
    
    
    
proc sql;
select Lname, Fname, City, State,
           b.id, Salary, Jobcode
from staff as a,payroll as b
where a.id=b.id and (a.id in (1919,1400, 1350,1333));
 
 
 
 proc freq data =payroll;
 table jobcode/ plots=freqplot(type=dot);
 proc sql;
 select jobcode, count(*) from payroll group by jobcode;
 proc sort data=payroll out=p1;
 by jobcode;
 run;
 data p1;
 set p1;
 by jobcode;
 if first.jobcode then num=0;
 num+1;
 if last.jobcode then output;
 run;
 
 
 proc sql ;
 select coalesce(a.id,b.id) 'ID number' ,Lname, Fname, City, State,
            Salary, Jobcode
            from staff as a full join payroll as b on a.id=b.id
            ;



**merge dataset;
data class;
   input Name $ 1-25 Year $ 26-34 Major $ 36-50;
   datalines;
Abbott, Jennifer         first
Carter, Tom              third     Theater
Kirby, Elissa            fourth    Mathematics
Tucker, Rachel           first
Uhl, Roland              second
Wacenske, Maurice        third     Theater
;
proc print data=class;
   title 'Acting Class Roster';
run;
data time_slot;
   input Date date9.  @12 Time $ @19 Room $;
   format date date9.;
   datalines;
14sep2000  10:00  103
14sep2000  10:30  103
14sep2000  11:00  207
15sep2000  10:00  105
15sep2000  10:30  105
17sep2000  11:00  207
;
proc print data=time_slot;
   title 'Dates, Times, and Locations of Conferences';
run;
data schedule;
   merge class time_slot;
run;

proc print data=schedule;
   title 'Student Conference Assignments';
run;
data class2;
   input Name $ 1-25 Year $ 26-34 Major $ 36-50;
   datalines;
Hitchcock-Tyler, Erin    second
Keil, Deborah            third     Theater
Nacewicz, Chester        third     Theater
Norgaard, Rolf           second
Prism, Lindsay           fourth    Anthropology
Singh, Rajiv             second
Wittich, Stefan          third     Physics
;
proc print data=class2;
   title 'Acting Class Roster';
   title2 '(second section)';
run;
data exercise;
   merge class (drop=Year Major)
         class2 (drop=Year Major rename=(Name=Name2))
         time_slot;
run;
/*data exercise;
   merge class (drop=Year Major)
         class2 (drop=Year Major)
         time_slot;
run;*/

proc print data=exercise;
   title 'Acting Class Exercise Schedule';
run;


***match merging;
data company;
   input Name $ 1-25 Age 27-28 Gender $ 30;
   datalines;
Vincent, Martina          34 F
Phillipon, Marie-Odile    28 F
Gunter, Thomas            27 M
Harbinger, Nicholas       36 M
Benito, Gisela            32 F
Rudelich, Herbert         39 M
Sirignano, Emily          12 F
Morrison, Michael         32 M
;

proc sort data=company;
   by Name;
run;

data finance;
   input IdNumber $ 1-11 Name $ 13-40 Salary;
   datalines;
074-53-9892 Vincent, Martina             35000
776-84-5391 Phillipon, Marie-Odile       29750
929-75-0218 Gunter, Thomas               27500
446-93-2122 Harbinger, Nicholas          33900
228-88-9649 Benito, Gisela               28000
029-46-9261 Rudelich, Herbert            35000
442-21-8075 Sirignano, Emily             5000
;
proc sort data=finance;
   by Name;
run;
proc print data=company;
   title 'Little Theater Company Roster';
run;

proc print data=finance;
   title 'Little Theater Employee Information';
run;
data employee_info;
   merge company finance;
   by name;
run;

proc print data=employee_info;
   title 'Little Theater Employee Information';
   title2 '(including personal and financial information)';
run;

**Match-Merging Data Sets with Multiple Observations in a BY Group;
data repertory;
   input Play $ 1-23 Role $ 25-48 IdNumber $ 50-60;
   datalines;
No Exit                 Estelle                  074-53-9892
No Exit                 Inez                     776-84-5391
No Exit                 Valet                    929-75-0218
No Exit                 Garcin                   446-93-2122
Happy Days              Winnie                   074-53-9892
Happy Days              Willie                   446-93-2122
The Glass Menagerie     Amanda Wingfield         228-88-9649
The Glass Menagerie     Laura Wingfield          776-84-5391
The Glass Menagerie     Tom Wingfield            929-75-0218
The Glass Menagerie     Jim O'Connor             029-46-9261
The Dear Departed       Mrs. Slater              228-88-9649
The Dear Departed       Mrs. Jordan              074-53-9892
The Dear Departed       Henry Slater             029-46-9261
The Dear Departed       Ben Jordan               446-93-2122
The Dear Departed       Victoria Slater          442-21-8075
The Dear Departed       Abel Merryweather        929-75-0218
;
proc print data=repertory;
   title 'Little Theater Season Casting Assignments';
run;
proc sort data=finance;
   by IdNumber;
run;

proc sort data=repertory;
   by IdNumber;
run;
proc print data=finance;
   title 'Little Theater Employee Information';
   title2 '(sorted by employee ID number)';
run;

proc print data=repertory;
   title 'Little Theater Season Casting Assignments';
   title2 '(sorted by employee ID number)';
run;

options linesize=120;

data repertory_name;
   merge finance repertory;
   by IdNumber;
run;

proc print data=repertory_name;
   title 'Little Theater Season Casting Assignments';
   title2 'with employee financial information';
run;
