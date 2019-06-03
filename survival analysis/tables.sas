****lab shift table;
data ADSL;
length USUBJID $ 3;
label USUBJID = "Unique Subject Identifier"
      TRTPN   = "Planned Treatment (N)";
input USUBJID $ TRTPN @@;
datalines;
101 1  102 0  103 0  104 1  105 0  106 0  107 1  108 1  109 1  110 1
;
run;

**** INPUT SAMPLE LABORATORY DATA AS SDTM LB DATA;
data LB;
label USUBJID     = "Unique Subject Identifier"
      VISITNUM    = "Visit Number"
      LBCAT       = "Category for Lab Test"
      LBTEST      = "Laboratory Test"
      LBSTRESU    = "Standard Units"
      LBSTRESN    = "Numeric Result/Finding in Standard Units"
      LBSTNRLO    = "Reference Range Lower Limit-Std Units"
      LBSTNRHI    = "Reference Range Upper Limit-Std Units"
      LBNRIND     = "Reference Range Indicator";

input USUBJID $ 1-3 VISITNUM 6 LBCAT $ 9-18 LBTEST $ 20-29
      LBSTRESU $ 32-35 LBSTRESN 38-41 LBSTNRLO 45-48 
      LBSTNRHI 52-55 LBNRIND $ 59;
datalines;
101  0  HEMATOLOGY HEMATOCRIT  %     31     35     49     L
101  1  HEMATOLOGY HEMATOCRIT  %     39     35     49     N
101  2  HEMATOLOGY HEMATOCRIT  %     44     35     49     N
101  0  HEMATOLOGY HEMOGLOBIN  g/dL  11.5   11.7   15.9   L
101  1  HEMATOLOGY HEMOGLOBIN  g/dL  13.2   11.7   15.9   N
101  2  HEMATOLOGY HEMOGLOBIN  g/dL  14.3   11.7   15.9   N
102  0  HEMATOLOGY HEMATOCRIT  %     39     39     52     N
102  1  HEMATOLOGY HEMATOCRIT  %     39     39     52     N
102  2  HEMATOLOGY HEMATOCRIT  %     44     39     52     N
102  0  HEMATOLOGY HEMOGLOBIN  g/dL  11.5   12.7   17.2   L
102  1  HEMATOLOGY HEMOGLOBIN  g/dL  13.2   12.7   17.2   N
102  2  HEMATOLOGY HEMOGLOBIN  g/dL  18.3   12.7   17.2   H
103  0  HEMATOLOGY HEMATOCRIT  %     50     35     49     H
103  1  HEMATOLOGY HEMATOCRIT  %     39     35     49     N
103  2  HEMATOLOGY HEMATOCRIT  %     55     35     49     H
103  0  HEMATOLOGY HEMOGLOBIN  g/dL  12.5   11.7   15.9   N
103  1  HEMATOLOGY HEMOGLOBIN  g/dL  12.2   11.7   15.9   N
103  2  HEMATOLOGY HEMOGLOBIN  g/dL  14.3   11.7   15.9   N
104  0  HEMATOLOGY HEMATOCRIT  %     55     39     52     H
104  1  HEMATOLOGY HEMATOCRIT  %     45     39     52     N
104  2  HEMATOLOGY HEMATOCRIT  %     44     39     52     N
104  0  HEMATOLOGY HEMOGLOBIN  g/dL  13.0   12.7   17.2   N
104  1  HEMATOLOGY HEMOGLOBIN  g/dL  13.3   12.7   17.2   N
104  2  HEMATOLOGY HEMOGLOBIN  g/dL  12.8   12.7   17.2   N
105  0  HEMATOLOGY HEMATOCRIT  %     36     35     49     N
105  1  HEMATOLOGY HEMATOCRIT  %     39     35     49     N
105  2  HEMATOLOGY HEMATOCRIT  %     39     35     49     N
105  0  HEMATOLOGY HEMOGLOBIN  g/dL  13.1   11.7   15.9   N
105  1  HEMATOLOGY HEMOGLOBIN  g/dL  14.0   11.7   15.9   N
105  2  HEMATOLOGY HEMOGLOBIN  g/dL  14.0   11.7   15.9   N
106  0  HEMATOLOGY HEMATOCRIT  %     53     39     52     H
106  1  HEMATOLOGY HEMATOCRIT  %     50     39     52     N
106  2  HEMATOLOGY HEMATOCRIT  %     53     39     52     H
106  0  HEMATOLOGY HEMOGLOBIN  g/dL  17.0   12.7   17.2   N
106  1  HEMATOLOGY HEMOGLOBIN  g/dL  12.3   12.7   17.2   L
106  2  HEMATOLOGY HEMOGLOBIN  g/dL  12.9   12.7   17.2   N
107  0  HEMATOLOGY HEMATOCRIT  %     55     39     52     H
107  1  HEMATOLOGY HEMATOCRIT  %     56     39     52     H
107  2  HEMATOLOGY HEMATOCRIT  %     57     39     52     H
107  0  HEMATOLOGY HEMOGLOBIN  g/dL  18.0   12.7   17.2   N
107  1  HEMATOLOGY HEMOGLOBIN  g/dL  18.3   12.7   17.2   H
107  2  HEMATOLOGY HEMOGLOBIN  g/dL  19.2   12.7   17.2   H
108  0  HEMATOLOGY HEMATOCRIT  %     40     39     52     N
108  1  HEMATOLOGY HEMATOCRIT  %     53     39     52     H
108  2  HEMATOLOGY HEMATOCRIT  %     54     39     52     H
108  0  HEMATOLOGY HEMOGLOBIN  g/dL  15.0   12.7   17.2   N
108  1  HEMATOLOGY HEMOGLOBIN  g/dL  18.0   12.7   17.2   H
108  2  HEMATOLOGY HEMOGLOBIN  g/dL  19.1   12.7   17.2   H
109  0  HEMATOLOGY HEMATOCRIT  %     39     39     52     N
109  1  HEMATOLOGY HEMATOCRIT  %     53     39     52     H
109  2  HEMATOLOGY HEMATOCRIT  %     57     39     52     H
109  0  HEMATOLOGY HEMOGLOBIN  g/dL  13.0   12.7   17.2   N
109  1  HEMATOLOGY HEMOGLOBIN  g/dL  17.3   12.7   17.2   H
109  2  HEMATOLOGY HEMOGLOBIN  g/dL  17.3   12.7   17.2   H
110  0  HEMATOLOGY HEMATOCRIT  %     50     39     52     N
110  1  HEMATOLOGY HEMATOCRIT  %     51     39     52     N
110  2  HEMATOLOGY HEMATOCRIT  %     57     39     52     H
110  0  HEMATOLOGY HEMOGLOBIN  g/dL  13.0   12.7   17.2   N
110  1  HEMATOLOGY HEMOGLOBIN  g/dL  18.0   12.7   17.2   H
110  2  HEMATOLOGY HEMOGLOBIN  g/dL  19.0   12.7   17.2   H
;
run;

