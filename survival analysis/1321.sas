proc format;
   value trtpn
      1 = "Active"
      2 = "Placebo"; 
      
      
      data ADTTE;
label TRTA  = "Actual Treatment"
      AVAL   = "Analysis Value"
      CNSR   = "Censor";
input TRTA $ AVAL CNSR @@;
datalines;
A  52    0     A  825   1     C  693   1     C  981   1
B  279   0     B  826   1     B  531   1     B  15    1
C  1057  1     C  793   1     B  1048  1     A  925   1
C  470   1     A  251   0     C  830   1     B  668   0
B  350   1     B  746   1     A  122   0     B  825   1
A  163   0     C  735   1     B  699   1     B  771   0
C  889   1     C  932   1     C  773   0     C  767   1
A  155   1     A  708   1     A  547   1     A  462   0
B  114   0     B  704   1     C  1044  1     A  702   0
A  816   1     A  100   0     C  953   1     C  632   1
C  959   1     C  675   1     C  960   0     A  51    1
B  33    0     B  645   1     A  56    0     A  980   0
C  150   1     A  638   1     B  905   1     B  341   0
B  686   1     B  638   1     A  872   0     C  1347  1
A  659   1     A  133   0     C  360   1     A  907   0
C  70    1     A  592   1     B  112   1     B  882   0
A  1007  1     C  594   1     C  7     1     B  361   1
B  964   1     C  582   1     B  1024  0     A  540   0
C  962   1     B  282   1     C  873   1     C  1294  1
B  961   1     C  521   1     A  268   0     A  657   1
C  1000  1     B  9     0     A  678   1     C  989   0
A  910   1     C  1107  1     C  1071  0     A  971   1
C  89    1     A  1111  1     C  701   1     B  364   0
B  442   0     B  92    0     B  1079  1     A  93    1
B  532   0     A  1062  1     A  903   1     C  792   1
C  136   1     C  154   1     C  845   1     B  52    1
A  839   1     B  1076  1     A  834   0     A  589   1
A  815   1     A  1037  1     B  832   1     C  1120  1
C  803   1     C  16    0     A  630   1     B  546   1
A  28    0     A  1004  1     B  1020  1     A  75    1
C  1299  1     B  79    1     C  170   1     B  945   1
B  1056  1     B  947   1     A  1015  1     A  190   0
B  1026  1     C  128   0     B  940   1     C  1270  1
A  1022  0     A  915   1     A  427   0     A  177   0
C  127   1     B  745   0     C  834   1     B  752   1
A  1209  1     C  154   1     B  723   1     C  1244  1
C  5     1     A  833   1     A  705   1     B  49    1
B  954   1     B  60    0     C  705   1     A  528   1
A  952   1     C  776   1     B  680   1     C  88    1
C  23    1     B  776   1     A  667   1     C  155   1
B  946   1     A  752   1     C  1076  1     A  380   0
B  945   1     C  722   1     A  630   1     B  61    0
C  931   1     B  2     1     B  583   1     A  282   0
A  103   0     C  1036  1     C  599   1     C  17    1
C  910   1     A  760   1     B  563   1     B  347   0
B  907   1     B  896   1     A  544   1     A  404   0
A  8     0     A  895   1     C  525   1     C  740   1
C  11    1     C  446   0     C  522   1     C  254   1
A  868   1     B  774   1     A  500   1     A  27    1
B  842   1     A  268   0     B  505   1     B  505   0
; 
run;









** DESCRIPTION   :code for K-M plot
** MACRO USED    :kmplot 
** INPUT         :the dataset in book
** OUTPUT        :km plot figure
** ASSUMPTIONS   :
**
** MODIFICATION HISTORY:
** MODIFIED BY:
*********************************************************;
 

**get dataset**;
data km1;   
   set ADTTE;
   if TRTA = "A" then trtpn = 1;
   if TRTA = "B" then trtpn = 2;
   if TRTA = "C" then delete;
      pfs_mon = AVAL/30.4375;
run;



     *-----------------------------------------------------*;
     *--Run KM lifetest------------------------------------*;
     *-----------------------------------------------------*;
     **create timelist for patients at risk**;
     proc sort data=km1; by PFS_MON; run;
     data maxpfs_mon; 
        set km1(keep=PFS_MON) end=eof;
        if eof then do;
           do time = 0 to ceil(PFS_MON/2)*2 by 2;
              *put timelist into macro variable for axis**;
              call symputx("_axisy", ceil(PFS_MON/2)*2);
              call symputx("_axisby", 2);
              output;
           end;
        end;
     run; 

     proc sql noprint; 
       select put(max(0,time-0.0000000001),15.10) into :_timelist separated by " "
       from maxpfs_mon
        ;
     quit; 

     **run lifetest**;
     proc sort data=km1; by trtpn ; run;
     ods listing close;
     ods output ProductLimitEstimates = kmptrisk /*use for get atrisk table*/
                Quartiles=kmmed /*use for get lifetest medians*/
                censoredsummary=censinfo; /*use for get censor information*/   
     proc lifetest data=km1 method=KM timelist=&_timelist conftype=loglog outsurv=kmsurv;/*use for get curv*/
         time PFS_MON*CNSR(1);
         strata trtpn;
     run;

