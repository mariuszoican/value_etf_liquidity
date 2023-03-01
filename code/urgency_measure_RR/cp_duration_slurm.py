import pandas as pd
import numpy as np
import warnings
import sys
warnings.filterwarnings('ignore')

list_quarters=[20104,
 20111,
 20112,
 20113,
 20114,
 20121,
 20122,
 20123,
 20124,
 20131,
 20132,
 20133,
 20134,
 20141,
 20142,
 20143,
 20144,
 20151,
 20152,
 20153,
 20154,
 20161,
 20162,
 20163,
 20164,
 20171,
 20172,
 20173,
 20174,
 20181,
 20182,
 20183,
 20184,
 20191,
 20192,
 20193,
 20194,
 20201,
 20202,
 20203,
 20204,
 20211,
 20212,
 20213,
 20214,
 20221,
 20222]
quarters=pd.DataFrame(list_quarters,columns=['quarter'])

# load raw 13F data
print("Load (raw) 13F data and CRSP data")
data13f=pd.read_csv("../../data/data_13F_RR_complete.csv.gz",index_col=0)

# keep only the last report for any given quarter
data13f=data13f.drop_duplicates(subset=['mgrno','cusip','quarter'],keep='last')

data13f=data13f[['mgrno','mgrname','quarter','ticker','shares','shrout2']]

# count number of reporting quarters by manager
mgr_count=data13f.groupby(['mgrno',
                           'quarter']).count()['rdate'].groupby('mgrno').count().reset_index()
mgr_count=mgr_count.rename(columns={'rdate':'mgr_quarter_count'})
data13f=data13f.merge(mgr_count, on='mgrno',how='left')
data13f=data13f[data13f.mgr_quarter_count>=8] # keep only managers with 8 quarters or more

# get list for slurm
def partition_list(lst, k):
    n = len(lst)
    quotient = n // k
    remainder = n % k
    partition_sizes = [quotient + 1 if i < remainder else quotient for i in range(k)]
    partitions = [lst[sum(partition_sizes[:i]):sum(partition_sizes[:i+1])] for i in range(k)]
    return partitions

# get list of managers
list_managers=data13f.mgrno.drop_duplicates().tolist()

# partition the list of managers
partition_managers=partition_list(list_managers,1000)

# idx=int(sys.argv[1])
idx=0

sample=data13f[data13f.mgrno.isin(partition_managers[idx])]

def compute_duration(temp):

    temp=temp.merge(quarters,on='quarter',how='outer')
    temp['shares']=temp['shares'].fillna(0)
    temp=temp.fillna(method='ffill')
    temp=temp.sort_values(by='quarter',ascending=True)

    temp['pshare']=temp['shares']/(10*temp['shrout2']) # percentage shares
    temp['pshare_start_window']=temp['pshare'].shift(w) # proxy for H

    temp['pshare_start_window']=temp['pshare_start_window'].fillna(0)

    temp['pshare_diff']=temp['pshare'].diff() # proxy for alpha
    temp['pshare_diff_bought']=np.where(temp['pshare_diff']>0,temp['pshare_diff'],0)

    temp['bought_diff']=temp['pshare_diff_bought'].rolling(20).sum() # proxy for B
    temp['HB']=temp['bought_diff']+temp['pshare_start_window'] # proxy for H+B

    # define weights
    weights=np.array([x for x in range(w-1,-1,-1)]) 
    # define the custom function for rolling mean with weights
    
    def weighted_sum(x):
        return np.sum(x * weights)
    
    temp['rolling_alpha']=temp['pshare_diff'].rolling(window=
                                                      len(weights)).apply(lambda x: weighted_sum(x))

    # compute duration
    temp['duration']=temp['rolling_alpha']/temp['HB']+(w-1)*temp['pshare_start_window']/temp['HB']
    temp['duration']=np.where(temp['shares']==0,0,temp['duration'])
    
    # drop extraneous columns
    # temp=temp.drop(['pshare','pshare_start_window','pshare_diff','rolling_alpha'], axis=1)
    
    return temp[temp['duration']>0]

w=20
data=sample.groupby(['mgrno','ticker']).apply(compute_duration)
data=data.reset_index(drop=True)

print("Save data!")
data.to_csv("output/duration_data_%i.csv.gz"%idx, compression='gzip')