proc sort
   data = lb;
      by usubjid lbcat lbtest lbstresu visitnum;
run;

proc sort
   data = adsl;
      by usubjid;
run;

**** MERGE TREATMENT INFORMATION WITH LAB DATA.;
data lb;
   merge adsl(in = inadsl) lb(in = inlb);
      by usubjid;

      if inlb and not inadsl then
         put "WARN" "ING: Missing treatment assignment for subject "
             usubjid=;

      if inadsl and inlb;
run;

**** CARRY FORWARD BASELINE LABORATORY ABNORMAL FLAG.;
data lb;
   set lb;
      by usubjid lbcat lbtest lbstresu visitnum;

      retain baseflag " ";

      **** INITIALIZE BASELINE FLAG TO MISSING.;
      if first.lbtest then
         baseflag = " ";

      **** AT VISITNUM 0 ASSIGN BASELINE FLAG.;
      if visitnum = 0 then
         baseflag = lbnrind;
run;

proc sort
   data = lb;
      by lbcat lbtest lbstresu visitnum trtpn;
run;

**** GET COUNTS AND PERCENTAGES FOR SHIFT TABLE.
**** WE DO NOT WANT COUNTS FOR VISITNUM 0 SO IT IS SUPRESSED.;
ods listing close;
ods output CrossTabFreqs = freqs;
proc freq
   data=lb(where = (visitnum ne 0));
      by lbcat lbtest lbstresu visitnum trtpn;

      tables baseflag*lbnrind;
run;
ods output close;
ods listing;

data freqs1;
set freqs;
where baseflag ne ' ' and LBNRIND ne ' ';
drop Table _TABLE_ Percent RowPercent ColPercent Missing _TYPE_;
run;

proc sort data = freqs1;
by LBCAT LBTEST LBSTRESU VISITNUM TRTPN baseflag LBNRIND;
run;

****create a dummy dataset;

proc sort data = freqs1 out=dummy(keep=LBCAT LBTEST LBSTRESU ) nodupkey;
by LBCAT LBTEST LBSTRESU ;
run;

data dummy1;
set dummy;
    do VISITNUM = 1 to 2;
        do TRTPN = 0 to 1;
            do baseflag = "H","N","L" ;
                do LBNRIND = "H","N","L" ;
                output;
                end;
            end;
        end;
    end;
run;

