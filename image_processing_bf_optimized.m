% By Dr. Chien-cheng Shih (Mike)
% This script crop, rotate and save images from Zeiss AxioScan with
% three color channels. Tiff saving depends on saveastiff.m functions.
% 
% The procedure is rewritten for parallel computing.  
%
%

tic

%% Define the path of folders
folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
input_folder = 'raw_images';
output_folder = 'output_images';
input = dir(fullfile(folder_path, input_folder, '*.ome.tiff')); 
filename = {input.name}';
numFrames= numel(filename);

%% generate file list 
inputfilename = fullfile(folder_path, input_folder, filename);
outputfilename = fullfile(folder_path, output_folder, filename);
outputfilename = strrep(outputfilename, '.ome.tiff', '.tif'); %% change file name

%% file readers

parpool('local', 4)
parfor i = 1: numFrames
    % Initialize logging at INFO level
    bfInitLogging('INFO');
    % Initialize a new reader per worker as Bio-Formats is not thread safe
    r = javaObject('loci.formats.Memoizer', bfGetReader(), 0);
    
    inName = fullfile(inputfilename{i});
    disp(inName);
    
    % Initialization should use the memo file cached before entering the
    % parallel loop
    r.setId(inName);
    I = bfopen(inName);
    r.close()
    
    I_TIF = bf2arrayxyc(I);
    I = [];
    
    outName = fullfile(outputfilename{i});
    imwrite(I_TIF, outName);
   
    I_TIF = [];
end

delete(gcp('nocreate'))

toc