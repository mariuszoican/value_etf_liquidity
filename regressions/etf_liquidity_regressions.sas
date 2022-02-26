*Define libraries;

%let rc = %sysfunc(dlgcdir("D:\ResearchProjects\kpz_etfliquidity\regressions")); *set to current folder with code and output;

libname f ".\sas_panels"; *library with sas datasets needed to reproduce this code 
(CHANGE THIS PATH TO WHERE YOU SAVE THE DATASETS);


options obs=max mprint sortsize=0 notes; ods _all_ close;


****************************************************************************************************************************
HOW TO RUN THIS CODE 


1. SAVE THE DATASETS ATTACHED TO THE FOLDER UNDER FILE PATH SPECIFIED ABOVE (e.g., libname f "D:\ResearchProjects\kpz_etfliquidity\regressions")
2. CLICK "RUN"
;







*******************************************************************************************************************************
TABLE "Relation between ETF fees, liquidity, and trading activity in the cross-section"

*This code runs cross-sectional regressions using the 137 ETFs that compete in tracking the same index as at least one other ETF. 
The dependent variable is the ETF's fee (MER or net expense ratio) in basis points. The unit of observation is ETF.
All variables are calculated as an average per ETF in the year 2020 from daily data.

*******************************************************************************************************************************;


*Model 1;
ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.reg_cs; class index_id ; cluster index_id ;
		model mer_bps = spread_bps_crsp  index_id/ solution ADJRSQ;
run;


*Model 2;
ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=f.reg_cs; class index_id ; cluster index_id ;
		model mer_bps = spread_bps_crsp tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id/ solution ADJRSQ;
run;



*Model 3;

	ods output ParameterEstimates=temp3 fitstatistics=fit3;
	proc surveyreg data=f.reg_cs; class index_id ; cluster index_id ;
		model mer_bps = logDvol index_id / solution ADJRSQ;
	run;

*Model 4;
	ods output ParameterEstimates=temp4 fitstatistics=fit4;
	proc surveyreg data=f.reg_cs; class index_id ; cluster index_id ;
		model mer_bps = logDvol  tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id / solution ADJRSQ;
	run;



*Model 5;
	ods output ParameterEstimates=temp5 fitstatistics=fit5;
	proc surveyreg data=f.reg_cs; class index_id ; cluster index_id ;
		model mer_bps = turnover_frac index_id / solution ADJRSQ;
	run;


*Model 6;
	ods output ParameterEstimates=temp6 fitstatistics=fit6;
	proc surveyreg data=f.reg_cs; class index_id ; cluster index_id ;
		model mer_bps = turnover_frac tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id / solution ADJRSQ;
	run;

	
*Model 7;

	ods output ParameterEstimates=temp7 fitstatistics=fit7;
	proc surveyreg data=f.reg_cs; class index_id ; cluster index_id ;
		model mer_bps =mkt_share index_id / solution ADJRSQ;
	run;

*Model 8;
	ods output ParameterEstimates=temp8 fitstatistics=fit8;
	proc surveyreg data=f.reg_cs; class index_id ; cluster index_id ;
		model mer_bps = mkt_share tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id / solution ADJRSQ;
	run;

	
****************************************************************************************************************************
*Preparing Latex output for the TABLE "Relation between ETF fees, liquidity, and trading activity in the cross-section"

*This code takes regression output from sas files temp1-temp8 (with regression coefficients) and files fit1-fit8(with AdjRsq),
 and combines them into a file that we output into txt and paste into Latex  to generate TABLE "Relation between ETF fees, 
 liquidity, and trading activity in the cross-section";
	
****************************************************************************************************************************


*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1(rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
		 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;




*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;

*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
		 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;


*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
		 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;




*Model 5;
data temp_5 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp5 fit5 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_5(keep=Parameter estimate5 tValue5 probt5) ;
	  set temp_5(rename=(estimate=estimate5 tValue=tValue5 probt=probt5));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;


*Model 6;
data temp_6 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp6 fit6 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_6(keep=Parameter estimate6 tValue6 probt6) ;
	  set temp_6(rename=(estimate=estimate6 tValue=tValue6 probt=probt6));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;

	  


	  *Model 7;
data temp_7 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp7 fit7 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_7(keep=Parameter estimate7 tValue7 probt7) ;
	  set temp_7(rename=(estimate=estimate7 tValue=tValue7 probt=probt7));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;



	  *Model 8;
data temp_8 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp8 fit8 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_8(keep=Parameter estimate8 tValue8 probt8) ;
	  set temp_8(rename=(estimate=estimate8 tValue=tValue8 probt=probt8));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;



proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;
proc sort data=temp_5; by parameter; run;
proc sort data=temp_6; by parameter; run;
proc sort data=temp_7; by parameter; run;
proc sort data=temp_8; by parameter; run;



data temp; merge temp_1 temp_2 temp_3 temp_4 temp_5 temp_6 temp_7 temp_8 ; by parameter; run;


*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);
	 pvalue5 = put(probt5,best32.);
	 pvalue6 = put(probt6,best32.);
	 pvalue7 = put(probt7,best32.);
	 pvalue8 = put(probt8,best32.);



if parameter="Intercept" then parameter="A_Intercept";
if parameter="spread_bps_crsp" then parameter="B_spread_bps";
if parameter="logDvol" then parameter="C_logDvol";
if parameter="turnover_frac" then parameter="D_turnover_frac";
if parameter="mkt_share" then parameter="E_mkt_share";
if parameter="tr_error_bps" then parameter="F_tr_error";
if parameter="perf_drag_bps" then parameter="G_perf_drag_bps";
if parameter="d_UIT" then parameter="H_D_uit";
if parameter="lend_byAUM_bps" then parameter="I_lend";
if parameter="marketing_fee_bps" then parameter="J_mktng";
if parameter="AdjR2" then parameter="K_AdjR2";

run;
proc sort data=temp_v1_; by parameter; run;



/* Create Latex-specific file and convert into txt;*/

data  table2;
set temp_v1_;
/* an array is used to use the various variables,
for example aCOEF(3) refers to variable COEF3
this is helpful in do-while loops, where a counter is used
(in this case I is used, which counts from 1 till 9)
*/
array aest(1:8) estimate1-estimate8;
array atvalue(1:8) tValue1-tValue8;
array apvalue(1:8) pvalue1-pvalue8;
run;


/* create variables latexCoef and latexSign holding the latex markup;*/
data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:8) estimate1-estimate8;
array atvalue(1:8) tValue1-tValue8;
array apvalue(1:8) pvalue1-pvalue8;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 8;

if apvalue(i)=. then apvalue(i)=" ";
if atvalue(i)=. then atvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

/* this would be the place to also add a symbol for significance at 10% */		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;

if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="Relative spread";
else if _NAME_="latexCoef" and famid=3 then col0="Log dollar volume";
else if _NAME_="latexCoef" and famid=4 then col0="Turnover";
else if _NAME_="latexCoef" and famid=5 then col0="Market share";
else if _NAME_="latexCoef" and famid=6 then col0="Tracking error";
else if _NAME_="latexCoef" and famid=7 then col0="Performance drag";
else if _NAME_="latexCoef" and famid=8 then col0="$D_\text{UIT}$";
else if _NAME_="latexCoef" and famid=9 then col0="Lending income";
else if _NAME_="latexCoef" and famid=10 then col0="Marketing expenses";
else if _NAME_="latexCoef" and famid=11 then col0="Adjusted $R^2$";



else col0=" ";

if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";


run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;


proc export data=table6 outfile=".\output\Table1_CrossSection.txt" dbms=tab replace;
putnames=no;
run;



*******************************************************************************************************************************
TABLE "Relation between ETF fees, liquidity, and trading activity in panel regressions"

This table reports results of panel regressions using the 137 ETFs that compete in tracking the same index as at least one other ETF. 
The dependent variable is the ETF's fee (MER or net expense ratio) in basis points. The unit of observation is ETF-year-month.
All variables are calculated from daily data as an average per ETF-month. The period covered is 2016 -- 2020.

*******************************************************************************************************************************;




*Model 1;
ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.reg_panel; class index_id yearmonth; cluster index_id yearmonth;
		model mer_bps = spread_bps_crsp  index_id yearmonth/ solution ADJRSQ;
run;


*Model 2;
ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=f.reg_panel; class index_id yearmonth; cluster index_id yearmonth;
		model mer_bps = spread_bps_crsp  tr_error_bps  perf_drag_bps d_UIT  marketing_fee_bps lend_byAUM_bps  index_id yearmonth/ solution ADJRSQ;
run;


*Model 3;
ods output ParameterEstimates=temp3 fitstatistics=fit3;
	proc surveyreg data=f.reg_panel; class index_id yearmonth; cluster index_id yearmonth;
		model mer_bps = logDvol index_id yearmonth/ solution ADJRSQ;
	run;

*Model 4;
ods output ParameterEstimates=temp4 fitstatistics=fit4;
	proc surveyreg data=f.reg_panel; class index_id yearmonth; cluster index_id yearmonth;
		model mer_bps = logDvol  tr_error_bps  perf_drag_bps d_UIT  marketing_fee_bps lend_byAUM_bps  index_id yearmonth/ solution ADJRSQ;
