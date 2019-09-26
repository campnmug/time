

PROC IMPORT OUT= WORK.EPOP
            DATAFILE= "d:\EPOP\E-POP and U-rates FRED data.xlsx" 
            DBMS=xlsx REPLACE;
     	SHEET='sasdata'; 
	RUN;
PROC IMPORT OUT= WORK.EPOPpct
            DATAFILE= "d:\EPOP\E-POP in percent terms and U-rates FRED data.xlsx" 
            DBMS=xlsx REPLACE;
     	SHEET='sasdata'; 
	RUN;
proc sort data=epop; by date; run;
proc sort data=epoppct; by date; run;

/* DATE EPOPTOT EPOPBLACK EPOPMEN EPOPWOMEN URATE URATEBLASCK URATEWOMEN URATEMEN */

Data work.temp;
	merge work.EPOP work.epoppct; by date;
	length group $9;

	T=_N_;

	group='         ';
	if date ge '1jan09'd and date lt '1jan11'd then group='2009-2010';
	if date ge '1jan11'd and date lt '1jan14'd then group='2011-2013';
	if date ge '1jan14'd and date lt '1jan17'd then group='2014-2016';
	if date ge '1jan17'd and date lt '1jan20'd then group='2017-2019';

	run;

Title1 'Exploring Time Series Data';;
Title2 'Print the variable names from the Excel dataset ';
Proc contents data =work.temp ; run;

ODS GRAPHICS on / ATTRPRIORITY=color noborder width=4.5in; /* Look it up to see what this does */

Title1 'Employment/Population Ratios - Jul 2009 to Jul 2019';
title2 'Both series measured as percentages. ';
	proc sgplot data=work.temp;
	series x=date y=EPOPTOTpct / curvelabel='EPOP total';
	series x=date y=EPOPblackpct  /curvelabel='EPOP black';
	format date year4. ;
	xaxis values=('1jun09'd to '1jul19'd by year); 
	run;
