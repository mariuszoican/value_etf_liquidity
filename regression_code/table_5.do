
// Table 5 - Shapley values
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data/etf_panel_processed.csv"


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
egen ratio_tii_std=std(ratio_tii)
egen log_volume_std=std(log_volume)
egen spread_bps_crsp_std=std(spread_bps_crsp)
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
label variable net_expenses_std "Other net expenses"
label variable stock_tweets_std "Stock tweets"
label variable log_volume_std "Log volume"
label variable spread_bps_crsp_std "Relative spread"
label variable creation_fee_std "Creation fee"





//
gen tii_return=ratio_tii * logret_q_lag

encode index_id, gen(index_no)

// keep if marketing_fee_bps>0

quietly regress mer_bps i.index_no i.quarter
predict mer_bps_fe, residuals

quietly regress mkt_share i.index_no i.quarter
predict mkt_share_fe, residuals



drop log_aum
gen log_aum=log(aum)

// quietly regress log_aum i.index_no i.quarter
// predict mkt_share_fe, residuals

label variable mkt_share_fe "Market share"
label variable mer_bps_fe "MER"

rego mkt_share_fe   spread_bps_crsp_std \ stock_tweets marketing_fee_bps_std other_expense_std fee_waiver_std  \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "`directory'\output\table_5.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mkt_share_fe    turnover_frac_std  \ stock_tweets marketing_fee_bps_std other_expense_std fee_waiver_std  \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "`directory'\output\table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mkt_share_fe    log_volume_std  \ stock_tweets marketing_fee_bps_std other_expense_std fee_waiver_std  \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "`directory'\output\table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_fe    spread_bps_crsp_std \ stock_tweets marketing_fee_bps_std other_expense_std fee_waiver_std  \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "`directory'\output\table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_fe    turnover_frac_std  \ stock_tweets marketing_fee_bps_std other_expense_std fee_waiver_std \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "`directory'\output\table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

rego mer_bps_fe    log_volume_std  \ stock_tweets marketing_fee_bps_std other_expense_std fee_waiver_std \ ratio_tii_std \ lend_byaum_bps_std  tr_error_bps_std perf_drag_bps_std d_uit, vce(cl quarter)
outreg2 using "`directory'\output\table_5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)