proc sort data = dummy1;
by LBCAT LBTEST LBSTRESU VISITNUM TRTPN baseflag LBNRIND;
run;

data new;
merge dummy1 freqs1;
by LBCAT LBTEST LBSTRESU VISITNUM TRTPN baseflag LBNRIND;
run;

proc sort data=new;
   by LBCAT LBTEST LBSTRESU VISITNUM baseflag TRTPN LBNRIND;
   run;
proc transpose data=new out=table(drop=_:) prefix=trtp delim=_;
   by lbcat lbtest lbstresu visitnum baseflag;
   var frequency;
   id trtpn lbnrind;
   run;


   **** dm table;
**** INPUT SAMPLE DEMOGRAPHICS DATA AS CDISC ADaM ADSL;
data ADSL;
label USUBJID = "Unique Subject Identifier"
      TRTPN   = "Planned Treatment (N)"
      SEXN    = "Sex (N)"
      RACEN   = "Race (N)"
      AGE     = "Age";
input USUBJID $ TRTPN SEXN RACEN AGE @@;
datalines;
101 0 1 3 37  301 0 1 1 70  501 0 1 2 33  601 0 1 1 50  701 1 1 1 60
102 1 2 1 65  302 0 1 2 55  502 1 2 1 44  602 0 2 2 30  702 0 1 1 28
103 1 1 2 32  303 1 1 1 65  503 1 1 1 64  603 1 2 1 33  703 1 1 2 44
104 0 2 1 23  304 0 1 1 45  504 0 1 3 56  604 0 1 1 65  704 0 2 1 66
105 1 1 3 44  305 1 1 1 36  505 1 1 2 73  605 1 2 1 57  705 1 1 2 46
106 0 2 1 49  306 0 1 2 46  506 0 1 1 46  606 0 1 2 56  706 1 1 1 75
201 1 1 3 35  401 1 2 1 44  507 1 1 2 44  607 1 1 1 67  707 1 1 1 46
202 0 2 1 50  402 0 2 2 77  508 0 2 1 53  608 0 2 2 46  708 0 2 1 55
203 1 1 2 49  403 1 1 1 45  509 0 1 1 45  609 1 2 1 72  709 0 2 2 57
204 0 2 1 60  404 1 1 1 59  510 0 1 3 65  610 0 1 1 29  710 0 1 1 63
205 1 1 3 39  405 0 2 1 49  511 1 2 2 43  611 1 2 1 65  711 1 1 2 61
206 1 2 1 67  406 1 1 2 33  512 1 1 1 39  612 1 1 2 46  712 0 . 1 49
;
 
**** DEFINE VARIABLE FORMATS NEEDED FOR TABLE;
proc format;
   value trtpn
      1 = "Active"
      0 = "Placebo"; 
   value sexn
      . = "Missing"
      1 = "Male"
      2 = "Female";
   value racen
      1 = "White"
      2 = "Black"
      3 = "Other*";
run;

**** DUPLICATE THE INCOMING DATASET FOR OVERALL COLUMN CALCULATIONS SO
**** NOW TRT HAS VALUES 0 = PLACEBO, 1 = ACTIVE, AND 2 = OVERALL.;
data adsl;
   set adsl;
   output;
   trtpn = 2;
   output;
run;

**** AGE STATISTICS PROGRAMMING ************************************;
**** GET P VALUE FROM NON PARAMETRIC COMPARISON OF AGE MEANS.;
proc npar1way 
   data = adsl
   wilcoxon 
   noprint;
      where trtpn in (0,1);
      class trtpn;
      var age;
      output out=pvalue wilcoxon;
run;

proc sort 
   data=adsl;
      by trtpn;
run;
 
***** GET AGE DESCRIPTIVE STATISTICS N, MEAN, STD, MIN, AND MAX.;
proc univariate 
   data = adsl noprint;
      by trtpn;

      var age;
      output out = age 
             n = _n mean = _mean std = _std min = _min max = _max;
run;

**** FORMAT AGE DESCRIPTIVE STATISTICS FOR THE TABLE.;
data age;
   set age;

   format n mean std min max $14.;
   drop _n _mean _std _min _max;

   n = put(_n,5.);
   mean = put(_mean,7.1);
   std = put(_std,8.2);
   min = put(_min,7.1);
   max = put(_max,7.1);
run;

**** TRANSPOSE AGE DESCRIPTIVE STATISTICS INTO COLUMNS.;
proc transpose 
   data = age 
   out = age 
   prefix = col;
      var n mean std min max;
      id trtpn;
run; 
 
**** CREATE AGE FIRST ROW FOR THE TABLE.;
data label;
   set pvalue(keep = p2_wil rename = (p2_wil = pvalue));
   length label $ 85;
   label = "#S={font_weight=bold} Age (years)";
