# %%
import os, sys
import re

datapath = "/Volumes/LaCie_DataStorage/Mast_Lab/Mast_Lab_002/resource/raw_output"

# %%
nameset1 = os.listdir(datapath)
print(nameset1)
for i, item in enumerate(nameset1):
    print(i, item)
    slide_number = re.search('slide_(.*)-Scene', item)
    
    if slide_number != None:
        print(slide_number.group(1))
        scene_number = re.search('Scene-(.*)-Scan', item)
        print(scene_number.group(1))
        newfilename = 'batch_02_slide_' + slide_number.group(1) + '_scene_' + scene_number.group(1) + '.ome.tiff'
        print(newfilename)

        filedir_org = os.path.join(datapath, item)
        filedir_new = os.path.join(datapath, newfilename)
        os.rename(filedir_org, filedir_new)
    
# %%
nameset2 = os.listdir(datapath)
print(nameset2)
for i, item in enumerate(nameset2):
    print(i, item)
    slide_number = re.search('_ome.tiff', item)
    
    if slide_number != None:
        p = re.compile('_ome.tiff')
        newfilename = p.sub('.ome.tiff', item)
        print(newfilename)

        filedir_org = os.path.join(datapath, item)
        filedir_new = os.path.join(datapath, newfilename)
        os.rename(filedir_org, filedir_new)

# %%
for filename in os.listdir():
    print(filename)

