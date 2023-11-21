// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data/etf_panel_processed.csv"
//import delimited "D:/Research/kpz_etfliquidity/data/etf_panel_processed.csv"

drop spread_bps_crsp
gen spread_bps_crsp=10000*quotedspread_percent_tw 

gen eff_spread_bps=10000*effectivespread_percent_ave
gen rspread_bps=10000*percentrealizedspread_lr_ave


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

gen aum_bn=aum/10^9
gen other_expenses_100=other_expenses*100
gen fee_waivers_100=fee_waivers*100

gen  net_expense_mer=other_expenses-marketing_fee_bps/100+fee_waivers
gen net_expense_100=net_expense_mer*100

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
label variable ratio_tra "AUM share of transient investors"
label variable spread_bps_crsp "Quoted spread (bps)"
label variable eff_spread_bps "Effective spread (bps)"
label variable rspread_bps "Realized spread (bps)"


outreg2 using "`directory'\output\table_1.tex", replace tex sum(detail) eqkeep(N mean sd p25 p50 p75) dec(2) keep(aum_bn mer_bps spread_bps_crsp eff_spread_bps rspread_bps turnover_frac ratio_tra  ratio_tii  mgr_duration lend_byaum_bps marketing_fee_bps stock_tweets_raw other_expenses_100 fee_waivers_100 tr_error_bps perf_drag_bps )
//outreg2 using "D:/Research/kpz_etfliquidity/output/table_1.tex", replace tex sum(detail) eqkeep(N mean sd p25 p50 p75) dec(2) keep(aum_bn mer_bps spread_bps_crsp eff_spread_bps rspread_bps turnover_frac ratio_tra  ratio_tii  mgr_duration lend_byaum_bps marketing_fee_bps stock_tweets_raw other_expenses_100 fee_waivers_100 tr_error_bps perf_drag_bps )