% cd '/Users/michaelshih/Documents/wucci_data/batch_test/';
% home
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code/';

clear all
tic
profile on

%% creat the list for unprocessed files
% get folder names
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab_current/';

foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = 'raw_image_ometiff_10';
% inputfolder = 'raw_output_ometif';
inputfiles = dir(fullfile(folder_path, inputfolder, '*.ome.tiff')); 
inputfiles = removedot({inputfiles.name}');
% inputfiles = strrep(inputfiles, '.ome.tiff', '.ometiff');
% inputfiles_noext = rmext(inputfiles);

inputfiles = fullfile(folder_path, inputfolder, inputfiles);
inputfiles_t = regexprep(inputfiles, '-Export-[0-9][0-9]_', '-Export-01_');
for m = 1:length(inputfiles)
% for m = 1
	display(m);
	if ~strcmp(inputfiles{m}, inputfiles_t{m})		
		movefile(inputfiles{m}, inputfiles_t{m});
	end
end

