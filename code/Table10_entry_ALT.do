// Load data
// -------------------------------------
clear all
set more off

local directory "D:\ResearchProjects\kpz_etfliquidity\"
import delimited "`directory'data\entry_analysis_AUM.csv"

gen log_AUM_etf=log(aum_q)

label variable mkt_share "Market share"
label variable mer_bps "MER"
label variable spread_bps_crsp "Relative spread"
label variable d_lwc "Post-entry"
label variable tr_error_bps "Tracking error"
label variable perf_drag_bps "Performance drag"
label variable marketing_fee_bps "Marketing expenses"
label variable log_AUM_etf "Log AUM"

reghdfe mkt_share d_lwc, absorb(ticker) vce(cluster ticker)
outreg2 using "`directory'output\Table10_Entry_Alt.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe mkt_share d_lwc tr_error_bps perf_drag_bps marketing_fee_bps, absorb(ticker) vce(cluster ticker)
outreg2 using "`directory'output\Table10_Entry_Alt.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe mer_bps d_lwc, absorb(ticker) vce(cluster ticker)
outreg2 using "`directory'output\Table10_Entry_Alt.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe mer_bps d_lwc tr_error_bps perf_drag_bps marketing_fee_bps, absorb(ticker) vce(cluster ticker)
outreg2 using "`directory'output\Table10_Entry_Alt.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_bps_crsp d_lwc, absorb(ticker) vce(cluster ticker)
outreg2 using "`directory'output\Table10_Entry_Alt.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe spread_bps_crsp d_lwc tr_error_bps perf_drag_bps marketing_fee_bps, absorb(ticker) vce(cluster ticker)
outreg2 using "`directory'output\Table10_Entry_Alt.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe log_AUM_etf d_lwc, absorb(ticker) vce(cluster ticker)
outreg2 using "`directory'output\Table10_Entry_Alt.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe log_AUM_etf  d_lwc tr_error_bps perf_drag_bps marketing_fee_bps, absorb(ticker) vce(cluster ticker)
outreg2 using "`directory'output\Table10_Entry_Alt.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


