import pandas as pd

data=pd.read_csv('../data/etf_panel_merged.csv',index_col=0)

def compute_diff(var):
    temp=data.dropna(subset=['launch_order']).pivot(
        columns='sequence_of_entry',index=['index','yearqtr'],values=var).reset_index()
    temp[2]=temp[2].fillna(0)
    temp['diff_%s'%var]=temp[1]-temp[2]
    temp=temp[['index','yearqtr','diff_%s'%var]]
    temp=temp.set_index(['index','yearqtr'])
    return temp

differences=compute_diff('mkt_share')

list_var=['tr_error_bps','tr_difference_bps','mer_bps','turnover_frac',
          'logDvol','tr_error_perc','tr_difference_perc','lend_byAUM_bps','marketing_fee_bps',
          'vol_share','urgency_mean','spread_bps_etfg',
          'spread_bps_crsp']
for v in list_var:
    differences=differences.join(compute_diff(v))

differences=differences.reset_index()
differences=differences.merge(data[['index','yearqtr','ix_urgency_mean','ix_urgency_median','ix_urgency_std',
                                    'aum_index']])

differences.to_csv('../data/diff_leader_follower.csv')