% By Dr. Chien-cheng Shih (Mike)
% This script crop, rotate and save images from Zeiss AxioScan with
% three color channels. Tiff saving depends on saveastiff.m functions.
% 
% The procedure is rewritten for parallel computing.  
%
%

% cd '/Users/michaelshih/Documents/wucci_data/batch_test/';
% home
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

clear all
tic
profile on

%% creat the list for unprocessed files
% get folder names
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
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
filters = {'tif_images'; 'crop_rotate'; 'crop_rotate_resized'; 'BWbrain'; 'BWsmth'; 'BWoutlinergb'};
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
    outputfiles = dir(fullfile(folder_path, foldername)); 
    outputfiles = removedot({outputfiles.name}');
    %remove extension
    outputfiles_noext = rmext(outputfiles); 
    
    inputidx = ~ismember(inputfiles_noext, outputfiles_noext);
    idxresults{i} = inputidx;
    fileresults{i} = inputfiles_noext(inputidx);
    
end

if sum(sum(cell2mat(idxresults))) > 0
    parpool('local', 4)
end

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
        omeMeta = I{1,4};
        ChannelCount = omeMeta.getChannelCount(0); %  number of channels
        ChannelCount = uint8(ChannelCount);

        channelname = [];
        exwave = [];
        for n = 1:ChannelCount;
            x = n-1; 
            % eval(['channelname_', num2str(n), '= omeMeta.getChannelName(0,' num2str(x),');']);
            % eval(['channelname_', num2str(n), 
            % channelname_', num2str(n), '.toCharArray'';']);
            % disp(eval(['channelname_', num2str(n)]));
            channelnameTemp = omeMeta.getChannelName(0, x);
            channelname{n} = channelnameTemp.toCharArray'; 
            exwaveTemp = omeMeta.getChannelExcitationWavelength(0, x);
            exwave{n} = exwaveTemp.value.double;

        end
        channelinfo = table([1:3]', channelname', [cell2mat(exwave)]');
    
        channelinfo.Properties.VariableNames = {'Idx','ChannelName', 'ChannelExWave'};
        channelinfo = sortrows(channelinfo, 'ChannelExWave');
        Idx = channelinfo.Idx;

        I_TIF = bf2arrayxyc(I, Idx);
        I = [];

        imwrite(I_TIF, outName);
        I_TIF = [];
    end
    
end

%% Filter 02: Crop and rotate images
filter_order = 2;
[inputfls, outputfls, numFrames] = filegen(filters, filter_order, folder_path, fileresults, '.tif', '.tif');

% create tiff output
if sum(idxresults{filter_order}) > 0
    parfor i = 1: numFrames
        %create filename variables for output and input
        inName = inputfls{i};
        outName = outputfls{i};
        
        disp(inName);
        I = imread(inName);
        
        I_TIF = CropRotate(I);
        I = [];

        imwrite(I_TIF, outName);
        I_TIF = [];
    end
    
end

%% Filter 03: resize
filter_order = 3;
[inputfls, outputfls, numFrames] = filegen(filters, filter_order, folder_path, fileresults, '.tif', '.tif');

% create tiff output
if sum(idxresults{filter_order}) > 0
    % parpool('local', 4)
    parfor i = 1: numFrames
        %create filename variables for output and input
        inName = inputfls{i};
        outName = outputfls{i};
        
        disp(inName);
        I = imread(inName);
        
        I_TIF = imresize(I, 0.1);
        I = [];

        imwrite(I_TIF, outName);
        I_TIF = [];
    end
    
end

%% Filter 04: BWbrain
filter_order = 4;
[inputfls, outputfls, numFrames] = filegen(filters, filter_order, folder_path, fileresults, '.tif', '.tif');

% create tiff output
if sum(idxresults{filter_order}) > 0
    parfor i = 1: numFrames
        %create filename variables for output and input
        inName = inputfls{i};
        outName = outputfls{i};
        
        disp(inName);
        I = imread(inName);
        
        expandsize = [10, 10];
        exI = padarray(I, expandsize, 0, 'both');
        I_TIF = brainseg(exI, 0.3);        
%         figure
%         imshow(outI, []);
%         impixelinfo;
        
        I = [];
        exI = [];
        imwrite(I_TIF, outName);
        I_TIF = [];
    end
    
end

%% Filter 05: BWsmth
filter_order = 5;
[inputfls, outputfls, numFrames] = filegen(filters, filter_order, folder_path, fileresults, '.tif', '.mat');

% create tiff output
if sum(idxresults{filter_order}) > 0
    parfor i = 1: numFrames
        %create filename variables for output and input
        inName = inputfls{i};
        outName = outputfls{i};
        
        disp(inName);
        I = imread(inName);
        options = [20, 6, 4, 20, 6, 1];
        [I_TIF, stats] = bw3dsmth(I, options); 
        I = [];
        exI = [];
        
        parsave(outName, I_TIF);
        I_TIF = [];
        
    end
    
end

%% Filter 06: BWoutline
filter_order = 6;
[inputfls, outputfls, numFrames] = filegen(filters, filter_order, folder_path, fileresults, '.mat', '.tif');
inputfls1 = inputfls;

filenames = fileresults{filter_order};
inputfls2 = fullfile(folder_path, 'crop_rotate_resized', strcat(filenames, '.tif'));

% create tiff output
if sum(idxresults{filter_order}) > 0
    parfor i = 1: numFrames
        %create filename variables for output and input
        inName1 = inputfls1{i}; %BW
        inName2 = inputfls2{i}; %allimage
        outName = outputfls{i};
        
        disp(inName1);
        disp(inName2);
        data = load(inName1);   
        I1 = data.variable;
        
        I2 = imread(inName2);
        expandsize = [10, 10];
        exI2 = padarray(I2, expandsize, 0, 'both');
        exI2 = imlincomb(1/3, exI2(:, :, 1), 1/3, exI2(:, :, 2), 1/3, exI2(:, :, 3));
        
        tic 
        imgOLrgb = outlineoverlap3D(exI2, I1)        
        figure
        imshow(imgOLrgb, []);
        impixelinfo;
        toc

        I = [];
        exI = [];
        
        imwrite(imgOLrgb, outName);
        imgOLrgb = [];
        
    end
end

%% end
delete(gcp('nocreate'))
profile off
toc