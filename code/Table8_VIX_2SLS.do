// Load data
// -------------------------------------
clear all
set more off

local directory "D:\ResearchProjects\kpz_etfliquidity\"
import excel "`directory'data\reg_panel.xlsx", firstrow


label variable mer_bps "MER"
label variable spread_bps_crsp "Relative spread"
label variable tr_error_bps "Tracking error"
label variable logDvol "Log dollar volume"
label variable perf_drag_bps "Performance drag"
label variable mkt_share "Market share"
label variable turnover_frac "Turnover"
label variable d_UIT "$D_\text{UIT}$"
label variable lend_byAUM_bps "Lending income"
label variable marketing_fee_bps "Marketing expenses"

reghdfe mer_bps spread_bps_crsp, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table2.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(1)") title("Management expense ratio")

reghdfe mer_bps spread_bps_crsp tr_error_bps perf_drag_bps d_UIT lend_byAUM_bps marketing_fee_bps, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table2.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(2)") title("Management expense ratio")

reghdfe mer_bps logDvol, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table2.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(3)") title("Management expense ratio")

reghdfe mer_bps logDvol tr_error_bps perf_drag_bps d_UIT lend_byAUM_bps marketing_fee_bps, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table2.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(4)") title("Management expense ratio")

reghdfe mer_bps turnover_frac, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table2.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(5)") title("Management expense ratio")

reghdfe mer_bps turnover_frac tr_error_bps perf_drag_bps d_UIT lend_byAUM_bps marketing_fee_bps, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table2.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(6)") title("Management expense ratio")

reghdfe mer_bps mkt_share, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table2.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(7)") title("Management expense ratio")

reghdfe mer_bps mkt_share tr_error_bps perf_drag_bps d_UIT lend_byAUM_bps marketing_fee_bps, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table2.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) ctitle("(8)") title("Management expense ratio")