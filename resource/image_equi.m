clear 
addpath = '/Volumes/wuccistaff/Mike/Mark R/code';

%% Define the path of folders
folder_path = '/Volumes/wuccistaff/Mike/Mark_R';
input_folder = 'raw'; % specify the input folder
output_folder_crop = 'raw_crop';
output_folder_crop_ROI = 'raw_crop_ROI';% specify the output folder
input = dir(fullfile(folder_path, input_folder));
subfoldername = {input.name}'; % get filenames

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
display(input_filenames_all);

%% create output filenames
output_crop_filenames_all = strrep(input_filenames_all, input_folder, output_folder_crop); 
output_ROI_filenames_all = strrep(input_filenames_all, input_folder, output_folder_crop_ROI);


%% get ROI

%% get fit size for each stack
img_count = [0, img_count];

idx = {};
step = 50;
for i = 1:dataset_count
    dataset_size = img_count(i+1);
    idx_start = 1+sum(img_count(1: (i)));
    idx_end = sum(img_count(1:i+1));
    if rem(dataset_size, step) == 0 
        idx{i} = idx_start:step:idx_end;
    else
        idx{i} = [idx_start:step:idx_end, idx_end];
    end
end

boundingbox_crop = []; 
boundingbox_ROI = [];

idx_flat = cell2mat(idx);
input_filenames_sele = input_filenames_all(idx_flat);

%% extract max area
%for i = 1:1
for i = 1 : size(input_filenames_sele, 1);     
    close all
    idx_selected = idx_flat(i);
    imgname = char(input_filenames_sele(i));
    display(imgname);
    I = imread(imgname);
     
    BW = imbinarize(I, isodata(I)*0.1);
    
    BW_crop = bwareafilt(BW, 4,'largest'); 
    stats_BW_crop = regionprops('table', BW_crop, 'BoundingBox');
    stats_BW_crop_ary = table2array(stats_BW_crop);
    
    stats_BW_crop_ary(:, 5) = stats_BW_crop_ary(:, 1) + stats_BW_crop_ary(:, 3);
    stats_BW_crop_ary(:, 6) = stats_BW_crop_ary(:, 2) + stats_BW_crop_ary(:, 4);
    
    xymin = min(stats_BW_crop_ary(:, 1:2),[], 1);
    xymax = max(stats_BW_crop_ary(:, 5:6),[], 1);
    xylength = xymax - xymin;   
    xyBoundingBox = [xymin, xylength];    
    boundingbox_crop = cat(1, boundingbox_crop, xyBoundingBox);
    
    BW_ROI = bwareafilt(BW, 1,'largest');
    stats_BW_ROI = regionprops('table', BW_ROI, 'BoundingBox');
    
    xyBoundingBox_ROI = table2array(stats_BW_ROI);
    boundingbox_ROI = cat(1, boundingbox_ROI, xyBoundingBox_ROI);
    
%     figure
%     imshow(I, []);
%     figure
%     imshow(I_crop, []);
%     figure
%     imshow(I_ROI, []);
    
%     cropname = char(output_crop_filenames_all(i));
%     imwrite(I_crop, cropname);
%     ROIname = char(output_ROI_filenames_all(i));
%     imwrite(I_ROI, ROIname);
    
end

% add index
boundingbox_crop = cat(2, idx_flat', boundingbox_crop); 
boundingbox_ROI = cat(2, idx_flat', boundingbox_ROI);

%%
maxboundingbox_crop = [];
maxboundingbox_ROI = [];
img_count_idx = cumsum(img_count);

groupsize = [0, cellfun('length', idx)];
groupidx = cumsum(groupsize);
for i = 1:dataset_count
    group_start = groupidx(i)+1;
    group_end = groupidx(i+1);
    
    temp_crop = findmaxbw(boundingbox_crop(group_start:group_end, 2:5));
    maxboundingbox_crop = cat(1, maxboundingbox_crop, temp_crop);
    
    temp_ROI = findmaxbw(boundingbox_ROI(group_start:group_end, 2:5));
    maxboundingbox_ROI = cat(1, maxboundingbox_ROI, temp_ROI);
end
maxboundingbox_crop
maxboundingbox_ROI


%% crop image
data_group = [];
for i = 1: dataset_count
    group_temp = repelem(i, img_count(i+1));
    data_group = cat(2, data_group, group_temp);
end
data_group = data_group';

for i = 1:size(input_filenames_all, 1);     
    close all
    imgname = char(input_filenames_all(i));
    display(imgname);
    I = imread(imgname);
    group = data_group(i);
    BB_crop = maxboundingbox_crop(group, :);
    BB_roi = maxboundingbox_ROI(group, :); 
    
    I_crop = imcrop(I, BB_crop);
    ROIname = char(output_crop_filenames_all(i)); 
    imwrite(I_crop, ROIname);
    
    I_ROI = imcrop(I, BB_roi);  
    ROIname = char(output_ROI_filenames_all(i));
    imwrite(I_ROI, ROIname);
       
end


 

