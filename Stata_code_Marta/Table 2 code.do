
// Table 2 - Transient investors and ETF fees
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

//local directory "U:\kpz_etfliquidity\data_Marta"

local directory "D:\Research\kpz_etfliquidity\data_Marta"
import delimited "`directory'\etf_panel_processed"

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
label variable stock_tweets "Name recognition (Twitter msg.)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"
label variable stock_tweets_std "Stock tweets"



//// REGRESSIONS FOR RATIO TRANSIENT - Marius's version 

//NOTE: standardised variables: log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std 

//// -----------------------------------------

reghdfe ratio_tra highfee , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)





//// REGRESSIONS FOR RATIO TRANSIENT - Marta's version 

//NOTE: replace standardised variables (log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std ) with non-standardised

//// -----------------------------------------

label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
label variable time_existence "ETF age (quarters)"
label variable time_since_first "Time since first position"
label variable log_aum_index "Log index AUM"
label variable d_uit "Unit investment trust"
label variable lend_byaum_bps "Lending income (bps of AUM)"
label variable marketing_fee_bps "Marketing expense (bps)"
label variable stock_tweets "Name recognition (Twitter msg.)"
label variable tr_error_bps "Tracking error (bps)"
label variable perf_drag_bps "Performance drag (bps)"
label variable turnover_frac "ETF turnover"
label variable other_expenses "Other expenses"
label variable fee_waivers "Fee waivers"
label variable creation_fee "Creation fee"



reghdfe ratio_tra highfee , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra2.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe ratio_tra highfee stock_tweets log_aum_index , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps, absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_ratiotra2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)



//// REGRESSIONS FOR RATIO TRANSIENT - Talis's version 

//NOTE1: replace standardised variables (log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std ) with non-standardised
//NOTE2: use different code: Example: reghdfe ln_wage age i.race, absorb(temp) cluster(idcode year)

//// -----------------------------------------



reghdfe ratio_tra highfee, absorb(index quarter) cluster(index quarter)
outreg2 using "`directory'\output\clientele_ratiotra3.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) cluster(index quarter)
outreg2 using "`directory'\output\clientele_ratiotra3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe ratio_tra highfee stock_tweets log_aum_index , absorb(index quarter) cluster(index quarter)
outreg2 using "`directory'\output\clientele_ratiotra3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps, absorb(index quarter) cluster(index quarter)
outreg2 using "`directory'\output\clientele_ratiotra3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers , absorb(index quarter) cluster(index quarter)
outreg2 using "`directory'\output\clientele_ratiotra3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) cluster(index quarter)
outreg2 using "`directory'\output\clientele_ratiotra3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


