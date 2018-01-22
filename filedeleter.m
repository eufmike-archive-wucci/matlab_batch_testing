close all; clear all;
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab_current/';

foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

filters = {'01_tif_images'; '02_crop_rotate'; '03_crop_rotate_resized'; ...
            '04_BWbrain'; '05_BWoutlinergb'; ...
            '06_SelectedROI'; '07_SelectedBWraw';...
            '08_BWsmth'; '09_BWsmthoutlinergb'; '10_BWsmthadj';...
            '11_SelectedBrainGrey'; '12_SelectedBrainRGB'};
fileExt = {'.tif'; '.tif'; '.tif'; ... 
            '.tif'; '.tif'; ...
            '.tif'; '.tif'; ...
            '.mat'; '.tif'; '.tif';...
            '.tif'; '.tif'};

filter_rage = 4:12;
filters = filters(filter_rage);
fileExt = fileExt(filter_rage);


filenamelist = {};

filefordeletion_path = fullfile(folder_path, 'code', 'data', 'filefordeletion.csv');
filefordeletion = csvread(filefordeletion_path);


x = 1
for m = 1:size(filefordeletion, 1);
	for n = 1:length(filter_rage)
	    
	    filename = strcat('1979a-', sprintf('%04d', filefordeletion(m, 1)), '-OME TIFF-Export-01_s', ...
	    	sprintf('%01d', filefordeletion(m, 2)));
	    
	    foldername = filters{n};
	    ext = fileExt{n};

	    % build file name with dir
	    fullfilename = fullfile(folder_path, foldername, strcat(filename, ext)); 
	   
		filenamelist{x} = fullfilename; 		
		x = x + 1; 
	end
end

filenamelist = filenamelist';

for m = 1: size(filenamelist, 1)
	if (exist(filenamelist{m}) ~= 0)
	delete(filenamelist{m});
	end
end