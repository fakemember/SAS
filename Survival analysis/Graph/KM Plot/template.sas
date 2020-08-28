 proc template;/*obtain the template*/
 source Stat.Lifetest.Graphics.ProductLimitFailure;
 source Stat.Lifetest.Graphics.ProductLimitSurvival;
 run;

proc template;
	define statgraph inset;
		begingraph;
		
		entrytitle 'Freedom from CD-TLR, ITT Population';
		
        layout overlay / xaxisopts=(linearopts=(viewmax=1080 tickvaluelist=(0 90 180 
			270 360 450 540 630 720 810 900 990 1080)) 
			label="Time after Index Procedure (days)") 
			yaxisopts=(linearopts=(tickvaluelist=(0 .1 .2 .3 .4 .5 .6 .7 .8 .9 1) 
			viewmin=0 viewmax=1 tickvalueformat=percent.) label="Freedom from CD-TLR");
		
        stepplot x=time y=survival/group=stratum name='Step';

		scatterplot x=TIMELIST y=survival/ yerrorlower=SDF_LCL yerrorupper=SDF_UCL 
			group=stratum markerattrs=(symbol=CircleFilled size=0.000001) 
			name='Treatment';

		mergedlegend 'Step' 'Treatment';
		
        
        
        innermargin/ ALIGN=bottom;
        /* blockplot x=TIMELIST block=atrisk / display=(label values) class=stratum valuehalign=start; */
		axistable x=TATRISK value=ATRISK / display=(label) valueattrs=(size=7pt) 
			class=stratum;
		endinnermargin;
        
        
        /* create inset */
        layout gridded / columns = 2 border=true
        columngutter = 5px autoalign=(bottomleft); 
        entry "log-rank pvalue";
        entry '0.0003';
        endlayout;

		endlayout;
		endgraph;
	end;
run;


proc lifetest data=sashelp.bmt maxtime=1080 timelist=0 to 1080 by 90 
		plots=survival(atrisk( atrisktickonly maxlen=13)=0 to 1080 by 90 test cl) reduceout outsurv=bmtsurv;
	time t*status(0);
	strata group;
	ods output SurvivalPlot=bmtsurvplot
	CensoredSummary=cs;
run;


data bmtsurv;
	set bmtsurv;
	STRATUMNUM=put(STRATUM, 1.);
	drop STRATUM;
run;

data bmtsurvplot;
	set bmtsurvplot;
	STRATUMNUM_=put(STRATUMNUM, 1.);
	t=time;
	rename STRATUMNUM_=STRATUMNUM;
	drop STRATUMNUM;
run;

data kmdata;
	merge bmtsurvplot bmtsurv;
	by STRATUMNUM T;
run;

proc sgrender data=kmdata template=inset;
run;