************************************************************************************************;
* Project           : Plot template
*
* Program name      : 3 Arms Consort Diagram.sas
*
* Author            : Chao
*
* Date created      : 09September2020
*
* SAS version       : SAS 9.4
*
* Purpose           : 
*
* Input files       : 
*
* Output files      : 
*
* Program included  :
*
* Macro variables   : 
*
* Macros            : 
*
* Revision History  :
*
* Date        Author      Ref    Revision 
* 
*
**********************************************************************************************;
/*--Utility macros--*/
%macro enrollExcluded(n1=, n2=, n3=, n4=);
	cat ("Excluded (n=", &n1., ").* Not meeting inclusion criteria (n=", &n2., 
		").* Declined to participate (n=", &n3., ").* Other reasons (n=", &n4., ")");
%mend enrollExcluded;

%macro allocation(arm=, n1=, n2=, n3=);
	cat ("Allocated to ", &arm., ". (n=", &n1., 
		").* Received allocated.  drug (n=", &n2., 
		").* Did not receive.  allocated drug (n=", &n3., ")");
%mend allocation;

%macro followup(n1=, n2=, n3=, n4=, n5=);
	cat ("Discontinued drug. (n=", &n1., ") due to:.* Adverse events (n=", &n2., 
		").* Withdrawn (n=", &n3., ").* Death (n=", &n4., ").* Other (n=", &n5., ")");
%mend followup;

%macro analysis(n1=, n2=, n3=, n4=);
	cat ("FAS (n=", &n1., ").* Excluded from FAS.  (n=", &n2., 
		").* Safety set (n=", &n3., ").* Excluded from SS.  (n=", &n4., ")");
%mend analysis;

