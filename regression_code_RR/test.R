library(xtable)
library(plm)
library(dplyr)
library(fwildclusterboot)
library(lmtest)
library(tidyr)
library(lfe)
library(stargazer)
library(broom)
library(standardize)
library(rstudioapi)


# Set working directory
# Replace with your directory path
setwd("D:/Research/kpz_etfliquidity/")

# Load data
data <- read.csv("data/etf_panel_processed.csv",
                 header=TRUE, sep=",")

# Calculate new variables

data$tii_return=data$ratio_tii * data$logret_q_lag
data$ratio_tra_ix_std=scale(data$ratio_tra_ix)
data$log_aum_index_std=scale(data$log_aum_index)
data$lend_byaum_bps_std=scale(data$lend_byAUM_bps)
data$marketing_fee_bps_std=scale(data$marketing_fee_bps)
data$other_expense_std=scale(data$other_expense)
data$fee_waiver_std=scale(data$fee_waiver)
data$tr_error_bps_std=scale(data$tr_error_bps)
data$perf_drag_bps_std=scale(data$perf_drag_bps)
data$ix_ratiotra_highfee=data$highfee * data$ratio_tra_ix_std
data$tra_above=ifelse(data$ratio_tra_ix_std >= 0,1,0)
data$ix_tra_above=data$highfee * data$tra_above

m1 <-felm(mkt_share ~ highfee + ix_ratiotra_highfee + ratio_tra_ix_std +
              stock_tweets + log_aum_index_std + lend_byaum_bps_std +
              marketing_fee_bps_std + other_expense_std + fee_waiver_std +
              tr_error_bps_std + perf_drag_bps_std + d_UIT + ratio_tii +
              logret_q_lag + tii_return
    | index_id+quarter | 0 | index_id+quarter, data=subset(data), exactDOF = TRUE, 
    cmethod='cgm2')

m2 <-felm(mkt_share ~ highfee + ix_ratiotra_highfee + ratio_tra_ix_std +
              stock_tweets + log_aum_index_std + lend_byaum_bps_std +
              marketing_fee_bps_std + other_expense_std + fee_waiver_std +
              tr_error_bps_std + perf_drag_bps_std + d_UIT + ratio_tii +
              logret_q_lag + tii_return
    | index_id+quarter | 0 | index_id+quarter, data=subset(data), exactDOF = TRUE, 
    cmethod='cgm')


summary(m1)