/// Table 6 - Investor urgency and differences in liquidity, market shares, and fees
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
egen tr_error_bps_std=std(tr_error_bps)
egen perf_drag_bps_std=std(perf_drag_bps)
egen turnover_frac_std=std(turnover_frac)
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
label variable stock_tweets_std "Name recognition (Twitter msg.)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable qs_dollar_tw_std "Quoted \$ spread"


label variable mkt_share "Market share"
label variable spread_bps_crsp "Relative spread"
label variable mer_bps "MER"
label variable logret_q_lag "Lagged return"
label variable ratio_tii "Tax-insensitive investors"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"


gen tii_return=ratio_tii * logret_q_lag


egen ratio_tra_ix_std=std(ratio_tra_ix )
gen ix_ratiotra_highfee=highfee * ratio_tra_ix_std

gen tra_above=ratio_tra_ix_std>0
gen ix_tra_above=highfee * tra_above

label variable ratio_tra_ix_std "Index AUM share of transient investors ($\text{TRA}_\text{ix}$)"
label variable ix_ratiotra_highfee "High MER $\times$ $\text{TRA}_\text{ix}$"

drop log_aum
gen log_aum=log(aum)
gen qs_bps_tw=100 * qs_percent_tw

label variable qs_bps_tw "Quoted spread"
label variable tii_return "TII $\times$ Lagged Return"


// Marius's version (with STD)
// ---------------------------------------------------------------------------------------


reghdfe mkt_share highfee ix_ratiotra_highfee ratio_tra_ix_std , absorb(index quarter) vce(cl ticker quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\effect_magnitude.tex",  adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee ix_ratiotra_highfee ratio_tra_ix_std   stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)

outreg2 using "U:\kpz_etfliquidity\data_Marta\output\effect_magnitude.tex",  adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe qs_bps_tw highfee ix_ratiotra_highfee ratio_tra_ix_std , absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\effect_magnitude.tex",  adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe qs_bps_tw   highfee ix_ratiotra_highfee ratio_tra_ix_std   stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\effect_magnitude.tex",  adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mer_bps highfee ix_ratiotra_highfee ratio_tra_ix_std , absorb(index quarter) vce(cl index quarter)

outreg2 using "U:\kpz_etfliquidity\data_Marta\output\effect_magnitude.tex",  adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe mer_bps  highfee ix_ratiotra_highfee ratio_tra_ix_std   stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)

outreg2 using "U:\kpz_etfliquidity\data_Marta\output\effect_magnitude.tex",  adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


