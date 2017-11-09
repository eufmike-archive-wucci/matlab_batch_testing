% By Dr. Chien-cheng Shih (Mike)
% This script crop, rotate and save images from Zeiss AxioScan with
% three color channels. Tiff saving depends on saveastiff.m functions.
% 
% The procedure is rewritten for parallel computing.  
%
%
clear all
tic
profile on

%% Define the path of folders
folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

%% create and check folder
input_folder = 'raw_images';

% define the filter
filters = {'tif_images'; 'crop_rotate'};
numberfilters = length(filters); % get the count of filter

% assign filters to variable 
for i = 1:numberfilters
    eval(['outputfolder', num2str(i), ' = "' filters{i}, '";']);
    eval(['outputfolder', num2str(i), ' = ', 'char(outputfolder', num2str(i), ')'])
end

% check the availability of outputfolder
for i = 1:numberfilters
    foldername = eval(['outputfolder', num2str(i)]);
    if any(strcmp(foldernested_nodot, foldername)) == 0
            mkdir(fullfile(folder_path, foldername));
    end
end
%% compare files in the "raw_images" and "tif_images" 
inputfiles = dir(fullfile(folder_path, input_folder, '*.ome.tiff')); 
inputfiles = removedot({inputfiles.name}');
outputfiles = dir(fullfile(folder_path, outputfolder1, '*.tif')); 
outputfiles = removedot({outputfiles.name}');

filenamesA_noext = strrep(inputfiles, '.ome.tiff', ''); %remove extension
filenamesB_noext = strrep(outputfiles, '.tif', ''); %remove extension

inputidx = ~ismember(filenamesA_noext, filenamesB_noext);

filenames = filenamesA_noext(inputidx)

%% generate filename
% inputfilename
inputfilename = fullfile(folder_path, input_folder, filenames);
% outputfilename
outputfilename = fullfile(folder_path, outputfolder1, filenames);
% change file name
outputfilename = strrep(outputfilename, '.ome.tiff', '.tif'); 

% number of image need to be processed
numFrames= numel(inputfilename_fin);

%% create tiff output
if sum(inputidx) > 0w
    parpool('local', 4)
    parfor i = 1: numFrames
        %create filename variables for output and input
        inName = fullfile(inputfilename_fin{i});
        outName = fullfile(outputfilename{i});
        
        % Initialize logging at INFO level
        bfInitLogging('INFO');
        % Initialize a new reader per worker as Bio-Formats is not thread safe
        r = javaObject('loci.formats.Memoizer', bfGetReader(), 0);
        
        disp(inName);
        I = bfopen(inName);
        r.close()
        
        I_TIF = bf2arrayxyc(I);
        I = [];

        imwrite(I_TIF, outName);

        I_TIF = [];
    end
    delete(gcp('nocreate'))
end

%% second filter
% generate inputfilename
inputfilename = fullfile(folder_path, input_folder, inputfiles);
inputfilename_fin = inputfilename(inputidx);

% number of image need to be processed
numFrames= numel(inputfilename_fin);

%% generate tiff output file list
outputfilename = fullfile(folder_path, outputfolder1, inputfilename);
outputfilename = strrep(outputfilename(inputidx), '.ome.tiff', '.tif'); % change file name

profile off
toc