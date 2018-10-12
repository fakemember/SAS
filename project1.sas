data wine;
  input Y  Z; 
  if _N_ = 1 then tn = y; 
  if _N_ = 1 then tm = z; 
  nn = int(_N_/2)*2;
  if _N_ > 1  and nn ne _N_ then do; 
 		DMIM=1; 
  		Resp = y;
		qit = int( _N_/2) ;
		loc = "SB";
		R = 1;
		output;
 		DMIM=2; 
  		Resp = z;
		output;
   		R = 2;
 		DMIM=1; 
  		Resp = tn-y;
		output;
 		DMIM=2; 
  		Resp = tm-z;
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
do gr= 1 to 2;
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
	

