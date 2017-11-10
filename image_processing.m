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

%% creat the list for unprocessed files
% get folder names
folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = 'raw_images';
inputfiles = dir(fullfile(folder_path, inputfolder, '*.ome.tiff')); 
inputfiles = removedot({inputfiles.name}');
inputfiles = strrep(inputfiles, '.ome.tiff', '.ometiff');
inputfiles_noext = rmext(inputfiles);

% define the filter
filters = {'tif_images'; 'crop_rotate'};
numberfilters = length(filters); % get the count of filter

idxresults = {};
fileresults = {};
% check the availability of outputfolder and check the uncompleted files 
for i = 1:numberfilters
    foldername = filters{i};
    
    % the existance of folder
    if any(strcmp(foldernested_nodot, foldername)) == 0
            mkdir(fullfile(folder_path, foldername));
    end
    
    % the existance of files, assuming they are all tif files
    outputfiles = dir(fullfile(folder_path, foldername, '*.tif')); 
    outputfiles = removedot({outputfiles.name}');
    %remove extension
    outputfiles_noext = rmext(outputfiles); 
    
    inputidx = ~ismember(inputfiles_noext, outputfiles_noext);
    idxresults{i} = inputidx;
    fileresults{i} = inputfiles_noext(inputidx);
    
end

%compare files


%% Filter 01: Save OME.TIFF to TIF
filter_order = 1;
% generate filename
filenames = fileresults{filter_order};
outputfolder = filters(filter_order);
% construct filenames
inputfilename = fullfile(folder_path, inputfolder, strcat(filenames, '.ome.tiff'));
outputfilename = fullfile(folder_path, outputfolder, strcat(filenames, '.tif'));

% number of image need to be processed
numFrames= numel(filenames);

% create tiff output
if sum(idxresults{filter_order}) > 0
    parpool('local', 4)
    parfor i = 1: numFrames
        %create filename variables for output and input
        inName = inputfilename{i};
        outName = outputfilename{i};
        
%         % Initialize logging at INFO level
%         bfInitLogging('INFO');
%         % Initialize a new reader per worker as Bio-Formats is not thread safe
%         r = javaObject('loci.formats.Memoizer', bfGetReader(), 0);
        
        disp(inName);
        I = bfopen(inName);
        %r.close()
        
        I_TIF = bf2arrayxyc(I);
        I = [];

        imwrite(I_TIF, outName);
        I_TIF = [];
    end
    
end

%% Filter 02: Crop and rotate images
filter_order = 2;
% generate filename
filenames = fileresults{filter_order};

inputfolder = filters(filter_order-1);
outputfolder = filters(filter_order);
% construct filenames
inputfilename = fullfile(folder_path, inputfolder, strcat(filenames, '.tif'));
outputfilename = fullfile(folder_path, outputfolder, strcat(filenames, '.tif'));

% number of image need to be processed
numFrames= numel(filenames);

% create tiff output
if sum(idxresults{filter_order}) > 0
    parpool('local', 4)
    parfor i = 1: numFrames
        %create filename variables for output and input
        inName = inputfilename{i};
        outName = outputfilename{i};
        
        disp(inName);
        I = imread(inName);
        
        I_TIF = CropRotate(I);
        I = [];

        imwrite(I_TIF, outName);
        I_TIF = [];
    end
    
end

%% end
delete(gcp('nocreate'))
profile off
toc