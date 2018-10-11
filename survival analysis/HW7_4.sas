/* data source: Section 1.11 */
/* http://www.mcw.edu/Biostatistics/Statistical-Resources.htm */
/*
Tumor DNA profile (1=Aneuploid Tumor, 2=Diploid Tumor) 
Time to death or on-study time, weeks 
Death indicator (0=alive, 1=dead) 
Reference Sickle-Santanello et al. Cytometry 9 (1988): 594-599.
*/
data hw7_4;
input type o_time censor;
cards;
1 1 1
1 3 1
1 3 1
1 4 1
1 10 1
1 13 1
1 13 1
1 16 1
1 16 1
1 24 1
1 26 1
1 27 1
1 28 1
1 30 1
1 30 1
1 32 1
1 41 1
1 51 1
1 65 1
1 67 1
1 70 1
1 72 1
1 73 1
1 77 1
1 91 1
1 93 1
1 96 1
1 100 1
1 104 1
1 157 1
1 167 1
1 61 0
1 74 0
1 79 0
1 80 0
1 81 0
1 87 0
1 87 0
1 88 0
1 89 0
1 93 0
1 97 0
1 101 0
1 104 0
1 108 0
1 109 0
1 120 0
1 131 0
1 150 0
1 231 0
1 240 0
1 400 0
2 1 1
2 3 1
2 4 1
2 5 1
2 5 1
2 8 1
2 12 1
2 13 1
2 18 1
2 23 1
2 26 1
2 27 1
2 30 1
2 42 1
2 56 1
2 62 1
2 69 1
2 104 1
2 104 1
2 112 1
2 129 1
2 181 1
2 8 0
2 67 0
2 76 0
2 104 0
2 176 0
2 231 0
;
run;

symbol c=orange; 
proc lifetest data = hw7_4 method=pl aalen plots=(s, ls) censoredsymbol=circle;
time o_time*censor(0);
strata type / test=(logrank wilcoxon lr);
run;

