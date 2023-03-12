// Load data
// -------------------------------------
clear all
set more off

// local directory "D:\ResearchProjects\kpz_etfliquidity\"
local directory "D:\Research\kpz_etfliquidity\"
import delimited "`directory'data\etf_panel_processed"

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


//// REGRESSIONS FOR MANAGER DURATION
//// -----------------------------------------
reghdfe mgr_duration highfee time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee turnover_frac_std stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii highfee time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee turnover_frac_std stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


//
reghdfe mgr_duration_tsi highfee time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tsi  highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

// reghdfe mgr_duration_tsi  highfee turnover_frac_std stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
// outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


//// REGRESSIONS FOR RATIO TRANSIENT
//// -----------------------------------------

reghdfe ratio_tra highfee , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_ratiotra.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_ratiotra.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_ratiotra.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std, absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_ratiotra.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_ratiotra.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\clientele_ratiotra.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


//// REGRESSIONS MAIN HYPOTHESES
//// ---------------------------------------------------

gen tii_return=ratio_tii * logret_q_lag
**# Bookmark #1
gen profit=aum*mer_bps
gen log_pr=log(profit)

label variable ratio_tii "Tax-insensitive investors (TII)"
label variable logret_q_lag "Lagged ETF return"
label variable tii_return "TII $\times$ Lagged ETF return"
label variable mer_bps "MER"
label variable spread_bps_crsp "Relative spread"
label variable log_volume "Log dollar volume"
label variable log_pr "Log profit"
label variable mkt_share "Market share"

reghdfe mer_bps highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\main_table_RR.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_bps_crsp highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\main_table_RR.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\main_table_RR.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\main_table_RR.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\main_table_RR.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker)
outreg2 using "`directory'\output\RR_RFS\main_table_RR.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

