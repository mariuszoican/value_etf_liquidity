// Table 4 - Fees and liquidity for competing ETFs
// -------------------------------------


// Load data
// -------------------------------------
clear all
set more off

//local directory "D:\ResearchProjects\kpz_etfliquidity\"
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
label variable stock_tweets_std "Name recognition (Twitter msg.)"
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
label variable qs_dollar_tw "Quoted \$ spread"
label variable log_volume "Log dollar volume"
label variable log_pr "Log profit"
label variable mkt_share "Market share"
label variable log_aum "Log AUM"



reghdfe mer_bps highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\table_4.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe qs_dollar_tw highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\table_4.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)



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
label variable stock_tweets_std "Name recognition (Twitter msg.)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"


//// REGRESSIONS MAIN HYPOTHESES
//// ---------------------------------------------------

gen tii_return=ratio_tii * logret_q_lag
**# Bookmark #1
gen profit=aum*mer_bps
gen log_pr=log(profit)

drop log_aum
gen log_aum=log(aum)

label variable ratio_tii "Tax-insensitive investors (TII)"
label variable logret_q_lag "Lagged ETF return"
label variable tii_return "TII $\times$ Lagged ETF return"
label variable mer_bps "MER"
label variable qs_dollar_tw "Quoted \$ spread"
label variable log_volume "Log dollar volume"
label variable log_pr "Log profit"
label variable mkt_share "Market share"
label variable log_aum "Log AUM"

reghdfe mer_bps highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR_clean.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

//// NOTE:updated spread measure to be in dollar terms (quoted spread in dollars, time-weighted)
reghdfe qs_dollar_tw highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)





//// REGRESSIONS with just spread measures - Robustness 1
//// ---------------------------------------------------


// Load data
// -------------------------------------
clear all
set more off

//local directory "D:\ResearchProjects\kpz_etfliquidity\"
local directory "U:\kpz_etfliquidity\data_Marta"
import delimited "`directory'\etf_panel_processed1.csv"



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
label variable stock_tweets_std "Name recognition (Twitter msg.)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"



gen tii_return=ratio_tii * logret_q_lag
**# Bookmark #1
gen profit=aum*mer_bps
gen log_pr=log(profit)

drop log_aum
gen log_aum=log(aum)

label variable ratio_tii "Tax-insensitive investors (TII)"
label variable logret_q_lag "Lagged ETF return"
label variable tii_return "TII $\times$ Lagged ETF return"
label variable mer_bps "MER"
label variable qs_dollar_tw "Quoted \$ spread"
label variable log_volume "Log dollar volume"
label variable log_pr "Log profit"
label variable mkt_share "Market share"
label variable log_aum "Log AUM"


gen qs_bps_tw=qs_percent_tw*100
gen es_bps_ave=es_percent_ave*100
gen rs_bps_ave=rs_percent_ave*100


reghdfe qs_dollar_tw highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR5.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe qs_bps_tw highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe es_dollar_ave highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe es_bps_ave highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe rs_dollar_ave highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe rs_bps_ave highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_RR5.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)




///-------------------------------------------------------------------------------------------------------------
/// Running regressions in the cross-section - Robustness 2
///-------------------------------------------------------------------------------------------------------------
// Load data
// -------------------------------------
clear all
set more off

local directory "U:\kpz_etfliquidity\data_Marta"
import delimited "U:\kpz_etfliquidity\data_Marta\etf_cs_processed1"

gen avg_qs_bps_tw=avg_qs_percent_tw*100
gen avg_es_bps_ave=avg_es_percent_ave*100
gen avg_rs_bps_ave=avg_rs_percent_ave*100


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
egen ratio_tii_std = std(avg_ratio_tii)

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
label variable avg_qs_bps_tw "Quoted spread"
label variable ratio_tii_std "Tax-insensitive investors (TII)"



//// REGRESSIONS MAIN HYPOTHESES - cross-sectional (Robustness for main results and share of transient investors)
//// ---------------------------------------------------

reghdfe avg_mer_bps avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std avg_d_uit ratio_tii_std, absorb(index) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_cs.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe avg_mkt_share avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std avg_d_uit ratio_tii_std, absorb(index) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe avg_qs_bps_tw avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std avg_d_uit ratio_tii_std, absorb(index) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_avg_volume avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std avg_d_uit ratio_tii_std, absorb(index) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe avg_turnover_frac avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std avg_d_uit ratio_tii_std, absorb(index) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_avg_pr avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std avg_d_uit ratio_tii_std, absorb(index) vce(cl index)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe avg_ratio_tra avg_highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std avg_d_uit ratio_tii_std, absorb(index) vce(cl index )
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_cs.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)







// Robustness 3 - panel regs only for same-index ETFs
//// ----------------------------------------------------------------------------------------------------------------



// Load data
// -------------------------------------
clear all
set more off

//local directory "D:\ResearchProjects\kpz_etfliquidity\"
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
label variable stock_tweets_std "Name recognition (Twitter msg.)"
label variable tr_error_bps_std "Tracking error (bps)"
label variable perf_drag_bps_std "Performance drag (bps)"
label variable turnover_frac_std "ETF turnover"
label variable other_expense_std "Other expenses"
label variable fee_waiver_std "Fee waivers"
label variable creation_fee_std "Creation fee"


//// REGRESSIONS 
//// ---------------------------------------------------

gen tii_return=ratio_tii * logret_q_lag
**# Bookmark #1
gen profit=aum*mer_bps
gen log_pr=log(profit)

drop log_aum
gen log_aum=log(aum)

label variable ratio_tii "Tax-insensitive investors (TII)"
label variable logret_q_lag "Lagged ETF return"
label variable tii_return "TII $\times$ Lagged ETF return"
label variable mer_bps "MER"
label variable qs_dollar_tw "Quoted \$ spread"
label variable log_volume "Log dollar volume"
label variable log_pr "Log profit"
label variable mkt_share "Market share"
label variable log_aum "Log AUM"

reghdfe mer_bps highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_Robust_clean.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_Robust_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe spread_bps_crsp highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_Robust_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_Robust_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_Robust_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_pr highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std other_expense_std fee_waiver_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return if d_sameind==1, absorb(index quarter) vce(cl index quarter)
outreg2 using "U:\kpz_etfliquidity\data_Marta\output\main_table_Robust_clean.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)








