close all; clear all;

folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab/data/Mast_Lab_demo';
foldername = 'resource';
sudfoldername = 'raw_output';

filenamelist = dir(fullfile(folder_path, foldername, sudfoldername));
filenamelist = removedot({filenamelist.name}');
filenamelist = rmext(filenamelist); 
filenamelist = rmext(filenamelist);
filenamelist = cell2table(filenamelist);

if ~exist(fullfile(folder_path, 'code', 'note'), 'dir')
    mkdir(fullfile(folder_path, 'code', 'note'));
end 

datafolder = fullfile(folder_path, 'code', 'note', 'filenamelist.csv');
writetable(filenamelist, datafolder);