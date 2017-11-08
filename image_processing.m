% By Dr. Chien-cheng Shih (Mike)
% This script crop, rotate and save images from Zeiss AxioScan with
% three color channels. Tiff saving depends on saveastiff.m functions.
% 
% The procedure is rewritten for parallel computing.  
%
%
%% Define the path of folders
folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
input_folder = 'raw_images';
output_folder = 'output_images';
input = dir(fullfile(folder_path, input_folder, '*.ome.tiff')); 
filename = {input.name}';
numFrames= numel(filename);

%% generate output file list 
inputfilename = fullfile(folder_path, input_folder, filename);
outputfilename = fullfile(folder_path, output_folder, filename);
outputfilename = strrep(outputfilename, '.ome.tiff', '.tif'); %% change file name

parpool('local', 4)
parfor i = 2: numFrames
    inName = fullfile(inputfilename{i});
    disp(inName);
    I = bfopen(inName);
    
    I_TIF = bf2arrayxyc(I);
    clear I;
    
    outName = fullfile(outputfilename{i});
    imwrite(I_TIF, outName);
   
end

delete(gcp('nocreate'))