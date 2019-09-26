

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


/* run macros DIF and Explore first */





Data work.temp;
	merge work.EPOP work.epoppct; by date;
	length group $9;

	T=_N_;

	group='         ';
	if date ge '1jan09'd and date lt '1jan11'd then group='2009-2010';
	if date ge '1jan11'd and date lt '1jan14'd then group='2011-2013';
	if date ge '1jan14'd and date lt '1jan17'd then group='2014-2016';
	if date ge '1jan17'd and date lt '1jan20'd then group='2017-2019';

	%dif(EPOPTOTpct,12,EPT);
	%dif(EPOPmen,12,EPM);
	%dif(EPOPwomen,12,EPW);
	%dif(EPOPblack,12,EPB);
	run;

Title1;
Title2 'Print the variable names from the Excel dataset ';
Proc contents data =work.temp ; run;


ods pdf file='d:\EPOP\timeseries_results.pdf';
ODS GRAPHICS on / ATTRPRIORITY=color noborder width=4.5in;  

Title1 'Employment/Population Ratios - Jul 2009 to Jul 2019';
title2 'Both series measured as percentages. ';
	proc sgplot data=work.temp;
	series x=date y=EPOPTOTpct / curvelabel='EPOP total';
	series x=date y=EPOPblackpct  /curvelabel='EPOP black';
	format date year4. ;
	xaxis values=('1jun09'd to '1jul19'd by year); 
	run;

title2 'Both series indexed such that June 2009 EMP/POP = 100. ';
	proc sgplot data=work.temp;
	series x=date y=EPOPTOT / curvelabel='EPOP total';
	series x=date y=EPOPblack  /curvelabel='EPOP black';
	refline '1jan11'd '1jan14'd '1jan17'd /axis=x;
	format date year4. ;
	xaxis values=('1jun09'd to '1jul19'd by year); 
	run;

title2 'Both series measured as percentages. ';
proc sgplot data=temp ; label group='Time Slice';
	vbox EPOPTOTpct / category = group boxwidth=0.50 /* discreteoffset=-0.20 datalabel*/ connect=median ;
	vbox Epopblackpct/ category = group boxwidth=0.50 /* discreteoffset= 0.20 datalabel*/ connect=median ;
	run;
title2 'Both series indexed such that June 2009 EMP/POP = 100. ';
proc sgplot data=temp ; label group='Time Slice';
	vbox EPOPTOT / category = group boxwidth=0.40 discreteoffset=-0.25 connect=median ;
	vbox Epopblack/ category = group boxwidth=0.40 discreteoffset= 0.25 connect=median ;
	run;

title2 'Series indexed such that June 2009 EMP/POP = 100. Series marked PCT are not indexed.';
Proc tabulate data=temp;
	class group;
	var epoptot epopblack  epoptotpct epopblackpct;
	Table ( mean='Central tendency of series (mean)' stddev='Volitility of series (std dev)' cv='Stability of series (CV)')*(epoptot epopblack epoptotpct epopblackpct ) , ( all group='Time Slice');
	run;

	/***********************************************/

%let name_list = EPT EPB;
%explore(12);

/*
data work.temp;
set work.temp;
WMepop=epopwomen/epopmen; /* EPOP Womwn as a porportion to men */
BTepop=epopblack/epoptot; /* EPOP Black as a porportion to total */
/*	%dif(WMEPOP,EPWM);
	%dif(BTEPOP,EPBT);

run;

%let name_list = EPWM EPBT;
%explore;
*/
ods pdf close;




/****************************************************************************/

ods graphics on;

proc corr data=temp;
var lev_epm lev_epw d1logepm d1logepw;
run;



proc arima data=temp;
  identify var=EPOPTOT;
run;

	proc sgplot data=work.temp;
	series x=date y=EPOPTOT / curvelabel='EPOP total';
	series x=date y=EPOPblack  /curvelabel='EPOP black';
	refline '1jan11'd '1jan14'd '1jan17'd /axis=x;
	format date year4. ;
	xaxis values=('1jun09'd to '1jul19'd by year); 
	run;

	proc arima data=temp;
  identify var=EPOPblack;
run;

		proc sgplot data=work.temp;
	series x=date y=d1ept / curvelabel='DIF EPOP total';
	series x=date y=d1epb  /curvelabel='DIF EPOP black';
	refline '1jan11'd '1jan14'd '1jan17'd /axis=x;
	format date year4. ;
	xaxis values=('1jun09'd to '1jul19'd by year); 
	run;

