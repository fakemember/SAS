data wine;
	input Y Z;

	if _N_=1 then
		tn=y;

	if _N_=1 then
		tm=z;
	nn=int(_N_/2)*2;

	if _N_ > 1 and nn ne _N_ then
		do;
			DMIM=1;
			Resp=y;
			qit=int(_N_/2);
			loc="SB";
			R=1;
			output;
			DMIM=2;
			Resp=z;
			output;
			R=2;
			DMIM=1;
			Resp=tn-y;
			output;
			DMIM=2;
			Resp=tm-z;
			output;
		end;
	retain tn tm;
	keep qit loc DMIM R RESP;
	datalines;
27 27
0 0	
6 7
22 26
2 4
7 15
4 3
15 11
4 13
15 48
3 2
11 7
11 5
41 19
2 0
7 0
1 0
4 0
;

proc print;
run;

Data a;
	input y @;

	do gr=1 to 2;
		input fr @;
		output;
	end;
	cards;
5 3 1
4 2 3
3 3 0
2 1 1
1 1 0
;

proc print;
run;

Proc npar1way wilcoxon;
	Class gr;
	Var y;
	Freq fr;
run;

/* sourse of knowledge SB and HK */
DATA TABLE11;
	INPUT CITY $ NUM FREQ;
	CARDS;
SB 1 14
SB 2 11
SB 3 32
SB 4 36
SB 5 38
SB 6 23
HK 1 22
HK 2 9
HK 3 35
HK 4 33
HK 5 30
HK 6 33
;

PROC PRINT;
RUN;

PROC NPAR1WAY DATA=table11 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table11;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*Certification */
DATA TABLE13;
	INPUT CITY $ NUM FREQ;
	CARDS;
SB 1 8
SB 2 45
SB 3 1
HK 1 21
HK 2 30
HK 3 0
;

PROC PRINT;
RUN;

PROC NPAR1WAY DATA=table13 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table13;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*Knowledge*/
DATA TABLE37;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 10 0
SB 9 3
SB 8 0
SB 7 3
SB 6 5
SB 5 7
SB 4 8
SB 3 12
SB 2 10
SB 1 5
SB 0 1
HK 10 3
HK 9 3
HK 8 0
HK 7 2
HK 6 10
HK 5 18
HK 4 9
HK 3 4
HK 2 2
HK 1 0
HK 0 0
;

PROC NPAR1WAY DATA=table37;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC MEANS DATA=table37;
	CLASS CITY;
	FREQ FREQ;
	VAR NUM;
RUN;

PROC FREQ data=table37;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*interest*/
DATA TABLE17;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 0
SB 2 27
SB 3 27
HK 1 1
HK 2 17
HK 3 33
;

PROC NPAR1WAY DATA=table17;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table17;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*Area like to learn*/
DATA TABLE18;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 38
SB 2 32
SB 3 35
SB 4 38
HK 1 35
HK 2 22
HK 3 21
HK 4 36
;

PROC NPAR1WAY DATA=table18;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table18;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*Format to learn*/
DATA TABLE19;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 14
SB 2 17
SB 3 45
SB 4 34
SB 5 2
HK 1 30
HK 2 8
HK 3 23
HK 4 34
HK 5 1
;

PROC NPAR1WAY DATA=table19;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table19;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*Willing to pay*/
DATA TABLE20;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 19
SB 2 20
SB 3 15
HK 1 32
HK 2 18
HK 3 1
;

PROC NPAR1WAY DATA=table20;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table20;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*Cost willing to pay*/
DATA TABLE21;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 8
SB 2 4
SB 3 2
SB 4 2
SB 5 0
SB 6 0
SB 7 0
SB 8 3
HK 1 0
HK 2 2
HK 3 8
HK 4 3
HK 5 6
HK 6 3
HK 7 8
HK 8 2
;

PROC NPAR1WAY DATA=table21;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table21;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*level of interest*/
DATA TABLE22;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 8
SB 2 28
SB 3 18
HK 1 6
HK 2 22
HK 3 23
;

PROC NPAR1WAY DATA=table22;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table22;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*willing to subsidize*/
DATA TABLE26;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 16
SB 2 4
SB 3 7
HK 1 16
HK 2 2
HK 3 8
;

