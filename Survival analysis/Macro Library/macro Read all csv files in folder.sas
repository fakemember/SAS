*******************************
*%drive imports all files with specified extension at one time.
*parameter:
*          dir: file directory 
*          ext: extension,csv,xlsx..... 
*          lib: library name  
*output: SAS dataset
*author: Chao Cheng
*******************************


*options mprint symbolgen mlogic;

%macro drive(dir,ext,lib); 
   %local cnt filrf rc did memcnt name; 
   %let cnt=0;          

   %let filrf=mydir;    
   %let rc=%sysfunc(filename(filrf,&dir)); 
   %let did=%sysfunc(dopen(&filrf));
    %if &did ne 0 %then %do;   
   %let memcnt=%sysfunc(dnum(&did));    

    %do i=1 %to &memcnt;              
                       
      %let name=%qscan(%qsysfunc(dread(&did,&i)),-1,.);                    
                    
      %if %qupcase(%qsysfunc(dread(&did,&i))) ne %qupcase(&name) %then %do;
       %if %superq(ext) = %superq(name) %then %do;                         
          %let cnt=%eval(&cnt+1);
%let outfname= %sysfunc(compress(%scan(%qsysfunc(dread(&did,&i)),1,'.')));

%if %length(&outfname)>30 %then %let outfname=%substr(&outfname,%length(&outfname)-30);

%put %qsysfunc(dread(&did,&i));  
          proc import datafile="&dir\%qsysfunc(dread(&did,&i))" out=&lib..
%if %index(&outfname,-)>0 %then %do;
 %sysfunc(translate(&outfname,_,-))
 %end;
%else %do;
&outfname
%end;
             dbms=&ext replace;
%if &ext=csv %then %do;             
guessingrows=max; 
%end;
          run;          
       %end; 
      %end;  

    %end;
      %end;
  %else %put &dir cannot be opened.;
  %let rc=%sysfunc(dclose(&did));      
             
 %mend drive;
 
*%drive(Z:\Chao Cheng\2020.08,csv,impdata);
