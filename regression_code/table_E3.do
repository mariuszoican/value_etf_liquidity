
// Table 4 - Main hypotheses
// -------------------------------------

// Load data
// -------------------------------------
clear all
set more off

cd ..
local directory : pwd
display "`working_dir'"
import delimited "`directory'/data/etf_panel_processed.csv"

drop spread_bps_crsp
gen spread_bps_crsp=10000*quotedspread_percent_tw 

egen time_existence_std=std(time_existence)
egen time_since_first_std=std(time_since_first)
egen log_aum_index_std=std(log_aum_index)
egen lend_byaum_bps_std=std(lend_byaum_bps)
egen marketing_fee_bps_std=std(marketing_fee_bps)
egen tr_error_bps_std=std(tr_error_bps)
egen perf_drag_bps_std=std(perf_drag_bps)
egen turnover_frac_std=std(turnover_frac)
gen  net_expense_mer=other_expense-marketing_fee_bps/100+fee_waiver
egen net_expenses_std=std(net_expense_mer)
egen stock_tweets_std=std(stock_tweets)

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
label variable net_expenses_std "Other net expenses"
label variable stock_tweets_std "Stock tweets"


label variable mkt_share "Market share"
label variable spread_bps_crsp "Relative spread"
label variable mer_bps "MER"
label variable logret_q_lag "Lagged return"
label variable ratio_tii "Tax-insensitive investors"


gen tii_return=ratio_tii * logret_q_lag
label variable tii_return "TII $\times$ Lagged return"


egen ratio_tra_ix_std=std(ratio_tra_ix )
gen ix_ratiotra_highfee=highfee * ratio_tra_ix_std

gen tra_above=ratio_tra_ix_std>0
gen ix_tra_above=highfee * tra_above

label variable ratio_tra_ix_std "Index AUM share of transient investors ($\text{TRA}_\text{ix}$)"
label variable ix_ratiotra_highfee "High MER $\times$ $\text{TRA}_\text{ix}$"

drop log_aum
gen log_aum=log(aum)


gen qspread_bps=10000*quotedspread_percent_tw 
gen qspread_dollar=100*quotedspread_dollar_tw 

gen efspread_dollar=100*effectivespread_dollar_ave
gen efspread_bps=10000*effectivespread_percent_ave

gen rspread_dollar=100*dollarrealizedspread_lr_ave
gen rspread_bps=10000*percentrealizedspread_lr_ave



reghdfe qspread_bps highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E3.tex", adjr2 replace tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe qspread_dollar highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe efspread_bps highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe efspread_dollar highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe rspread_bps highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)
reghdfe rspread_dollar highfee stock_tweets_std log_aum_index_std lend_byaum_bps_std marketing_fee_bps_std net_expenses_std tr_error_bps_std perf_drag_bps_std d_uit ratio_tii logret_q_lag tii_return, absorb(index quarter) vce(cl ticker quarter)
outreg2 using "`directory'/output/table_E3.tex", adjr2 append tex tstat label  dec(2) tdec(2) eqdrop(/) keep(*)