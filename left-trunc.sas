/***
Data on 26 psychiatric patients
See Section 1.15
Data can be read in free format. The variables represented in the dataset are as follows: 

Patient sex (1=male, 2=female) 
Patient age 
Time to death or on-study time 
Death indicator (0=alive, 1=dead) 
Reference Woolsen Biometrics 37 (1981): 687-696.
***/

/*** Survival Analysis: Left-Truncated Data by Russel Banks  ***/

data psych;
input gender $ age time death;
cards;
2 51 1 1
2 58 1 1
2 55 2 1
2 28 22 1
1 21 30 0
1 19 28 1
2 25 32 1
2 48 11 1
2 47 14 1
2 25 36 0
2 31 31 0
1 24 33 0
1 25 33 0
2 30 37 0
2 33 35 0 
1 36 25 1
1 30 31 0
1 41 22 1
2 43 26 1
2 45 24 1
2 35 35 0
1 29 34 0
1 35 30 0
1 32 35 1
2 36 40 1
1 32 39 0
;
run;

proc contents data=psych;
run;

proc lifetest data=psych method=km plots=(survival(cl)); 
strata gender; 
time time*death(0);  
survival out=out1 conftype=log; 
run;

proc phreg data=psych plots(cl overlay=stratum)=survival; 
strata gender; 
model time*death(0)=; 
output out=psych01 survival=S; 
run;

data temp; set psych; agetime=age+time; run; 

proc phreg data=temp; 
class gender / param=ref ref=first;
model agetime*death(0)= gender;  
run;

proc phreg data=temp plots(cl overlay=stratum)=survival; 
strata gender; model agetime*death(0)=/entry=age; output out=psych02 survival=S; run;

proc phreg data=temp; 
class gender / param=ref ref=first;
model agetime*death(0)= gender / entry=age;  
run;
