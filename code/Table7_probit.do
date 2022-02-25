// Load data
// -------------------------------------
clear all
set more off

local directory "D:\ResearchProjects\kpz_etfliquidity\"
import excel "`directory'data\probit_data.xlsx", firstrow


label variable sep_ind_ "Multi-ETF index"
label variable ratio_hu "Investor heterogeneity"
label variable dvol_ind_bn "Dollar volume"
label variable aum_ind_bn "Assets under management"
label variable top3_ind "Top 3 issuer dummy"
label variable num_const_00 "Number of constituents"
label variable spread_ind_bps "Relative spread"


probit sep_ind_ ratio_hu aum_ind_bn top3_ind
outreg2 using "`directory'\output\table7.tex", replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) 
probit sep_ind_ ratio_hu aum_ind_bn spread_ind_bps top3_ind num_const_00
outreg2 using "`directory'\output\table7.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) 
probit sep_ind_ ratio_hu dvol_ind_bn aum_ind_bn top3_ind
outreg2 using "`directory'\output\table7.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) 
probit sep_ind_ ratio_hu dvol_ind_bn spread_ind_bps top3_ind 
outreg2 using "`directory'\output\table7.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) 
probit sep_ind_ ratio_hu dvol_ind_bn spread_ind_bps top3_ind num_const_00
outreg2 using "`directory'\output\table7.tex", append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*) 