/*--Compute all the box and link data, given the counts data--*/
%macro consortData (inData=, arms=, outData=);
	/*--Consort diagram Node locations--*/
	data node_info;
		set &inData.;

		/*--Compute node center (x, y)--*/
		select (Row);

			/*--Analysis, Follow-Up and Allocation--*/
			when (5, 4, 3) 
				do;

					/*--Analysis, Follow-Up and Allocation--*/
					select (Col);
						when (1) 
							do;
								ny=(row-1.5)*&rowSpacing;
								nx=&headerWidth/2;
								output;
							end;
						when (2) 
							do;
								ny=(row-1.5)*&rowSpacing;
								nx=&headerWidth+w/2;
								output;
							end;
						when (3) 
							do;
								ny=(row-1.5)*&rowSpacing;
								nx=&headerWidth+1.5*w;
								output;
							end;
						when (4) if &arms > 2 then 
							do;
								ny=(row-1.5)*&rowSpacing;
								nx=&headerWidth+2.5*w;
								output;
							end;
						when (5) if &arms > 3 then 
							do;
								ny=(row-1.5)*&rowSpacing;
								nx=&headerWidth+3.5*w;
								output;
							end;
						otherwise ;
					end;
				end;

			/*--Dummy Row to draw the top arrows from horz line--*/
			when (2) 
				do;

					select (Col);
						when (1) 
							do;
								ny=(row-1)*&rowSpacing-1*&pad;
								nx=&headerWidth/2;
								output;
							end;
						when (2) 
							do;
								ny=(row-1)*&rowSpacing-1*&pad;
								nx=&headerWidth+w/2;
								output;
							end;
						when (3) 
							do;
								ny=(row-1)*&rowSpacing-1*&pad;
								nx=&headerWidth+1.5*w;
								output;
							end;
						when (4) if &arms > 2 then 
							do;
								ny=(row-1)*&rowSpacing-1*&pad;
								nx=&headerWidth+2.5*w;
								output;
							end;
						when (5) if &arms > 3 then 
							do;
								ny=(row-1)*&rowSpacing-1*&pad;
								nx=&headerWidth+3.5*w;
								output;
							end;
						otherwise ;
					end;
				end;

			/*--Enrollment--*/
			when (1) 
				do;

					select (Col);
						when (1) 
							do;
								ny=&yHeader*&rowSpacing;
								nx=&headerWidth/2;
								output;
							end;
						when (4) 
							do;
								ny=&yRandom*&rowSpacing;
								nx=&headerWidth+dx;
								output;
							end;
						when (2) 
							do;
								ny=&yAssess*&rowSpacing;
								nx=&headerWidth+dx;
								output;
							end;
						when (3) 
							do;
								ny=&yExclude*&rowSpacing;
								nx=&headerWidth+(&nColumns-1)*dx+&wf;
								output;
							end;
						otherwise ;
					end;
				end;
			otherwise ;
		end;
	run;

	/*--Consort diagram Node polygon data--*/
	data nodes;
		length vLabel $10 hLabel $200 position $10;
		retain pid 0;
		set node_info;
		nh=h-2*&pad;
		nw=w-2*&pad;
		pid+1;

		/*--Compute node polygons for non-Dummy rows--*/
		if row ne 2 then
			do;

				if col eq 1 then
					do;

						/*--Is a Header--*/
						yf=ny-nh/2;
						xf=nx-nw/2;
						vlabel='';
						output;
						yf=ny-nh/2;
						xf=nx+nw/2;
						vlabel='';
						output;
						yf=ny+nh/2;
						xf=nx+nw/2;
						vlabel='';
						output;
						yf=ny+nh/2;
						xf=nx-nw/2;
						vlabel='';
						output;
						yl=ny;
						xl=nx;
						vlabel=stage;
						output;
					end;
				else
					do;

						/*--Not a Header--*/
						y=ny-nh/2;
						x=nx-nw/2;
						hlabel='';
						output;
						y=ny-nh/2;
						x=nx+nw/2;
						hlabel='';
						output;
						y=ny+nh/2;
						x=nx+nw/2;
						hlabel='';
						output;
						y=ny+nh/2;
						x=nx-nw/2;
						hlabel='';
						output;
						yl=ny;

						/*--set the text for the nodes--*/
						if row=5 then
							do;
								hlabel=%analysis(n1=n1, n2=n2, n3=n3, n4=n4);
								xl=nx-nw/2;
								position='Right';
							end;

						if row=4 then
							do;
								hlabel=%followup(n1=n1, n2=n2, n3=n3, n4=n4, n5=n5);
								xl=nx-nw/2;
								position='Right';
							end;

						if row=3 then
							do;
								hlabel=%allocation(arm=case, n1=n1, n2=n2, n3=n3);
								xl=nx-nw/2;
								position='Right';
							end;

						/*--set the text for the nodes in Enrollment stage--*/
						if row=1 then
							do;

								if col=2 then
									do;
										hlabel=cat ("Assessed for Eligibility (", n1, ")");
										xl=nx;
										position='Center';
									end;

								if col=3 then
									do;
										hlabel=%enrollExcluded(n1=n1, n2=n2, n3=n3, n4=n4);
										xl=nx-nw/2;
										position='Right';
									end;

								if col=4 then
									do;
										hlabel=cat ("Randomized (", n1, ")");
										xl=nx;
										position='Center';
									end;
							end;
						output;
					end;
			end;
	run;

	/*--Reorder node_info by X & Y--*/
	proc sort data=node_info out=nodes_Sorted;
		by col row;
	run;

	/*--Compute the Consort diagram Links between non-Header nodes--*/
	data links;
		keep stage case lid lid2 xlink ylink xlink2 ylink2;
		retain lid 0 xp yp;
		set nodes_Sorted (where=(stage ne 'Enrollment' and case ne 'Header')) 
			end=last;
		by col row;
		lid2=.;

		/*--Upper end of link as "previous" (xp, yp)--*/
		if first.col then
			do;
				nh=h-2*&pad;
				yp=ny+nh/2;
				xp=nx;
			end;

		/*--Bottom end of link, output both ends, and compute "previous"--*/
		else
			do;
				nh=h-2*&pad;
				ylink=yp;
				xlink=xp;
				output;
				ylink=ny-nh/2;
				xlink=nx;
				output;
				yp=ny+nh/2;
				xp=nx;
				lid+1;
			end;

		/*--Create the custom links in the Enrollment stage--*/
		if last then
			do;
				call missing (stage, case, xlink, ylink);
				w=&headerWidth;
				dx=(1-w)/&nColumns;
				call missing (lid2, xlink2, ylink2);

				/*--Assessed to Randomize link--*/
				ny=&yAssess*&rowSpacing;
				nx=&headerWidth+dx;
				h=0.1;
				nh=h-2*&pad;
				ylink=ny+nh/2;
				xlink=nx;
				output;
				ny=&yRandom*&rowSpacing;
				nx=&headerWidth+dx;
				h=0.1;
				nh=h-2*&pad;
				ylink=ny-nh/2;
				xlink=nx;
				output;
				lid+1;

				/*--Horizontal link to Excluded--*/
				ny=&yExclude*&rowSpacing;
				nx=&headerWidth+1*dx;
				w=(&nColumns-1)*dx/2;
				nw=w-2*&pad;
				ylink=ny;
				xlink=nx;
				output;
				ny=&yExclude*&rowSpacing;
				nx=&headerWidth+(&nColumns-1)*dx+&wf;
				w=&wf+(&nColumns-1)*dx/2;
				nw=w-2*&pad;
				ylink=ny;
				xlink=nx-nw/2;
				output;
				lid=.;

				/*--Horizontal link over 4 ARMs--*/
				nx=w+dx/2;
				w=dx;
				lid2=0;
				ylink2=&rowSpacing-&pad;
				xlink2=&headerWidth+dx/2;
				output;
				xlink2=&headerWidth+(&arms-0.5)*dx;
				output;

				/*--Randomize to Horz link--*/
				ny=&yRandom*&rowSpacing;
				nx=&headerWidth+dx;
				h=0.1;
				nh=h-2*&pad;
				lid2=1;
				ylink2=ny+nh/2;
				xlink2=nx;
				output;
				ylink2=&rowSpacing-&pad;
				output;
			end;
	run;

	/*--combine node and link data--*/
	data &outData.;
		set nodes links;
	run;

