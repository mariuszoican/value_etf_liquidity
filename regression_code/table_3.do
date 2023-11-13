
// Table 3 - Investor holding duration and ETF fees
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data/etf_panel_processed.csv"

drop spread_bps_crsp
gen spread_bps_crsp=10000*quotedspread_percent_tw 

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



reghdfe mgr_duration_tii highfee time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std  time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee turnover_frac_std stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tsi highfee time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tsi  highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std  time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tsi  highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration highfee time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std  time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee turnover_frac_std stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)





