// Load data
// -------------------------------------
clear all
set more off

local directory "D:\ResearchProjects\kpz_etfliquidity\"
// local directory "D:\Research\kpz_etfliquidity\"
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
egen other_expense_std=std(other_expenses)
egen fee_waiver_std=std(fee_waivers)
egen creation_fee_std=std(creation_fee)

gen aum_bn=aum/10^9
gen other_expenses_100=other_expenses*100
gen fee_waivers_100=fee_waivers*100

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

outreg2 using "`directory'\output\RR_RFS\sumstats.tex", replace tex sum(detail) eqkeep(N mean sd p25 p50 p75) dec(2) keep(aum_bn mer_bps spread_bps_crsp turnover_frac lend_byaum_bps tr_error_bps perf_drag_bps marketing_fee_bps  other_expenses_100 stock_tweets_raw fee_waivers_100 time_existence mgr_duration ratio_tii ratio_tra)