%mend consortData;

%macro consortDiagram(data=, fillColor=stgb);
	proc sgplot data=&data noborder noautolegend;
		/*--Filled boxes--*/
		polygon id=pid x=xf y=yf / fill outline fillattrs=(color=&fillcolor) 
			lineattrs=graphdatadefault;

		/*--vertical text--*/
		text x=xl y=yl text=vlabel / rotate=90 textattrs=(size=9 color=white);

		/*--Empty boxes--*/
		polygon id=pid x=x y=y / lineattrs=graphdatadefault;

		/*--horizontal text, left aligned--*/
		text x=xl y=yl text=hLabel / splitchar='.' splitpolicy=splitalways 
			position=position;

		/*--Links--*/
		series x=xlink y=ylink / group=lid lineattrs=graphdatadefault 
			arrowheadpos=end arrowheadshape=barbed arrowheadscale=0.4;

		/*--Links without arrow heads--*/
		series x=xlink2 y=ylink2 / group=lid2 lineattrs=graphdatadefault;
		xaxis display=none min=0 max=1 offsetmin=0 offsetmax=0;
		yaxis display=none min=0 max=1 offsetmin=0 offsetmax=0 reverse;
	run;

%mend consortDiagram;

/*--Macro variables for layout--*/ %let rowSpacing=0.25;
%let pad=0.02;
%let headerWidth=0.1;
%let nColumns=4;
%let yAssess=0.2;
%let yRandom=0.7;
%let yExclude=0.4;
%let yHeader=0.5;

proc format;
	value row 5='Analysis' 4='Follow-up' 3='Allocation' 2='Dummy' 1='Enrollment';
	value col 1='Header' 2='Placebo' 3='Arm-1' 4='Arm-2' 5='Arm-3';
run;

/*--Diagram Layout--*/
data layout;
	length Stage $12 case $12;
	format Row row. Col col.;
	input Row Col Stage $ Case $ n1-n5;

	/*--Pad to increase the width of the Exclude box when columns=3--*/
	wf=(4-&nColumns)*0.05;
	call symput("wf", wf);

	/*--Node widths and heights--*/
	h=&rowSpacing;

	if Stage='Dummy' then
		h=2*&pad;
	dx=(1-&headerWidth)/&nColumns;

	select (case);
		when ('Header') w=&headerWidth;
		when ('Randomized', 'Assessed') 
			do;
				w=(&nColumns-1)*dx/2;
				h=0.1;
			end;
		when ('Excluded') 
			do;
				w=wf+(&nColumns-1)*dx/2;
				h=0.2;
			end;
		otherwise w=dx;
	end;

	/*--Update your n1-n5 counts here--*/
	datalines;
1   1   Enrollment  Header        .    .    .   .   . 
1   2   Enrollment  Assessed    445    .    .   .   . 
1   3   Enrollment  Excluded     39   22   14   3   . 
1   4   Enrollment  Randomized  406    .    .   .   . 
2   1   Dummy       Header       .     .    .   .   . 
2   2   Dummy       Placebo      .     .    .   .   . 
2   3   Dummy       ARM-1        .     .    .   .   . 
2   4   Dummy       ARM-2        .     .    .   .   . 
3   1   Allocation  Header       .     .    .   .   . 
3   2   Allocation  Placebo      95   90    5   .   . 
3   3   Allocation  ARM-1       103  103    0   .   . 
3   4   Allocation  ARM-2       105   98    7   .   . 
4   1   Follow-Up   Header       .     .    .   .   . 
4   2   Follow-Up   Placebo      10    2    4   9   5 
4   3   Follow-Up   ARM-1         7    3    2   1   1 
4   4   Follow-Up   ARM-2        11    5    2   1   3 
5   1   Analysis    Header       .     .    .   .   . 
5   2   Analysis    Placebo      89    7   90   6   . 
5   3   Analysis    ARM-1       100    2  103   0   . 
5   4   Analysis    ARM-2        98    7   98   7   . 
;
run;

/*--Create the Diagram data, given the counts data set --*/ %consortData (inData=layout, 
	outData=consort, arms=3);
%let gpath=Z:\Chao Cheng\2020.09;
%let dpi=200;
ods _all_ close;
ods listing gpath="&gpath" image_dpi=&dpi;
ods graphics / reset width=6in height=4in imagename='Consort_3_Arms_4_Col';

/*--Draw the Consort diagram--*/
title 'CONSORT Diagram for Displaying Counts';
%consortDiagram(data=consort, fillColor=darkmagenta);