data kmsurv(rename=(survival2=survival));
set kmsurv;
retain survival2;
if survival ne . then survival2=survival;
drop survival;



	 *-----------------------------------------------------------*;
     *--------------Caculate all the required stats--------------*;
     *-----------------------------------------------------------*;

      /**Hazard Ratio**/
	  **calculate HR using proc phreg**;
	  proc sort data=km1; by trtpn; run;
      options validvarname=V7; 
      ods output parameterestimates=hratio;
      ods listing close;
          proc phreg data=km1;
             model PFS_MON*CNSR(1)=trtpn / ties=exact alpha=0.05 risklimits; 
          run;
	
      ods listing;

      **format HR as the same with the shell**;
      data hratio2(keep=hratio );
         set hratio(where=(upcase(PARAMETER)="TRTPN"));
         length hratio $200;
         hratio= "Hazard Ratio"||" = "||strip(coalescec(put(hazardratio,6.3),"NE"))||
			                 " ["||coalescec(strip(put(HRLowerCL,6.3)),"NE")||" ; "||
                                   coalescec(strip(put(HRUpperCL,6.3)),"NE")||"]"; 
       run;
 

     /**K-M Medians**/
	**calculate the medians using lifetest**;
     ods listing close;
     ods output Quartiles=kmmed2;    
     proc lifetest data=km1 method=KM conftype=loglog;
         time PFS_MON*CNSR(1);
         strata trtpn;
     run;



     
data  _trt;
input trt $ trtpn;
cards;
0 0
1 1
1 2
;

