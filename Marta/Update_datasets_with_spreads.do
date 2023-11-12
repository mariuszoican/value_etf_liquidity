
///-------------------------------------------------------------------------------------------------------------
/// Adding spreads data (realised spread, effective spread, absolute quoted spread)
///-------------------------------------------------------------------------------------------------------------


* Load the first dataset
import delimited "U:\kpz_etfliquidity\data_Marta\etf_spread_measures.csv", clear

* Create a date variable from the string date
gen datevar = date(date, "YMD")

* Format the date variable as a Stata date
format datevar %td

* Generate the year-quarter variable
gen year = year(datevar)
gen quarter_ = quarter(datevar)
gen quarter = year*10 + quarter_

* Ensure the ticker variable is in the correct format (if necessary, adjust as needed)
destring ticker, replace

* Save the dataset with the yearquarter variable
save "U:\kpz_etfliquidity\data_Marta\etf_spread_measures_with_yq.dta", replace



* Load the dataset
use "U:\kpz_etfliquidity\data_Marta\etf_spread_measures_with_yq.dta", clear


* Sort the data and take averages
bysort ticker quarter: egen QS_dollar_tw = mean(quotedspread_dollar_tw)
bysort ticker quarter: egen QS_percent_tw = mean(quotedspread_percent_tw)
bysort ticker quarter: egen ES_dollar_ave = mean(effectivespread_dollar_ave)
bysort ticker quarter: egen ES_percent_ave = mean(effectivespread_percent_ave)
bysort ticker quarter: egen RS_dollar_ave = mean(dollarrealizedspread_lr_ave)
bysort ticker quarter: egen  RS_percent_ave = mean(percentrealizedspread_lr_ave)
bysort ticker quarter: egen PI_dollar_ave = mean(dollarpriceimpact_lr_ave)
bysort ticker quarter: egen PI_percent_ave = mean(percentpriceimpact_lr_ave)

bysort ticker quarter: egen ES_dollar_dw = mean(effectivespread_dollar_dw)
bysort ticker quarter: egen ES_dollar_sw = mean(effectivespread_dollar_sw)
bysort ticker quarter: egen ES_percent_dw = mean(effectivespread_percent_dw)
bysort ticker quarter: egen ES_percent_sw = mean(effectivespread_percent_sw)
bysort ticker quarter: egen RS_dollar_sw = mean(dollarrealizedspread_lr_sw)
bysort ticker quarter: egen RS_dollar_dw = mean(dollarrealizedspread_lr_dw)
bysort ticker quarter: egen RS_percent_sw = mean(percentrealizedspread_lr_sw)
bysort ticker quarter: egen RS_percent_dw = mean(percentrealizedspread_lr_dw)
bysort ticker quarter: egen PI_dollar_sw = mean(dollarpriceimpact_lr_sw)
bysort ticker quarter: egen PI_dollar_dw = mean(dollarpriceimpact_lr_dw)
bysort ticker quarter: egen PI_percent_sw = mean(percentpriceimpact_lr_sw)
bysort ticker quarter: egen PI_percent_dw = mean(percentpriceimpact_lr_dw)



* Collapse the dataset to have one row per ticker-yearquarter with the mean values
collapse (mean) QS_dollar_tw QS_percent_tw ES_dollar_ave ES_percent_ave RS_dollar_ave RS_percent_ave PI_dollar_ave PI_percent_ave ES_dollar_dw ES_dollar_sw ES_percent_dw ES_percent_sw RS_dollar_sw  RS_dollar_dw RS_percent_sw RS_percent_dw PI_dollar_sw PI_dollar_dw PI_percent_sw PI_percent_dw, by(ticker quarter)


* Export the collapsed dataset to a CSV file
export delimited using "U:\kpz_etfliquidity\data_Marta\mean_spread_measures_by_ticker_yq.csv", replace



* Import the master dataset
import delimited "U:\kpz_etfliquidity\data_Marta\etf_panel_processed.csv", clear

* Make sure that the 'ticker' and 'quarter' variables are formatted correctly
destring ticker, replace
destring quarter, replace

* Save the master dataset as a Stata file temporarily if needed
save "U:\kpz_etfliquidity\data_Marta\etf_panel_processed.dta", replace

* Import the using dataset
import delimited "U:\kpz_etfliquidity\data_Marta\mean_spread_measures_by_ticker_yq.csv", clear

* Make sure that the 'ticker' and 'quarter' variables are formatted correctly
destring ticker, replace
destring quarter, replace

* Save the using dataset as a Stata file temporarily if needed
save "U:\kpz_etfliquidity\data_Marta\mean_spread_measures_by_ticker_yq.dta", replace

* Re-load the master dataset
use "U:\kpz_etfliquidity\data_Marta\etf_panel_processed.dta", clear

* Merge the datasets using an inner merge
merge 1:1 ticker quarter using "U:\kpz_etfliquidity\data_Marta\mean_spread_measures_by_ticker_yq.dta", keep(master match) nogenerate

* Export the merged dataset to a new CSV file
export delimited using "U:\kpz_etfliquidity\data_Marta\etf_panel_processed1.csv", replace