run;


*Model 5;
ods output ParameterEstimates=temp5 fitstatistics=fit5;
	proc surveyreg data=f.reg_panel; class index_id yearmonth; cluster index_id yearmonth ;
		model mer_bps = turnover_frac index_id yearmonth/ solution ADJRSQ;
	run;

*Model 6;
ods output ParameterEstimates=temp6 fitstatistics=fit6;
	proc surveyreg data=f.reg_panel; class index_id yearmonth ; cluster index_id yearmonth ;
		model mer_bps = turnover_frac  tr_error_bps  perf_drag_bps d_UIT marketing_fee_bps lend_byAUM_bps index_id yearmonth/ solution ADJRSQ;
run;


*Model 7;
ods output ParameterEstimates=temp7 fitstatistics=fit7;
	proc surveyreg data=f.reg_panel; class index_id yearmonth; cluster index_id yearmonth ;
		model mer_bps = mkt_share index_id yearmonth/ solution ADJRSQ;
	run;

*Model 8;
ods output ParameterEstimates=temp8 fitstatistics=fit8;
	proc surveyreg data=f.reg_panel; class index_id yearmonth ; cluster index_id yearmonth ;
		model mer_bps = mkt_share  tr_error_bps  perf_drag_bps d_UIT marketing_fee_bps lend_byAUM_bps  index_id yearmonth/ solution ADJRSQ;
run;


****************************************************************************************************************************
*Preparing Latex output for the TABLE "Relation between ETF fees, liquidity, and trading activity in panel regressions"

*This code takes regression output from sas files temp1-temp8 (with regression coefficients) and files fit1-fit8(with AdjRsq),
 and combines them into a file that we output into txt and paste into Latex  to generate TABLE "Relation between ETF fees, 
 liquidity, and trading activity in panel regressions";
****************************************************************************************************************************

*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1(rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
		 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;




*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;

*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
		 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;


*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
		 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;




*Model 5;
data temp_5 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp5 fit5 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_5(keep=Parameter estimate5 tValue5 probt5) ;
	  set temp_5(rename=(estimate=estimate5 tValue=tValue5 probt=probt5));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;


*Model 6;
data temp_6 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp6 fit6 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_6(keep=Parameter estimate6 tValue6 probt6) ;
	  set temp_6(rename=(estimate=estimate6 tValue=tValue6 probt=probt6));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;

	  


	  *Model 7;
data temp_7 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp7 fit7 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_7(keep=Parameter estimate7 tValue7 probt7) ;
	  set temp_7(rename=(estimate=estimate7 tValue=tValue7 probt=probt7));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;



	  *Model 8;
data temp_8 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp8 fit8 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_8(keep=Parameter estimate8 tValue8 probt8) ;
	  set temp_8(rename=(estimate=estimate8 tValue=tValue8 probt=probt8));
	 	where parameter in ("Intercept","spread_bps_crsp", "logDvol", "turnover_frac", "tr_error_bps", "perf_drag_bps", "d_UIT", "mkt_share",
		"lend_byAUM_bps", "marketing_fee_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;



proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;
proc sort data=temp_5; by parameter; run;
proc sort data=temp_6; by parameter; run;
proc sort data=temp_7; by parameter; run;
proc sort data=temp_8; by parameter; run;



data temp; merge temp_1 temp_2 temp_3 temp_4 temp_5 temp_6 temp_7 temp_8 ; by parameter; run;


*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);
	 pvalue5 = put(probt5,best32.);
	 pvalue6 = put(probt6,best32.);
	 pvalue7 = put(probt7,best32.);
	 pvalue8 = put(probt8,best32.);



if parameter="Intercept" then parameter="A_Intercept";
if parameter="spread_bps_crsp" then parameter="B_spread_bps";
if parameter="logDvol" then parameter="C_logDvol";
if parameter="turnover_frac" then parameter="D_turnover_frac";
if parameter="mkt_share" then parameter="E_mkt_share";
if parameter="tr_error_bps" then parameter="F_tr_error";
if parameter="perf_drag_bps" then parameter="G_perf_drag_bps";
if parameter="d_UIT" then parameter="H_D_uit";
if parameter="lend_byAUM_bps" then parameter="I_lend";
if parameter="marketing_fee_bps" then parameter="J_mktng";
if parameter="AdjR2" then parameter="K_AdjR2";
run;
proc sort data=temp_v1_; by parameter; run;



/* Create Latex-specific file and convert into txt;*/

data  table2;
set temp_v1_;
/* an array is used to use the various variables,
for example aCOEF(3) refers to variable COEF3
this is helpful in do-while loops, where a counter is used
(in this case I is used, which counts from 1 till 9)
*/
array aest(1:8) estimate1-estimate8;
array atvalue(1:8) tValue1-tValue8;
array apvalue(1:8) pvalue1-pvalue8;
run;


/* create variables latexCoef and latexSign holding the latex markup;*/
data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:8) estimate1-estimate8;
array atvalue(1:8) tValue1-tValue8;
array apvalue(1:8) pvalue1-pvalue8;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 8;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

/* this would be the place to also add a symbol for significance at 10% */		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="Relative spread";
else if _NAME_="latexCoef" and famid=3 then col0="Log dollar volume";
else if _NAME_="latexCoef" and famid=4 then col0="Turnover";
else if _NAME_="latexCoef" and famid=5 then col0="Market share";
else if _NAME_="latexCoef" and famid=6 then col0="Tracking error";
else if _NAME_="latexCoef" and famid=7 then col0="Performance drag";
else if _NAME_="latexCoef" and famid=8 then col0="$D_\text{UIT}$";
else if _NAME_="latexCoef" and famid=9 then col0="Lending income";
else if _NAME_="latexCoef" and famid=10 then col0="Marketing expenses";
else if _NAME_="latexCoef" and famid=11 then col0="Adjusted $R^2$";



else col0=" ";

if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";


run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;


proc export data=table6 outfile='.\output\Table2_Panel.txt' dbms=tab replace;
putnames=no;
run;



*******************************************************************************************************************************
TABLE "Testing whether first-mover ETFs attract short-term investors"

This table reports results of panel regressions using the 137 ETFs that compete in tracking the same index as at least one other
ETF. The dependent variable is a measure of investor holding horizon: in models (1)-(3) we consider average trading urgency for 
each ETF and in models (4)-(6) we take ETF turnover as a proxy for urgency. Trading urgency is the average flow-return sensitivity
across managers holding a given ETF in a given quarter. Turnover (as a fraction) is the annualized ratio of daily dollar volume in 
the ETF's secondary market and assets under management (AUM). The unit of observation is ETF-year-month.
The period covered is 2016 -- 2020. 
*******************************************************************************************************************************;







*Model 1;
ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.reg_panel_hetero; class index_id yearmonth ; cluster index_id yearmonth;
		model urgency_mean = d_firstETF  yearmonth index_id/ solution ADJRSQ;
run;

*Model 2;
ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=f.reg_panel_hetero; class index_id yearmonth ; cluster index_id yearmonth;
		model urgency_mean = d_firstETF tr_error_bps  perf_drag_bps  D_uit marketing_fee_bps lend_byAUM_bps yearmonth index_id/ solution ADJRSQ;
run;


*Model 3;
ods output ParameterEstimates=temp3 fitstatistics=fit3;
proc surveyreg data=f.reg_panel_hetero; class index_id yearmonth ; cluster index_id yearmonth;
		model urgency_mean = sequence_of_entry tr_error_bps  perf_drag_bps  D_uit marketing_fee_bps lend_byAUM_bps yearmonth index_id/ solution ADJRSQ;
run;


*Model 4;
ods output ParameterEstimates=temp4 fitstatistics=fit4;
proc surveyreg data=f.reg_panel_hetero; class index_id yearmonth ; cluster index_id yearmonth;
		model turnover_frac = d_firstETF  yearmonth index_id/ solution ADJRSQ;
run;


*Model 5;
ods output ParameterEstimates=temp5 fitstatistics=fit5;
proc surveyreg data=f.reg_panel_hetero; class index_id yearmonth ; cluster index_id yearmonth;
		model turnover_frac = d_firstETF tr_error_bps  perf_drag_bps  D_uit marketing_fee_bps lend_byAUM_bps  yearmonth index_id/ solution ADJRSQ;
run;


*Model 6;
ods output ParameterEstimates=temp6 fitstatistics=fit6;
proc surveyreg data=f.reg_panel_hetero; class index_id yearmonth ; cluster index_id yearmonth;
		model turnover_frac = sequence_of_entry tr_error_bps  perf_drag_bps  D_uit marketing_fee_bps lend_byAUM_bps yearmonth index_id/ solution ADJRSQ;
run;





****************************************************************************************************************************
*Preparing Latex output for the TABLE "Testing whether first-mover ETFs attract short-term investors"

*This code takes regression output from sas files temp1-temp6 (with regression coefficients) and files fit1-fit6(with AdjRsq),
 and combines them into a file that we output into txt and paste into Latex  to generate TABLE 
 "Testing whether first-mover ETFs attract short-term investors";
