% get histogram
addpath = '/Volumes/wuccistaff/Mike/Mark R/code';
close all
%% Define the path of folders
folder_path = '/Volumes/wuccistaff/Mike/Mark_R';
input_folder = 'raw_crop_ROI';
output_folder = 'raw_crop_equ';
input_folder_mark = 'raw_crop';
input_folder_ROI = 'raw_crop_ROI';
raw_crop_equ_mark = 'raw_crop_equ_full';
raw_crop_ROI_equ = 'raw_crop_ROI_equ';

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
input_mark = strrep(input_filenames_all, input_folder, input_folder_mark);
input_ROI = strrep(input_filenames_all, input_folder, input_folder_ROI);
output_foldername = strrep(input_filenames_all, input_folder, output_folder);
output_equ_mark = strrep(input_filenames_all, input_folder, raw_crop_equ_mark);
output_equ_ROI = strrep(input_filenames_all, input_folder, raw_crop_ROI_equ);

img_count = [0, img_count];
img_count_idx = cumsum(img_count);
%% read img
max_mix = [];
hist_plot = {};
hist_plot_filter = {};
max_min_par = [1 0.03 0.03, 0, 0; 2 0.03 0.03, 0, 0; 3 0.03 0.03, 0, 0];

figure_data = {};
for i = 1:3
%for i = 1:(size(img_count_idx, 2)-1)    
    counts = [];
    counts_filter = [];
    data_compile = [];
    for j = 1:50:img_count(i+1)
        imgname = char(input_filenames_all(img_count_idx(i)+j));
        I = imread(imgname);
%         figure
%         imshow(I);
%         impixelinfo; 

        I = imcrop(I, [1400, 400, 1023, 1023]);
        [tmp_counts,binLocations] = imhist(I);
        tmp_counts = [counts, tmp_counts];
        counts = sum(tmp_counts, 2);
        
        I = imgaussfilt(I, 0.5);
%         figure
%         imshow(I);
%         impixelinfo;
        [tmp_counts,binLocations] = imhist(I);
        tmp_counts = [counts_filter, tmp_counts];
        sum(tmp_counts)
        counts_filter = sum(tmp_counts, 2);
        sum(counts_filter)
        data_compile = cat(3, data_compile, I);
    
    end
    sum(counts)
    hist_plot{i} = [binLocations counts];
    sum(counts_filter)
    hist_plot_filter{i} = [binLocations counts_filter];
    
    a = sort(data_compile(:), 'descend');
    data_max = mean(a(1:ceil(size(a, 1)* max_min_par(i, 2)))) - max_min_par(i, 4);

    b = sort(data_compile(:), 'ascend');
    data_min = mean(b(1:ceil(size(b, 1)* max_min_par(i, 3)))) + max_min_par(i, 5);
    
    max_mix = cat(1, max_mix, [data_max data_min]);
    
    close all    
    
end


%% image equi
hist_plot_2 = {};
for i = 1:3
%for i = 1:(size(img_count_idx, 2)-1)    
counts = [];
    for j = 1:50:img_count(i+1)
        imgname = char(input_filenames_all(img_count_idx(i)+j));
        I = imread(imgname);
%         figure
%         imshow(I);
%         impixelinfo; 

        I = imcrop(I, [1400, 400, 1023, 1023]);
        max_int = max_mix(i, 1);
        min_int = max_mix(i, 2);
        I_nml = histnml(I, max_int, min_int);
        
%         figure
%         imshow(I_nml, []);
%         impixelinfo;
        
        imgname_output = output_foldername(img_count_idx(i)+j);
        imgname_output = char(imgname_output);
        imwrite(I_nml, imgname_output);
        
        [tmp_counts,binLocations] = imhist(I_nml);
        tmp_counts = [counts, tmp_counts];
        counts = sum(tmp_counts, 2);
        
    end
    hist_plot_2{i} = [binLocations counts];
    
    close all
    
end

%% plot figure no filter

for i = 1:3
    hist_plot_temp = hist_plot{i};
    binLocations = hist_plot_temp(:, 1);
    counts = hist_plot_temp(:, 2);
    figure
    h = bar(binLocations, counts, 'histc');
    
    max_mix(i, 1)
    max_mix(i, 2)  
    min_line = vline(max_mix(i, 2), 'r');
    max_line = vline(max_mix(i, 1), 'r');
end

%% plot figure with filter

for i = 1:3
    hist_plot_temp = hist_plot_filter{i};
    binLocations = hist_plot_temp(:, 1);
    counts = hist_plot_temp(:, 2);
    figure
    h = bar(binLocations, counts, 'histc');
    
    max_mix(i, 1)
    max_mix(i, 2)  
    min_line = vline(max_mix(i, 2), 'r');
    max_line = vline(max_mix(i, 1), 'r');
end

%% plot
for i = 1:3
    hist_plot_temp = hist_plot_2{i};
    binLocations = hist_plot_temp(:, 1);
    counts = hist_plot_temp(:, 2);
    figure
    h = bar(binLocations, counts, 'histc');
    
end

%% image equi real 
hist_plot_2 = {};
for i = 1:3
%for i = 1:(size(img_count_idx, 2)-1)    
    counts = [];
    for j = 1:img_count(i+1)
        j
        imgname = char(input_mark(img_count_idx(i)+j));
        I = imread(imgname);
%         figure
%         imshow(I);
%         impixelinfo; 

        max = max_mix(i, 1);
        min = max_mix(i, 2);
        I_nml = histnml(I, max, min);
        
%         figure
%         imshow(I_nml, []);
%         impixelinfo;
        
        imgname_output = output_equ_mark(img_count_idx(i)+j);
        imgname_output = char(imgname_output);
        imwrite(I_nml, imgname_output);
        
        clear I
        clear I_nml
    end
    
    close all
    
end

%% image equi real ROI
% hist_plot_2 = {};
% for i = 1:3
% %for i = 1:(size(img_count_idx, 2)-1)    
% counts = [];
%     for j = 1:img_count(i+1)
%         imgname = char(input_ROI(img_count_idx(i)+j));
%         I = imread(imgname);
% %         figure
% %         imshow(I);
% %         impixelinfo; 
% 
%         max_int = max_mix(i, 1);
%         min_int = max_mix(i, 2);
%         I_nml = histnml(I, max_int, min_int);
%         
% %         figure
% %         imshow(I_nml, []);
% %         impixelinfo;
%         
%         imgname_output = output_equ_ROI(img_count_idx(i)+j);
%         imgname_output = char(imgname_output);
%         imwrite(I_nml, imgname_output);
%                
%     end
%     
%     close all
%     
% end