run;
 
**** APPEND AGE DESCRIPTIVE STATISTICS TO AGE P VALUE ROW AND 
**** CREATE AGE DESCRIPTIVE STATISTIC ROW LABELS.; 
data age;
   length label $ 85 col0 col1 col2 $ 25 ;
   set label age;

   keep label col0 col1 col2 pvalue ;
   if _n_ > 1 then 
      select;
         when(_NAME_ = 'n')    label = "#{nbspace 6}N";
         when(_NAME_ = 'mean') label = "#{nbspace 6}Mean";
         when(_NAME_ = 'std')  label = "#{nbspace 6}Standard Deviation";
         when(_NAME_ = 'min')  label = "#{nbspace 6}Minimum";
         when(_NAME_ = 'max')  label = "#{nbspace 6}Maximum";
         otherwise;
      end;
run;
**** END OF AGE STATISTICS PROGRAMMING *****************************;

 
**** SEX STATISTICS PROGRAMMING ************************************;
**** GET SIMPLE FREQUENCY COUNTS FOR SEX.;
proc freq 
   data = adsl 
   noprint;
      where trtpn ne .; 
      tables trtpn * sexn / missing outpct out = sexn;
run;
 
**** FORMAT SEX N(%) AS DESIRED.;
data sexn;
   set sexn;
      where sexn ne .;
      length value $25;
      value = put(count,4.) || ' (' || put(pct_row,5.1)||'%)';
run;

proc sort
   data = sexn;
      by sexn;
run;
 
**** TRANSPOSE THE SEX SUMMARY STATISTICS.;
proc transpose 
   data = sexn 
   out = sexn(drop = _name_) 
   prefix = col;
      by sexn;
      var value;
      id trtpn;
run;
 
**** PERFORM A CHI-SQUARE TEST ON SEX COMPARING ACTIVE VS PLACEBO.;
proc freq 
   data = adsl 
   noprint;
      where sexn ne . and trtpn not in (.,2);
      table sexn * trtpn / chisq;
      output out = pvalue pchi;
run;

**** CREATE SEX FIRST ROW FOR THE TABLE.;
data label;
	set pvalue(keep = p_pchi rename = (p_pchi = pvalue));
	length label $ 85;
	label = "#S={font_weight=bold} Sex";
run;

**** APPEND SEX DESCRIPTIVE STATISTICS TO SEX P VALUE ROW AND 
**** CREATE SEX DESCRIPTIVE STATISTIC ROW LABELS.; 
data sexn;
   length label $ 85 col0 col1 col2 $ 25 ;
   set label sexn;

   keep label col0 col1 col2 pvalue ;
   if _n_ > 1 then 
        label= "#{nbspace 6}" || put(sexn,sexn.);
run;
**** END OF SEX STATISTICS PROGRAMMING *****************************;

 
**** RACE STATISTICS PROGRAMMING ***********************************;
**** GET SIMPLE FREQUENCY COUNTS FOR RACE;
proc freq 
   data = adsl 
   noprint;
      where trtpn ne .; 
      tables trtpn * racen / missing outpct out = racen;
run;
 
**** FORMAT RACE N(%) AS DESIRED;
data racen;
   set racen;
      where racen ne .;
      length value $25;
      value = put(count,4.) || ' (' || put(pct_row,5.1)||'%)';
run;

proc sort
   data = racen;
      by racen;
run;
 
**** TRANSPOSE THE RACE SUMMARY STATISTICS;
proc transpose 
   data = racen 
   out = racen(drop = _name_) 
   prefix=col;
      by racen;
      var value;
      id trtpn;
run;
 
**** PERFORM A FISHER'S EXACT TEST ON RACE COMPARING ACTIVE VS PLACEBO.;
proc freq 
   data = adsl 
   noprint;
      where racen ne . and trtpn not in (.,2);
      table racen * trtpn / exact;
      output out = pvalue exact;
run;
 
**** CREATE RACE FIRST ROW FOR THE TABLE.;
data label;
	set pvalue(keep = xp2_fish rename = (xp2_fish = pvalue));
	length label $ 85;
	label = "#S={font_weight=bold} Race";
run;

**** APPEND RACE DESCRIPTIVE STATISTICS TO RACE P VALUE ROW AND 
**** CREATE RACE DESCRIPTIVE STATISTIC ROW LABELS.; 
data racen;
   length label $ 85 col0 col1 col2 $ 25 ;
   set label racen;

   keep label col0 col1 col2 pvalue ;
   if _n_ > 1 then 
        label= "#{nbspace 6}" || put(racen,racen.);
run;
**** END OF RACE STATISTICS PROGRAMMING *******************************;


