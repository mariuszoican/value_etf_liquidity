// Load data
// -------------------------------------
clear all
set more off

//local directory "D:\ResearchProjects\kpz_etfliquidity\"
local directory "D:\Research\kpz_etfliquidity\"
import delimited "`directory'data\probit_data_processed.csv"

gen log_aum=log(aum_index)
gen major_brand_index=1-d_ownindex
gen numhold_000=num_hold_index/1000

probit competition log_aum 
probit competition log_aum top3_issuer major_brand_index
probit competition log_aum top3_issuer major_brand_index numhold_000
probit competition log_aum top3_issuer major_brand_index numhold_000 spread_index ratio_tra ratio_tii