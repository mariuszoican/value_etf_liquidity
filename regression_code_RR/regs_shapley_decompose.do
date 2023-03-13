// Load data
// -------------------------------------
clear all
set more off

// local directory "D:\ResearchProjects\kpz_etfliquidity\"
local directory "D:\Research\kpz_etfliquidity\"
// import delimited "`directory'data\etf_panel_differences_RR.csv"
import delimited "`directory'data\etf_panel_processed"

egen time_existence_std=std(time_existence)
egen time_since_first_std=std(time_since_first)
egen log_aum_index_std=std(log_aum_index)
egen lend_byaum_bps_std=std(lend_byaum_bps)
egen marketing_fee_bps_std=std(marketing_fee_bps)
egen tr_error_bps_std=std(tr_error_bps)
egen perf_drag_bps_std=std(perf_drag_bps)
egen turnover_frac_std=std(turnover_frac)

//
gen tii_return=ratio_tii * logret_q_lag

encode index_id, gen(index_no)

// keep if marketing_fee_bps>0

quietly regress mer_bps_diff i.index_no i.quarter
predict mer_bps_fe, residuals


reghdfe mer_bps highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index_id quarter) vce(cl ticker)


rego mer_bps_fe highfee stock_tweets log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return 