**** CONCATENATE AGE, SEX, AND RACE STATISTICS AND CREATE GROUPING
**** GROUP VARIABLE FOR LINE SKIPPING IN PROC REPORT.;
data forreport;
   set age(in = in1)
       sexn(in = in2)
       racen(in = in3);

       group = sum(in1 * 1, in2 * 2, in3 * 3);
run;


**** DEFINE THREE MACRO VARIABLES &N0, &N1, AND &NT THAT ARE USED IN 
**** THE COLUMN HEADERS FOR "PLACEBO," "ACTIVE" AND "OVERALL" THERAPY 
**** GROUPS.;
data _null_;
   set adsl end=eof;

   **** CREATE COUNTER FOR N0 = PLACEBO, N1 = ACTIVE.;
   if trtpn = 0 then
      n0 + 1;
   else if trtpn = 1 then
      n1 + 1;

   **** CREATE OVERALL COUNTER NT.; 
   nt + 1;
  
   **** CREATE MACRO VARIABLES &N0, &N1, AND &NT.;
   if eof then
      do;     
         call symput("n0",compress('(N='||put(n0,4.) || ')'));
         call symput("n1",compress('(N='||put(n1,4.) || ')'));
         call symput("nt",compress('(N='||put(nt,4.) || ')'));
      end;
run;


**** USE PROC REPORT TO WRITE THE DEMOGRAPHICS TABLE TO FILE.; 
options nodate nonumber missing = ' ';
ods escapechar='#';
ods pdf style=htmlblue file='program5.3.pdf';

proc report
   data=forreport
   nowindows
   spacing=1
   headline
   headskip
   split = "|";

   columns (group label col1 col0 col2 pvalue);

   define group   /order order = internal noprint;
   define label   /display " ";
   define col0    /display style(column)=[asis=on] "Placebo|&n0";
   define col1    /display style(column)=[asis=on] "Active|&n1";
   define col2    /display style(column)=[asis=on] "Overall|&nt";
   define pvalue  /display center " |P-value**" f = pvalue6.4;

   compute after group;
      line '#{newline}';
   endcomp;

   title1 j=l 'Company/Trial Name' 
          j=r 'Page #{thispage} of #{lastpage}';
   title2 j=c 'Table 5.3';
   title3 j=c 'Demographics and Baseline Characteristics';

   footnote1 j=l '* Other includes Asian, Native American, and other'
                 ' races.';
   footnote2 j=l "** P-values:  Age = Wilcoxon rank-sum, Sex = Pearson's"  
                 " chi-square, Race = Fisher's exact test.";
   footnote3 j=l "Created by %sysfunc(getoption(sysin)) on &sysdate9..";  
run; 
ods pdf close;   



**** ae table;
**** INPUT TREATMENT CODE DATA AS ADAM ADSL DATA.;
data ADSL;
length USUBJID $ 3;
label USUBJID = "Unique Subject Identifier"
      TRTPN   = "Planned Treatment (N)";
input USUBJID $ TRTPN @@;
datalines;
101 1  102 0  103 0  104 1  105 0  106 0  107 1  108 1  109 0  110 1
111 0  112 0  113 0  114 1  115 0  116 1  117 0  118 1  119 1  120 1
121 1  122 0  123 1  124 0  125 1  126 1  127 0  128 1  129 1  130 1
131 1  132 0  133 1  134 0  135 1  136 1  137 0  138 1  139 1  140 1
141 1  142 0  143 1  144 0  145 1  146 1  147 0  148 1  149 1  150 1
151 1  152 0  153 1  154 0  155 1  156 1  157 0  158 1  159 1  160 1
161 1  162 0  163 1  164 0  165 1  166 1  167 0  168 1  169 1  170 1
;
run;

**** INPUT ADVERSE EVENT DATA AS SDTM AE DOMAIN.;
data AE;
label USUBJID     = "Unique Subject Identifier"
      AEBODSYS    = "Body System or Organ Class"
      AEDECOD     = "Dictionary-Derived Term"
      AEREL       = "Causality"
	  AESEV       = "Severity/Intensity";    
input USUBJID $ 1-3 AEBODSYS $ 5-30 AEDECOD $ 34-50 
      AEREL $ 52-67 AESEV $ 70-77;