****************************************************************************************************************************


*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1(rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
	where parameter in ("Intercept","d_firstETF", "sequence_of_entry", "tr_error_bps", "perf_drag_bps", "d_UIT",
            "marketing_fee_bps", "lend_byAUM_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;





*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
	  where parameter in ("Intercept","d_firstETF", "sequence_of_entry", "tr_error_bps", "perf_drag_bps", "d_UIT",
            "marketing_fee_bps", "lend_byAUM_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;


*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
	 	where parameter in ("Intercept","d_firstETF", "sequence_of_entry", "tr_error_bps", "perf_drag_bps", "d_UIT",
            "marketing_fee_bps", "lend_byAUM_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;



*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
	where parameter in ("Intercept","d_firstETF", "sequence_of_entry", "tr_error_bps", "perf_drag_bps", "d_UIT",
            "marketing_fee_bps", "lend_byAUM_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;





*Model 5;
data temp_5 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp5 fit5 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_5(keep=Parameter estimate5 tValue5 probt5) ;
	  set temp_5(rename=(estimate=estimate5 tValue=tValue5 probt=probt5));
	  	where parameter in ("Intercept","d_firstETF", "sequence_of_entry", "tr_error_bps", "perf_drag_bps", "d_UIT",
            "marketing_fee_bps", "lend_byAUM_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;



*Model 6;
data temp_6 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp6 fit6 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_6(keep=Parameter estimate6 tValue6 probt6) ;
	  set temp_6(rename=(estimate=estimate6 tValue=tValue6 probt=probt6));
	  where parameter in ("Intercept","d_firstETF", "sequence_of_entry", "tr_error_bps", "perf_drag_bps", "d_UIT",
            "marketing_fee_bps", "lend_byAUM_bps", "AdjR2"); 
	  if missing(parameter) then delete; run;




proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;
proc sort data=temp_5; by parameter; run;
proc sort data=temp_6; by parameter; run;



data temp; merge temp_1 temp_2 temp_3 temp_4 temp_5 temp_6; by parameter; run;


*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);
	 pvalue5 = put(probt5,best32.);
	 pvalue6 = put(probt6,best32.);




if parameter="Intercept" then parameter="A_Intercept";
if parameter="d_firstETF" then parameter="B_d_firstETF";
if parameter="sequence_of_entry" then parameter="C_sequence_of_entry";
if parameter="tr_error_bps" then parameter="D_tr_error_bps";
if parameter="perf_drag_bps" then parameter="E_perf_drag_bps";
if parameter="d_UIT" then parameter="F_D_uit";
if parameter="lend_byAUM_bps" then parameter="G_lend_byAUM_bps";
if parameter="marketing_fee_bps" then parameter="H_mktng";
if parameter="AdjR2" then parameter="K_AdjR2";

run;
proc sort data=temp_v1_; by parameter; run;



/* Create Latex-specific file and convert into txt;*/

data  table2;
set temp_v1_;
/* an array is used to use the various variables,
for example aCOEF(3) refers to variable COEF3
this is helpful in do-while loops, where a counter is used
(in this case I is used, which counts from 1 till 9)
*/
array aest(1:6) estimate1-estimate6;
array atvalue(1:6) tValue1-tValue6;
array apvalue(1:6) pvalue1-pvalue6;
run;


/* create variables latexCoef and latexSign holding the latex markup;*/
data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:6) estimate1-estimate6;
array atvalue(1:6) tValue1-tValue6;
array apvalue(1:6) pvalue1-pvalue6;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 6;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

/* this would be the place to also add a symbol for significance at 10% */		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="First-ETF dummy";
else if _NAME_="latexCoef" and famid=3 then col0="ETF sequence of entry";
else if _NAME_="latexCoef" and famid=4 then col0="Tracking error";
else if _NAME_="latexCoef" and famid=5 then col0="Performance drag";
else if _NAME_="latexCoef" and famid=6 then col0="$D_\text{UIT}$";
else if _NAME_="latexCoef" and famid=7 then col0="Lending income";
else if _NAME_="latexCoef" and famid=8 then col0="Marketing expenses";
else if _NAME_="latexCoef" and famid=9 then col0="Adjusted $R^2$";



else col0=" ";

if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";


run;
data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;

proc export data=table6 outfile='.\output\Table3_Urgency.txt' dbms=tab replace;
putnames=no;
run;







*******************************************************************************************************************************
TABLE "First-mover advantage OLS tests"

This table reports results of cross-sectional regressions using the 137 ETFs that compete in the same index as at least one other ETF. 
The dependent variables in the regressions are (1) ETF fee (MER or net expense ratio) in basis points,
(2) Relative bid-ask spread (in basis points), (3) Log dollar volume, (4) Turnover as a fraction (the annualized ratio of daily dollar 
volume in the ETF's secondary market and assets under management, AUM), (5) Log profitability (AUM times MER), (6) market share as a 
fraction (AUM of the ETF divided by the total AUM of all ETFs tracking the given index). ll variables are calculated from daily 
data and averaged per ETF during the year 2020. The unit of observation is ETF.
*******************************************************************************************************************************;



*Model 1;

ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model mer_bps = d_firstETF     tr_error_bps  perf_drag_bps  D_uit lend_byAUM_bps marketing_fee_bps index_id  / solution ADJRSQ;
run;


*Model 2;

ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model spread_bps_crsp = d_firstETF tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id  / solution ADJRSQ;
run;



*Model 3;
ods output ParameterEstimates=temp3 fitstatistics=fit3;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model logDvol = d_firstETF   tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id / solution ADJRSQ;
run;



*Model 4;
ods output ParameterEstimates=temp4 fitstatistics=fit4;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model Turnover_frac = d_firstETF   tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id / solution ADJRSQ;
run;


*Model 5;
ods output ParameterEstimates=temp5 fitstatistics=fit5;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model logETFProfit = d_firstETF   tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id / solution ADJRSQ;
run;


*Model 6;
ods output ParameterEstimates=temp6 fitstatistics=fit6;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model mkt_share= d_firstETF   tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id / solution ADJRSQ;
run;




****************************************************************************************************************************
*Preparing Latex output for the TABLE "First-mover advantage OLS tests"

*This code takes regression output from sas files temp1-temp6 (with regression coefficients) and files fit1-fit6(with AdjRsq),
 and combines them into a file that we output into txt and paste into Latex  to generate TABLE 
 "First-mover advantage OLS tests";
****************************************************************************************************************************



*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps",  "AdjR2"); 
	  if missing(parameter) then delete; run;




*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps",  "AdjR2"); 
	  if missing(parameter) then delete; run;


*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps",  "AdjR2"); 
	  if missing(parameter) then delete; run;

*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps",  "AdjR2"); 
	  if missing(parameter) then delete; run;


*Model 5;
data temp_5 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp5 fit5 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_5(keep=Parameter estimate5 tValue5 probt5) ;
	  set temp_5(rename=(estimate=estimate5 tValue=tValue5 probt=probt5));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps",  "AdjR2"); 
	  if missing(parameter) then delete; run;



*Model 6;
data temp_6 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp6 fit6 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_6(keep=Parameter estimate6 tValue6 probt6) ;
	  set temp_6(rename=(estimate=estimate6 tValue=tValue6 probt=probt6));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps",  "AdjR2"); 
	  if missing(parameter) then delete; run;



proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;
proc sort data=temp_5; by parameter; run;
proc sort data=temp_6; by parameter; run;

data temp; merge temp_1 temp_2 temp_3 temp_4 temp_5  temp_6; by parameter; run;



*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);
	 pvalue5 = put(probt5,best32.);
	 pvalue6 = put(probt6,best32.);
	

if parameter="Intercept" then parameter="A_Intercept";
if parameter="d_firstETF" then parameter="B_d_firstETF";
if parameter="tr_error_bps" then parameter="C_tr_error_bps";
if parameter="perf_drag_bps" then parameter="D_tr_difference";
if parameter="d_UIT" then parameter="E_D_uit";
if parameter="lend_byAUM_bps" then parameter="F_lend_byAUM_bps";
if parameter="marketing_fee_bps" then parameter="G_marketing_fee_bps";

if parameter="AdjR2" then parameter="H_AdjR2";

run;
proc sort data=temp_v1_; by parameter; run;




/* Create Latex-specific file and convert into txt;*/

data  table2;
set temp_v1_;
/* an array is used to use the various variables,
for example aCOEF(3) refers to variable COEF3
this is helpful in do-while loops, where a counter is used
(in this case I is used, which counts from 1 till 9)
*/
array aest(1:6) estimate1-estimate6;
array atvalue(1:6) tValue1-tValue6;
array apvalue(1:6) pvalue1-pvalue6;
run;


/* create variables latexCoef and latexSign holding the latex markup;*/
data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:6) estimate1-estimate6;
array atvalue(1:6) tValue1-tValue6;
array apvalue(1:6) pvalue1-pvalue6;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 6;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

/* this would be the place to also add a symbol for significance at 10% */		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="First-ETF dummy";
else if _NAME_="latexCoef" and famid=3 then col0="Tracking error";
else if _NAME_="latexCoef" and famid=4 then col0="Performance drag";
else if _NAME_="latexCoef" and famid=5 then col0="$D_\text{UIT}$";
else if _NAME_="latexCoef" and famid=6 then col0="Lending income";
else if _NAME_="latexCoef" and famid=7 then col0="Marketing expenses";
else if _NAME_="latexCoef" and famid=8 then col0="Adjusted $R^2$";


else col0=" ";
if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";


run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;

proc export data=table6 outfile='.\output\Table4_FirstMover.txt' dbms=tab replace;
putnames=no;
run;




*******************************************************************************************************************************
TABLE "First-mover advantage OLS tests, with controls for turnover and ETF market share"

*Note: this table does not appear in the main paper. It reports the same resgressions as ""First-mover advantage OLS tests", but with 
control variables for turnover and mkt share to adress the referee comment "It is critical for the authors to show that the coefficient
of FirstETFDummy reported in Table 7 becomes nonsignificant when the regression includes a control for ETF trading activity (e.g. Turnover).
This is what one would expect if attracting a large pool of investors and being subject to high turnover were the main mechanisms behind 
the differences in fees". We show that indeed with extra controls the coef on d_firstETF becomes insignificant (or in case of market 
share regressions - becomes substantially smaller than before. This indicates that attracting a large pool of investors and being subject 
to high turnover are the main mechanisms behind the differences in fees.

This table reports results of cross-sectional regressions using the 137 ETFs that compete in the same index as at least one other ETF. 
The dependent variables in the regressions are (1) ETF fee (MER or net expense ratio) in basis points, (2) Relative bid-ask spread 
(in basis points), (3) Log Dollar Volume, (4) Log Profitability (AUM times MER). All variables are calculated from daily 
data and averaged per ETF during the year 2020. The unit of observation is ETF.
*******************************************************************************************************************************;



*Model 1;
ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model mer_bps = d_firstETF   mkt_share turnover_frac  tr_error_bps  perf_drag_bps  D_uit lend_byAUM_bps marketing_fee_bps index_id  / solution ADJRSQ;
run;


*Model 2;
ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model spread_bps_crsp = d_firstETF  mkt_share turnover_frac tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id  / solution ADJRSQ;
run;




*Model 3;
ods output ParameterEstimates=temp3 fitstatistics=fit3;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model logDvol = d_firstETF  mkt_share turnover_frac tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id  / solution ADJRSQ;
run;

*Model 4;
ods output ParameterEstimates=temp4 fitstatistics=fit4;
proc surveyreg data=f.reg_dFirst; class index_id ; cluster index_id ;
		model logETFProfit = d_firstETF  mkt_share turnover_frac tr_error_bps  perf_drag_bps  D_uit  lend_byAUM_bps marketing_fee_bps index_id  / solution ADJRSQ;
run;





****************************************************************************************************************************
*Preparing Latex output for the TABLE "First-mover advantage OLS tests, with controls for turnover and ETF market share"

*This code takes regression output from sas files temp1-temp6 (with regression coefficients) and files fit1-fit6(with AdjRsq),
 and combines them into a file that we output into txt and paste into Latex  to generate TABLE 
"First-mover advantage OLS tests, with controls for turnover and ETF market share";
****************************************************************************************************************************



*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps", "mkt_share", "turnover_frac", "AdjR2"); 
	  if missing(parameter) then delete; run;




*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps", "mkt_share", "turnover_frac", "AdjR2"); 
	  if missing(parameter) then delete; run;



*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps", "mkt_share", "turnover_frac", "AdjR2"); 
	  if missing(parameter) then delete; run;


*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
	  where parameter in ("Intercept","d_firstETF",  "tr_error_bps",  "perf_drag_bps",  "d_UIT", "lend_byAUM_bps", "marketing_fee_bps", "mkt_share", "turnover_frac", "AdjR2"); 
	  if missing(parameter) then delete; run;


proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;


data temp; merge temp_1 temp_2 temp_3 temp_4 ; by parameter; run;



*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);

	

if parameter="Intercept" then parameter="A_Intercept";
if parameter="d_firstETF" then parameter="B_d_firstETF";
if parameter="tr_error_bps" then parameter="C_tr_error_bps";
if parameter="perf_drag_bps" then parameter="D_tr_difference";
if parameter="d_UIT" then parameter="E_D_uit";
if parameter="lend_byAUM_bps" then parameter="F_lend_byAUM_bps";
if parameter="marketing_fee_bps" then parameter="G_marketing_fee_bps";

if parameter="turnover_frac" then parameter="H_turnover_frac";
if parameter="mkt_share" then parameter="I_mktshare";

if parameter="AdjR2" then parameter="K_AdjR2";

run;
proc sort data=temp_v1_; by parameter; run;




/* Create Latex-specific file and convert into txt;*/

data  table2;
set temp_v1_;
/* an array is used to use the various variables,
for example aCOEF(3) refers to variable COEF3
this is helpful in do-while loops, where a counter is used
(in this case I is used, which counts from 1 till 9)
*/
array aest(1:4) estimate1-estimate4;
array atvalue(1:4) tValue1-tValue4;
array apvalue(1:4) pvalue1-pvalue4;
run;


/* create variables latexCoef and latexSign holding the latex markup;*/
data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:4) estimate1-estimate4;
array atvalue(1:4) tValue1-tValue4;
array apvalue(1:4) pvalue1-pvalue4;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 4;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

/* this would be the place to also add a symbol for significance at 10% */		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="First-ETF dummy";
else if _NAME_="latexCoef" and famid=3 then col0="Tracking error";
else if _NAME_="latexCoef" and famid=4 then col0="Performance drag";
else if _NAME_="latexCoef" and famid=5 then col0="$D_\text{UIT}$";
else if _NAME_="latexCoef" and famid=6 then col0="Lending income";
else if _NAME_="latexCoef" and famid=7 then col0="Marketing expenses";
else if _NAME_="latexCoef" and famid=8 then col0="Turnover";
else if _NAME_="latexCoef" and famid=9 then col0="Market share";
else if _NAME_="latexCoef" and famid=10 then col0="Adjusted $R^2$";


else col0=" ";
if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";

run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;


proc export data=table6 outfile='.\output\Table5_FirstMoverControls.txt' dbms=tab replace;
putnames=no;
run;




*******************************************************************************************************************************
TABLE "Investor heterogeneity and leader-follower differences"

This table reports results of panel regressions using the 137 ETFs that compete in tracking the same index as at least one other ETF.
The unit of observation is index-year-month. The dependent variable is the difference between leader and follower's (i) market share 
(first and second models), (ii) management fee (third and fourth models), and (iii) relative spread (fifth and sixth models) 
The period covered is 2016-2020. The unit of observation is index-year-month.
*******************************************************************************************************************************;



*Model 1;
ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.reg_lf; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mkt_share = ix_ratio_hu  index_id yearmonth / solution ADJRSQ;
run;


*Model 2;
ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=f.reg_lf; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mkt_share = ix_ratio_hu delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id yearmonth / solution ADJRSQ;
run;



*Model 3;
ods output ParameterEstimates=temp3 fitstatistics=fit3;
proc surveyreg data=f.reg_lf; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mer_bps = ix_ratio_hu index_id yearmonth / solution ADJRSQ;
run;


*Model 4;
ods output ParameterEstimates=temp4 fitstatistics=fit4;
proc surveyreg data=f.reg_lf; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mer_bps = ix_ratio_hu delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id yearmonth / solution ADJRSQ;
run;




*Model 5;
ods output ParameterEstimates=temp5 fitstatistics=fit5;
proc surveyreg data=f.reg_lf; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_spread_bps = ix_ratio_hu index_id yearmonth / solution ADJRSQ;
run;


*Model 6;
ods output ParameterEstimates=temp6 fitstatistics=fit6;
proc surveyreg data=f.reg_lf; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_spread_bps = ix_ratio_hu delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id yearmonth / solution ADJRSQ;
run;





****************************************************************************************************************************
*Preparing Latex output for the TABLE "Investor heterogeneity and leader-follower differences"

*This code takes regression output from sas files temp1-temp6 (with regression coefficients) and files fit1-fit6(with AdjRsq),
 and combines them into a file that we output into txt and paste into Latex  to generate TABLE 
"Investor heterogeneity and leader-follower differences";
****************************************************************************************************************************



*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1(rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
where parameter in ("Intercept","ix_urgency_std", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;





*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
where parameter in ("Intercept","ix_urgency_std", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;



*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
where parameter in ("Intercept","ix_urgency_std", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;




*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
where parameter in ("Intercept","ix_urgency_std", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;






*Model 5;
data temp_5 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp5 fit5 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_5(keep=Parameter estimate5 tValue5 probt5) ;
	  set temp_5(rename=(estimate=estimate5 tValue=tValue5 probt=probt5));
where parameter in ("Intercept","ix_urgency_std", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;




*Model 6;
data temp_6 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp6 fit6 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_6(keep=Parameter estimate6 tValue6 probt6) ;
	  set temp_6(rename=(estimate=estimate6 tValue=tValue6 probt=probt6));
where parameter in ("Intercept","ix_urgency_std", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;



	  


proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;
proc sort data=temp_5; by parameter; run;
proc sort data=temp_6; by parameter; run;



data temp; merge temp_1 temp_2 temp_3 temp_4 temp_5 temp_6; by parameter; run;


*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);
	 pvalue5 = put(probt5,best32.);
	 pvalue6 = put(probt6,best32.);


if parameter="Intercept" then parameter="A_Intercept";
if parameter="ix_ratio_hu" then parameter="C_ix_ratio_hu";

if parameter="delta_tr_error_bps" then parameter="D_tr_error_bps";
if parameter="delta_perf_drag_bps" then parameter="E_perf_drag_bps";
if parameter="d_UIT" then parameter="F_D_uit";
if parameter="delta_lend_byAUM_bps" then parameter="G_lend_byAUM_bps";
if parameter="delta_marketing_fee_bps" then parameter="H_mktng";

if parameter="AdjR2" then parameter="I_AdjR2";

run;
proc sort data=temp_v1_; by parameter; run;



* Create Latex-specific file and convert into txt;

data  table2;
set temp_v1_;


array aest(1:6) estimate1-estimate6;
array atvalue(1:6) tValue1-tValue6;
array apvalue(1:6) pvalue1-pvalue6;
run;



data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:6) estimate1-estimate6;
array atvalue(1:6) tValue1-tValue6;
array apvalue(1:6) pvalue1-pvalue6;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 6;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="Investor heterogeneity";
else if _NAME_="latexCoef" and famid=3 then col0="$\Delta$ Tracking error";
else if _NAME_="latexCoef" and famid=4 then col0="$\Delta$ Performance drag";
else if _NAME_="latexCoef" and famid=5 then col0="$D_\text{UIT}$";
else if _NAME_="latexCoef" and famid=6 then col0="$\Delta$ Lending income";
else if _NAME_="latexCoef" and famid=7 then col0="$\Delta$ Marketing expenses";
else if _NAME_="latexCoef" and famid=8 then col0="Adjusted $R^2$";

else col0=" ";

if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";


run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;

proc export data=table6 outfile='.\output\Table6_leaderfollowerdiff.txt' dbms=tab replace;
putnames=no;
run;


************************************************************************************************************************
*******************************************************************************************************************************
TABLE "Determinants of ETF competition", regressions 1-4

This table reports results of probit regressions in which the units of observation are indices. The dependent variable is
the probability of observing multiple ETFs competing in tracking the given index. 
All variables are computed as the average per index for year 2020.
*********************************************************************************************************************************;






*Model 1;
proc logistic data=f.probit descending;
  model sep_ind_ = ratio_hu aum_ind_bn  top3_ind /link=probit rsquare;
  ods output ParameterEstimates=probit1 fitstatistics=fit1;
run;
data fit1(keep=estimate variable); format variable $10.; informat variable $10.; set fit1;
pseudo_rsq=(InterceptOnly-InterceptAndCovariates)/InterceptOnly;
if rowid="M2LOGL"  then do; Estimate=pseudo_rsq; Variable="PseudoR2"; end;
run;


*Model 2;
proc logistic data=f.probit descending;
  model sep_ind_ = ratio_hu aum_ind_bn dvol_ind_bn  top3_ind  /link=probit rsquare;
  ods output ParameterEstimates=probit2 fitstatistics=fit2;
run;
data fit2(keep=estimate variable); format variable $10.; informat variable $10.; set fit2;
pseudo_rsq=(InterceptOnly-InterceptAndCovariates)/InterceptOnly;
if rowid="M2LOGL"  then do; Estimate=pseudo_rsq; Variable="PseudoR2"; end;
run;


*Model 3;
proc logistic data=f.probit descending;
  model sep_ind_ =  ratio_hu dvol_ind_bn spread_ind_bps top3_ind  /link=probit rsquare;
  ods output ParameterEstimates=probit3 fitstatistics=fit3;
run;
data fit3(keep=estimate variable); format variable $10.; informat variable $10.; set fit3;
pseudo_rsq=(InterceptOnly-InterceptAndCovariates)/InterceptOnly;
if rowid="M2LOGL"  then do; Estimate=pseudo_rsq; Variable="PseudoR2"; end;
run;


*Model 4;
proc logistic data=f.probit descending;
  model sep_ind_ = ratio_hu dvol_ind_bn spread_ind_bps num_const_00  top3_ind /link=probit rsquare;
  ods output ParameterEstimates=probit4 fitstatistics=fit4;
run;
data fit4(keep=estimate variable); format variable $10.; informat variable $10.; set fit4;
pseudo_rsq=(InterceptOnly-InterceptAndCovariates)/InterceptOnly;
if rowid="M2LOGL"  then do; Estimate=pseudo_rsq; Variable="PseudoR2"; end;
run;





**********************************************************************************
LATEX output for TABLE "Determinants of ETF competition", regressions 1-4
*********************************************************************************;


*Model 1;
data temp_1(rename=(variable=parameter WaldChiSq=tvalue ProbChiSq=probt  )) ; set probit1 fit1 ; run; 
	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1 ));
	  if missing(parameter) then delete; run;

*Model 2;
data temp_2(rename=(variable=parameter WaldChiSq=tvalue ProbChiSq=probt )) ; set probit2 fit2 ; run; 
	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
	  if missing(parameter) then delete; run;



*Model 3;
data temp_3(rename=(variable=parameter WaldChiSq=tvalue ProbChiSq=probt )) ; set probit3 fit3 ; run; 
	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
	  if missing(parameter) then delete; run;

*Model 4;
data temp_4(rename=(variable=parameter WaldChiSq=tvalue ProbChiSq=probt )) ; set probit4 fit4 ; run; 
	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
	  if missing(parameter) then delete; run;




proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;


data temp; merge temp_1 temp_2 temp_3 temp_4; by parameter; run;



*Arranging the parameters in sequence
;

data temp_v1_; format parameter $100.; informat parameter $100.; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);

	

if parameter="Intercept" then parameter="A_Intercept";
if parameter="ratio_hu" then parameter="B_ratio_hu";
if parameter="dvol_ind_b" then parameter="C_dvol";
if parameter="spread_ind" then parameter="D_spread";

if parameter="aum_ind_bn" then parameter="E_aum_ind_bn";
if parameter="top3_ind" then parameter="F_top3_ind";
if parameter="num_const_" then parameter="G_num_const_";

if parameter="PseudoR2" then parameter="H_PseudoR2";

run;
proc sort data=temp_v1_; by parameter; run;



/* Create Latex-specific file and convert into txt;*/

data  table2;
set temp_v1_;
/* an array is used to use the various variables,
for example aCOEF(3) refers to variable COEF3
this is helpful in do-while loops, where a counter is used
(in this case I is used, which counts from 1 till 9)
*/
array aest(1:4) estimate1-estimate4;
array atvalue(1:4) tValue1-tValue4;
array apvalue(1:4) pvalue1-pvalue4;
run;


/* create variables latexCoef and latexSign holding the latex markup;*/
data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:4) estimate1-estimate4;
array atvalue(1:4) tValue1-tValue4;
array apvalue(1:4) pvalue1-pvalue4;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 4;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

/* this would be the place to also add a symbol for significance at 10% */		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="Investor heterogeneity";
else if _NAME_="latexCoef" and famid=3 then col0="Dollar volume";
else if _NAME_="latexCoef" and famid=4 then col0="Relative spread";
else if _NAME_="latexCoef" and famid=5 then col0="Assets under management";
else if _NAME_="latexCoef" and famid=6 then col0="Top 3 Issuer dummy";
else if _NAME_="latexCoef" and famid=7 then col0="Number of constituents";
else if _NAME_="latexCoef" and famid=8 then col0="Pseudo $R^2$";
else col0=" ";

if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";


run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;

proc export data=table6 outfile='.\output\Table7_Probit.txt' dbms=tab replace;
putnames=no;
run;


*******************************************************************************************************************************
TABLE "Determinants of ETF competition", regressions 5-8

This table reports results of probit regressions in which the units of observation are indices. The dependent variable is
the probability of observing multiple ETFs competing in tracking a given index. 
All variables are computed as the average per index for year 2020.
*********************************************************************************************************************************;



*Model 5;
proc logistic data=f.probit_rob descending;
  model sep_ind_ = ratio_hu aum_ind_bn  top3_ind /link=probit rsquare;
  ods output ParameterEstimates=probit1 fitstatistics=fit1;
run;
data fit1(keep=estimate variable); format variable $10.; informat variable $10.; set fit1;
pseudo_rsq=(InterceptOnly-InterceptAndCovariates)/InterceptOnly;
if rowid="M2LOGL"  then do; Estimate=pseudo_rsq; Variable="PseudoR2"; end;
run;


*Model 6;
proc logistic data=f.probit_rob descending;
  model sep_ind_ = ratio_hu aum_ind_bn dvol_ind_bn  top3_ind  /link=probit rsquare;
  ods output ParameterEstimates=probit2 fitstatistics=fit2;
run;
data fit2(keep=estimate variable); format variable $10.; informat variable $10.; set fit2;
pseudo_rsq=(InterceptOnly-InterceptAndCovariates)/InterceptOnly;
if rowid="M2LOGL"  then do; Estimate=pseudo_rsq; Variable="PseudoR2"; end;
run;


*Model 7;
proc logistic data=f.probit_rob descending;
  model sep_ind_ =  ratio_hu dvol_ind_bn spread_ind_bps top3_ind  /link=probit rsquare;
  ods output ParameterEstimates=probit3 fitstatistics=fit3;
run;
data fit3(keep=estimate variable); format variable $10.; informat variable $10.; set fit3;
pseudo_rsq=(InterceptOnly-InterceptAndCovariates)/InterceptOnly;
if rowid="M2LOGL"  then do; Estimate=pseudo_rsq; Variable="PseudoR2"; end;
run;


*Model 8;
proc logistic data=f.probit_rob descending;
  model sep_ind_ = ratio_hu dvol_ind_bn spread_ind_bps num_const_00  top3_ind /link=probit rsquare;
  ods output ParameterEstimates=probit4 fitstatistics=fit4;
run;
data fit4(keep=estimate variable); format variable $10.; informat variable $10.; set fit4;
pseudo_rsq=(InterceptOnly-InterceptAndCovariates)/InterceptOnly;
if rowid="M2LOGL"  then do; Estimate=pseudo_rsq; Variable="PseudoR2"; end;
run;




**********************************************************************************
LATEX output
*********************************************************************************;


*Model 5;
data temp_1(rename=(variable=parameter WaldChiSq=tvalue ProbChiSq=probt )) ; set probit1 fit1 ; run; 
	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
	  if missing(parameter) then delete; run;

*Model 6;
data temp_2(rename=(variable=parameter WaldChiSq=tvalue ProbChiSq=probt )) ; set probit2 fit2 ; run; 
	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
	  if missing(parameter) then delete; run;



*Model 7;
data temp_3(rename=(variable=parameter WaldChiSq=tvalue ProbChiSq=probt )) ; set probit3 fit3 ; run; 
	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
	  if missing(parameter) then delete; run;

*Model 8;
data temp_4(rename=(variable=parameter WaldChiSq=tvalue ProbChiSq=probt )) ; set probit4 fit4 ; run; 
	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
	  if missing(parameter) then delete; run;




proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;


data temp; merge temp_1 temp_2 temp_3 temp_4; by parameter; run;



*Arranging the parameters in sequence
;

data temp_v1_; format parameter $100.; informat parameter $100.; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);

	

if parameter="Intercept" then parameter="A_Intercept";
if parameter="ratio_hu" then parameter="B_ratio_hu";
if parameter="dvol_ind_b" then parameter="C_dvol";
if parameter="spread_ind" then parameter="D_spread";

if parameter="aum_ind_bn" then parameter="E_aum_ind_bn";
if parameter="top3_ind" then parameter="F_top3_ind";
if parameter="num_const_" then parameter="G_num_const_";

if parameter="PseudoR2" then parameter="H_PseudoR2";

run;
proc sort data=temp_v1_; by parameter; run;



/* Create Latex-specific file and convert into txt;*/

data  table2;
set temp_v1_;
/* an array is used to use the various variables,
for example aCOEF(3) refers to variable COEF3
this is helpful in do-while loops, where a counter is used
(in this case I is used, which counts from 1 till 9)
*/
array aest(1:4) estimate1-estimate4;
array atvalue(1:4) tValue1-tValue4;
array apvalue(1:4) pvalue1-pvalue4;
run;


/* create variables latexCoef and latexSign holding the latex markup;*/
data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:4) estimate1-estimate4;
array atvalue(1:4) tValue1-tValue4;
array apvalue(1:4) pvalue1-pvalue4;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 4;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

