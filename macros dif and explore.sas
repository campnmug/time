%macro DIF(var,n_obs_per_year, id);

    /* level variable */
	LEV_&id = &var;

	/* id = short abreviation for the variable name */
	/* n_obs_per_year = frequency of the series */
	/* Annual = 1, Monthly = 12, Quarterly =4, Bi-weekly = 26, Weekly=52 */
	/* var = variable name of variable to be manipulated, Y in the examples below */ 

	/* lag variable */
	LAG1&id=lag(&var);
	/* if Y = variable on the RHS, this gives y(t-1) */

	/* lag n_obs_per_year variable */
	LAG&n_obs_per_year&id=lag&n_obs_per_year(&var);
	/* if Y = variable on the RHS, this gives y(t-1) */

	/* Change from one period ago */
	D1&id=dif1(&var);
	/* if y = variable on RHS, this gives y(t)-y(t-1) */

	/* Change from 1 Year ago */
	D&n_obs_per_year&id=dif&n_obs_per_year(&var);
	/* if y = variable on RHS, this gives y(t)-y(t-n) */

	/* percent change in variable, period over period */
	PCTD1&id= ((&var / LAG1&id)-1)*100;
	/* if y = variable on RHS, this gives [y(t)/y(t-1)-1]*100 */

	/* percent change from one year ago, year over year */
	PCTD&n_obs_per_year&id= ((&var / LAG&n_obs_per_year&id)-1)*100;
	/* if y = variable on RHS, this gives [y(t)/y(t-1)-1]*100 */

	/* Compounded Annual Rate of Change */
	CARC&n_obs_per_year&id=(((&var/LAG1&id)**&n_obs_per_year )-1)*100;
	/* if y = variable on RHS, this gives [((y(t)/y(t-1)^n)-1]*100 */

	/* Log of variable*/
	LOG&id=log(&var);
	/* if y = variable on RHS, this gives ln(y) */

	/* Lag of log variable*/
	LAGLOG&id=lag(LOG&id);
	/* if y = variable on RHS, this gives ln(y) */

	/* Continually Compounded Rate of Change */
	CCR&id=(LOG&id-LAGLOG&id)*100;
	/* if y = variable on RHS, this gives lny(t) - lny(t-1) */

	/* Continually Compounded Annual Rate of Change */
	CCAR&id=(LOG&id-LAGLOG&id)*100*&n_obs_per_year;
	/* if y = variable on RHS, this gives lny(t) - lny(t-1) */

%mend;

%macro explore(n);
/* 	source and inspiration
	https://blogs.sas.com/content/sastraining/2015/01/30/sas-authors-tip-getting-the-macro-language-to-perform-a-do-loop-over-a-list-of-values/ */
/*  This macro requires a next_name list set 
	
n=frequency of variables per year
*/


%let var_list = LEV_  D&n  PCTD&n CARC&n CCAR;

%local i next_name;
%local j next_var;

%do i=1 %to %sysfunc(countw(&name_list));
   %let next_name = %scan(&name_list, &i);


   %do j=1 %to %sysfunc(countw(&var_list));
   		%let next_var = %scan(&var_list, &j);


   %** DO whatever needs to be done for &NEXT_NAME;
	Title "Variable &next_var&next_name";

	Proc tabulate data=temp;
			class group;
			var &next_var&next_name;
			Table ( mean='Central tendency of series (mean)' stddev='Volitility of series (std dev)' cv='Stability of series (CV)')
			*(&next_var&next_name )
			, ( all group='Time Slice');
			run;

	proc sgplot data=work.temp;
			loess x=date y=&next_var&next_name ;
			series x=date y=&next_var&next_name ;
			format date year4. ;
			xaxis values=('1jun09'd to '1jul19'd by year); 
			run;

	proc sgplot data=work.temp;
			vbox &next_var&next_name / category = group boxwidth=0.50 connect=median;
			run;
%end; %end;
%mend;