datalines;
101 Cardiac disorders            Atrial flutter    NOT RELATED       MILD
101 Gastrointestinal disorders   Constipation      POSSIBLY RELATED  MILD
102 Cardiac disorders            Cardiac failure   POSSIBLY RELATED  MODERATE
102 Psychiatric disorders        Delirium          NOT RELATED       MILD
103 Cardiac disorders            Palpitations      NOT RELATED       MILD
103 Cardiac disorders            Palpitations      NOT RELATED       MODERATE
103 Cardiac disorders            Tachycardia       POSSIBLY RELATED  MODERATE
115 Gastrointestinal disorders   Abdominal pain    RELATED           MODERATE
115 Gastrointestinal disorders   Anal ulcer        RELATED           MILD
116 Gastrointestinal disorders   Constipation      POSSIBLY RELATED  MILD
117 Gastrointestinal disorders   Dyspepsia         POSSIBLY RELATED  MODERATE
118 Gastrointestinal disorders   Flatulence        RELATED           SEVERE
119 Gastrointestinal disorders   Hiatus hernia     NOT RELATED       SEVERE
130 Nervous system disorders     Convulsion        NOT RELATED       MILD
131 Nervous system disorders     Dizziness         POSSIBLY RELATED  MODERATE
132 Nervous system disorders     Essential tremor  NOT RELATED       MILD
135 Psychiatric disorders        Confusional state NOT RELATED       SEVERE
140 Psychiatric disorders        Delirium          NOT RELATED       MILD
140 Psychiatric disorders        Sleep disorder    POSSIBLY RELATED  MILD
141 Cardiac disorders            Palpitations      NOT RELATED       SEVERE
;
run;


**** CREATE ADAE ADAM DATASET TO MAKE HELPFUL COUNTING FLAGS FOR SUMMARIZATION.
**** THIS WOULD TYPICALLY BE DONE AS A SEPARATE PROGRAM OUTSIDE OF AN AE SUMMARY.;
data adae;
  merge ae(in=inae) adsl;
    by usubjid;

	if inae;

    select (aesev);
      when('MILD') aesevn = 1;
      when('MODERATE') aesevn = 2;
      when('SEVERE') aesevn = 3;
      otherwise;
    end;
    label aesevn = "Severity/Intensity (N)";
run;

proc sort
  data=adae;
    by usubjid aesevn;
run;

data adae;
  set adae;
    by usubjid aesevn;

    if last.usubjid then
      aoccifl = 'Y';

    label aoccifl = "1st Max Sev./Int. Occurrence Flag";
run;

proc sort
  data=adae;
    by usubjid aebodsys aesevn;
run;

data adae;
  set adae;
    by usubjid aebodsys aesevn;

    if last.aebodsys then
      aoccsifl = 'Y';

    label aoccsifl = "1st Max Sev./Int. Occur Within SOC Flag";
run;

proc sort
  data=adae;
    by usubjid aedecod aesevn;
run;

data adae;
  set adae;
    by usubjid aedecod aesevn;

    if last.aedecod then
      aoccpifl = 'Y';

    label aoccpifl = "1st Max Sev./Int. Occur Within PT Flag";
run;
**** END OF ADAM ADAE ADAM DATASET DERIVATIONS;


**** PUT COUNTS OF TREATMENT POPULATIONS INTO MACRO VARIABLES;
proc sql noprint;
  select count(unique usubjid) format = 3. into :n0 from adsl where trtpn=0;
  select count(unique usubjid) format = 3. into :n1 from adsl where trtpn=1;
  select count(unique usubjid) format = 3. into :n2 from adsl;
quit;

**** OUTPUT A SUMMARY TREATMENT SET OF RECORDS. TRTPN=2;
data adae;
  set adae;
  output;
  trtpn=2;
  output;
run;

**** BY SEVERITY ONLY COUNTS;
proc sql noprint;
  create table All as
         select trtpn,               
                sum(aoccifl='Y') as frequency from adae
  group by trtpn;
quit;

proc sql noprint;
  create table AllBySev as
         select aesev, trtpn,               
                sum(aoccifl='Y') as frequency from adae
  group by aesev, trtpn;
quit;

**** BY BODY SYSTEM AND SEVERITY COUNTS;
proc sql noprint;
  create table AllBodysys as
         select trtpn, aebodsys,               
                sum(aoccsifl='Y') as frequency from adae
  group by trtpn, aebodsys;
quit;

proc sql noprint;
  create table AllBodysysBysev as
         select aesev, trtpn, aebodsys,               
                sum(aoccsifl='Y') as frequency from adae
  group by aesev, trtpn, aebodsys;
quit;

**** BY PREFERRED TERM AND SEVERITY COUNTS;
proc sql noprint;
  create table AllPT as
         select trtpn, aebodsys, aedecod,               
                sum(aoccpifl='Y') as frequency from adae
  group by trtpn, aebodsys, aedecod;
quit;

proc sql noprint;
  create table AllPTBySev as
         select aesev, trtpn, aebodsys, aedecod,               
                sum(aoccpifl='Y') as frequency from adae
  group by aesev, trtpn, aebodsys, aedecod;
quit;

