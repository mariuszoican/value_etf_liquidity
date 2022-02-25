// Load data
// -------------------------------------
clear all
set more off

local directory "D:\ResearchProjects\kpz_etfliquidity\"
import delimited "`directory'data\data_all_controls.csv"


label variable mer_bps "MER"
label variable spread_bps_crsp "Relative spread"
label variable tr_error_bps "Tracking error"
label variable logdvol "Log dollar volume"
label variable perf_drag_bps "Performance drag"
label variable mkt_share "Market share"
label variable turnover_frac "Turnover"
label variable d_uit "$D_\text{UIT}$"
label variable lend_byaum_bps "Lending income"
label variable marketing_fee_bps "Marketing expenses"

reghdfe mer_bps spread_bps_crsp, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table1.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(1)") title("Management expense ratio")

reghdfe mer_bps spread_bps_crsp tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table1.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(2)") title("Management expense ratio")

reghdfe mer_bps logdvol, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table1.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(3)") title("Management expense ratio")

reghdfe mer_bps logdvol tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table1.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(4)") title("Management expense ratio")

reghdfe mer_bps turnover_frac, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table1.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(5)") title("Management expense ratio")

reghdfe mer_bps turnover_frac tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table1.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(6)") title("Management expense ratio")

reghdfe mer_bps mkt_share, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table1.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(7)") title("Management expense ratio")

reghdfe mer_bps mkt_share tr_error_bps perf_drag_bps d_uit lend_byaum_bps marketing_fee_bps, absorb(index_id) vce(cluster index_id)
outreg2 using "`directory'\output\table1.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(8)") title("Management expense ratio")