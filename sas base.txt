options pageno=1;
data inventory;
input idnum 5. @10 price;
cards;
24613    $25.31
;
run;


data sub;
city='new brunswick piscataway';
sub=scan(city,3);

data firstlast;
   input String  $60.;
   First_Word = scan(string, 1);
   Last_Word = scan(string, -1);
   datalines4;
Jack and Jill
& Bob & Carol & Ted & Alice &
Leonardo
! $ % & ( ) * + , - . / ;
;;;;

proc print data=firstlast;
run;

data all;
   length word $20;
   drop string;
   string = ' The quick brown fox jumps over the lazy dog.   ';
   do until(word=' ');
      count+1;
      word = scan(string, count);
      output;
   end;
run;

proc print data=all noobs;
run;

data comma;
   keep count word;
   length word $30;
   string = ',leading, trailing,and multiple,,delimiters,,';
   delim = ',';
   modif = 'mo';
   nwords = countw(string, delim, modif);
   do count = 1 to nwords;
      word = scan(string, count, delim, modif);
      output;
   end;
run;

proc print data=comma noobs;
run;   

options nonumber;
options date;
data a;
a=341231;
b=substr(a,1,7);
c='  sss'!!b;
d=mdy(10,20,1967);
e=mdy('10','20','1967');
f=weekday(d);


data numrecords;
/*length of agent 1 2 3 is 8  */
    infile cards dlm=',' dsd   ;
    input agent1 $ agent2 $ agent3 $;
cards;
jones,,brownjones,spencer,brown
;


data new;
input sale;
total+sale;
cards;
1
2
.
4
5
;


options pageno=1;




data work.condo_ranch;
    infile datalines dsd;
    input style $ @;
    if style = 'CONDO' or style = 'RANCH' then
        input sqfeet bedrooms baths street $ price : dollar10.;
        cards;
RANCH,1250,2,1,Sheppard Avenue,"$64,000"
SPLIT,1190,1,1,Rand Street,"$65,850"
CONDO,1400,2,1.5,Market Street,"80,050"
TWOSTORY,1810,4,3,Garris Street,"$107,250"
RANCH,1500,3,3,Kemble Avenue,"$86,650"
SPLIT,1615,4,3,West Drive,"94,450"
SPLIT,1305,3,1.5,Graham Avenue,"$73,650"        
;

data scores;
   infile datalines dsd;
   input Name : $9. Score1-Score3 Team ~ $25. Div $;
   datalines;
Smith,12,22,46,"Green Hornets, Atlanta",AAA 
Mitchel,23,19,25,"High Volts, Portland",AAA 
Jones,09,17,54,"Vulcans, Las Vegas",AA 
; 

proc print data=scores noobs; 
run;


data male female;
set sashelp.class;
if sex='M' then output male;
else output female;



data class;
set male(in=inm)
female(in=inf);
if inm and inf;

%let path=/folders/myfolders/ecsql193;
libname orion "&path";

proc datasets lib=sashelp;
contents data=class varnum ; 


data group;
    infile cards;
    input name $15. age 2.;
    file "&path";
    put name $15. =5 age 2.;
    cards;
Janice 10
Henri 11
Michael 11
Susan 12
;
run;

data students;
    input name $15. @5 age 2.;
    cards;
Alfr14
Alic13
Barb13a
Caro14
;
data work.homework;
    input name $ age height;
    if age LE 10;
    cards;
John McCloskey 35 71
June Rosesette 10 43
TinekeJones 9 37
  ;  
run;


data _null_;
set class;
file "path";
put sex weight;


data work.flights;
    destination = 'CPH';
    select(destination);
        when('LHR') city = 'London';
        when('CPH') city = 'Copenhgen';
        otherwise;
    end;
run;


data work.staff;
    JobCategory= 'FA';
    JobLevel= '1';
    jobCategory= JobCategory || JobLevel;
run;
data work.test;
    Title = 'A Tale of two Cities, Charles j.Dickens';
    Word = scan(title,7,',  ');
run;

data work.test;
    Author = 'Christie, Agatha';
    First = substr(scan(author,2,' ,'),1,1);
run;

data work.products;
    Product_Number=5461;
    Item = '1001';
    Item_Reference=Item||'/'||Product_Number;
run;


data work.clients;
 
    do while (calls le 6);
        calls + 1;
    end;
run;

data work.test;
    Author = 'Agatha Christie';
    First = substr(scan(author,1,' ,'),1,1);
run;



proc print data=male;
data newbank;
    do year = 1 to 3;
        set male;
        capital + 5000;
    end;
run;




data grocery;
   input Sector $ Manager $ Department $ Sales @@;
   datalines;
