****lab shift table


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