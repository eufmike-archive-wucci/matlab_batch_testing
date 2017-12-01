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

filtercount = 11;
% define the filter
filters = {'tif_images'; 'crop_rotate'; 'crop_rotate_resized'; ...
            'BWbrain'; 'BWoutlinergb'; ...
            'BWsmth'; 'BWsmthoutlinergb';...
            'SelectedROI'; 'SelectedBW'; 'SelectedBrainGrey'; 'SelectedBrainRGB'};
fileExt = {'.tif'; '.tif'; '.tif'; ... 
            '.tif'; '.tif'; ...
            '.mat'; '.tif'; ...
            '.tif'; '.tif'; '.tif'; '.tif'};

% filterrange ver 1.0: 
filters = filters(1:filtercount);
fileExt = fileExt(1:filtercount);

idxresults = {};
fileresults = {};

% house keeping files 
BRFilename = fullfile(folder_path, 'data', 'brainregion.csv');
brainROIcode = csvread(BRFilename);

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

% parpool('local', 4);
% parfor m = 1:numFiles
parfor (m = 1:numFiles, parforArg)
% for m = 1:1
% for m = 1:numFiles 
    fprintf('\nForloop start...');
    if (sum(idxresultsMat(m, :)) == 0)
        continue;
    end

    % ================================================================================================
    % Filter 01: bf2arrayxyc.m
    
    filter_order = 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    % generate and construct filename
    inputfilename = filenames{filter_order}{m}; 
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d input filename: %s\n', filter_order, inputfilename);
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);

    if (idxresultsMat(m, filter_order) == 1)
        
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
        imwrite(I_TIF, outputfilename, 'tif');
        % ********************************
    else
        if (idxresultsMat(m, filter_order+1) == 1)
            I_TIF = imread(outputfilename);
        end       
    end
    I = [];

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 02: CropRotate.m

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
     % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    if (idxresultsMat(m, filter_order) == 1)    
        % **** Apply filter ************** 
        I_TIF = CropRotate(I_TIF);
        imwrite(I_TIF, outputfilename, 'tif');
        % ********************************
    else
        if (idxresultsMat(m, filter_order+1) == 1)
            I_TIF = imread(outputfilename);
        end
    end

    fprintf('\nFilter %d end\n', filter_order);
    
    % ================================================================================================
    % Filter 03: imresize.m

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter ************** 
        I_TIF_resized = imresize(I_TIF, 0.1);
        imwrite(I_TIF_resized, outputfilename, 'tif');
        % ********************************

    else       
        I_TIF_resized = imread(outputfilename);
    end    
    I_TIF = [];
    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 04: brainseg.m

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter ************** 
        expandsize = [10, 10];
        exI = padarray(I_TIF_resized, expandsize, 0, 'both');
        options = {false};
        brainsegI = brainseg(exI, options);
        imwrite(brainsegI, outputfilename);
        % ********************************

    else
        brainsegI = imread(outputfilename);
    end 

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 05: outlineoverlap.m

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});

    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    expandsize = [10, 10];
    sum3cI = padarray(I_TIF_resized, expandsize, 0, 'both');
    sum3cI = imlincomb(1/3, sum3cI(:, :, 1), 1/3, sum3cI(:, :, 2), 1/3, sum3cI(:, :, 3));
    
    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter ************** 
        brainsegI_m = imfill(brainsegI, 'holes');
        imgOLrgb = outlineoverlap(sum3cI, brainsegI_m); 
        % imwrite(imgOLrgb, outputfilename);

        stats = extendedproperty(brainsegI_m);
        figure(m)
        imshow(imgOLrgb); 
        hold on
        for n = 1: height(stats);
            t = text(stats.Centroid(n, 1), stats.Centroid(n, 2), num2str(stats.idx(n)));
            t.Color = 'red';
            t.FontSize = 20;
        end
        hold off
        fig = gcf;
        saveas(fig, outputfilename);
        export_fig(outputfilename, '-native');
        % ********************************

    else

    end

    fprintf('\nFilter %d end\n', filter_order);


    % ================================================================================================
    % Filter 06: bw2bwary.m & smthbwary.m

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});

    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter ************** 
        bwI3D = bw2bwary(brainsegI); 
        options = {true, [20, 6, 4, 20, 6, 1]};
        bwI3Dsmth = smthbwary(bwI3D, options);
        parsave(outputfilename, bwI3Dsmth);
        % ********************************

    else
        data = load(outputfilename);
        bwI3Dsmth = data.variable;
    end

    fprintf('\nFilter %d end\n', filter_order);



    % ================================================================================================
    % Filter 07: folder: BWsmthoutlinergb 
    % outlineoverlap3D.m & extendedproperty3D.m

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    % house keeping variables
    stats3D = extendedproperty3D(bwI3Dsmth);

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************
        % expandsize = [10, 10];
        % sum3cI = padarray(I_TIF_resized, expandsize, 0, 'both');
        % sum3cI = imlincomb(1/3, sum3cI(:, :, 1), 1/3, sum3cI(:, :, 2), 1/3, sum3cI(:, :, 3));
        img3DOLrgb = outlineoverlap3D(sum3cI, bwI3Dsmth);
        % imwrite(img3DOLrgb, outputfilename);
        
        figure(m)
        imshow(img3DOLrgb); 
        hold on
        for n = 1: height(stats3D);
            t = text(stats3D.Centroid(n, 1), stats3D.Centroid(n, 2), num2str(stats3D.idx(n)));
            t.Color = 'red';
            t.FontSize = 20;
        end
        hold off
        fig = gcf;
        saveas(fig, outputfilename);
        export_fig(outputfilename, '-native');
        % ********************************
        close(m)
    else        
        img3DOLrgb = imread(outputfilename);
    end

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 08: folder: SelectedROI

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    % house keeping variables
    code = brainROIcode(m, :);
    code = code(code>0);
    bwI3DsmthExtc = bwI3Dsmth(:, :, :, code);

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************     
        imgsmth3DOLrgb = outlineoverlap3D(sum3cI, bwI3DsmthExtc);
        stats3DExtc = stats3D(code, :);
        figure(m)
        imshow(imgsmth3DOLrgb); 
        hold on
        for n = 1: height(stats3DExtc);
            t = text(stats3DExtc.Centroid(n, 1), stats3DExtc.Centroid(n, 2), num2str(stats3DExtc.idx(n)));
            t.Color = 'red';
            t.FontSize = 20;
        end
        hold off
        fig = gcf;
        saveas(fig, outputfilename);
        export_fig(outputfilename, '-native');
        close(m)
        % ********************************
    else        
        
    end

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 09: folder: SelectedBW

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************
        bwIsmthExtc = max(bwI3DsmthExtc, [], 4);
        imwrite(bwIsmthExtc, outputfilename);
        % ********************************
    else        
        bwIsmthExtc = imread(outputfilename);
    end

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 10: folder: SelectedBrainGrey
    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************
        braingrey = sum3cI.*uint16(bwIsmthExtc); 
        imwrite(braingrey, outputfilename);
        % ********************************
    else        
        
    end

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 11: folder: SelectedBrainRGB
    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************
        expandsize = [10, 10];
        sum3cI = padarray(I_TIF_resized, expandsize, 0, 'both');
        brainrgb = sum3cI.*uint16(repmat(bwIsmthExtc, [1, 1, 3])); 
        imwrite(brainrgb, outputfilename, 'tif');
        % ********************************
    else        
        
    end
    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % clear variable
    fprintf('\nRemove variables\n');
    I = [];
    I_TIF = [];
    I_TIF_resized = [];
    exI = []; 
    brainsegI = [];
    bwI3D = []; 
    bwI3Dsmth = [];
    imgOLrgb =[];
    sum3cI = [];
    bwI3DsmthExt = [];
    bwIsmthExtc = [];
    braingrey = [];
    brainrgb = [];

end
delete(gcp('nocreate'))
profile off
toc
