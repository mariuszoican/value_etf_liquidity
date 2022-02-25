// Load data
// -------------------------------------
clear all
set more off

local directory "D:\ResearchProjects\kpz_etfliquidity\"
import excel "`directory'data\reg_panel_hetero.xlsx", firstrow

label variable urgency_mean "Urgency"
label variable d_firstETF "First-ETF dummy"
label variable sequence_of_entry "ETF sequence of entry"
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

reghdfe urgency_mean d_firstETF, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table3.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) addtext(Index FE, Yes, Year-month FE, YES) ctitle("Urgency")

reghdfe urgency_mean d_firstETF tr_error_bps perf_drag_bps d_UIT lend_byAUM_bps marketing_fee_bps, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table3.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) addtext(Index FE, Yes, Year-month FE, YES) ctitle("Urgency")

reghdfe urgency_mean sequence_of_entry tr_error_bps perf_drag_bps d_UIT lend_byAUM_bps marketing_fee_bps, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table3.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) addtext(Index FE, Yes, Year-month FE, YES) ctitle("Urgency")


reghdfe turnover_frac d_firstETF, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table3.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) addtext(Index FE, Yes, Year-month FE, YES) ctitle("Turnover")

reghdfe turnover_frac d_firstETF tr_error_bps perf_drag_bps d_UIT lend_byAUM_bps marketing_fee_bps, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table3.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) addtext(Index FE, Yes, Year-month FE, YES) ctitle("Turnover")

reghdfe turnover_frac sequence_of_entry tr_error_bps perf_drag_bps d_UIT lend_byAUM_bps marketing_fee_bps, absorb(index yearmonth) vce(cluster index yearmonth)
outreg2 using "`directory'\output\table3.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) addtext(Index FE, Yes, Year-month FE, YES) ctitle("Turnover")