**** PUT ALL COUNT DATA TOGETHER;
data all;
  set All(in=in1)
      AllBySev(in=in2)
      AllBodysys(in=in3)
      AllBodysysBysev(in=in4)
      AllPT(in=in5)
      AllPTBySev(in=in6);

      length description $ 40 sorter $ 200;
      if in1 then
        description = 'Any Event';
      else if in2 or in4 or in6 then
        description = '#{nbspace 6} ' || propcase(aesev);
      else if in3 then
        description = aebodsys;
      else if in5 then
        description = '#{nbspace 3}' || aedecod;

      sorter = aebodsys || aedecod || aesev;
run;

proc sort
  data=all;
  by sorter aebodsys aedecod description;
run;

**** TRANSPOSE THE FREQUENCY COUNTS;
proc transpose
  data=all
  out=flat
  prefix=count;
  by sorter aebodsys aedecod description;
  id trtpn;
  var frequency;
run;

proc sort
  data=flat;
  by aebodsys aedecod sorter;
run;

**** CREATE A SECTION BREAK VARIABLE AND FORMATTED COLUMNS;
data flat;
  set flat;
  by aebodsys aedecod sorter;

  retain section 1;

  length col0 col1 col2 $ 20;
  if count0 not in (.,0) then
    col0 = put(count0,3.) || " (" || put(count0/&n0*100,5.1) || "%)";
  if count1 not in (.,0) then
    col1 = put(count1,3.) || " (" || put(count1/&n1*100,5.1) || "%)";
  if count2 not in (.,0) then
    col2 = put(count2,3.) || " (" || put(count2/&n2*100,5.1) || "%)";
  
  if sum(count1,count2,count3)>0 then
    output;
  if last.aedecod then
    section + 1;
run;

**** USE PROC REPORT TO WRITE THE AE TABLE TO FILE.; 
options nodate nonumber missing = ' ';
ods escapechar='#';
ods pdf style=htmlblue file='program5.4.pdf';

proc report
   data=flat
   nowindows
   split = "|";

   columns section description col1 col0 col2;

   define section     /order order = internal noprint;
   define description /display style(header)=[just=left] 
   "Body System|#{nbspace 3} Preferred Term|#{nbspace 6} Severity";
   define col0        /display "Placebo|N=&n0";
   define col1        /display "Active|N=&n1";
   define col2        /display "Overall|N=&n2";

   compute after section;
      line '#{newline}';
   endcomp;

   title1 j=l 'Company/Trial Name' 
          j=r 'Page #{thispage} of #{lastpage}';
   title2 j=c 'Table 5.4';
   title3 j=c 'Adverse Events';
   title4 j=c "By Body System, Preferred Term, and Greatest Severity";
run; 
ods pdf close;   



**** cm table;
**** INPUT TREATMENT CODE DATA AS ADAM ADSL DATA.;
data ADSL;
length USUBJID $ 3;
label USUBJID = "Unique Subject Identifier"
      TRTPN   = "Planned Treatment (N)";
input USUBJID $ TRTPN @@;
datalines;
101 1  102 0  103 0  104 1  105 0  106 0  107 1  108 1  109 0  110 1
111 0  112 0  113 0  114 1  115 0  116 1  117 0  118 1  119 1  120 1
121 1  122 0  123 1  124 0  125 1  126 1  127 0  128 1  129 1  130 1
131 1  132 0  133 1  134 0  135 1  136 1  137 0  138 1  139 1  140 1
141 1  142 0  143 1  144 0  145 1  146 1  147 0  148 1  149 1  150 1
151 1  152 0  153 1  154 0  155 1  156 1  157 0  158 1  159 1  160 1
161 1  162 0  163 1  164 0  165 1  166 1  167 0  168 1  169 1  170 1
;
run;

**** INPUT SAMPLE CONCOMITANT MEDICATION DATA AS SDTM CM DOMAIN.;
data CM;
label USUBJID = "Unique Subject Identifier"
      CMDECOD = "Standardized Medication Name";
input USUBJID $ 1-3 CMDECOD $ 5-27;
datalines;
101 ACETYLSALICYLIC ACID   
101 HYDROCORTISONE         
102 VICODIN                
102 POTASSIUM              
102 IBUPROFEN              
103 MAGNESIUM SULFATE      
103 RINGER-LACTATE SOLUTION
115 LORAZEPAM              
115 SODIUM BICARBONATE     
116 POTASSIUM              
117 MULTIVITAMIN           
117 IBUPROFEN              
119 IRON                   
130 FOLIC ACID             
131 GABAPENTIN             
132 DIPHENHYDRAMINE        
135 SALMETEROL             
140 HEPARIN                
140 HEPARIN                
140 NICOTINE               
141 HYDROCORTISONE         
141 IBUPROFEN              
;


