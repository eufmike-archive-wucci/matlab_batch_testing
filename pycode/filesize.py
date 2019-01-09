# 01-01-2019
# Mike Shih

# This script will print file size.

# %%
import os, sys
import re
import pandas as pd

datapath = "/Volumes/LaCie_DataStorage/Mast_Lab/Mast_Lab_002/resource/raw_output"
# %%
nameset1 = os.listdir(datapath)
filename = []
filesizelist = []
for i, item in enumerate(nameset1):
    # print(i, item)
    slide_name = re.search('^batch', item)
    
    if slide_name != None:
        filepath = os.path.join(datapath, item)
        size_temp = round((os.path.getsize(filepath))/(1024**3), 2)
        filesizelist.append(size_temp)
        filename.append(item)

data = {
        'file_name' : filename,
        'size_GB' : filesizelist,
}

df = pd.DataFrame(data)

# %%
df_sort = df.sort_values(by = 'size_GB', ascending = False)
df_sort