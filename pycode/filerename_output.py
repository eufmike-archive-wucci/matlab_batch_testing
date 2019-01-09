# 01-01-2019
# Mike Shih

# This script is designed for renaming the files by using python os and sys. 
# Files are generated from Zen export. 

# %%
import os, sys
import re

datapath = '/Volumes/LaCie_DataStorage/Mast_Lab/Mast_Lab_002/'
namefolder = 'raw_for_construction'
filenamepath = os.path.join(datapath, namefolder)

input_subfolder_1 = 'finaloutput'
input_subfolder_2 = 'Mast_Lab_final'
input_subfolder_nested_1x = '04_brain_1_aligned'
input_subfolder_nested_4x = '07_brain_4_aligned'
filepath_1x = os.path.join(datapath, input_subfolder_1, input_subfolder_2, input_subfolder_nested_1x)
filepath_4x = os.path.join(datapath, input_subfolder_1, input_subfolder_2, input_subfolder_nested_4x)


# %%

filelist = []
outputfileabslist_1x = []
outputfileabslist_4x = []

for directory, dir_names, file_names in os.walk(filenamepath):
    for file_name in file_names:
        if (not file_name.startswith('.')) & (file_name.endswith('.tif')):
            filepath_tmp_1x =  os.path.join(filepath_1x, file_name)
            filepath_tmp_4x =  os.path.join(filepath_4x, file_name)
            
            filelist.append(file_name)
            outputfileabslist_1x.append(filepath_tmp_1x)
            outputfileabslist_4x.append(filepath_tmp_4x)
            
print(outputfileabslist_1x)

# %%

inputfileabslist_1x = []

for directory, dir_names, file_names in os.walk(filepath_1x):
    for file_name in file_names:
        if (not file_name.startswith('.')) & (file_name.endswith('.tif')):
            filepath_tmp_1x =  os.path.join(filepath_1x, file_name)
            inputfileabslist_1x.append(filepath_tmp_1x)

inputfileabslist_4x = []

for directory, dir_names, file_names in os.walk(filepath_4x):
    for file_name in file_names:
        if (not file_name.startswith('.')) & (file_name.endswith('.tif')):
            filepath_tmp_4x =  os.path.join(filepath_4x, file_name)            
            inputfileabslist_4x.append(filepath_tmp_4x)

print(inputfileabslist_1x)

# %%
for i in range(len(inputfileabslist_1x)):
    os.rename(inputfileabslist_1x[i], outputfileabslist_1x[i])
    os.rename(inputfileabslist_4x[i], outputfileabslist_4x[i])