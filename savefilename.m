close all; clear all;
cd '/Users/michaelshih/Documents/code/wucci/mast_lab_code';

folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab/Mast_Lab_002';
foldername = 'resource';
sudfoldername = 'raw_output';

filenamelist = dir(fullfile(folder_path, foldername, sudfoldername));
filenamelist = removedot({filenamelist.name}');
filenamelist = rmext(filenamelist); 
filenamelist = rmext(filenamelist);
filenamelist = cell2table(filenamelist);


datafolder = fullfile(folder_path, 'code', 'note', 'filenamelist.csv');
writetable(filenamelist, datafolder);