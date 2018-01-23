% cd '/Users/michaelshih/Documents/wucci_data/batch_test/';
% home
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code/';

clear all
tic
profile on

%% creat the list for unprocessed files
% get folder names
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';

inputfolder = '/Volumes/LaCie_1TB/Mast_Lab_final/07_brain_4_aligned';

inputfiles = dir(inputfolder);
inputfiles = removedot({inputfiles.name}');
inputfiles = fullfile(inputfolder, inputfiles);

outputfolder = '/Volumes/LaCie_DataStorage/Mast_Lab_current/raw_for_construction';

outputfiles = dir(outputfolder);
outputfiles = removedot({outputfiles.name}');
outputfiles = fullfile(inputfolder, outputfiles);

for m = 1:length(inputfiles)
% for m = 1
	display(m);
	if ~strcmp(inputfiles{m}, outputfiles{m})		
		movefile(inputfiles{m}, outputfiles{m});
	end
end