data kmmed2;
length est lower upper $8;
set kmmed2;
if estimate eq . then est ='NE';
else est=put(estimate,6.3);
if LowerLimit eq . then lower ='NE';
else lower=put(LowerLimit,6.3);
if UpperLimit eq . then upper ='NE';
else upper=put(UpperLimit,6.3);

     **format the medians as the same with the shell**;
     data perc1(keep=trt  trtpn kmmed );
        merge kmmed2(where=(percent = 50 ))
              _trt;
        by  trtpn;
        length kmmed $200;         
        if trt ne "0" then 
                        kmmed=strip(put(trtpn,trtpn.))||" : "||strip(est)||
						" ["|| strip(lower)||"; "||
                              strip(upper)||"]"; 
        else if trt eq "0" then kmmed="Kaplan-Meier Medians [95% C.I.]";
     run;

     /**Censoring Times**/
     proc sort data=censinfo; by  trtpn; run;
     data censinfo2(keep=trt trtpn centime);
        merge censinfo
              _trt;
        by  trtpn;
		if trt in (0 1 2 3 4 );
        if trt ne "0" then centime="    "||strip(put(trtpn,trtpn.))||" (N = "||strip(put(total,3.))||")";
        else centime="Censoring Times ";
     run;

	  /**Number of Events**/
     data events (keep=trt  trtpn evetime);
        merge censinfo
              _trt;
        by  trtpn;
		if trt in (0 1 2 3 4 );
        if trt ne "0" then evetime=strip(put(trtpn,trtpn.))||" (N = "||strip(put(Failed,3.))||")";
        else evetime="No. of events ";
     run;     



     *-----------------------------------------------------------*;
     *--Create annotation dataset Combine all stats information--*;
     *-----------------------------------------------------------*;
     data annotate1(keep=trt trtpn function text x y xsys ysys position angle size line color) ;
         set censinfo2(in=a)
		     events   (in=b)
             hratio2 (in=c)
             perc1    (in=d) 
             kmsurv  (where=(_censor_=1)
                       in=e);
         length function $8 text $200;
          
         /**censor times*/;
         if a then do;
            ***text**;
            xsys="1"; ysys="1"; position="3"; angle=0; size=1; line=1; x=6; function="label";
            text=centime;
            y=100-30-(trtpn*3);
            output;
            **line**;
			if trt ne "0" then do
               function='MOVE'; line=input(trt,3.); y=y+3; x=x; 
                 if trtpn=1 then color="black";
                 if trtpn=2 then color="red";
               output;
               x = x-5;
               function='DRAW' ;
               output;
			end;
            **symbol**;
            if trt ne "0" then do i = 2.5;
               function='SYMBOL'; text="triangle";
               color="black";
               x=x+i;
               output;
            end;
         end;

         /**Number of Events**/;
         if b then do;
            ***text**;
            xsys="1"; ysys="1"; position="3"; angle=0; size=1; line=1; x=6; function="label";
            text=evetime;
            y=100-30-15-(trtpn*3);
            output;
         end;

         /**Hazard ratio**/;
         if c then do;
            **text**;
             xsys="1"; ysys="1"; position="3"; angle=0; size=1; line=1; x=6; function="label";

             text=hratio;
             y=100-30-15-10-3;
             output;
         end;

         /**K-M medians**/;
         if d then do;
            ***text**;
            xsys="1"; ysys="1"; position="3"; angle=0; size=1; line=1; x=6; function="label";
            text=kmmed;
            y=100-30-15-10-15-(trtpn*3);
            output;
         end;

         /**censoring marks**/;
         if e then do;
            ***symbol**;
            xsys="2"; ysys="2"; position="3"; angle=0; size=1; line=1; function="symbol";
            y=survival;
            x=PFS_MON;
            text="triangle";
            output;
         end;
     run; 
    

	 *-----------------------------------------------------------*;
     *--------------create atrisk table -------------------------*;
     *-----------------------------------------------------------*;

	 **time**;
     proc sql noprint;
        create table incpfs_mon as
        select a.time, b.*
        from maxpfs_mon as a
        cross join _trt as b
        order by trt, time;
     quit;
     %let boot=0.2;
    data atrisk(keep=trt function text x y xsys ysys position angle size line newtrt);   
        set kmptrisk(in=a)
            incpfs_mon  (in=b)
            _trt(in=c) end=eof;
        **flip treament to show Trt A first**;
        newtrt=6-trtpn*2;
        length function $8 text $200;
        if a then do;
           xsys="2"; ysys="3"; position="2"; angle=0; size=1.3; line=1; function="label"; x=timelist;
           y=newtrt+(&boot+6);
           text=put(left,3.);
           output;
        end;
        if b then do;
           xsys="2"; ysys="3"; position="2"; angle=0; size=1.3; line=1; function="label";
           x=time;
           y=6+(&boot+6);
           text=put(time,3.);
           output;
        end;     
        if c then do;
           xsys="3"; ysys="3"; position="3"; angle=0; size=1.3; line=1; function="label";
           x=0;
           if trt ne "0" then do;
              y=newtrt+(&boot+6);
              text=strip(put(trtpn,trtpn.));
              output;
           end;
           else do;            
              y=8+(&boot+6);
              text="Number of patients still at risk";
              output;
              y=6+(&boot+6);
              text="Time (Months)";
              output;
           end;
        end;     
     run;

     data annotate;
        set annotate1
            atrisk
            ;
     
     run;





    *------------------------------------------------------------------*;
    *------------Create plot by using goption---------------------------*;
    *------------------------------------------------------------------*; 
    %let sizetitle=0.35; 
    %let sizetext=2;

    ***use goption to set up the graph***;
    options orientation=landscape papersize='ISO A4' nodate nonumber nobyline; 
    goptions  device= SASEMF  
            hsize = 25cm
            vsize = 17cm
            xmax=25cm
            horigin=1.3cm
            horigin=1.3cm
            vorigin=1.3cm
            gunit     = pct
            colors    = (black)  
            ftext="Albany AMT" 
            htext=2;

  **set up the axis**;
      axis1 label  = (h = 2  j = c "Time (Months)")
            offset = (2,2)
            minor  = none
            order  = (0 to &_axisy by &_axisby)
            length = 90
            value  = (h = 2 );
            
      axis2 label  = (h = 2  A = 90 R = 0 " Event- free Probability (%) ")
            offset = (2,2)
            value  = (h = 2 )
            major  = (h = 1 w = 2)
            minor  = none
            order  = ( 0  to 1 by 0.2);

      

  **set up the curve**;
  symbol1 interpol = steplj h = 1 width=2 line=1 color = black value= none;
  symbol2 interpol = steplj h = 1 width=2 line=1 color = red value=none;

  **generate the plot**;
        proc gplot data = kmsurv;
          plot survival * PFS_MON = trtpn / frame 
                haxis  = axis1
                vaxis  = axis2
                anno=annotate
                nolegend;
         run;
        quit;

    ods rtf close;



     proc lifetest data=km1 method=KM conftype=loglog plots=survival;
         time PFS_MON*CNSR(1);
         strata trtpn;
     run;