/* this would be the place to also add a symbol for significance at 10% */		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="Investor heterogeneity";
else if _NAME_="latexCoef" and famid=3 then col0="Dollar volume";
else if _NAME_="latexCoef" and famid=4 then col0="Relative spread";
else if _NAME_="latexCoef" and famid=5 then col0="Assets under management";
else if _NAME_="latexCoef" and famid=6 then col0="Top 3 Issuer dummy";
else if _NAME_="latexCoef" and famid=7 then col0="Number of constituents";
else if _NAME_="latexCoef" and famid=8 then col0="Pseudo $R^2$";

else col0=" ";

if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";


run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;

proc export data=table6 outfile='.\output\Table7b_probit.txt' dbms=tab replace;
putnames=no;
run;




*******************************************************************************************************************************
TABLE "Two-stage least squares: instrumenting heterogeneity with VIX changes

This table reports results of 2SLS regressions that test how investor heterogeneity affects the difference in market share, MER,
liquidity between the leader and follower ETFs. The unit of observation is index-year-month. The period covered is 2016 -- 2020.
*********************************************************************************************************************************;



*Estimating the vix innovations;
proc surveyreg data=f.vix;  
		model dvix_perc = lag_dvix_perc ; output out=c p=dvixhat;
run; 

data c; set c;
vix_innov=dvix_perc-dvixhat;
if vix_innov>0 then vix_innov_plus=vix_innov; else vix_innov_plus=0; run; 

