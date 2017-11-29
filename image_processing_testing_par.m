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
folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
% folder_path = '/Volumes/wuccistaff/Mike/Mast_Lab_03';

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

% define the filter
filters = {'tif_images'; 'crop_rotate'; 'crop_rotate_resized'; 'BWbrain'; 'BWsmth'; 'BWoutlinergb'; 'selectedROI'};
fileExt = {'.tif'; '.tif'; '.tif'; '.tif'; '.mat'; '.tif'; '.tif'};
numberfilters = length(filters); % get the count of filter
idxresults = {};
fileresults = {};
% check the availability of outputfolder and check the uncompleted files 
for m = 1:numberfilters
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
idxresultsMat = cell2mat(idxresults);
numFiles = size(idxresultsMat, 1);

filenames = {};
% generate filename array 
for m = 1:numberfilters
    foldername = filters{m};
    ext = fileExt{m};
    filenames{m} = fullfile(folder_path, foldername, strcat(inputfiles_noext, ext)); 
end


% Switch parfor according to the file counts
% if numFiles < 2
%   parforArg = 0;
% else
%   parforArg = 4;
% end

% parfor (m = 1:numFiles, parforArg)
for m = 1:numFiles
    fprintf('\nForloop start...');
    if (sum(idxresultsMat(m, :)) == 0)
        continue;
    end

    % ================================================================================================
    % Filter 01: bf2arrayxyc.m
    
    filter_order = 1;
    fprintf('\nFilter %d start\n', filter_order);

    
    % generate and construct filename
    inputfilename = filenames{filter_order}{m}; 
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d input filename: %s\n', filter_order, inputfilename);
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    I = bfopen(inputfilename);
    
    omeMeta = I{1,4};
    ChannelCount = omeMeta.getChannelCount(0); %  number of channels
    ChannelCount = uint8(ChannelCount);

    channelname = [];
    exwave = [];
    for n = 1:ChannelCount;
        x = n-1; 
        channelnameTemp = omeMeta.getChannelName(0, x);
        channelname{n} = channelnameTemp.toCharArray'; 
        exwaveTemp = omeMeta.getChannelExcitationWavelength(0, x);
        exwave{n} = exwaveTemp.value.double;

    end
    channelinfo = table([1:3]', channelname', [cell2mat(exwave)]');
    
    channelinfo.Properties.VariableNames = {'Idx','ChannelName', 'ChannelExWave'};
    channelinfo = sortrows(channelinfo, 'ChannelExWave');
    Idx = channelinfo.Idx;

    % **** Apply filter **************
    I_TIF = bf2arrayxyc(I, Idx);
    imwrite(I_TIF, outputfilename);
    % ********************************

    
    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 02: CropRotate.m

    filter_order = 2;
    fprintf('\nFilter %d start\n', filter_order);

    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s', filter_order, outputfilename);
    
    % **** Apply filter ************** 
    I_TIF = CropRotate(I_TIF);
    imwrite(I_TIF, outputfilename);
    % ********************************

    fprintf('\nFilter %d end\n', filter_order);
    
    % ================================================================================================
    % Filter 03: imresize.m

    filter_order = 3;
    fprintf('\nFilter %d start\n', filter_order);
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s', filter_order, outputfilename);
    
    % **** Apply filter ************** 
    I_TIF_resized = imresize(I_TIF, 0.1);
    imwrite(I_TIF_resized, outputfilename);
    % ********************************

    fprintf('\nFilter %d start\n', filter_order);

    % ================================================================================================
    % Filter 04: brainseg.m

    filter_order = 4;
    fprintf('\nFilter %d start\n', filter_order);
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s', filter_order, outputfilename);
    
    % **** Apply filter ************** 
    expandsize = [10, 10];
    exI = padarray(I_TIF, expandsize, 0, 'both');
    options = {false};
    brainsegI = brainseg(exI, options);        
    imwrite(brainsegI, outputfilename);
    % ********************************

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 05: bw2bwary.m & smthbwary.m

    filter_order = 5;
    fprintf('\nFilter %d start\n', filter_order);
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s', filter_order, outputfilename);
    
    % **** Apply filter ************** 
    bwI3D = bw2bwary(brainsegI); 
    options = {true, [20, 6, 4, 20, 6, 1]};
    bwI3Dsmth = smthbwary(bwI3D, options);
    parsave(outputfilename, bwI3Dsmth);
    % ********************************

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 06: outlineoverlap3D.m

    filter_order = 6;
    fprintf('\nFilter %d start\n', filter_order);
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s', filter_order, outputfilename);
    
    % **** Apply filter **************
    expandsize = [10, 10];
    sum3cI = padarray(I_TIF_resized, expandsize, 0, 'both');
    sum3cI = imlincomb(1/3, sum3cI(:, :, 1), 1/3, sum3cI(:, :, 2), 1/3, sum3cI(:, :, 3));
    imgOLrgb = outlineoverlap3D(sum3cI, bwI3Dsmth);
    imwrite(imgOLrgb, outputfilename);
    % ********************************

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % clear variable
    I = [];
    I_TIF = [];
    I_TIF_resized = [];
    exI = []; 
    brainsegI = [];
    bwI3D = []; 
    bwI3Dsmth = [];
    imgOLrgb =[];

end
delete(gcp('nocreate'))
profile off
toc
