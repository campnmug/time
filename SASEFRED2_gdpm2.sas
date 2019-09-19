options validvarname=any;
title 'Acquire M2 GDP and Federal Debt Data';
libname _all_ clear;
%let dir = d:\freddata;

libname fred sasefred "&dir"
   	OUTXML=gdpm2
   	XMLMAP="&dir\gdpm2.map"
	FREQ='q'
	start='1981-01-01'
    end='2019-06-01'
/* your 32-character alphanumeric API key goes here. */
   	APIKEY='f9e776bdbf5b5db03e14495e270dc2ca' 
/* IDLIST is comma delimited with no spaces between the single quotes.  */
IDLIST='gdp,m2,GFDEBTN,CPILFENS';
data work.gdpm2;
   	set fred.gdpm2 ;
	length group $9;

	T=_N_;

	 group='         ';
	if date ge '1jan80'd and date lt '1jan90'd then group='1980-1989';
	if date ge '1jan90'd and date lt '1jan00'd then group='1990-1999';
	if date ge '1jan00'd and date lt '1jan09'd then group='2000-2008';
	if date ge '1jan09'd and date lt '1jan11'd then group='2009-2010';
	if date ge '1jan11'd and date lt '1jan14'd then group='2011-2013';
	if date ge '1jan14'd and date lt '1jan17'd then group='2014-2016';
	if date ge '1jan17'd and date lt '1jan20'd then group='2017-2019'; 
	
	%dif(gfdebtn,4,DBT);
	%dif(M2,4,M2);
	%dif(GDP,4,GDP);
	%dif(CPILFENS,4,CPI);

	gfdebtn = gfdebtn/1000;

	m2_GDP = m2/gdp;
	debt_gdp= gfdebtn/gdp;

run;
proc contents data=work.gdpm2; run;
proc print data=work.gdpm2(obs=15); run;

proc autoreg data=gdpm2;
model gdp= /stationarity=(adf=0);
model gdp= /stationarity=(phillips);
model m2= /stationarity=(adf=0);
model m2= /stationarity=(phillips);
model PCTD4m2= /stationarity=(adf=0);
model PCTD4m2= /stationarity=(phillips); 
model gfdebtn= /stationarity=(adf=0);
model gfdebtn= /stationarity=(phillips);
model PCTD4CPI= /stationarity=(adf=0);
model PCTD4CPI= /stationarity=(phillips);
run;
quit;
proc autoreg data=gdpm2;
model m2= /stationarity=(adf=0);
model m2= /stationarity=(adf=4);
run;
quit;
proc arima data=gdpm2;
identify var=m2 stationarity=(adf=4);
run;
quit;
proc arima data=gdpm2;
identify var=d4m2 stationarity=(adf=4);
run;
quit;
proc reg data=gdpm2;
model m2 = d4m2;
model m2 = d4m2 t;
run;
quit;
Title 'Federal Public Debt and the money supply (M2)';
	proc sgplot data=work.gdpm2;
	series x=date y=lev_dbt / curvelabel='Federal Debt' CURVELABELPOS=end lineattrs=(thickness=3px color=red);
	series x=date y=lev_m2  /curvelabel='Money supply' CURVELABELPOS=max y2axis lineattrs=(thickness=3px color=blue);
	format date year4. ;
	xaxis values=('1jan81'd to '1jul19'd by year); 
	run;
ODS GRAPHICS / ATTRPRIORITY=NONE;
Title 'Percent Change from a year ago: Federal Public Debt and the money Supply (M2)';
	proc sgplot data=work.gdpm2;
	styleattrs  datacontrastcolors=(grey brown) datasymbols=(circle circleFilled ) ;
	series x=date y=pctd4dbt ;
	loess x=date y=pctd4dbt / curvelabel='LR Federal Debt'  CURVELABELPOS=max lineattrs=(thickness=5px color=red pattern=1) legendlabel="Loess debt";
	series x=date y=pctd4M2   ;
	loess x=date y=pctd4M2  / curvelabel='LRMoney supply'  CURVELABELPOS=start lineattrs=(thickness=5px color=blue pattern=1) legendlabel="Loess M2";
	format date year4. ;
	xaxis values=('1jan81'd to '1jul19'd by year) ; 
	run;

Title1 'Deflated by GDP: Federal Public Debt and the money Supply (M2)';
title2 '';
	proc sgplot data=work.gdpm2;
	series x=date y=debt_gdp / curvelabel='Debt/gdp';
	loess x=date y=debt_gdp / curvelabel='LR Debt/gdp'  lineattrs=(thickness=3px color=red);
	series x=date y=m2_gdp  /curvelabel='M2/GDP' y2axis ;
	loess x=date y=m2_gdp  /curvelabel='LR M2/GDP' y2axis  lineattrs=(thickness=3px color=blue);
	format date year4. ;
	xaxis values=('1jan81'd to '1jul19'd by year); 
	run;

Title1 'First Differences Federal Public Debt and the money Supply (M2) Q2 2009 to Q2 2019';
title2 '';
	proc sgplot data=work.gdpm2;
	scatter x=m2_gdp y=debt_gdp / group=group;
	loess x=m2_GDP y=debt_gdp ;
	
	run;

title1;
proc corr data=gdpm2;
var lev_dbt lev_m2 d4dbt d4m2 pctd4dbt pctd4m2 CARCdbt CARCm2 CCAR4dbt CCAR4m2 d1dbt d1m2 pctd1dbt pctd1m2 ;
where date gt '01jan1981'd;
run;

proc sort data=gdpm2; by group; run;
proc corr data=gdpm2;
var lev_dbt lev_m2 lev_gdp d4dbt d4m2 d4gdp pctd4dbt pctd4m2 pctd4GDP  ;
where date gt '01jan1981'd;

run;
proc corr data=gdpm2;
var lev_dbt lev_m2 lev_gdp d4dbt d4m2 d4gdp pctd4dbt pctd4m2 pctd4GDP  ;
where date gt '01jan1981'd;
by group;
run;

proc arima data=gdpm2;
identify var=m2 stationarity=(ADF=0);
run;

proc autoreg data=gdpm2;
model lev_dbt= /stationarity=(adf=0);
model lev_m2= /stationarity=(adf=0);
model d4dbt= /stationarity=(adf=0);
model d4m2= /stationarity=(adf=0);
model pctd4dbt= /stationarity=(adf=0);
model pctd4m2= /stationarity=(adf=0);

run;

proc autoreg data=gdpm2;
/*
model lev_m2 = lev_dbt / stationarity=(adf=0);
model lev_dbt = lev_m2 / stationarity=(adf=0); */
model d4m2 = d4dbt / stationarity=(adf=0);
model d4dbt = d4m2 / stationarity=(adf=0);
run;
quit;
