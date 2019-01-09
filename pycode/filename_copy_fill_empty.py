# 01-07-2019
# Mike Shih

# This script copy the files created in 
# "12_SelectedBrainRGB" and "14_SelectedBrainRGB_4x" 
# into "raw_for_construction" and "raw_for_construction_4x". 
# Duplication follows this rule: 
# 1. It use "filenamelist.xlsx" as reference
# 2. If the file is coded as "1" in the column of "accept_code", 
#    file will be copied.
#    Otherwise, the previous fille (index -1) will be used as a dummy. 

# %%
import os, sys, shutil
import pandas as pd
datapath = "/Volumes/LaCie_DataStorage/Mast_Lab/Mast_Lab_002/"

datafolder = 'code'
datasubfolder = 'data'
filename = 'filenamelist.xlsx'

filelistpath = os.path.join(datapath, datafolder, datasubfolder, filename)
print(filelistpath)

# %%
data = pd.read_excel(filelistpath, index_col=None)

# %%
display(data)

# %%
folderlist = os.listdir(datapath)
folder1 = 'raw_for_construction'
folder2 = 'raw_for_construction_4x'

if (not folder1 in folderlist):
    os.makedirs(os.path.join(datapath, folder1))

if (not folder1 in folderlist):
    os.makedirs(os.path.join(datapath, folder2))

# %%
print(data.shape[0])
# %%
for i in range(data.shape[0]):
    acceptance = data['accept_code'][i]
    if acceptance == 1:
        filename = data['filenamelist'][i] + '.tif'

        src_dir_1x = os.path.join(datapath, '12_SelectedBrainRGB', filename)
        dst_dir_1x = os.path.join(datapath, 'raw_for_construction', filename)

        src_dir_4x = os.path.join(datapath, '14_SelectedBrainRGB_4x', filename)
        dst_dir_4x = os.path.join(datapath, 'raw_for_construction_4x', filename)
        shutil.copy(src_dir_1x, dst_dir_1x)    
        shutil.copy(src_dir_4x, dst_dir_4x)

    else:
        src_filename = data['filenamelist'][i-1] + '.tif'
        dst_filename = data['filenamelist'][i] + '_dummy.tif'
        
        src_dir_1x = os.path.join(datapath, '12_SelectedBrainRGB', src_filename)
        dst_dir_1x = os.path.join(datapath, 'raw_for_construction', dst_filename)

        src_dir_4x = os.path.join(datapath, '14_SelectedBrainRGB_4x', src_filename)
        dst_dir_4x = os.path.join(datapath, 'raw_for_construction_4x', dst_filename)

        shutil.copy(src_dir_1x, dst_dir_1x)    
        shutil.copy(src_dir_4x, dst_dir_4x)
    
    print(filename)
    print(acceptance)    
    
    

