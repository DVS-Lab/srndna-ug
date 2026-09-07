import numpy as np 
import json
import pandas as pd
import os
import re
import itertools
import argparse
from scipy.stats import zscore


mriqc_dir = "/ZPOOL/data/projects/srndna-ug/derivatives/mriqc/"
path_derivative=mriqc_dir[:-5]
bids_dir="/ZPOOL/data/projects/srndna-ug/bids"
all_subs=[s for s in os.listdir(bids_dir) if s.startswith('sub-1')] # only grab imaging subjects

j_files=[os.path.join(root, f) for root,dirs,files in os.walk(mriqc_dir)
         for f in files if f.endswith('bold.json')]


keys=['tsnr','fd_mean'] # the IQM's we might care about
sr=['Sub','task','run']

# Open an empty array and fill it. 
row=[]
for i in range(len(j_files)):
    sub=re.search('/mriqc/(.*)/func', j_files[i]).group(1) # this will parse the text for a string that looks like sub-###
    task=re.search('task-(.*)_run',j_files[i]).group(1)
    run=re.search('_run-(.*)_bold.json', j_files[i]).group(1) # this is parsed just as # so we have to put in the run text ourselves if we want later
    with open(j_files[i]) as f: #we load the j_son file and extract the dictionary ingo
        data = json.load(f)
    now=[sub,task,run]+[data[x]for x in keys] #the currently created row in the loop
    row.append(now) #through that row on the end
    
df_full=pd.DataFrame(row,columns=sr+keys)

task_list = ['ultimatum']

# for task in df_full.task.unique():
for task in task_list:
    print(task)
    df = df_full[df_full['task']==task]
    mriqc_subs_missing = np.setdiff1d(all_subs,df.Sub.unique())
    print("%s are missing MRIQC OUTPUT"%(mriqc_subs_missing))
    
    # make boxplot and identify outliers
    Q1=df[keys].quantile(0.25)
    Q3=df[keys].quantile(0.75)
    IQR = Q3 - Q1
    lower=Q1 - 1.5 * IQR
    upper=Q3 + 1.5 * IQR
    upper.tsnr=upper.tsnr*100 # so we don't exclude runs with "too good" signal-noise ratio

    print("These are the upper and lower bounds for our metrics")
    print(lower.to_frame(name='lower').join(upper.to_frame(name='upper')))

    outList=(df[keys]<upper)&(df[keys]>lower)
    df['outlier_run_Custom1']=~outList.all(axis='columns')
    
    #HERE's WHERE The MANUAL SUBS AND RUNS ARE ENTERED
    if task=='ultimatum':
        df
    elif task == 'trust':
        df.loc[(df.Sub=='sub-111') & (df.run==1),['outlier_run_Custom1']]=True
        df.loc[(df.Sub=='sub-150') & (df.run==2),['outlier_run_Custom1']]=True
    elif task == 'sharedreward':
        df['outlier_run_Custom1'][df.Sub.isin(shared_exclude)]=True


    print('These are the identities outlier Runs')
    print(df[df['outlier_run_Custom1']==True])
    df.to_csv('Task-%s_Level-Run_Outlier-info.tsv'%(task),sep='\t',index=False)

    GS=df[df['outlier_run_Custom1']==False]
    #GS=list(GS.Sub.value_counts().reset_index(name="count").query("count > 1")['index'])
    # GS = GS.Sub.value_counts().reset_index(name="count").query("count > 1").index.tolist()
    GS = df[df['outlier_run_Custom1'] == False].groupby('Sub').filter(lambda x: len(x) > 1)['Sub'].unique().tolist()
    BS=df[~df.Sub.isin(GS)]['Sub']

    df_cov=df[df.Sub.isin(GS)]
    df_cov=df_cov[df_cov['outlier_run_Custom1']==False]
    df_cov=df_cov.groupby(by='Sub').mean(numeric_only=True).reset_index().rename(columns={'index':'Sub'})
    df_cov=df_cov[['Sub']+keys]
    df_cov[['tsnr','fd_mean']]=df_cov[['tsnr','fd_mean']].apply(zscore)
    df_cov.to_csv('Task-%s_Level-Group_Covariates.tsv'%(task),sep='\t',index=False)

    df_out=df[df.Sub.isin(BS)]
    df_out=df_out.Sub.value_counts().reset_index().rename(columns={'index':'Sub'})
    df_out=df_out.sort_values(by='Sub')
    df_out.to_csv('Task-%s_CustomSubOutlier.tsv'%(task),sep='\t',index=False)
    print("df_out")
    display(df_out)
