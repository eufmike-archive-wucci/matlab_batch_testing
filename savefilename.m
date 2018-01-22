close all; clear all;
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab_current/';
foldername = '12_SelectedBrainRGB';

filenamelist = dir(fullfile(folder_path, foldername));
filenamelist = removedot({filenamelist.name}');
filenamelist = rmext(filenamelist); 
filenamelist = cell2table(filenamelist);


datafolder = fullfile(folder_path, 'code', 'data', 'filenamelist.csv');
writetable(filenamelist, datafolder);