% get histogram
clear all
addpath = '/Volumes/wuccistaff/Mike/Mark R/code';
close all
%% Define the path of folders
folder_path = '/Volumes/wuccistaff/Mike/Mark_R';
input_folder = 'raw_crop_equ_full';
output_folder = 'crop_mark_equ';

input = dir(fullfile(folder_path, input_folder));
subfoldername = {input.name}';

%% Remove hidden files (any filenames start with ".").  
subfoldername = removedot(subfoldername); 

dataset_count = size(subfoldername, 1); 
img_count = [];

%% get subfolder filenames
input_filenames_all = [];
for i = 1:size(subfoldername, 1);
    foldername = fullfile(folder_path, input_folder, subfoldername(i));
    foldername = char(foldername);
    input = dir(foldername);
    
    filename = {input.name}'; % get filenames
    filename = removedot(filename);
    filename = removethumb(filename);
    
    img_count = cat(2, img_count, size(filename, 1)); 
    
    filename = fullfile(foldername, filename);
    input_filenames_all = cat(1, input_filenames_all, filename);
    
end
outputfolder = strrep(input_filenames_all, input_folder, output_folder);

img_count = [0, img_count];
img_count_idx = cumsum(img_count);

%%
imgname = char(input_filenames_all(img_count_idx(2)));
I1 = imread(imgname);
figure
imshow(I1, [])
impixelinfo;

imgname = char(input_filenames_all(img_count_idx(2)+1));
I2 = imread(imgname);
figure
imshow(I2, [])
impixelinfo;

imgname = char(input_filenames_all(img_count_idx(3)));
I3 = imread(imgname);
figure
imshow(I3, [])
impixelinfo;

imgname = char(input_filenames_all(img_count_idx(3)+1));
I4 = imread(imgname);
figure
imshow(I4, [])
impixelinfo;

imgname = char(input_filenames_all(img_count_idx(4)));
I5 = imread(imgname);
figure
imshow(I5, [])
impixelinfo;

close all

%% get info

aligment_point_01 = [242 2375];
aligment_point_02 = [140 2193];
aligment_point_03 = [150 2188]; %% unused
aligment_point_04 = [165 2030];
aligment_point_05 = [177 2021]; %% unused

delta_list = [];
I1_pad = I1;
delta_list = cat(1, delta_list, [0 0]);

delta = aligment_point_02 - aligment_point_01;

delta_list = cat(1, delta_list, delta);

delta_1 = aligment_point_03 - aligment_point_01;
delta_2 = aligment_point_04 - aligment_point_03;
delta = delta_2 + delta_1;

delta_list = cat(1, delta_list, delta);

delta_list

I2_pad = padbyorigin(I2, delta_list(2, :));
I3_pad = padbyorigin(I3, delta_list(2, :));
I4_pad = padbyorigin(I4, delta_list(3, :));
I5_pad = padbyorigin(I5, delta_list(3, :));

%% resize

img_size = cat(1, size(I1_pad), size(I2_pad), size(I3_pad), size(I4_pad));
max_fm_size = max(img_size(:, 1:2), [], 1); 
I1_pad = padframesizeadj(I1_pad, max_fm_size); 
I2_pad = padframesizeadj(I2_pad, max_fm_size);
I3_pad = padframesizeadj(I3_pad, max_fm_size);
I4_pad = padframesizeadj(I4_pad, max_fm_size);
I5_pad = padframesizeadj(I5_pad, max_fm_size);

%% save files
imgname_output = char(outputfolder(img_count_idx(2)));
imwrite(I1_pad, imgname_output);
imgname_output = char(outputfolder(img_count_idx(2)+1));
imwrite(I2_pad, imgname_output);
imgname_output = char(outputfolder(img_count_idx(3)));
imwrite(I3_pad, imgname_output);
imgname_output = char(outputfolder(img_count_idx(3)+1));
imwrite(I4_pad, imgname_output);
imgname_output = char(outputfolder(img_count_idx(4)));
imwrite(I5_pad, imgname_output);

%% save files
groupid = ['WT_01/'; 'WT_02/'; 'WT_03/'];
groupid_new = ['WT_01/01_'; 'WT_02/02_'; 'WT_03/03_'];
for i = 2:3 
%for i = 1:(size(img_count_idx, 2)-1)    
    for j = 1:img_count(i+1)
        j
        imgname = char(input_filenames_all(img_count_idx(i)+j));
        I = imread(imgname);
        I = padbyorigin(I, delta_list(i, :));
        I = padframesizeadj(I, max_fm_size);
        
        imgname_output = outputfolder(img_count_idx(i)+j);
        imgname_output = char(imgname_output);
        imgname_output = strrep(imgname_output, groupid(i,:), groupid_new(i,:));
        imwrite(I, imgname_output);
        
        clear I
        clear imgname
    end
    
end