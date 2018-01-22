cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

clear all
tic
profile on

%% creat the list for unprocessed files
% get folder names
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
folder_path_1 = '/Volumes/wuccistaff/Mike/Mast_Lab_03/test';
folder_path_2= '/Volumes/wuccistaff/Mike/Mast_Lab_03/';

foldernedted = dir(folder_path_1);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = 'raw_images';
% inputfolder = 'raw_output_ometif';
inputfiles = dir(fullfile(folder_path_1, inputfolder, '*.ome.tiff')); 
inputfiles = removedot({inputfiles.name}');
inputfiles = strrep(inputfiles, '.ome.tiff', '.ometiff');
inputfiles_noext = rmext(inputfiles);

inputfiles_noext = inputfiles_noext(1:142);

filtercount = 13;
% define the filter
filters = {'raw_images'; '01_tif_images'; '02_crop_rotate'; '03_crop_rotate_resized'; ...
            '04_BWbrain'; '05_BWoutlinergb'; ...
            '06_SelectedROI'; '07_SelectedBWraw';...
            '08_BWsmth'; '09_BWsmthoutlinergb'; '10_BWsmthadj';...
            '11_SelectedBrainGrey'; '12_SelectedBrainRGB'};
fileExt = {'.ome.tiff'; '.tif'; '.tif'; '.tif'; ... 
            '.tif'; '.tif'; ...
            '.tif'; '.tif'; ...
            '.mat'; '.tif'; '.tif';...
            '.tif'; '.tif'};

% filterrange ver 1.0: 
filters = filters(1:filtercount);
fileExt = fileExt(1:filtercount);

filenames_fm = {};
filenames_op = {};

% generate filename array 
for m = 1:filtercount
    foldername = filters{m};    
    ext = fileExt{m};
    filenames_fm{m} = fullfile(folder_path_1, foldername, strcat(inputfiles_noext, ext)); 
    filenames_op{m} = fullfile(folder_path_2, foldername, strcat(inputfiles_noext, ext)); 
end

for m = 1: length(filters)
	for n = 1:length(inputfiles)
		if ~strcmp(filenames_fm{m}{n}, filenames_op{m}{n})
			movefile(filenames_fm{m}{n}, filenames_op{m}{n});
		end
	end
end