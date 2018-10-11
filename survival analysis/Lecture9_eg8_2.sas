
/* http://www.mcw.edu/Biostatistics/Statistical-Resources.htm */
/*
Data on 90 males with larynx cancer
See Section 1.8
Data can be read in free format. The variables represented in the dataset are as follows: 

Stage of disease (1=stage 1, 2=stage2, 3=stage 3, 4=stage 4) 
Time to death or on-study time, months 
Age at diagnosis of larynx cancer 
Year of diagnosis of larynx cancer 
Death indicator (0=alive, 1=dead) 
Reference: Kardaun Stat. Nederlandica 37 (1983), 103-126.
*/

data eg8_2;
input stage i_time age year censor;
cards;
1 0.6 77 76 1
1 1.3 53 71 1
1 2.4 45 71 1
1 2.5 57 78 0
1 3.2 58 74 1
1 3.2 51 77 0
1 3.3 76 74 1
1 3.3 63 77 0
1 3.5 43 71 1
1 3.5 60 73 1
1 4 52 71 1
1 4 63 76 1
1 4.3 86 74 1
1 4.5 48 76 0
1 4.5 68 76 0
1 5.3 81 72 1
1 5.5 70 75 0
1 5.9 58 75 0
1 5.9 47 75 0
1 6 75 73 1
1 6.1 77 75 0
1 6.2 64 75 0
1 6.4 77 72 1
1 6.5 67 70 1
1 6.5 79 74 0
1 6.7 61 74 0
1 7 66 74 0
1 7.4 68 71 1
1 7.4 73 73 0
1 8.1 56 73 0
1 8.1 73 73 0
1 9.6 58 71 0
1 10.7 68 70 0
2 0.2 86 74 1
2 1.8 64 77 1
2 2 63 75 1
2 2.2 71 78 0
2 2.6 67 78 0
2 3.3 51 77 0
2 3.6 70 77 1
2 3.6 72 77 0
2 4 81 71 1
2 4.3 47 76 0
2 4.3 64 76 0
2 5 66 76 0
2 6.2 74 72 1
2 7 62 73 1
2 7.5 50 73 0
2 7.6 53 73 0
2 9.3 61 71 0
3 0.3 49 72 1
3 0.3 71 76 1
3 0.5 57 74 1
3 0.7 79 77 1
3 0.8 82 74 1
3 1 49 76 1
3 1.3 60 76 1
3 1.6 64 72 1
3 1.8 74 71 1
3 1.9 72 74 1
3 1.9 53 74 1
3 3.2 54 75 1
3 3.5 81 74 1
3 3.7 52 77 0
3 4.5 66 76 0
3 4.8 54 76 0
3 4.8 63 76 0
3 5 59 73 1
3 5 49 76 0
3 5.1 69 76 0
3 6.3 70 72 1
3 6.4 65 72 1
3 6.5 65 74 0
3 7.8 68 72 1
3 8 78 73 0
3 9.3 69 71 0
3 10.1 51 71 0
4 0.1 65 72 1
4 0.3 71 76 1
4 0.4 76 77 1
4 0.8 65 76 1
4 0.8 78 77 1
4 1 41 77 1
4 1.5 68 73 1
4 2 69 76 1
4 2.3 62 71 1
4 2.9 74 78 0
4 3.6 71 75 1
4 3.8 84 74 1
4 4.3 48 76 0
;
run;

data mydata;
set eg8_2;
if stage =2 then z1=1; else z1=0;
if stage =3 then z2=1; else z2=0;
if stage =4 then z3=1; else z3=0;
run;

/*** Text: Page 249, and Lecture 9 notes: Slide 10 ***/
   proc phreg data=mydata ;
      class stage / descending param=ref;
      model i_time*censor(0)= stage / ties=breslow;
	  hazardratio stage;
   run;
/*** OR ***/
  proc phreg data=mydata ;
      class stage / descending param=ref;
      model i_time*censor(0)= z1 z2 z3 / ties=breslow;
	  hazardratio z1;
      hazardratio z2;
      hazardratio z3;
   run;


/*** Text: Pages 249 - 251, and Lecture 9 notes: Slide 12 ***/
/*** Wald test, null hypothesis: beta1=0, beta2=0, beta3=0 ***/
proc phreg data=mydata ;
      model i_time*censor(0)= age z1 z2 z3;
	  test z1, z2, z3;
   run;
/*** likelihood ratio - The degrees of freedom are the number of
parameters in the full model minus the number of parameters in the
reduced model ***/
/*** the likelihood ratio chi-square statistic = (-2 LOG L of reduced model) - (-2 LOG L of full model) ***/
proc phreg data=mydata   ;
      model i_time*censor(0)= age z1 z2 z3;
   run;
   proc phreg data=mydata ;
      model i_time*censor(0)= age ;
   run;


/*** Text: Table 8.1, Page 266 - 267 ***/
proc phreg data=mydata  ;
      model i_time*censor(0)= age z1 z2 z3 / covb risklimits;
	  test z1;
   run;


/*** Text: Page 267 - 268, Lecture 9 notes: Slides 13 - 14 ***/
/*** likelihood ratio  *The degrees of freedom are the number of
parameters in the full model minus the number of parameters in the
reduced model   ***/
data mydata1;
set mydata;
zz=z1+z2+z3;
run;
proc phreg data=mydata  outest=allterm ;
      model i_time*censor(0)= age z1 z2 z3;
   run;
   proc phreg data=mydata1 outest=three_eq;
      model i_time*censor(0)= age zz ;
   run;
    /*** i.e. 386.275 - 376.359 = 9.916 = likelihood ratio chi-squared test statistic, null hypothesis: beta1=beta2=beta3 ***/
/* Wald test, null hypothesis: beta1=beta2=beta3 */
proc phreg data=mydata  ;
      model i_time*censor(0)= age z1 z2 z3 / covb risklimits;
	test z1=z2=z3;
   run;


/*** Text: Page 269 - 271, Lecture 9 notes: Slides 16 - 22 ***/
/* Interactions  */
data mydata2;
  set mydata;
  z4 = z1*age;
  z5 = z2*age;
  z6 = z3*age;
run;
proc phreg data = mydata2;
  model i_time*censor(0) = age  z1-z6 ;
test z4; /*** Wald test, null hypothesis: beta5=0 ***/
run;

/*** Wald test, null hypothesis: beta6=betat7=0  ***/
proc phreg data = mydata2;
  model i_time*censor(0) = age  z1-z6 ;
test z5=z6=0;
run;
proc phreg data = mydata2;
  model i_time*censor(0) = age  z1-z4 ;
run;
/*** the likelihood ratio chi-square statistic = (-2 LOG L of reduced model) - (-2 LOG L of full model) ***/
/*** i.e. 370.316 - 370.155 = 0.161 = the likelihood ratio test statistic, for null hypothesis: beta6=betat7=0 ***/