**** PERFORM A SIMPLE COUNT OF EACH TREATMENT ARM AND OUTPUT RESULT;
**** AS MACRO VARIABLES.  N1 = 1ST COLUMN N FOR ACTIVE THERAPY,
**** N2 = 2ND COLUMN N FOR PLACEBO, N3 REPRESENTS THE 3RD COLUMN TOTAL N.;
proc sql noprint;

   **** PLACE THE NUMBER OF ACTIVE SUBJECTS IN &N1.;
   select count(distinct usubjid) format = 3.
      into :n1 
      from adsl
      where trtpn = 1;
   **** PLACE THE NUMBER OF PLACEBO SUBJECTS IN &N2.;
   select count(distinct usubjid) format = 3.
      into :n2 
      from adsl
      where trtpn = 0;
   **** PLACE THE TOTAL NUMBER OF SUBJECTS IN &N3.;
   select count(distinct usubjid) format = 3.
      into :n3 
      from adsl
      where trtpn ne .;
quit;

***** MERGE CCONCOMITANT MEDICATIONS AND TREATMENT DATA.
***** KEEP RECORDS FOR SUBJECTS WHO HAD CONMEDS AND TOOK STUDY THERAPY.
***** GET UNIQUE CONCOMITANT MEDICATIONS WITHIN PATIENTS.;
proc sql
   noprint;
   create table cmtosum as
      select unique(c.cmdecod) as cmdecod, c.usubjid, t.trtpn
         from cm as c, adsl as t
         where c.usubjid = t.usubjid
         order by usubjid, cmdecod;
quit;

**** GET MEDICATION COUNTS BY TREATMENT AND PLACE IN DATASET COUNTS.;
**** TURN OFF LST OUTPUT.;
ods listing close;       
**** SEND SUMS BY TREATMENT TO COUNTS DATA SET.;
ods output CrossTabFreqs = counts; 
proc freq
   data = cmtosum;
      tables trtpn * cmdecod;
run;
ods output close;
ods listing;

proc sort
   data = counts;
      by cmdecod;
run;

**** MERGE COUNTS DATA SET WITH ITSELF TO PUT THE THREE 
**** TREATMENT COLUMNS SIDE BY SIDE FOR EACH CONMED.  CREATE GROUP
**** VARIABLE WHICH ARE USED TO CREATE BREAK LINE IN THE REPORT. 
**** DEFINE COL1-COL3 WHICH ARE THE COUNT/% FORMATTED COLUMNS.;
data cm;
   merge counts(where = (trtpn = 1) rename = (frequency = count1))
         counts(where = (trtpn = 0) rename = (frequency = count2))
         counts(where = (trtpn = .) rename = (frequency = count3))
         end = eof;
      by cmdecod;

	  keep cmdecod rowlabel col1-col3 section;
	  length rowlabel $ 25 col1-col3 $ 10;

	  **** LABEL "ANY MEDICATION" ROW AND PUT IN FIRST GROUP.
	  **** BY MEDICATION COUNTS GO IN THE SECOND GROUP.;
	  if cmdecod = '' then
	     do;
	        rowlabel = "ANY MEDICATION";	
		    section = 1;
         end;
	  else 
	     do;
            rowlabel = cmdecod;
		    section = 2;
         end;

	  **** CALCULATE PERCENTAGES AND CREATE N/% TEXT IN COL1-COL3.;
      pct1 = (count1 / &n1) * 100;
      pct2 = (count2 / &n2) * 100;
      pct3 = (count3 / &n3) * 100;
           
      col1 = put(count1,3.) || " (" || put(pct1, 3.) || "%)";
      col2 = put(count2,3.) || " (" || put(pct2, 3.) || "%)";
      col3 = put(count3,3.) || " (" || put(pct3, 3.) || "%)";
run;


**** USE PROC REPORT TO WRITE THE CONMED TABLE TO FILE.; 
options nodate nonumber missing = ' ';
ods escapechar='#';
ods pdf style=htmlblue file='program5.5.pdf';
 
proc report
   data=cm
   nowindows
   split = "|";

   columns section rowlabel col1 col2 col3;

   define section  /order order = internal noprint;
   define rowlabel /order width=25 "Preferred Medication Term";
   define col1     /display center width=14 "Active|N=&n1";
   define col2     /display center width=14 "Placebo|N=&n2";
   define col3     /display center width=14 "Total|N=&n3";
 
   compute after section;
      line '#{newline}';
   endcomp;

   title1 j=l 'Company/Trial Name' 
          j=r 'Page #{thispage} of #{lastpage}';
   title2 j=c 'Table 5.5';
   title3 j=c 'Summary of Concomitant Medication';
run; 
ods pdf close;   



