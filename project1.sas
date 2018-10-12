

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
	
/*certification*/
data table11;
input city$ num fq;
sb 1 3
sb 3 7
sb 2 9
hk 1 6
hk 2 4
hk 3 7
;
proc npar1way data=table11 wilcoxon;
class city;
var num;
freq fq;
run;



proc freq data=table11;
table city*num/chisq or;
weight fq;
exact fisher;
run;

