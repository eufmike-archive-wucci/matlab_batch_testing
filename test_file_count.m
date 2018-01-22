close all;
clear all;

cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

folder_path = '/Volumes/wuccistaff/Active/Staff/Mike Shih/active_project/Mast_Lab_Project/Mast_Lab_current/';

inputfolder = 'raw_images';
outputfolder = '01_tif_images';

inputfiles = dir(fullfile(folder_path, inputfolder));
inputfiles = removedot({inputfiles.name}');
inputfiles_noext = rmext(inputfiles);
inputfiles_size = size(inputfiles);
inputfiles_noext_size = size(inputfiles_noext);


fprintf('\ninputfiles size = %d %d \n', inputfiles_size(1), inputfiles_size(2));

outputfiles = dir(fullfile(folder_path, outputfolder));
outputfiles = removedot({outputfiles.name}');
outputfiles_noext = rmext(outputfiles);
outputfiles_size = size(outputfiles_noext);

fprintf('\noutputfiles size = %d %d \n', outputfiles_size(1), outputfiles_size(2)); 