import pandas as pd
import datetime as dt
import numpy as np

urgency=pd.read_csv('../data/all_urgency_measures.csv',index_col=0)
urgency['fdate']=urgency['fdate'].apply(lambda x: dt.datetime.strptime(str(x),"%Y%m%d"))
urgency['yearqtr'] = urgency['fdate'].dt.to_period('Q')
urgency['yearqtr']=urgency['yearqtr'].apply(lambda x: int(str(x).replace("Q","")))

panel=pd.read_csv('../data/etf_paneldata.csv')

del panel['urgency_mean']
del panel['urgency_std']
del panel['urgency_range']
del panel['index_id']
del panel['fdate']

panel2=panel.merge(urgency,on=['ticker','yearqtr'],how='left')

volshare = panel2.dropna(subset=['launch_order']).pivot(
    columns='sequence_of_entry', index=['index', 'yearqtr'], values='logDvol').reset_index()
volshare=volshare.set_index(['index','yearqtr'])
volshare=volshare.apply(np.exp).fillna(0)
volshare=volshare.div(volshare.sum(axis=1), axis=0)
volshare=volshare.stack().reset_index()
volshare=volshare.rename(columns={0:'vol_share'})

panel2=panel2.merge(volshare,on=['index','yearqtr','sequence_of_entry'],how='left')

controls=pd.read_csv('../data/data_all_controls.csv')

panel2=panel2.merge(controls[['ticker','lend_byAUM_bps','marketing_fee_bps']],on='ticker',how='left')

panel2.to_csv('../data/etf_panel_merged.csv')