PROC NPAR1WAY DATA=table26 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table26;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*NUMBER OF YEARS IN INDUSTRY*/
DATA TABLE4;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 0.5 1
SB 1 1    
SB 1.5 3
SB 2 1
SB 3 8
SB 4 4
SB 5 5
SB 6 5
SB 7 3
SB 8 3
SB 9 2
SB 10 2
SB 11 0
SB 12 4
SB 13 1
SB 14 1
SB 15 5
SB 17 0
SB 20 1
SB 22 0
SB 24 0
SB 28 1
SB 30 1
HK 1 0
HK 2 1
HK 3 1
HK 4 2
HK 5 6
HK 6 4
HK 7 1
HK 8 2
HK 9 0
HK 10 8
HK 11 2
HK 12 3
HK 13 3
HK 14 1
HK 15 6
HK 17 1
HK 20 7
HK 22 1
HK 24 2
;

PROC NPAR1WAY DATA=table4 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table4;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

DATA TABLE5;
	/* WOKR IN CURRENT POSITION*/
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 0.3 1
SB 0.5 2
SB 1 6
SB 2 10
SB 3 13
SB 4 1
SB 5 8
SB 6 4
SB 7 1
SB 8 1
SB 10 2
SB 12 1
SB 14 1
SB 15 0
SB 18 0
SB 20 1
HK 1 5
HK 2 4
HK 3 5
HK 4 4
HK 5 12
HK 6 6
HK 7 3
HK 8 5
HK 9 0
HK 10 2
HK 12 2
HK 14 1
HK 15 1
HK 18 1
;

PROC NPAR1WAY DATA=table5 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table5;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

DATA TABLE8;
	/*SOURCE OF KNOWLEDGE*/
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 14 
SB 2 11
SB 3 32
SB 4 36
SB 5 38
SB 6 23
HK 1 22
HK 2 9
HK 3 35
HK 4 33
HK 5 30
HK 6 33
;

PROC NPAR1WAY DATA=table8 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table8;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*
Formal wine courses in Hong Kong  (1)
Formal wine courses overseas  (2)
Colleagues or supervisors  (3)
Books and publications  (4)
Winery brand representatives  (5)
Wine tasting events  (6)
*/
/*ACHIEVEMENT AT WORK IF KNOW MORE ABOUT WINE*/
DATA TABLE16;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 14
SB 2 0
SB 3 27
SB 4 17
SB 5 24
SB 6 7
SB 7 1
HK 1 15 
HK 2 4
HK 3 36
HK 4 17
HK 5 6
HK 6 3
HK 7 2
;

	/*
	More knowledgeable  (1)
	Able to explain/ train other colleagues  (2)
	More confident and knowledgeable in selling wine to customers  (3)
	Improve communications with customers  (4)
	Help to make more profit for the company  (5)
	Secure the job/be promoted/have salary increase  (6)
	None  (98)
	*/
PROC NPAR1WAY DATA=table16 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table16;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

/*Preferred format to learn more about wine*/
DATA TABLE19;
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 14
SB 2 17
SB 3 45
SB 4 34
SB 5 2
HK 1 30
HK 2 8
HK 3 23
HK 4 34
HK 5 1
;

	/*
	Attend courses at school  (1)
	Attend online courses  (2)
	Learn via leisure reading  (3)
	Attend wine tasting events  (4)
	Others  (97)*/
PROC NPAR1WAY DATA=table19 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table19;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

DATA TABLE23;
	/*currently taking course on wine*/
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 16
SB 2 38
HK 1 3
HK 2 48
;

	/*YES 1 NO 2*/
PROC NPAR1WAY DATA=table23 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table23;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;

DATA TABLE25;
	/*Staff's competence for the jobs*/
	INPUT CITY$ NUM FREQ;
	CARDS;
SB 1 1
SB 2 0
SB 3 2
SB 4 0
SB 5 11
SB 6 6
SB 7 3
SB 8 2
SB 9 2
SB 10 0
HK 1 3
HK 2 2
HK 3 2
HK 4 3
HK 5 3
HK 6 6
HK 7 3
HK 8 2
HK 9 0
HK 10 0
;

PROC NPAR1WAY DATA=table25 WILCOXON;
	CLASS CITY;
	VAR NUM;
	FREQ FREQ;
	EXACT WILCOXON;
RUN;

PROC FREQ data=table25;
	TABLE CITY*NUM/ chisq;
	WEIGHT FREQ;
	EXACT FISHER;
RUN;


proc print data= table12;
run;
/* 10 VERY COMPETENT; 1 NOT COMPTENT */
