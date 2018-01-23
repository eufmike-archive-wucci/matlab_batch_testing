% cd '/Users/michaelshih/Documents/wucci_data/batch_test/';
% home
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code/';

clear all
tic
profile on

%% creat the list for unprocessed files
% get folder names
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab_current/Mast_Lab_final/';

foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = 'brain_04_color_seq';
nameinputfolder = '06_brain_4';
% outputfolder = 'Mast_Lab_final';
outputfolder = '07_brain_4_aligned';

inputfiles = dir(fullfile(folder_path, inputfolder, '*.tif')); 
inputfiles = removedot({inputfiles.name}');
inputfiles_noext = rmext(inputfiles);

outputfiles = dir(fullfile(folder_path, nameinputfolder, '*.tif')); 
outputfiles = removedot({outputfiles.name}');
outputfiles_noext = rmext(outputfiles);

inputfiles = fullfile(folder_path, inputfolder, strcat(inputfiles_noext, '.tif'));
outputfiles = fullfile(folder_path, outputfolder, strcat(outputfiles_noext, '.tif'));

numFiles_in = length(inputfiles);
numFiles_out = length(outputfiles);

if numFiles_out < 2
  parforArg = 0;
else
  parforArg = 4;
end
fprintf('\nnumber of workers: %d\n', parforArg);

% for m = 1:1
parfor (m = 1:numFiles_out, parforArg)
% for m = 1:numFiles_out
	
	I_TIF = [];
	I_TIF = uint16(I_TIF);
	for n = 1:3
		inputfilename = inputfiles{(m-1)*3+n};
		I_TIF(:, : , n) = imread(inputfilename);
	end
	outputfilename = outputfiles{m};

    imwrite(I_TIF, outputfilename, 'tif');

end