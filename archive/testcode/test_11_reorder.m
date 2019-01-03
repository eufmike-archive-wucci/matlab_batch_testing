cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

clear all
tic
profile on

%% creat the list for unprocessed files
% get folder names
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
folder_path = '/Volumes/wuccistaff/Mike/Mast_Lab_03/';

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

m = 1

% for m = 1:1
    filter_order = 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
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
        I_TIF_crop = imcrop(I_TIF, [size(I_TIF, 1)*0.1, size(I_TIF, 2)*0.1, size(I_TIF, 1)*0.8, size(I_TIF, 2)*0.8]);
        imwrite(I_TIF_crop, outputfilename, 'tif');
        % ********************************
    
    I = [];

    fprintf('\nFilter %d end\n', filter_order);


% end