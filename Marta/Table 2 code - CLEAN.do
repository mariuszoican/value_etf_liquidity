
// Table 2 - Transient investors and ETF fees
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

local directory "U:\kpz_etfliquidity\data_Marta"
import delimited "`directory'\etf_panel_processed1.csv"

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
egen other_expense_std=std(other_expenses)
egen fee_waiver_std=std(fee_waivers)
egen creation_fee_std=std(creation_fee)
egen stock_tweets_std=std(stock_tweets)

label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
label variable time_existence_std "ETF age (quarters)"
label variable time_since_first_std "Time since first position"
label variable log_aum_index_std "Log index AUM"
label variable d_uit "Unit investment trust"
label variable lend_byaum_bps_std "Lending income (bps of AUM)"
label variable marketing_fee_bps_std "Marketing expense (bps)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"
label variable stock_tweets_std "Name recognition (Twitter msg.)"



//// REGRESSIONS FOR RATIO TRANSIENT (Table 2) - panel
//// -----------------------------------------

reghdfe ratio_tra highfee , absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_clean.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)




//// 

//CROSS-SECTIONAL REGRESSIONS - COMBINE OUTPUT FROM SEVERAL TABLES (CHOOSE TEH MOST FULL SPECIFICATION) 

//1) REGRESSIONS FOR RATIO TRANSIENT (Table 2) - cross-section - REGS 2 AND 6
//
//// -----------------------------------------


///-------------------------------------------------------------------------------------------------------------
// Load data
// -------------------------------------
clear all
set more off

local directory "U:\kpz_etfliquidity\data_Marta"
import delimited "`directory'\etf_cs_processed1"


egen time_existence_std=std(avg_time_existence)
egen time_since_first_std=std(avg_time_since_first)
egen log_aum_index_std=std(log_avg_aum_index)
egen lend_byaum_bps_std=std(avg_lend_byaum_bps)
egen marketing_fee_bps_std=std(avg_marketing_fee_bps)
egen tr_error_bps_std=std(avg_tr_error_bps)
egen perf_drag_bps_std=std(avg_perf_drag_bps)
egen turnover_frac_std=std(avg_turnover_frac)
egen other_expense_std=std(avg_other_expenses)
egen fee_waiver_std=std(avg_fee_waivers)
egen creation_fee_std=std(avg_creation_fee)
egen stock_tweets_std=std(avg_stock_tweets)

label variable avg_mgr_duration "Investor holding duration"
label variable avg_highfee "High MER"
label variable time_existence_std "ETF age (quarters)"
label variable time_since_first_std "Time since first position"
label variable log_aum_index_std "Log index AUM"
label variable avg_d_uit "Unit investment trust"
label variable lend_byaum_bps_std "Lending income (bps of AUM)"
label variable marketing_fee_bps_std "Marketing expense (bps)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"
label variable stock_tweets_std "Name recognition (Twitter msg.)"


reghdfe avg_ratio_tra avg_highfee , absorb(index) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_cs.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe avg_ratio_tra avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std avg_d_uit time_existence_std time_since_first_std , absorb(index) vce(cl index )
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe avg_ratio_tra avg_highfee stock_tweets_std log_aum_index_std , absorb(index) vce(cl index )
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe avg_ratio_tra avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std, absorb(index) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe avg_ratio_tra avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std , absorb(index ) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe avg_ratio_tra avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std avg_d_uit time_existence_std time_since_first_std , absorb(index) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\clientele_ratiotra_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
