// Load data
// -------------------------------------
clear all
set more off

local directory "D:\ResearchProjects\kpz_etfliquidity\"
import excel "`directory'data\reg_lf.xlsx", firstrow

label variable delta_mkt_share "$\Delta$ Market share"
label variable delta_mer_bps "$\Delta$ MER"
label variable delta_spread_bps "$\Delta$ Relative spread"
label variable delta_tr_error_bps "$\Delta$ Tracking error"
label variable delta_perf_drag_bps "$\Delta$ Performance drag"
label variable d_UIT "$ D_\text{UIT}$"
label variable ix_ratio_hu "Investor heterogeneity"
label variable delta_lend_byAUM_bps "$\Delta$ Lending income"
label variable delta_marketing_fee_bps "$\Delta$ Marketing expenses"

gen yearmonth_index=yearmonth+index_id


reghdfe delta_mkt_share ix_ratio_hu, absorb(index_id yearmonth) vce(cluster yearmonth_index)
outreg2 using "`directory'\output\table6.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("$\Delta$ Market share")

reghdfe delta_mkt_share ix_ratio_hu delta_tr_error_bps delta_perf_drag_bps d_UIT delta_lend_byAUM_bps delta_marketing_fee_bps, absorb(index_id yearmonth) vce(cluster yearmonth_index)
outreg2 using "`directory'\output\table6.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("$\Delta$ Market share")

reghdfe delta_mer_bps ix_ratio_hu, absorb(index_id yearmonth) vce(cluster yearmonth_index)
outreg2 using "`directory'\output\table6.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("$\Delta$ MER")

reghdfe delta_mer_bps ix_ratio_hu delta_tr_error_bps delta_perf_drag_bps d_UIT delta_lend_byAUM_bps delta_marketing_fee_bps, absorb(index_id yearmonth) vce(cluster yearmonth_index)
outreg2 using "`directory'\output\table6.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("$\Delta$ MER")

reghdfe delta_spread_bps ix_ratio_hu, absorb(index_id yearmonth) vce(cluster yearmonth_index)
outreg2 using "`directory'\output\table6.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("$\Delta$ Relative spread")

reghdfe delta_spread_bps ix_ratio_hu delta_tr_error_bps delta_perf_drag_bps d_UIT delta_lend_byAUM_bps delta_marketing_fee_bps, absorb(index_id yearmonth) vce(cluster yearmonth_index)
outreg2 using "`directory'\output\table6.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("$\Delta$ Relative spread")