data vix1(keep=yearmonth dvix vix_innov_plus vix_innov dvix dvix_perc); set c; run;


*********************************************************************************************************************
2SLS TO BE REPORTED IN THE APPENDIX;
*Note: f.reg_lf_upd contains the variable vix_innov_plus generated above;




*Model 1: stage 1;

*generating regression coefficients;
ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.reg_lf_upd; class index_id yearmonth; cluster index_id yearmonth ;
		model ix_ratio_hu = vix_innov_plus delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id / solution ADJRSQ;
run;

*generating fitted values of ix_ratio_hu;
proc surveyreg data=f.reg_lf_upd; class index_id yearmonth; cluster index_id yearmonth ;
		model ix_ratio_hu = vix_innov_plus delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id ; output out=b p=yhat;
run;


*Model 2: stage 2;
ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=b; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mkt_share = yhat delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id  / solution ADJRSQ;
run;

*Model 3: stage 2;
ods output ParameterEstimates=temp3 fitstatistics=fit3;
proc surveyreg data=b; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mer_bps = yhat delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id   / solution ADJRSQ;
run;


*Model 4: stage 2;
ods output ParameterEstimates=temp4 fitstatistics=fit4;
proc surveyreg data=b; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_spread_bps = yhat delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id / solution ADJRSQ;
run;