se 1 np1 50    se 1 p1 100   se 1 np2 120   se 1 p2 80
se 2 np1 40    se 2 p1 300   se 2 np2 220   se 2 p2 70
nw 3 np1 60    nw 3 p1 600   nw 3 np2 420   nw 3 p2 30
nw 4 np1 45    nw 4 p1 250   nw 4 np2 230   nw 4 p2 73
nw 9 np1 45    nw 9 p1 205   nw 9 np2 420   nw 9 p2 76
sw 5 np1 53    sw 5 p1 130   sw 5 np2 120   sw 5 p2 50
sw 6 np1 40    sw 6 p1 350   sw 6 np2 225   sw 6 p2 80
ne 7 np1 90    ne 7 p1 190   ne 7 np2 420   ne 7 p2 86
ne 8 np1 200   ne 8 p1 300   ne 8 np2 420   ne 8 p2 125
;

proc format ;
   value $sctrfmt 'se' = 'Southeast'
                  'ne' = 'Northeast'
                  'nw' = 'Northwest'
                  'sw' = 'Southwest';

   value $mgrfmt '1' = 'Smith'   '2' = 'Jones'
                 '3' = 'Reveiz'  '4' = 'Brown'
                 '5' = 'Taylor'  '6' = 'Adams'
                 '7' = 'Alomar'  '8' = 'Andrews'
                 '9' = 'Pelfrey';

   value $deptfmt 'np1' = 'Paper'
                  'np2' = 'Canned'
                  'p1'  = 'Meat/Dairy'
                  'p2'  = 'Produce';
run;

options fmtsearch=(proclib);

proc report data=grocery nowd ;

   column manager department sales;

   rbreak after / dol summarize;

   where sector='se';

   format manager $mgrfmt. department $deptfmt.
          sales dollar11.2;

   title 'Sales for the Southeast Sector';
   title2 "for &sysdate";
run;



proc report data=grocery nowd
            colwidth=10
            spacing=5
            headline headskip;

   column manager department sales;

   define manager / order order=formatted format=$mgrfmt.;
   define department / order order=internal format=$deptfmt.;

   define sales / analysis sum format=dollar7.2;

   break after manager / ol
                         summarize
                         skip;

   compute after;
      line 'Total sales for these stores were: '
           sales.sum dollar9.2;
   endcomp;

   where sector='se';

   title 'Sales for the Southeast Sector';
 run;
 
 
 
 
 
 
 proc report data=grocery nowd headline headskip;

   column manager department sales
          sales=salesmin
          sales=salesmax;

   define manager / order
                    order=formatted
                    format=$mgrfmt.
                    'Manager';
   define department    / order
                    order=internal
                    format=$deptfmt.
                    'Department';

   define sales / analysis sum format=dollar7.2 'Sales';

   define salesmin / analysis min noprint;
   define salesmax / analysis max noprint;

   compute after;
      line ' ';
      line @7 53*'-';

      line @7 '| Departmental sales ranged from'
           salesmin dollar7.2  +1 'to' +1 salesmax dollar7.2
           '. |';
      line @7 53*'-';
   endcomp;

   where sector='se';

   title 'Sales for the Southeast Sector';
   title2 "for &sysdate";
run;

data work.test;
    First = 'Ipswich, England';
    City = substr(First,1,7);
    City_Country= City!!'; '!!'England';
    cirycountry=cats(city,'; ','England');
/*     length of cirycountry is 200 */
run;


data work.test;
    Title = 'A Tale of two Cities, Charles j.Dickens';
    Word = scan(title,7,' ,.');
run;


proc contents data=sasuser._all_ nods ;
run;


data work.family;
    input @1 date_of_birth mmddyy10.
           @15 first_name $5.
           @25 age ;
           cards;
01/05/1989    Frank     11
12/25/1987    June      13
01/05/1991    Sally      9
;
run;

proc print data=work.family noobs;
title "dog's home";
run;


data test;
/* default length of char is 8 */
    input animal1 $ animal2 $      
        mlgrams1 mlgrams2;
cards;
hummingbird ostrich 54000.39 90800000.87
;
run;


data work.AreaCodes;
    Phonenumber=3125551212;
    Code='('!!substr(Phonenumber,1,3)!!')';
run;
data money;
    input year quantity;
    total=total+quantity;
    cards;
1901 2
1905 1
1910 6
1925 1
1941 1
;
run;






DATA citypops;
   infile DATALINES FIRSTOBS = 2;
   input city & $12. pop2000 : comma.;
   DATALINES;
City  Yr2000Popn
New York  8,008,278
Los Angeles  3,694,820
Chicago  2,896,016
Houston  1,953,631
Philadelphia  1,517,550
Phoenix  1,321,045
San Antonio  1,144,646
San Diego  1,223,400
Dallas  1,188,580
San Jose  894,943
;
RUN;

PROC PRINT data = citypops;
   title 'The citypops data set';
   format pop2000 comma10.;
RUN;



