data productsample;
do pickit = 10 to totobs by 10;
set orion.productdim(keep= ProductLine ProductID ProductName SupplierName)
point=pickit  nobs=totobs ;
output;
end;
stop;
run;
proc print data=productsample(obs=5) noobs;
run;
proc print data=orion.totalsalaries ;
proc sort data=orion.totalsalaries out=sorttotsal;
by descending DeptSal;

data highest lowest;
 set sorttotsal(obs=5) end=last;
 output highest;
 if last then do i=totobs to totobs-4 by -1;
 set sorttotsal point=i nobs=totobs;
 output lowest;
 end;
 run;
 proc print data=highest;
 proc print data=lowest;
 
 
data cdimwrepl;
drop i;
do i = 1 to 20;
picked=ceil(ranuni(0)*tot);
set orion.customerdim nobs=tot point=picked;
output;
end;
stop;
run;
proc print data=cdimwrepl;
var CustomerID  CustomerName ;

options msglevel=i;

data customerorders(index= (CustomerID OrderID/ unique));
   set orion.orders;
   DaysToDelivery=DeliveryDate-OrderDate;
run;

proc sql;
drop index OrderID from 
 customerorders;
 
 proc datasets lib=work nolist;
 modify customerorders;
 index create OrDate =(OrderID OrderDate );
 
 
 
 proc contents data=customerorders;



options  msglevel=n;
 
 
 
 data pricelistupdate (index=(ProductID/unique));
 set orion.pricelist ;
 UnitProfit =UnitSalesPrice -UnitCostPrice;
 
 
 
 proc sql;
   insert into pricelistupdate(ProductID, 
                               StartDate,
                               EndDate, 
                               UnitCostPrice,
                               UnitSalesPrice,
                               Factor,
                               UnitProfit)
      values (210200100009, '15FEB2011'd, '31DEC9999'd, 15.50, 34.70, 1.00, 19.20);
quit;
 
 
options msglevel=i;
data allstaff (index=(AgeHired )) ;
set orion.nonsales(rename=(first=firstname last=lastname)) orion.sales;
AgeHired =intck('year',BirthDate ,HireDate,'c');
options msglevel=n;


proc print data=allstaff;
   var EmployeeID BirthDate HireDate AgeHired;
   where AgeHired>30;
run;
options msglevel=n;


options msglevel=I;

*** Example 1;
data rdu;
   set orion.saleshistory;
   if OrderID=1230166613;
run;

*** Example 2;
proc print data=orion.saleshistory;
   where OrderID=1230166613 or ProductID=220200100100;
run;

*** Example 3;
proc print data=orion.saleshistory;
   where ProductGroup ne 'Shoes';
run;

*** Example 4;
proc print data=orion.saleshistory;
   where CustomerID=12727;
run;

**** Example 5;
data saleshistorycopy;
   set orion.saleshistory;
run;

options msglevel=n;  



options msglevel=i;

proc print data=orion.supplier(idxwhere=no obs=5) noobs;
   where SupplierID > 1000;
run;

options msglevel=n;	



data compare;
   drop Month1-Month12 Statistic;
   array mon{12} Month1-Month12;
   if _N_=1 then 
      set orion.retailinformation
         (where=(Statistic='MedianRetailPrice'));
   set orion.retail;
   Month=month(OrderDate);
   MedianRetailPrice=mon{Month};
   format MedianRetailPrice dollar8.2;
run;



data trans;
drop i product21-product24;
array prod {21:24} product21-product24;
do i =1 to 6;
set orion.shoestats;
do productline =21 to 24;
value=prod{productline};
output;
end;
end;
run;




/* data trans; */
/*    drop Product21-Product24; */
/*    array prod{21:24} Product21-Product24; */
/*    set orion.shoestats; */
/*    do ProductLine=21 to 24; */
/*       Value=prod{ProductLine}; */
/*    output; */
/*    end; */
/* run; */




proc sort data=orion.orderfact 
          out=neworderfact (keep=CustomerID OrderType OrderDate
                                 DeliveryDate Quantity);
   where CustomerID in (89, 2550) and 
         year(OrderDate)=2011; 
   by OrderType;
run;		

proc sql;
   title 'Count by Order Type';
   select OrderType, 
          count(*) as count
      from neworderfact
         group by OrderType;
quit;

data all;
   array ordt{*} OrderedDate1-OrderedDate4;
   array deldt{*} DeliveryDate1-DeliveryDate4;
   array q{*} Quantity1 - Quantity4;
   format OrderedDate1-OrderedDate4 
          DeliveryDate1-DeliveryDate4 date9.;
   N=0;  
   do until (last.OrderType);
      set neworderfact;
      by OrderType;
      N+1;
      ordt{N}=OrderDate;
      deldt{N}=DeliveryDate;
      q{N}=Quantity;
   end;
