
// Table 5 - Liquidity channel vs alternatives
// -------------------------------------


// Load data
// -------------------------------------
clear all
set more off

local directory "U:\kpz_etfliquidity\data_Marta"
import delimited "`directory'\etf_panel_processed1"

// // Label variables
// // ---------------------------------


egen time_existence_std=std(time_existence)
egen time_since_first_std=std(time_since_first)
egen log_aum_index_std=std(log_aum_index)
egen lend_byaum_bps_std=std(lend_byaum_bps)
egen marketing_fee_bps_std=std(marketing_fee_bps)
egen cum_mktg_expense_std=std(cum_mktg_expense)
egen tr_error_bps_std=std(tr_error_bps)
egen perf_drag_bps_std=std(perf_drag_bps)
egen turnover_frac_std=std(turnover_frac)
egen ratio_tii_std=std(ratio_tii)
egen log_volume_std=std(log_volume)
egen spread_bps_crsp_std=std(spread_bps_crsp)
egen other_expense_std=std(other_expenses)
egen fee_waiver_std=std(fee_waivers)
egen creation_fee_std=std(creation_fee)
egen stock_tweets_std=std(stock_tweets)
egen qs_dollar_tw_std=std( qs_dollar_tw)
egen qs_percent_tw_std=std(qs_percent_tw)

label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
label variable time_existence_std "ETF age (quarters)"
label variable time_since_first_std "Time since first position"
label variable log_aum_index_std "Log index AUM"
label variable d_uit "Unit investment trust"
label variable lend_byaum_bps_std "Lending income (bps of AUM)"
label variable marketing_fee_bps_std "Marketing expense (bps)"
label variable cum_mktg_expense_std "Cumulative marketing expense (log)"
label variable stock_tweets "Name recognition (Twitter msg.)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable log_volume_std "Log volume"
label variable spread_bps_crsp_std "Relative spread"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"
label variable stock_tweets_std "Name recognition (Twitter msg.)"
label variable qs_dollar_tw_std "Quoted \$ spread"
label variable qs_percent_tw_std "Quoted spread"
//
gen tii_return=ratio_tii * logret_q_lag

encode index_id, gen(index_no)


quietly regress mer_bps i.index_no i.quarter
predict mer_bps_fe, residuals

quietly regress mkt_share i.index_no i.quarter
predict mkt_share_fe, residuals



drop log_aum
gen log_aum=log(aum)


label variable mkt_share_fe "Market share"
label variable mer_bps_fe "MER"



// Code with rego command - to produce R2 decompositions (note: I capture coefficients in the Log window, and input them manually)
// ---------------------------------------------------------------------------------------

rego mkt_share_fe  qs_percent_tw_std \ stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std  \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mkt_share_fe    turnover_frac_std  \ stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std  \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mkt_share_fe    log_volume_std  \ stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std  \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_fe    qs_percent_tw_std \ stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std  \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_fe    turnover_frac_std  \ stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_fe    log_volume_std  \ stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)







// Code with double-clustering - to produce coefficients and t-stas 
// ---------------------------------------------------------------------------------------



reghdfe mkt_share  qs_percent_tw_std  stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std  ratio_tii_std  lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, absorb(index_no quarter) vce(cl index_no quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR3.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)



reghdfe mkt_share    turnover_frac_std  stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std   ratio_tii_std  lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, absorb(index_no quarter) vce(cl index_no quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe mkt_share    log_volume_std   stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std   ratio_tii_std  lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, absorb(index_no quarter) vce(cl index_no quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe mer_bps   qs_percent_tw_std stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std   ratio_tii_std lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit,  absorb(index_no quarter) vce(cl index_no quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe mer_bps    turnover_frac_std   stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std  ratio_tii_std  lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit,  absorb(index_no quarter) vce(cl index_no quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe mer_bps    log_volume_std  stock_tweets_std marketing_fee_bps_std other_expense_std fee_waiver_std  ratio_tii_std  lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit,  absorb(index_no quarter) vce(cl index_no quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\shapley_table_RR3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)