data demo;
input country & $15.  a b c d e f:comma8. g h;
cards;
Netherlands  12 8 8 76 88 7710 68 1
New Zealand  16 8 13 74 83 7410 66 1
Nigeria  48 17 105 50 28 760 8 3
Norway  12 10 8 76 71 13,820 63 1
Pakistan  43 15 120 50 17 370 8 5
Peru  35 10 77 57 65 1040 12 3
Philippines  32 7 50 64 37 760 15 5
Poland  20 10 17 71 57 4200 53 5
Portugal  14 7 20 71 30 2170 22 2
Romania  15 10 28 71 47 2200 33 6
Senegal  50 17 141 43 42 440 11 4
South Africa  35 14 72 54 56 2450 33 6
Spain  13 7 10 74 71 4800 28 2
Sri Lanka  27 6 34 68 22 330 7 4
Sweden  11 11 7 76 83 12,400 81 1
Switzerland  11 7 8 76 58 16,370 57 1
Syria  47 7 57 64 47 1680 16 7
Thailand  25 6 51 63 17 810 12 4
Togo  45 17 113 47 20 280 15 6
Tunisia  33 10 85 61 52 1270 15 5
Turkey  35 10 110 63 45 1230 14 5
U.S.S.R.  20 10 32 67 64 6350 57 7
United Kingdom  13 12 10 73 76 7050 61 1
United States  16 7 11 75 74 14,070 100 1
Uruguay  18 7 32 67 84 2470 20 4
Venezuela  33 6 37 67 76 4100 25 2
West Germany  10 11 10 74 74 11,420 66 2
Yugoslavia  17 10 32 70 46 2570 23 5
Zaire  45 16 106 50 34 160 10 7
Zambia  48 15 101 51 43 580 12 6
;


data crackman;
input department $ gender $ salary@;
datalines;
market f 6000
market m 5000
market f 5500
market m 8000
market f 6000
market m 7000
sales  f 6000
seles  m 4000
sales  f 6000
seles  m 4000
sales  f 6000
seles  m 4000
;
proc sort data=crackman;
by department gender;
run;
data result;
set crackman;/*1*/
by department gender;
if first.gender then subtotal=salary;/*2*/
else subtotal+salary;/*3*/
if last.gender;/*4*/
run;/*5*/



data weather;
   infile datalines missover;
   input temp1-temp5;
   datalines;
97.9 98.1 98.3
98.6 99.2 99.1 98.5 97.5
96.2 97.3 98.3 97.6 96.5
;


data WORK.GEO;
     infile datalines;
     input City $20.;
     if City='Tulsa' then
     State='OK';
     Region='Central';
     if City='Los Angeles' then
     State='CA';
     Region='Western';
  datalines;
  Tulsa
  Los Angeles
  Bangor
  ;
  run;
  proc print;
  run;
data WORK.GEO;
     infile datalines;
     input City $20.;
     if City='Tulsa' then do;
     State='OK';
     Region='Central';
	 end;
     if City='Los Angeles' then do;
     State='CA';
     Region='Western';
	 end;
  datalines;
  Tulsa
  Los Angeles
  Bangor
  ;
  run;
  proc print;
  run;

  
  data temps;
input day month $ temp@;
datalines;
1 may 75
15 may 70
15 june 80
3 june 76
2 july 85
14 july 89
;
run;
proc sort data=WORK.TEMPS;
     by descending month day;
run;
proc print data=WORK.TEMPS;
run;
DATA two;
   INPUT x y;
   DATALINES;
5  2
3  1
5  6
;run;
PROC PRINT; RUN; 
  data ONE  TWO  OTHER;
     set TWO;
     if X eq 5 then output ONE;
     if Y lt 5 then output TWO;
     output;
  run; 
title'one';
 proc print data=one;run;
   title'two';
  proc print data=two;run;
 title 'other';
  proc print data=other;run;

  
  
  
  
    data FLOWERS;
     infile datalines truncover;
     length
        Type $ 5
        Color $ 11;
     input 
        Type $ 
        Color $;
		cards;
daisyyellow
;
  run;


  	data WORK.TEST;
	     drop City;
	     infile datalines;
	     input
	        Name $ 1-14 /
	        Address $ 1-14 /
	        City $ 1-12 ;
	     if City='New York' then input @1 State $2.;
	     else input;
  datalines;
Joe Conley
123 Main St.
Janesville
WI
Jane Ngyuen
555 Alpha Ave.
New York
NY
Jennifer Jason
666 Mt. Diablo
Eureka
CA
;

  
data one ;
input id char1 $;
cards;
111  A 
158  B   
329  C 
644  D 
;
data two ;
input id char2 $;
cards;
111  E 
538  F   
644  G 
;
  
  data WORK.BOTH;
     set WORK.ONE WORK.TWO;
     by Id;
  run;
