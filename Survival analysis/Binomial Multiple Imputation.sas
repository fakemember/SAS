/****************************************************************/
/*          S A S   S A M P L E   L I B R A R Y                 */
/*                                                              */
/*    NAME: MIEX17                                              */
/*   TITLE: Documentation Example 17 for PROC MI                */
/* PRODUCT: STAT                                                */
/*  SYSTEM: ALL                                                 */
/*    KEYS: multiple imputation                                 */
/*   PROCS: MI                                                  */
/*    DATA:                                                     */
/*                                                              */
/* SUPPORT: Yang Yuan             UPDATE: Jan 4, 2013           */
/*     REF: PROC MI, EXAMPLE 17                                 */
/*    MISC:                                                     */
/****************************************************************/

data Mono2;
   do Grd= 6 to 8;
   do j=1 to 50;

      Grade= Grd;
      if (Grd=6) then do;
         if (ranuni(999) > .80) then Grade= .;
      end;
      else if (ranuni(99) > .95) then Grade= .;

      if (j < 26) then Study= 1;
      else             Study= 0;

      Score0= 70 + 3*rannor(1);
      if (Score0 >= 100) then Score0= 100 - 10*ranuni(99);

      Score= Score0 + 2*rannor(99) + 2;
      if (Study = 1) then do;
         Score= Score + 3;
         if (Grd = 6) then Score= Score + 1;
         if (Grd = 8) then Score= Score + 3;
      end;

      output;
   end; end;
   drop Grd j;
run;

data mono2;
set mono2;
if grade in (6,8) then pass='Yes';
else pass='No';
drop grade x;
x=ranuni(123);
if x>0.95 then pass='';
run;


proc mi data=Mono2 seed=34857 nimpute=20 out=outex17;
   class Study pass;
   monotone logistic (pass / link=glogit);
   mnar adjust( pass (event='Yes') /shift=2);
   var Study Score0 Score pass;
run;

ods trace on;
proc freq data=outex17;
tables pass/binomial alpha=0.1;
by  _Imputation_;
exact binomial;
ods output Binomial=binom;
run;


DATA prop;
 MERGE
 binom(WHERE=(Label1="Proportion (P)")
 KEEP=_Imputation_  nValue1 Label1
 RENAME=(nValue1=prop))
 binom(WHERE=(Label1="ASE")
 KEEP=_Imputation_  nValue1 Label1
 RENAME=(nValue1=prop_se));
 BY _Imputation_ ;
RUN;

PROC SORT DATA=prop; BY _Imputation_; RUN;
PROC MIANALYZE DATA=prop;
 MODELEFFECTS prop;
 STDERR prop_se;
/*  ODS OUTPUT PARAMETERESTIMATES=mian_prop_trt; */
RUN;



/*---------------------------------------------------------*/
/*--- Performs multiple imputation analysis             ---*/
/*--- for specified shift parameters:                   ---*/
/*--- data= input data set                              ---*/
/*--- smin= min shift parameter                         ---*/
/*--- smax= max shift parameter                         ---*/
/*--- sinc= increment of the shift parameter            ---*/
/*--- outparms= output reg parameters                   ---*/
/*---------------------------------------------------------*/
%macro miparms( data=, smin=, smax=, sinc=, outparms=);
ods select none;

data &outparms;
   set _null_;
run;

/*------------ # of shift values ------------*/
%let ncase= %sysevalf( (&smax-&smin)/&sinc, ceil );

/*---- Multiple imputation analysis for each shift ----*/
%do jc=0 %to &ncase;
   %let sj= %sysevalf( &smin + &jc * &sinc);

  /*---- Generates 25 imputed data sets ----*/
proc mi data=&data seed=34857 nimpute=20 out=outmi;
   class Study pass;
   monotone logistic (pass / link=glogit);
   mnar adjust( pass (event='Yes') /shift=&sj );
   var Study Score0 Score pass;
run;

  /*------ Perform reg test -------*/
 
proc freq data=outmi;
tables pass/binomial alpha=0.1;
by  _Imputation_;
exact binomial;
ods output Binomial=binom;
run;

DATA prop;
 MERGE
 binom(WHERE=(Label1="Proportion (P)")
 KEEP=_Imputation_  nValue1 Label1
 RENAME=(nValue1=prop))
 binom(WHERE=(Label1="ASE")
 KEEP=_Imputation_  nValue1 Label1
 RENAME=(nValue1=prop_se));
 BY _Imputation_ ;
RUN;

  /*------ Combine reg results -------*/
  
PROC MIANALYZE DATA=prop;
 MODELEFFECTS prop;
 STDERR prop_se;
 ODS OUTPUT PARAMETERESTIMATES=miparm;
RUN;

   data miparm;
      set miparm;
      Shift= &sj;
      keep Shift estimate stderr;
   run;

  /*----- Output multiple imputation results ----*/
   data &outparms;
      set &outparms miparm;
   run;

%end;

ods select all;
%mend miparms;

%miparms( data=Mono2, smin=-3, smax=0, sinc=0.1, outparms=parm1);