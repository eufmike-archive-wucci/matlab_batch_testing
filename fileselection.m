close all; clear all;
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab_current/';
inputfolder = '14_SelectedBrainRGB_4x';
outputfolder = 'raw_for_construction_4x'

% input the reviewed file-pick as table
fileselection_path = fullfile(folder_path, 'code', 'data', 'filenamelist.csv');
fileselection = readtable(fileselection_path);
filenamelist = fileselection.filenamelist;
pick = fileselection.accept_1;

% check size
size(filenamelist, 1)
size(pick, 1)

% create filename list for picked images
file_pick = filenamelist(logical(pick));
size(file_pick, 1)

%% check if target folder exist
foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

if ~ismember(outputfolder, foldernested_nodot)
	mkdir(fullfile(folder_path, outputfolder));
end

%% copy files
inputfilelist = fullfile(folder_path, inputfolder, strcat(file_pick, '.tif'));
outputfilelist = fullfile(folder_path, outputfolder, strcat(file_pick, '.tif'));
for m = 1:size(inputfilelist, 1)
	copyfile(inputfilelist{m}, outputfilelist{m});
end

%% create dummy_files
file_notpick = filenamelist(~logical(pick));
file_notpick_loc = find(~logical(pick)); 
file_pick_loc = find(logical(pick));

% find source images for dummpy files
for m = 1: length(file_notpick)
	loc = file_notpick_loc(m);
	loc_compare = loc - 1;
	while sum(loc_compare == file_notpick_loc) == 1
		loc_compare = loc_compare - 1;
	end
	file_notpick_replace(m) = loc_compare;
end

% create file name for source images and renamed dummy files
file_notpick_replace_filename = filenamelist(file_notpick_replace); 
file_notpick_rename = strcat(file_notpick, '_dummy.tif');
inputfilelist = fullfile(folder_path, inputfolder, strcat(file_notpick_replace_filename, '.tif'));
outputfilelist = fullfile(folder_path, outputfolder, strcat(file_notpick_rename));

% copy files
for m = 1:size(inputfilelist, 1)
	copyfile(inputfilelist{m}, outputfilelist{m});
end