///-------------------------------------------------------------------------------------------------------------
/// Creating a cross-sectional dataset out of panel data, with updated spreads
///-------------------------------------------------------------------------------------------------------------

// Load data
// -------------------------------------
clear all
set more off

local directory "U:\kpz_etfliquidity\data_Marta"
import delimited "U:\kpz_etfliquidity\data_Marta\etf_panel_processed1.csv"

* Step 1: Ensure at least two ETFs exist in a given quarter

* Count the number of unique ETFs for each quarter
egen count_etfs = total(1), by(quarter)
* Keep only the quarters with at least two ETFs
keep if count_etfs >= 2

*update net expenses measure
gen  net_expense_mer=other_expense-marketing_fee_bps/100+fee_waiver

* Step 2: Average over quarters for each ETF

*volume, log_volume, log_aum, logret_q_lag (this oen is time series, so unnecessary for cs)

* Generate averages for each TICKER over all quarters
egen avg_net_expense_mer = mean(net_expense_mer), by(ticker) 
egen avg_time_existence = mean(time_existence), by(ticker) 
egen avg_time_since_first = mean(time_since_first), by(ticker)
egen avg_aum_index = mean(aum_index), by(ticker)
egen avg_lend_byaum_bps = mean(lend_byaum_bps), by(ticker)
egen avg_marketing_fee_bps = mean(marketing_fee_bps), by(ticker)
egen avg_other_expenses = mean(other_expenses), by(ticker)
egen avg_fee_waivers = mean(fee_waivers), by(ticker)
egen avg_creation_fee = mean(creation_fee), by(ticker)
egen avg_stock_tweets = mean(stock_tweets), by(ticker)
egen avg_ratio_tra = mean(ratio_tra), by(ticker)
egen avg_highfee =mean(highfee), by(ticker)
egen avg_tr_error_bps =mean(tr_error_bps), by(ticker)
egen avg_perf_drag_bps= mean(perf_drag_bps), by(ticker)
egen avg_d_uit =mean(d_uit), by(ticker)
egen avg_mgr_duration_tii = mean(mgr_duration_tii), by(ticker) 
egen avg_mgr_duration_tsi = mean (mgr_duration_tsi), by(ticker) 
egen avg_mgr_duration = mean(mgr_duration), by(ticker)
egen avg_ratio_tii = mean(ratio_tii), by(ticker)
egen avg_mer_bps = mean(mer_bps), by(ticker)
egen avg_mkt_share = mean(mkt_share), by(ticker)
egen avg_spread_bps_crsp = mean(spread_bps_crsp), by(ticker)
egen avg_turnover_frac = mean(turnover_frac), by(ticker)
egen avg_aum = mean(aum), by(ticker)
egen avg_qs_dollar_tw = mean(qs_dollar_tw), by(ticker)
egen avg_qs_percent_tw = mean(qs_percent_tw), by(ticker)
egen avg_es_dollar_ave = mean(es_dollar_ave), by(ticker)
egen avg_es_percent_ave = mean(es_percent_ave), by(ticker)
egen avg_rs_dollar_ave = mean(rs_dollar_ave), by(ticker)
egen avg_rs_percent_ave = mean(rs_percent_ave), by(ticker)


*un-log variables and then generate averages
gen volume=exp(log_volume)
generate log_profit_ = real(log_profit)
gen profit = exp(log_profit_)


*compute averages of unlogged
egen avg_volume = mean(volume), by(ticker)
egen avg_profit = mean(profit), by(ticker)

*log averages
gen log_avg_volume = log(avg_volume)
gen log_avg_aum=log(avg_aum)
gen log_avg_profit=log(avg_profit)
gen log_avg_aum_index=log(avg_aum_index)

*other variables
gen major_brand_index=1-d_ownindex
gen different_benchmarks=1-same_benchmark
gen different_lead_mm=1-same_lead_mm

egen avg_different_benchmarks = mean(different_benchmarks), by(ticker)
egen avg_different_lead_mm = mean(different_lead_mm), by(ticker)
egen avg_firstmover = mean(firstmover), by(ticker)


* Keep only the ETF identifier and the averaged variables
keep ticker  avg_net_expense_mer index avg_qs_dollar_tw avg_qs_percent_tw avg_es_dollar_ave avg_es_percent_ave avg_rs_dollar_ave avg_rs_percent_ave avg_time_existence avg_time_since_first  avg_aum_index log_avg_aum_index  avg_lend_byaum_bps  avg_marketing_fee_bps avg_other_expenses avg_fee_waivers avg_creation_fee  avg_stock_tweets  avg_ratio_tra  avg_highfee  avg_tr_error_bps  avg_perf_drag_bps  avg_d_uit   avg_mgr_duration_tii   avg_mgr_duration_tsi  avg_mgr_duration  avg_turnover_frac  avg_ratio_tii  avg_mer_bps  avg_mkt_share avg_spread_bps_crsp  avg_turnover_frac avg_profit avg_different_benchmarks avg_different_lead_mm  avg_firstmover log_avg_profit log_avg_volume log_avg_aum

sort ticker
duplicates drop ticker, force

* Save the new dataset
export delimited "U:\kpz_etfliquidity\data_Marta\etf_cs_processed1.csv", replace

