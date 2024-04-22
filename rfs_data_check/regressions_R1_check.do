
// Table 2 - Transient investors and ETF fees
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

local directory : pwd
display "`working_dir'"
import delimited "`directory'\df_R1_replication_quarterly.csv"



reghdfe volumeshare highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe logvolume highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe aumshare highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe logaum highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_win highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe discount_win_abs highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)


clear all
set more off

local directory : pwd
display "`working_dir'"
import delimited "`directory'\df_R1_replication_quarterly_longbenchmark.csv"



reghdfe volumeshare highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1_longbenchmark.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe logvolume highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1_longbenchmark.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe aumshare highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1_longbenchmark.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe logaum highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1_longbenchmark.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe spread_win highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1_longbenchmark.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

reghdfe discount_win_abs highfee , absorb(primary_benchmark quarter) vce(cl composite_ticker quarter)
outreg2 using "`directory'/regressions_r1_longbenchmark.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)

