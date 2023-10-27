// Table 3 - Investor holding duration
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

local directory "U:\kpz_etfliquidity\data_Marta"
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


//// REGRESSIONS FOR MANAGER DURATION
//// -----------------------------------------
reghdfe mgr_duration highfee time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee turnover_frac_std stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii highfee time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee turnover_frac_std stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

//
reghdfe mgr_duration_tsi highfee time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tsi  highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

// reghdfe mgr_duration_tsi  highfee turnover_frac_std stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit time_existence_std time_since_first_std , absorb(index quarter) vce(cl index quarter)
// outreg2 using "`directory'\output\RR_RFS\clientele_duration.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)



//// REGRESSIONS FOR MANAGER DURATION - without std
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


reghdfe mgr_duration highfee time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration2.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee turnover_frac stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii highfee time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee turnover_frac stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

//
reghdfe mgr_duration_tsi highfee time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tsi  highfee stock_tweets log_aum_index lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)




//// REGRESSIONS FOR MANAGER DURATION - without loAUMindex (because multicollinear with index FE)
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


reghdfe mgr_duration highfee time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration3.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee turnover_frac stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii highfee time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee turnover_frac stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

//
reghdfe mgr_duration_tsi highfee time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tsi  highfee stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb(index quarter) vce(cl index quarter)
outreg2 using "`directory'\output\clientele_duration3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)






//// REGRESSIONS FOR MANAGER DURATION - without time_existence
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

reghdfe mgr_duration highfee time_existence time_since_first , absorb( index quarter) vce(cl   quarter)
outreg2 using "`directory'\output\clientele_duration4.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb( index quarter) vce(cl   quarter)
outreg2 using "`directory'\output\clientele_duration4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration  highfee turnover_frac stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit  time_existence time_since_first , absorb(index  quarter) vce(cl   quarter)
outreg2 using "`directory'\output\clientele_duration4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii highfee time_existence time_since_first , absorb(index  quarter) vce(cl   quarter)
outreg2 using "`directory'\output\clientele_duration4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb( index quarter) vce(cl   quarter)
outreg2 using "`directory'\output\clientele_duration4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tii  highfee turnover_frac stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence time_since_first , absorb( index quarter) vce(cl   quarter)
outreg2 using "`directory'\output\clientele_duration4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tsi highfee time_existence time_since_first , absorb(index quarter) vce(cl quarter)
outreg2 using "`directory'\output\clientele_duration4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mgr_duration_tsi  highfee stock_tweets  lend_byaum_bps marketing_fee_bps other_expenses fee_waivers tr_error_bps perf_drag_bps d_uit time_existence  time_since_first , absorb(index quarter) vce(cl quarter)
outreg2 using "`directory'\output\clientele_duration4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

