proc sgplot data=sashelp.class;
 scatter x=weight y=height;
 inset "This is some important information"
 "in the bottom-right corner" /
 position=BottomRight;
 inset ("A"="37" "B"="209" "C"="Value") /
 position=TopLeft border;
run;



ods escapechar='\';
proc sgplot data=sashelp.class;
 reg x=weight y=height / clm cli;
 inset ("Y\{unicode bar}"="62.34"
 "R\{sup '2'}"="0.94"
 "\{unicode alpha}"=".05") /
 position=TopLeft border;
run;
