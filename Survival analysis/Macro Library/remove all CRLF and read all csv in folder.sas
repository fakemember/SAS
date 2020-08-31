*******************************;
*%drive imports all files with specified extension at one time and remove all CRLF if exist. 
*parameter:
*          dir: file directory 
*          ext: extension,csv,xlsx..... 
*          lib: library name  
*output: SAS dataset
*author: Chao Cheng
*******************************;

/* Create sample .csv file containing CR/LF bytes.  '0D'x is the */
/* hexadecimal representation of CR and '0A'x is the hexadecimal */
/* representation of LF.                                         */


/************************** CAUTION ***************************/
/*                                                            */
/* This program UPDATES IN PLACE, create a backup copy before */
/* running.                                                   */
/*                                                            */
/************************** CAUTION ***************************/
                                                           
/* Replace carriage return and linefeed characters inside     */
/* double quotes with a specified character.  This sample     */
/* uses '@' and '$', but any character can be used, including */
/* spaces.  CR/LFs not in double quotes will not be replaced. */


%let repA=' ';                    /* replacement character LF */
%let repD=' ';                    /* replacement character CR */

                          
******MACRO;

%macro CRLFremove(dsnnme=/*raw file in quotes*/);/* use full path of CSV file */
data _null_;
  /* RECFM=N reads the file in binary format. The file consists    */
  /* of a stream of bytes with no record boundaries.  SHAREBUFFERS */
  /* specifies that the FILE statement and the INFILE statement    */
  /* share the same buffer.                                        */
  infile &dsnnme recfm=n sharebuffers;
  file &dsnnme recfm=n;

  /* OPEN is a flag variable used to determine if the CR/LF is within */
  /* double quotes or not.  Retain this value.                        */
  retain open 0;

  input a $char1.;
  /* If the character is a double quote, set OPEN to its opposite value. */
  if a = '"' then open = ^(open);

  /* If the CR or LF is after an open double quote, replace the byte with */
  /* the appropriate value.                                               */
  if open then do;
    if a = '0D'x then put &repD;
    else if a = '0A'x then put &repA;
  end;
run;
%mend CRLFremove;
*%CRLFremove(dsnnme= "Z:\Chao Cheng\2020.08\adverse_event.csv");
    
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

%CRLFremove(dsnnme= "&dir\%qsysfunc(dread(&did,&i))" );

proc import datafile="&dir\%qsysfunc(dread(&did,&i))" out=


%if %index(&outfname,-)>0 %then %do;
&lib..%sysfunc(translate(&outfname,_,-))
%end;
%else %do;
&lib..&outfname
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

%drive(Z:\Chao Cheng\2020.08,csv,work);
