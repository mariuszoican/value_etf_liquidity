// Load data
// -------------------------------------
clear all
set more off

local directory "D:\ResearchProjects\kpz_etfliquidity\"
//local directory "D:\Research\kpz_etfliquidity\"
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

gen major_brand_index=1-d_ownindex
gen different_benchmarks=1-same_benchmark
gen different_lead_mm=1-same_lead_mm

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
label variable ratio_tii "Tax-insensitive investors (TII)"
label variable same_benchmark "Same benchmark"
label variable same_lead_mm "Same lead market-maker"
label variable major_brand_index "Major brand index"
label variable different_benchmarks "Different benchmarks"
label variable different_lead_mm "Different lead market-maker"

gen firstmover_diffbench=firstmover * different_benchmarks
gen firstmover_majorindex= firstmover * major_brand_index
gen firstmover_diffleadmm = firstmover * different_lead_mm

label variable firstmover "First mover"
label variable firstmover_majorindex "First mover $\times$ Major brand index"
label variable firstmover_diffbench "First mover $\times$ Different benchmarks"
label variable firstmover_diffleadmm "First mover $\times$ Different lead market-maker"

reghdfe highfee firstmover, absorb(index_id quarter) vce(cl quarter)
outreg2 using "`directory'\output\RR_RFS\highfee_determinants.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe highfee firstmover marketing_fee_bps_std other_expense_std fee_waiver_std stock_tweets lend_byaum_bps_std tr_error_bps_std creation_fee_std perf_drag_bps_std different_benchmarks different_lead_mm ratio_tii, absorb(index_id quarter) vce(cl quarter)
outreg2 using "`directory'\output\RR_RFS\highfee_determinants.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe highfee firstmover firstmover_diffbench marketing_fee_bps_std other_expense_std fee_waiver_std stock_tweets lend_byaum_bps_std tr_error_bps_std creation_fee_std perf_drag_bps_std different_benchmarks different_lead_mm ratio_tii, absorb(index_id quarter) vce(cl quarter)
outreg2 using "`directory'\output\RR_RFS\highfee_determinants.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe highfee firstmover firstmover_majorindex marketing_fee_bps_std other_expense_std fee_waiver_std stock_tweets lend_byaum_bps_std tr_error_bps_std creation_fee_std perf_drag_bps_std different_benchmarks  different_lead_mm ratio_tii, absorb(index_id quarter) vce(cl quarter)
outreg2 using "`directory'\output\RR_RFS\highfee_determinants.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)



reghdfe highfee firstmover firstmover_diffleadmm marketing_fee_bps_std other_expense_std fee_waiver_std stock_tweets lend_byaum_bps_std tr_error_bps_std creation_fee_std perf_drag_bps_std different_benchmarks  different_lead_mm ratio_tii, absorb(index_id quarter) vce(cl quarter)
outreg2 using "`directory'\output\RR_RFS\highfee_determinants.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