run;         



data customercoupons;
array pct{3,6}_temporary_ (10 	10 	15 	20 	20 	25
 	10 	15 	20 	25 	25 	30	10 	15 	15 	20 	25 	25
) ;
set  orion.orderfact(keep= CustomerID OrderType Quantity) ;
CouponValue=pct{OrderType ,Quantity};

proc print data=customercoupons(obs=5);
title 'The Coupon Value ';
run;
title;


data combine;
array msp {21:24,2} _temporary_ (. ,70.79,
 	173.79 ,	174.40,
 	. ,	. ,	29.65 ,	287.8);
set  orion.shoesales ;
ProductLine =input(substr(ProductID ,1,2),2.);
ProductCategory=input(substr(ProductID ,3,2),2.);
ManufacturerSuggestedPrice=msp{ProductLine,ProductCategory};

proc print data=combine (obs=5);
run;




data warehouses;
   array W{21:22,0:2,0:1} $ 5  _temporary_ 
        ('A2100','A2101','A2110',
         'A2111','A2120','A2121',
         'B2200','B2201','B2210',
         'B2211','B2220','B2221');
   set orion.productlist(keep=ProductID ProductName ProductLevel
      where=(ProductLevel=1));
   ProdID=put(ProductID,12.);
   ProductLine=input(substr
               (ProdID,1,2),2.);
   ProductCategory=input(substr
                   (ProdID,3,2),2.);
   ProductLocID=input(substr
                (ProdID,12,1),1.);
   if ProductLine in (21,22) 
      and ProductCategory<=2 
      and ProductLocID<2;
   Warehouse=W{ProductLine,ProductCategory, 
             ProductLocID};
run;		

data customercoupons;
   drop ot i j Quantity1-Quantity6;
   array pct{3,6} _temporary_;
   if _n_=1 then do i=1 to 3;
      set orion.coupons;
      array quan{6} Quantity1-Quantity6;
      do j=1 to 6;
         pct{i,j}=quan{j};
      end;
   end;
   set orion.orderfact(keep=CustomerID OrderType Quantity);
   CouponValue=pct{OrderType,Quantity};
run;


data combine;
keep ProductID ProductName TotalRetailPrice ManufacturerSuggestedPrice ;
format ManufacturerSuggestedPrice dollar10.2;
array msp {21:24,2} _temporary_;
if _N_=1 then do i=21 to 24;
do j=1 to 2;
set orion.msp;
msp{i,j}=AvgSuggestedRetailPrice;
end;
end;
set orion.shoesales;
productline=input(substr(ProductID,1,2),2.);
productcategory =input(substr(ProductID,3,2),2.);
ManufacturerSuggestedPrice =msp{productline,productcategory};



proc print data=combine(obs=5);
var ManufacturerSuggestedPrice 	ProductID 	ProductName 	TotalRetailPrice;
format ManufacturerSuggestedPrice TotalRetailPrice dollar10.2;



/* data combine; */
/*    array msp{21:24,2} _temporary_ ; */
/*    keep ProductID ProductName TotalRetailPrice  */
/*         ManufacturerSuggestedPrice;  */
/*    format ManufacturerSuggestedPrice dollar8.2; */
/*    if _N_= 1 then do i=1 to All; */
/*       set orion.msp nobs=All;       */
/*          msp{ProdLine,input(substr(put(ProdCatID,4.),3,2),2.)} */
/*              =AvgSuggestedRetailPrice; */
/*    end; */
/*    set orion.shoesales; */
/*    ProdID=put(ProductID,12.); */
/*    ProductLine=input(substr(ProdID,1,2),2.); */
/*    ProductCatID=input(substr(ProdID,3,2),2.); */
/*    ManufacturerSuggestedPrice= */
/*       msp{ProductLine, ProductCatID}; */
/* run; */


data threedim;
   keep ProductID ProductName Warehouse;
   array w{21:24,0:8,0:9} $ 5  _temporary_ ;
   if _n_=1 then do i=1 to all;
      set orion.warehouses nobs=all;
      W{ProductLine,ProductCatID,ProductLocID}=Warehouse;
   end;
   set orion.productlist(keep=ProductID ProductName 
                              ProductLevel where=(ProductLevel=1)); 
   ProdID=put(ProductID,12.);
   ProductLine=input(substr(ProdID,1,2),2.);
   ProductCatID=input(substr(ProdID,3,2),2.);
   ProductLocID=input(substr(ProdID,12,1),1.);
   Warehouse=w{ProductLine, ProductCatID, ProductLocID};
run;

