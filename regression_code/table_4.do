
// Table 4 - Main hypotheses
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data/etf_panel_processed.csv"


// // Label variables
// // ---------------------------------

egen time_existence_std=std(time_existence)
egen time_since_first_std=std(time_since_first)
egen log_aum_index_std=std(log_aum_index)
egen lend_byaum_bps_std=std(lend_byaum_bps)
egen marketing_fee_bps_std=std(marketing_fee_bps)
egen tr_error_bps_std=std(tr_error_bps)
egen perf_drag_bps_std=std(perf_drag_bps)
egen turnover_frac_std=std(turnover_frac)
gen  net_expense_mer=other_expense-marketing_fee_bps/100+fee_waiver
egen net_expenses_std=std(net_expense_mer)
egen stock_tweets_std=std(stock_tweets)

label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
label variable time_existence_std "ETF age (quarters)"
label variable time_since_first_std "Time since first position"
label variable log_aum_index_std "Log index AUM"
label variable d_uit "Unit investment trust"
label variable lend_byaum_bps_std "Lending income (bps of AUM)"
label variable marketing_fee_bps_std "Marketing expense (bps)"
label variable stock_tweets "Name recognition (Twitter msg.)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable net_expenses_std "Other net expenses"
label variable stock_tweets_std "Stock tweets"


gen tii_return=ratio_tii * logret_q_lag
gen profit=aum*mer_bps
gen log_pr=log(profit)

drop log_aum
gen log_aum=log(aum)

label variable ratio_tii "Tax-insensitive investors (TII)"
label variable logret_q_lag "Lagged ETF return"
label variable tii_return "TII $\times$ Lagged ETF return"
label variable mer_bps "MER"
label variable spread_bps_crsp "Relative spread"
label variable log_volume "Log dollar volume"
label variable log_pr "Log profit"
label variable mkt_share "Market share"
label variable log_aum "Log AUM"



reghdfe mer_bps highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_4.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_bps_crsp highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)



// Robustness
reghdfe mer_bps highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E1.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_bps_crsp highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)