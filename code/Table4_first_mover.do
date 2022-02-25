// Load data
// -------------------------------------
clear all
set more off

local directory "D:\ResearchProjects\kpz_etfliquidity\"
import delimited "`directory'data\data_all_controls.csv"


label variable mer_bps "MER"
label variable d_firstetf "First-ETF dummy"
label variable spread_bps_crsp "Relative spread"
label variable tr_error_bps "Tracking error"
label variable logdvol "Log dollar volume"
label variable perf_drag_bps "Performance drag"
label variable mkt_share "Market share"
label variable turnover_frac "Turnover"
label variable d_uit "$D_\text{UIT}$"
label variable lend_byaum_bps "Lending income"
label variable marketing_fee_bps "Marketing expenses"

reghdfe mer_bps d_firstetf tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table4.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("MER")

reghdfe spread_bps_crsp d_firstetf tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table4.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("Relative spread")

reghdfe logdvol d_firstetf tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table4.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("Log dollar volume")

reghdfe turnover_frac d_firstetf tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table4.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("Turnover")

reghdfe logetfprofit d_firstetf tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table4.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("Log profit")

reghdfe mkt_share d_firstetf tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table4.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("Market share")