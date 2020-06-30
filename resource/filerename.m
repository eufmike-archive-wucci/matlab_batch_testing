clear all
addpath = '/Volumes/wuccistaff/Mike/Mark R/code';
close all

%% Define the path of folders
folder_path = '/Volumes/wuccistaff/Mike/Mark_R';
input_folder = 'crop_mark_equ';

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

img_count = [0, img_count];
img_count_idx = cumsum(img_count);

%% rename files
groupid = ['01'; '02'; '03'];
for i = 1: (size(img_count_idx, 2)-1) 
    for j = 1: img_count(i+1)
        file = char(input_filenames_all(img_count_idx(i)+j));
        [filepath, name] = fileparts(file);
        new_name = strcat(groupid(i, :), '_', name);  
        new_input_filenames = strrep(file, name, new_name)
        movefile(file, new_input_filenames);
    end
end