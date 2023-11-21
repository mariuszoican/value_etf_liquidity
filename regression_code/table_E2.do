
// Table 4 - Main hypotheses
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data/cs_panel.csv"

drop spread_bps_crsp
gen spread_bps_crsp=10000*quotedspread_percent_tw 


// // Label variables
// // ---------------------------------

egen log_aum_index_std=std(log_aum_index)
egen lend_byaum_bps_std=std(lend_byaum_bps)
egen marketing_fee_bps_std=std(marketing_fee_bps)
egen tr_error_bps_std=std(tr_error_bps)
egen perf_drag_bps_std=std(perf_drag_bps)
egen turnover_frac_std=std(turnover_frac)
egen net_expenses_std=std(net_expense_mer)
egen stock_tweets_std=std(stock_tweets)
egen ratio_tii_std=std(ratio_tii)

label variable mgr_duration "Investor holding duration"
label variable highfee "High MER"
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


gen profit=aum*mer_bps
gen log_pr=log(profit)


label variable ratio_tii "Tax-insensitive investors (TII)"
label variable mer_bps "MER"
label variable spread_bps_crsp "Relative spread"
label variable log_volume "Log dollar volume"
label variable log_pr "Log profit"
label variable mkt_share "Market share"



reghdfe mer_bps highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii_std , absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'/output/table_E2.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_bps_crsp highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii_std , absorb(index_id)vce(cluster index_id)
outreg2 using "`directory'/output/table_E2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_volume highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii_std , absorb(index_id)vce(cluster index_id)
outreg2 using "`directory'/output/table_E2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe turnover_frac highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii_std , absorb(index_id)vce(cluster index_id)
outreg2 using "`directory'/output/table_E2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mkt_share highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii_std , absorb(index_id)vce(cluster index_id)
outreg2 using "`directory'/output/table_E2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


reghdfe log_pr highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii_std , absorb(index_id)vce(cluster index_id)
outreg2 using "`directory'/output/table_E2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe ratio_tra highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii_std , absorb(index_id)vce(cluster index_id)
outreg2 using "`directory'/output/table_E2.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

