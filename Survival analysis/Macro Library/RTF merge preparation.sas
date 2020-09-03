*******************************;
*%rtfmerger modifies all RTF files at one time and output to a specified folder to prepare for VBA merge
*parameter:
*          dir: file directory 
*          outdir: output file directory
*          ext: RTF 
*output: RTF files
*author: Chao Cheng
*******************************;
*options mprint symbolgen mlogic;

%macro rtfmerger(dir,outdir,ext); 
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

%put %qsysfunc(dread(&did,&i)); 
 
data _null_;
infile "&dir\%qsysfunc(dread(&did,&i))"  lrecl=32767 length = lg;
file "&outdir\%qsysfunc(dread(&did,&i))"  lrecl=32767;
input line $varying32767. lg;
line = tranwrd(line, '{ NUMPAGES', '{ SECTIONPAGES');
line = tranwrd(line, '\sectd', '\pard');
 new_lg = length(line);
put line $varying32767. new_lg;
run;  
       %end; 
      %end;  

    %end;
      %end;
  %else %put &dir cannot be opened.;
  %let rc=%sysfunc(dclose(&did));      
             
 %mend rtfmerger;
 
*%rtfmerger(Z:\Chao Cheng\2020.09,Z:\Chao Cheng\2020.09\VBA prepare,rtf);

