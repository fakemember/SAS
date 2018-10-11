
/* http://www.mcw.edu/Biostatistics/Statistical-Resources.htm */
/*
Data on 43 bone marrow transplants for HD and NHL 
See Section 1.10
Data can be read in free format. The variables represented in the dataset are as follows: 

Graft type (1=allogenic, 2=autologous) 
Disease type (1=Non Hodgkin lymphoma, 2=Hodgkins disease) 
Time to death or relapse, days 
Death/relapse indicator (0=alive, 1=dead) 
Karnofsky score 
Waiting time to transplant in months 
Reference Avalos et al. Bone Marrow Transplantation 13(1993):133-138.
*/

data hw8_3;
input g_type d_type i_time censor k_score wait;
cards;
1 1 28 1 90 24
1 1 32 1 30 7
1 1 49 1 40 8
1 1 84 1 60 10
1 1 357 1 70 42
1 1 933 0 90 9
1 1 1078 0 100 16
1 1 1183 0 90 16
1 1 1560 0 80 20
1 1 2114 0 80 27
1 1 2144 0 90 5
1 2 2 1 20 34
1 2 4 1 50 28
1 2 72 1 80 59
1 2 77 1 60 102
1 2 79 1 70 71
2 1 42 1 80 19
2 1 53 1 90 17
2 1 57 1 30 9
2 1 63 1 60 13
2 1 81 1 50 12
2 1 140 1 100 11
2 1 81 1 50 12
2 1 252 1 90 21
2 1 524 1 90 39
2 1 210 0 90 16
2 1 476 0 90 24
2 1 1037 0 90 84
2 2 30 1 90 73
2 2 36 1 80 61
2 2 41 1 70 34
2 2 52 1 60 18
2 2 62 1 90 40
2 2 108 1 70 65
2 2 132 1 60 17
2 2 180 0 100 61
2 2 307 0 100 24
2 2 406 0 100 48
2 2 446 0 100 52
2 2 484 0 90 84
2 2 748 0 90 171
2 2 1290 0 90 20
2 2 1345 0 80 98
;
run;

/** (a) **/
data mydata1;
set hw8_3;
if (g_type=2 and d_type=1) then z1=1; else z1=0;
if (g_type=2 and d_type=2) then z2=1; else z2=0;
if (g_type=1 and d_type=2) then z3=1; else z3=0;
run;
   proc phreg data=mydata1 ;
      model i_time*censor(0)= z1 z2 z3 / covb risklimits ties=breslow;
   run;


/** (b)  and wald test for interaction **/
data mydata2;
set hw8_3;
if d_type=2 then z1=1; else z1=0;
if g_type=2 then z2=1; else z2=0;
run;
   proc phreg data=mydata2;
      model i_time*censor(0)= z1 z2 z1*z2 / covb risklimits ties=breslow;
   run;
/** (b) to get likelihood test on interaction:
[-2 LOG L of 'reduced model'] - [-2 LOG L of 'full model'] is chi-square distri, degree of freedom= 1   
   **/
 proc phreg data=mydata2;
      model i_time*censor(0)= z1 z2 / ties=breslow;
   run;



/** (c) **/
data mydata1;
set hw8_3;
if (g_type=2 and d_type=1) then z1=1; else z1=0;
if (g_type=2 and d_type=2) then z2=1; else z2=0;
if (g_type=1 and d_type=2) then z3=1; else z3=0;
run;
   proc phreg data=mydata1 ;
      model i_time*censor(0)= z1 z2 z3 / ties=breslow;
	  hazardratio z1;
   run;

/** (d) **/
data mydata1;
set hw8_3;
if (g_type=2 and d_type=1) then z1=1; else z1=0;
if (g_type=2 and d_type=2) then z2=1; else z2=0;
if (g_type=1 and d_type=2) then z3=1; else z3=0;
run;
   proc phreg data=mydata1 ;
      model i_time*censor(0)= z1 z2 z3 / ties=breslow;
	 test1: test z3;
	 test2: test z1=z2;
   run;

   
/** (e) this is to test z1=0 and z2=z3  **/
data mydata1;
set hw8_3;
if (g_type=2 and d_type=1) then z1=1; else z1=0;
if (g_type=2 and d_type=2) then z2=1; else z2=0;
if (g_type=1 and d_type=2) then z3=1; else z3=0;
run;
   proc phreg data=mydata1 ;
      model i_time*censor(0)= z1 z2 z3 / ties=breslow;
	  test z1=0, z2=z3;
   run;





