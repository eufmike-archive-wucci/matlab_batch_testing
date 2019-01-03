cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

clear all
tic
profile on

%% creat the list for unprocessed files
% get folder names
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
folder_path = '/Volumes/wuccistaff/Mike/Mast_Lab_03/test/';

foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = 'raw_images';
% inputfolder = 'raw_output_ometif';
inputfiles = dir(fullfile(folder_path, inputfolder, '*.ome.tiff')); 
inputfiles = removedot({inputfiles.name}');
inputfiles = strrep(inputfiles, '.ome.tiff', '.ometiff');
inputfiles_noext = rmext(inputfiles);

inputfiles_noext = inputfiles_noext(1:1);

filtercount = 5;
% define the filter
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

% filterrange ver 1.0: 
filters = filters(1:filtercount);
fileExt = fileExt(1:filtercount);

idxresults = {};
fileresults = {};

% house keeping files 
brainsegparfile = fullfile(folder_path, 'code', 'data', 'brainsegpar.csv');
brainsegpar = csvread(brainsegparfile);
smthparfile = fullfile(folder_path, 'code', 'data', 'smthpar.csv');
smthpar = csvread(smthparfile);
BRFilename = fullfile(folder_path, 'code', 'data', 'brainregion.csv');
brainROIcode = csvread(BRFilename);
expandlevelfile = fullfile(folder_path, 'code', 'data', 'expand.csv');
expandlevel = csvread(expandlevelfile);

% check the availability of outputfolder and check the uncompleted files 
for m = 1:filtercount
    foldername = filters{m};
    
    % the existance of folder
    if any(strcmp(foldernested_nodot, foldername)) == 0
            mkdir(fullfile(folder_path, foldername));
    end
    
    % the existance of files, assuming they are all tif files
    outputfiles = dir(fullfile(folder_path, foldername)); 
    outputfiles = removedot({outputfiles.name}');
    %remove extension
    outputfiles_noext = rmext(outputfiles); 
    
    inputidx = ~ismember(inputfiles_noext, outputfiles_noext);
    idxresults{m} = inputidx;
    fileresults{m} = inputfiles_noext(inputidx);
    
end

idxresultsMat_raw = cell2mat(idxresults);
idxfilename = logical(sum(idxresultsMat_raw, 2));
idxresultsMat = idxresultsMat_raw(idxfilename, :);
idxlocation = find(idxfilename);

filenames = {};
filenames{1} = fullfile(folder_path, inputfolder, strcat(inputfiles_noext(idxfilename), '.ome.tiff'));
% generate filename array 
for m = 1:filtercount
    foldername = filters{m};
    ext = fileExt{m};
    filenames{m+1} = fullfile(folder_path, foldername, strcat(inputfiles_noext(idxfilename), ext)); 
end

numFiles = sum(idxfilename);
fprintf('\nnumber of files: %d\n', numFiles);

% Switch parfor according to the file counts
if numFiles < 2
  parforArg = 0;
else
  parforArg = 4;
end
fprintf('\nnumber of workers: %d\n', parforArg);