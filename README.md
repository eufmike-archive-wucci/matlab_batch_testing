# Embryonic Brain Reconstruction
Features: MATLAB, Image Processing Toolbox

## Introduction
This project was to contour the brain region on embryonic slide scans acquired from Zeiss Axio Scan.Z1. The sample was stained with four different nucleus and epithelial markers, which can be used for segmentation. The images were then exported to MBF Brain Maker for image registration. 3D reconstruction was done in Imaris

![](/figures/embryonic_brain.png)


## Information
* Microscope: Zeiss Axio Scan.Z1
* Images: 
  * Channels: 
    * Channel 1: DAPI
    * Channel 2: Alexa 488
    * Channel 3: Alexa 647
---
## Workflow
### 01_Summary
The MATLAB code executes 14 filters to segment the brain regions in embryonic head tissue. Filters are also called functions or steps. 
1. Filter 01: convert images from .ome.tif to .tif
2. Filter 02: Crop and rotate images
3. Filter 03: resize images (default: 0.1x)
4. Filter 04: performing brain segmentation with given parameter
5. Filter 05: overlap the outline of labels onto images
6. Filter 06: create images only with selected labels (region of interest)
7. Filter 07: create binary image of selected masks
8. Filter 08: save smooth binary into variables
9. Filter 09: smoothed outline of masks
10. Filter 10: smoothed masks
11. Filter 11: gray scale images
12. Filter 12: RGB image with ROI (0.1x)
13. Filter 13: resize to 0.4x resolution
14. Filter 14: RGB image with ROI (0.4x)

### 02_Data Preparation
1. Collected images (.czi) from Zeiss Axio
2. Using Zen Blue software to convert images from .czi to .ome.tif
3. Copy images to the storage drive:
   1. Create a folder under `/Volumes/LaCie_DataStorage/Mast_Lab/data`, for example 'Mast_Lab_demo'
   2. Save images under `/Volumes/LaCie_DataStorage/Mast_Lab/data/Mast_Lab_demo/resource/raw_output`. The folder name needs to be "raw_output"
4. Load parameters:
   1. Create `/Volumes/LaCie_DataStorage/Mast_Lab/code`
   2. Create `/Volumes/LaCie_DataStorage/Mast_Lab/code/data`
   3. Copy the following files from the previous experiments (they can be empty sheets):
      * `brainsegpar.csv`
      * `smthpar.csv`
      * `brainregion.csv`
      * `expand.csv`

### 03_Image Processing
1. Open `image_processing_demo.m` in MATLAB
2. Define the following variable in the dialog:
   * `filtercount`: the amount of filter/functions when executing the code
   * `image_start`: the number of starting image
   * `image_end`: the number of ending image
   * `par_switch`: run batch or not

3. Create segmentation with label ID
   1. Set `filtercount` to 5
   2. Run the code
   3. Open images in `05_BWoutlinergb`, document the label ID into `brainregion.csv` in `/code/data`
4. Finalize the selection
   1. Set `filtercount` to 14
   2. Run the code

### 04_Fine-tuning the mask
1. `brainsegpar.csv` defines parameters which control the function `brainseg.m`
   1. `dapithrdboth`
   2. `dapithrdmode`
   3. `dapithrd`
   4. `dapisensitivity`
   5. `dapirmbkg`
   6. `edgethrd`
   7. `dillvl1`
   8. `dapi2`
   9. `dillvl2`
   10. `erolvl1`
   11. `bwcount`
   12. `dapirmbg`
2. `smthpar.csv` defines parameters for smoothing the label in `smthbway.m`
3. `expand.csv` defines parameters which control the function `strel`

### 05_Reconstruct 3D brain
1. Select images based on their quality
   1. Create a list of filename by running `savefilename.m`
   2. Generate a file list like the one in `code/data`
   3. Run `fileselection.m` on both 0.1x and 0.4x images
      1. input folders: 
         1. `12_SelectedBrainRGB`
         2. `14_SelectedBrainRGB_4x`
      2. output folder: 
         1. `raw_for_construction`
         2. `raw_for_construction_4x`
2. Use Brain Maker to reconstruct the 3D brain from files in `raw_for_construction` and `raw_for_construction_4x`
3. Export the aligned images

### 06_Export the results
1. Create a folder for exporting files. For Example: `Mast_Lab_Final`, then create following folders
   1. `01_raw`
   2. `02_whole_1`
   3. `03_brain_1`
   4. `04_brain_1_aligned`
   5. `05_whole_4`
   6. `06_brain_4`
   7. `07_brain_4_aligned`
   8. `doc`
   9. `videos`
2. Copy raw files from `01_tif_images` to `01_raw`
3. Histogram standardization
   1. Execute code `equhisto.m`
   2. Define the input and output folder on both 0.1x and 0.4x
      1. input: `03_crop_rotate_resized` or `13_crop_rotate_resized_4x`
      2. output: `02_whole_1` or `05_whole_4`
4. Copy the aligned images to `04_brain_1_aligned` and `07_brain_4_aligned`.
5. Export 3D videos from Imaris
6. Prepare documents

# License
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.