*Produce LATEX output;

*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1 (rename=(label1=FitStat));
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
where parameter in ("Intercept","yhat1", "yhat", "vix_innov_plus", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;





*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
where parameter in ("Intercept","yhat1", "yhat", "vix_innov_plus", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;



*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
where parameter in ("Intercept","yhat1", "yhat", "vix_innov_plus", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;




*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
where parameter in ("Intercept","yhat1", "yhat", "vix_innov_plus", "ix_ratio_hu", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;





proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;



data temp; merge temp_1 temp_2 temp_3 temp_4; by parameter; run;


*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);



if parameter="Intercept" then parameter="A_Intercept";
if parameter="vix_innov_plus" then parameter="B_vix_innov_plus";
if parameter="yhat" then parameter="C_yhat";
if parameter="delta_tr_error_bps" then parameter="E_tr_error_bps";
if parameter="delta_perf_drag_bps" then parameter="F_perf_drag_bps";
if parameter="d_UIT" then parameter="G_D_uit";
if parameter="delta_lend_byAUM_bps" then parameter="H_lend_byAUM_bps";
if parameter="delta_marketing_fee_bps" then parameter="I_mktng";

if parameter="AdjR2" then parameter="J_AdjR2";

run;
proc sort data=temp_v1_; by parameter; run;



* Create Latex-specific file and convert into txt;

data  table2;
set temp_v1_;


array aest(1:4) estimate1-estimate4;
array atvalue(1:4) tValue1-tValue4;
array apvalue(1:4) pvalue1-pvalue4;
run;



data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:4) estimate1-estimate4;
array atvalue(1:4) tValue1-tValue4;
array apvalue(1:4) pvalue1-pvalue4;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;
DO i = 1 to 4;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="$dVIX^+$";
else if _NAME_="latexCoef" and famid=3 then col0="$\widehat{\text{Investor heterogeneity}}$";
else if _NAME_="latexCoef" and famid=4 then col0="$\Delta$ Tracking error";
else if _NAME_="latexCoef" and famid=5 then col0="$\Delta$ Performance drag";
else if _NAME_="latexCoef" and famid=6 then col0="$D_\text{UIT}$";
else if _NAME_="latexCoef" and famid=7 then col0="$\Delta$ Lending income";
else if _NAME_="latexCoef" and famid=8 then col0="$\Delta$ Marketing expenses";
else if _NAME_="latexCoef" and famid=9 then col0="Adjusted $R^2$";

else col0=" ";

if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";

run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;

proc export data=table6 outfile='.\output\Table8_VIX_IV.txt' dbms=tab replace;
putnames=no; run;



*******************************************************************************************************************************************
Regression reults reported in the Table "VIX changes and differences between leader and follower ETFs"

*******************************************************************************************************************************************;



*Model 1;
ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.reg_lf_upd; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mkt_share = vix_innov_plus  index_id  / solution ADJRSQ;
run;


*Model 2;
ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=f.reg_lf_upd; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mkt_share = vix_innov_plus delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id  / solution ADJRSQ;
run;


*Model 3;
ods output ParameterEstimates=temp3 fitstatistics=fit3;
proc surveyreg data=f.reg_lf_upd; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mer_bps = vix_innov_plus index_id  / solution ADJRSQ;
run;



*Model 4;
ods output ParameterEstimates=temp4 fitstatistics=fit4;
proc surveyreg data=f.reg_lf_upd; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_mer_bps = vix_innov_plus delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id  / solution ADJRSQ;
run;



*Model 5;
ods output ParameterEstimates=temp5 fitstatistics=fit5;
proc surveyreg data=f.reg_lf_upd; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_spread_bps = vix_innov_plus index_id / solution ADJRSQ;
run;



*Model 6;
ods output ParameterEstimates=temp6 fitstatistics=fit6;
proc surveyreg data=f.reg_lf_upd; class index_id yearmonth; cluster index_id yearmonth ;
		model delta_spread_bps = vix_innov_plus delta_tr_error_bps delta_perf_drag_bps d_UIT delta_marketing_fee_bps delta_lend_byAUM_bps index_id  / solution ADJRSQ;
run;


********************************************************************************************************************************
*Produce LATEX output for the Table "VIX changes and differences between leader and follower ETFs";

*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1(rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
where parameter in ("Intercept","ix_urgency_std", "vix_innov_plus", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;





*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
where parameter in ("Intercept","ix_urgency_std", "vix_innov_plus", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;



*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
where parameter in ("Intercept","ix_urgency_std", "vix_innov_plus", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;




*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
where parameter in ("Intercept","ix_urgency_std", "vix_innov_plus", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;






*Model 5;
data temp_5 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp5 fit5 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_5(keep=Parameter estimate5 tValue5 probt5) ;
	  set temp_5(rename=(estimate=estimate5 tValue=tValue5 probt=probt5));
where parameter in ("Intercept","ix_urgency_std", "vix_innov_plus", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;




*Model 6;
data temp_6 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp6 fit6 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_6(keep=Parameter estimate6 tValue6 probt6) ;
	  set temp_6(rename=(estimate=estimate6 tValue=tValue6 probt=probt6));
where parameter in ("Intercept","ix_urgency_std", "vix_innov_plus", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"delta_tr_error_bps", "delta_perf_drag_bps", "d_UIT",
"delta_marketing_fee_bps", "delta_lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;



	  


proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;
proc sort data=temp_5; by parameter; run;
proc sort data=temp_6; by parameter; run;



data temp; merge temp_1 temp_2 temp_3 temp_4 temp_5 temp_6; by parameter; run;


*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);
	 pvalue5 = put(probt5,best32.);
	 pvalue6 = put(probt6,best32.);


if parameter="Intercept" then parameter="A_Intercept";
if parameter="vix_innov_plus" then parameter="C_vix_innov_plus";

if parameter="delta_tr_error_bps" then parameter="D_tr_error_bps";
if parameter="delta_perf_drag_bps" then parameter="E_perf_drag_bps";
if parameter="d_UIT" then parameter="F_D_uit";
if parameter="delta_lend_byAUM_bps" then parameter="G_lend_byAUM_bps";
if parameter="delta_marketing_fee_bps" then parameter="H_mktng";

if parameter="AdjR2" then parameter="I_AdjR2";

run;
proc sort data=temp_v1_; by parameter; run;



* Create Latex-specific file and convert into txt;

data  table2;
set temp_v1_;


array aest(1:6) estimate1-estimate6;
array atvalue(1:6) tValue1-tValue6;
array apvalue(1:6) pvalue1-pvalue6;
run;



data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:6) estimate1-estimate6;
array atvalue(1:6) tValue1-tValue6;
array apvalue(1:6) pvalue1-pvalue6;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 6;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;


if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="Investor heterogeneity";
else if _NAME_="latexCoef" and famid=3 then col0="$\Delta$ Tracking error";
else if _NAME_="latexCoef" and famid=4 then col0="$\Delta$ Performance drag";
else if _NAME_="latexCoef" and famid=5 then col0="$D_\text{UIT}$";
else if _NAME_="latexCoef" and famid=6 then col0="$\Delta$ Lending income";
else if _NAME_="latexCoef" and famid=7 then col0="$\Delta$ Marketing expenses";
else if _NAME_="latexCoef" and famid=8 then col0="Adjusted $R^2$";

else col0=" ";



if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";



run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;


proc export data=table6 outfile='.\output\Table9_VIX_Direct.txt' dbms=tab replace;
putnames=no; run;



*****************************************************************************************************************************************
Producing regressions for the Table "Impact of follower ETF entry on leader (ticker FE)";

******************************************************************************************;

*Model 1;
ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model mkt_share1 = d_lwc  ticker / solution ADJRSQ;
run;


*Model 2;
ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model mkt_share1 = d_lwc tr_error_bps perf_drag_bps  marketing_fee_bps  ticker/ solution ADJRSQ;
run;


*Model 3;
ods output ParameterEstimates=temp3 fitstatistics=fit3;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model mer_leader_bps = d_lwc ticker/ solution ADJRSQ;
run;

*Model 4;
ods output ParameterEstimates=temp4 fitstatistics=fit4;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model mer_leader_bps = d_lwc tr_error_bps perf_drag_bps marketing_fee_bps  ticker/ solution ADJRSQ;
run;



*Model 5;

ods output ParameterEstimates=temp5 fitstatistics=fit5;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model spread_bps_crsp1 = d_lwc ticker / solution ADJRSQ;
run;

*Model 6;
ods output ParameterEstimates=temp6 fitstatistics=fit6;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model spread_bps_crsp1 = d_lwc tr_error_bps perf_drag_bps  marketing_fee_bps  ticker/ solution ADJRSQ;
run;

*Model 7;

ods output ParameterEstimates=temp7 fitstatistics=fit7;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model log_aum = d_lwc ticker / solution ADJRSQ;
run;

*Model 8;
ods output ParameterEstimates=temp8 fitstatistics=fit8;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model log_aum = d_lwc tr_error_bps perf_drag_bps  marketing_fee_bps  ticker/ solution ADJRSQ;
run;








*Produce LATEX output;

*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1(rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;





*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;



*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;




*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;






*Model 5;
data temp_5 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp5 fit5 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_5(keep=Parameter estimate5 tValue5 probt5) ;
	  set temp_5(rename=(estimate=estimate5 tValue=tValue5 probt=probt5));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;




*Model 6;
data temp_6 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp6 fit6 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_6(keep=Parameter estimate6 tValue6 probt6) ;
	  set temp_6(rename=(estimate=estimate6 tValue=tValue6 probt=probt6));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;


*Model 7;
data temp_7 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp7 fit7 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_7(keep=Parameter estimate7 tValue7 probt7) ;
	  set temp_7(rename=(estimate=estimate7 tValue=tValue7 probt=probt7));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;

*Model 8;
data temp_8 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp8 fit8 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_8(keep=Parameter estimate8 tValue8 probt8) ;
	  set temp_8(rename=(estimate=estimate8 tValue=tValue8 probt=probt8));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;

	  


proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;
proc sort data=temp_5; by parameter; run;
proc sort data=temp_6; by parameter; run;
proc sort data=temp_7; by parameter; run;
proc sort data=temp_8; by parameter; run;


data temp; merge temp_1 temp_2 temp_3 temp_4 temp_5 temp_6 temp_7 temp_8; by parameter; run;


*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);
	 pvalue5 = put(probt5,best32.);
	 pvalue6 = put(probt6,best32.);
	 pvalue7 = put(probt7,best32.);
	 pvalue8 = put(probt8,best32.);


if parameter="Intercept" then parameter="A_Intercept";
if parameter="d_lwc" then parameter="C_lwc";

if parameter="tr_error_bps" then parameter="D_tr_error_bps";
if parameter="perf_drag_bps" then parameter="E_perf_drag_bps";


if parameter="marketing_fee_bp" then parameter="H_mktng";

if parameter="AdjR2" then parameter="I_AdjR2";

run;
proc sort data=temp_v1_; by parameter; run;

* Create Latex-specific file and convert into txt;

data  table2;
set temp_v1_;


array aest(1:8) estimate1-estimate8;
array atvalue(1:8) tValue1-tValue8;
array apvalue(1:8) pvalue1-pvalue8;
run;



data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:8) estimate1-estimate8;
array atvalue(1:8) tValue1-tValue8;
array apvalue(1:8) pvalue1-pvalue8;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 8;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="$D_\text{entry}$";
else if _NAME_="latexCoef" and famid=3 then col0="Tracking error";
else if _NAME_="latexCoef" and famid=4 then col0="Performance drag";
else if _NAME_="latexCoef" and famid=5 then col0="Marketing expenses";
else if _NAME_="latexCoef" and famid=6 then col0="Adjusted $R^2$";

else col0=" ";

if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";


run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;

proc export data=table6 outfile='.\output\Table10_Entry.txt' dbms=tab replace;
putnames=no; run;


*****************************************************************************************************************************************
Producing regressions for the Table "Impact of follower ETF entry on leader" (ticker and year-month FE);

******************************************************************************************;

*Model 1;
ods output ParameterEstimates=temp1 fitstatistics=fit1;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model mkt_share1 = d_lwc  ticker yearmonth/ solution ADJRSQ;
run;


*Model 2;
ods output ParameterEstimates=temp2 fitstatistics=fit2;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model mkt_share1 = d_lwc tr_error_bps perf_drag_bps  marketing_fee_bps  ticker yearmonth/ solution ADJRSQ;
run;


*Model 3;
ods output ParameterEstimates=temp3 fitstatistics=fit3;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model mer_leader_bps = d_lwc ticker yearmonth/ solution ADJRSQ;
run;

*Model 4;
ods output ParameterEstimates=temp4 fitstatistics=fit4;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model mer_leader_bps = d_lwc tr_error_bps perf_drag_bps marketing_fee_bps  ticker yearmonth/ solution ADJRSQ;
run;



*Model 5;

ods output ParameterEstimates=temp5 fitstatistics=fit5;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model spread_bps_crsp1 = d_lwc ticker yearmonth/ solution ADJRSQ;
run;

*Model 6;
ods output ParameterEstimates=temp6 fitstatistics=fit6;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model spread_bps_crsp1 = d_lwc tr_error_bps perf_drag_bps  marketing_fee_bps  ticker yearmonth/ solution ADJRSQ;
run;

*Model 7;

ods output ParameterEstimates=temp7 fitstatistics=fit7;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model log_aum = d_lwc ticker yearmonth/ solution ADJRSQ;
run;

*Model 8;
ods output ParameterEstimates=temp8 fitstatistics=fit8;
proc surveyreg data=f.entry_analysis; class ticker yearmonth; cluster ticker yearmonth;
		model log_aum = d_lwc tr_error_bps perf_drag_bps  marketing_fee_bps  ticker yearmonth/ solution ADJRSQ;
run;








*Produce LATEX output;

*Model 1;
data temp_1 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp1 fit1(rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_1(keep=Parameter estimate1 tValue1 probt1 ) ;
	  set temp_1(rename=(estimate=estimate1 tValue=tValue1 probt=probt1));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;





*Model 2;
data temp_2 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp2 fit2 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_2(keep=Parameter estimate2 tValue2 probt2 ) ;
	  set temp_2(rename=(estimate=estimate2 tValue=tValue2 probt=probt2));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;



*Model 3;
data temp_3 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp3 fit3 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_3(keep=Parameter estimate3 tValue3 probt3) ;
	  set temp_3(rename=(estimate=estimate3 tValue=tValue3 probt=probt3));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;




*Model 4;
data temp_4 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp4 fit4 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_4(keep=Parameter estimate4 tValue4 probt4) ;
	  set temp_4(rename=(estimate=estimate4 tValue=tValue4 probt=probt4));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;






*Model 5;
data temp_5 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp5 fit5 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_5(keep=Parameter estimate5 tValue5 probt5) ;
	  set temp_5(rename=(estimate=estimate5 tValue=tValue5 probt=probt5));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;




*Model 6;
data temp_6 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp6 fit6 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_6(keep=Parameter estimate6 tValue6 probt6) ;
	  set temp_6(rename=(estimate=estimate6 tValue=tValue6 probt=probt6));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;


*Model 7;
data temp_7 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp7 fit7 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_7(keep=Parameter estimate7 tValue7 probt7) ;
	  set temp_7(rename=(estimate=estimate7 tValue=tValue7 probt=probt7));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;

*Model 8;
data temp_8 (drop=cValue1 nValue1 fitStat denDF); 
	  set temp8 fit8 (rename=(label1=FitStat)); 
	  if fitStat^="Root MSE" & fitStat^="Denominator DF"; 
	  if substrn(Parameter,1,3)^="symbol" & substrn(Parameter,1,3)^="year"; if FitStat="Adjusted R-Square" then do; 
	  Estimate=cValue1; Parameter="AdjR2"; end; run; 

	  data temp_8(keep=Parameter estimate8 tValue8 probt8) ;
	  set temp_8(rename=(estimate=estimate8 tValue=tValue8 probt=probt8));
where parameter in ("Intercept","ix_urgency_std", "d_lwc", "tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",  
"tr_error_bps", "perf_drag_bps", "d_UIT",
"marketing_fee_bps", "lend_byAUM_bps",
"AdjR2"); if missing(parameter) then delete; run;

	  


proc sort data=temp_1; by parameter; run;
proc sort data=temp_2; by parameter; run;
proc sort data=temp_3; by parameter; run;
proc sort data=temp_4; by parameter; run;
proc sort data=temp_5; by parameter; run;
proc sort data=temp_6; by parameter; run;
proc sort data=temp_7; by parameter; run;
proc sort data=temp_8; by parameter; run;


data temp; merge temp_1 temp_2 temp_3 temp_4 temp_5 temp_6 temp_7 temp_8; by parameter; run;


*Arranging the parameters in sequence
;

data temp_v1_; set temp;
*FOrmat p-values;
 pvalue1 = put(probt1,best32.);
  pvalue2 = put(probt2,best32.);
   pvalue3 = put(probt3,best32.);
    pvalue4 = put(probt4,best32.);
	 pvalue5 = put(probt5,best32.);
	 pvalue6 = put(probt6,best32.);
	 pvalue7 = put(probt7,best32.);
	 pvalue8 = put(probt8,best32.);


if parameter="Intercept" then parameter="A_Intercept";
if parameter="d_lwc" then parameter="C_lwc";

if parameter="tr_error_bps" then parameter="D_tr_error_bps";
if parameter="perf_drag_bps" then parameter="E_perf_drag_bps";


if parameter="marketing_fee_bp" then parameter="H_mktng";

if parameter="AdjR2" then parameter="I_AdjR2";

run;
proc sort data=temp_v1_; by parameter; run;

* Create Latex-specific file and convert into txt;

data  table2;
set temp_v1_;


array aest(1:8) estimate1-estimate8;
array atvalue(1:8) tValue1-tValue8;
array apvalue(1:8) pvalue1-pvalue8;
run;



data table3 (keep = latexCoef latexSign );
set  table2;

array aest(1:8) estimate1-estimate8;
array atvalue(1:8) tValue1-tValue8;
array apvalue(1:8) pvalue1-pvalue8;

LENGTH latexCoef latexSign strTVal2 $5000.;

*latexCoef = " ";	* starts with decile number;
latexSign = " ";	* starts with empty column;



*raw1;

DO i = 1 to 8;

if apvalue(i)=. then apvalue(i)=" ";
if aEST(i)=. then aEST(i)=" ";


		latexCoef = strip(latexCoef) || " & " || put( Round(aEST(i), 0.01), 6.2) ;
		strTVal = put((Round(atvalue(i), 0.01)), 6.2);	
		strTVal2 = "("  || strip(strTVal) || ")"; 	

		


		if (apvalue(i)<= 0.01 and apvalue(i)>=0)     or (apvalue(i)>= -0.01 and apvalue(i)<=0)     then latexCoef =  strip(latexCoef) || "$^{\ast\ast\ast}$"  ;
		if (apvalue(i) <= 0.05 and apvalue(i)>0.01) or (apvalue(i)>= -0.05 and apvalue(i)<-0.01) then latexCoef =  strip(latexCoef) || "$^{\ast\ast}$"  ;	
		if (apvalue(i) <= 0.1 and apvalue(i)>0.05)  or (apvalue(i)>= -0.1 and apvalue(i)<-0.05)   then latexCoef =  strip(latexCoef) || "$^{\ast}$"  ;


		latexSign = strip(latexSign) || " & " ||  strip (strTVal2);
end;
run;


*Transpose;

data table3; set table3; famid=_n_; run;
proc transpose data=table3 out=table4  ;
   by famid;
var latexCoef latexSign ;
run;



data table5 (keep=col0 col1 col_n); 
LENGTH col_n col0 $5000.;
retain col0 col1 col_n;
set table4;
if _NAME_="latexCoef" and famid=1 then col0="Intercept";
else if _NAME_="latexCoef" and famid=2 then col0="$D_\text{entry}$";
else if _NAME_="latexCoef" and famid=3 then col0="Tracking error";
else if _NAME_="latexCoef" and famid=4 then col0="Performance drag";
else if _NAME_="latexCoef" and famid=5 then col0="Marketing expenses";
else if _NAME_="latexCoef" and famid=6 then col0="Adjusted $R^2$";

else col0=" ";

if _NAME_="latexCoef" then col_n="\vspace{0.05in}\\";
if _NAME_="latexSign" then col_n="\\";


run;

data table6;
	set table5;
	col1=tranwrd(col1,"    .", " ");
	col1=tranwrd(col1," (.) ", " ");
run;

proc export data=table6 outfile='.\output\Table10_Entry_2wayFE.txt' dbms=tab replace;
putnames=no; run;

