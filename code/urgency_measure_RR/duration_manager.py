import pandas as pd
import numpy as np

dur_13F=pd.read_csv("../../data/duration_13F.csv.gz",index_col=0)
dur_13F['dollar_pos']=dur_13F['shares']*dur_13F['prc_crsp']

def weighted_avg(x):
    return np.average(x['duration'],weights=x['dollar_pos'])

manager_dur=dur_13F.groupby(['mgrno','mgrname','quarter']).apply(weighted_avg)
manager_dur=manager_dur.reset_index()
manager_dur=manager_dur.rename(columns={0:'mgr_duration'})

manager_dur.to_csv("../../data/manager_duration_panel.csv.gz", compression='gzip')