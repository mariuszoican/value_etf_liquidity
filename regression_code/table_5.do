
// Table 5 - Shapley values
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
//import delimited "`directory'/data/etf_panel_processed.csv"
import delimited "D:/ResearchProjects/kpz_etfliquidity/data/etf_panel_processed.csv"



gen qspread_bps=10000*quotedspread_percent_tw 
gen qspread_dollar=100*quotedspread_dollar_tw 

gen efspread_dollar=100*effectivespread_dollar_ave
gen efspread_bps=10000*effectivespread_percent_ave

gen rspread_dollar=100*dollarrealizedspread_lr_ave
gen rspread_bps=10000*percentrealizedspread_lr_ave


drop net_expenses
gen  net_expenses=other_expense-marketing_fee_bps/100+fee_waiver

gen mer_diff=(mer_bps-mer_avg_ix)

// List of variables to regress on index_id and quarter
local varlist mkt_share mer_bps mer_diff stock_tweets marketing_fee_bps net_expenses ratio_tii lend_byaum_bps tr_error_bps perf_drag_bps d_uit turnover_frac qspread_bps qspread_dollar efspread_bps efspread_dollar rspread_bps rspread_dollar

// Loop through the list of variables
foreach var in `varlist' {
    // Perform the regression and save residuals
    quietly reghdfe `var', absorb(index_id quarter) resid
    predict `var'_resid, residuals
}


label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
label variable time_existence "ETF age (quarters)"
label variable time_since_first "Time since first position"
label variable log_aum_index "Log index AUM"
label variable d_uit "Unit investment trust"
// label variable lend_byaum_bps "Lending income (bps of AUM)"
// label variable marketing_fee_bps "Marketing expense (bps)"
// label variable stock_tweets "Name recognition (Twitter msg.)"
// label variable tr_error_bps "Tracking error (bps)"
// label variable perf_drag_bps "Performance drag (bps)"
// label variable turnover_frac "ETF turnover"
// label variable net_expenses "Other net expenses"
// label variable stock_tweets "Stock tweets"
// label variable log_volume "Log volume"
// label variable spread_bps_crsp "Relative spread"
// label variable creation_fee "Creation fee"


label variable qspread_bps "Quoted spread (bps)"
label variable qspread_dollar "Quoted spread (cents)"
label variable efspread_bps "Effective spread (bps)"
label variable efspread_dollar "Effective spread (cents)"
label variable rspread_bps "Realized spread (bps)"
label variable rspread_dollar "Realized spread (cents)"

rego mkt_share_resid   qspread_bps_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mkt_share_resid   efspread_bps_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mkt_share_resid   rspread_bps_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mkt_share_resid    turnover_frac_resid  \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_resid   qspread_bps_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_resid   efspread_bps_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_resid   rspread_bps_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_resid    turnover_frac_resid  \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


// Robustness table with dollar measures

rego mkt_share_resid   qspread_dollar_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5_dollar.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mkt_share_resid   efspread_dollar_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5_dollar.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mkt_share_resid   rspread_dollar_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5_dollar.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_resid   qspread_dollar_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5_dollar.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_resid   efspread_dollar_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5_dollar.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_resid   rspread_dollar_resid \ stock_tweets_resid marketing_fee_bps_resid net_expenses_resid  \ ratio_tii_resid \ lend_byaum_bps_resid  tr_error_bps_resid perf_drag_bps_resid d_uit_resid, vce(cl index_id)
outreg2 using "`directory'/output/table_5_dollar.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


