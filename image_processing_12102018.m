% By Dr. Chien-cheng Shih (Mike)
% This script crop, rotate and save images from Zeiss AxioScan with
% three color channels. Tiff saving depends on saveastiff.m functions.
% 
% The procedure is rewritten for parallel computing.  
%
%

% cd '/Users/michaelshih/Documents/wucci_data/batch_test/';
% home
cd '/Users/michaelshih/Documents/code/wucci/mast_lab_code';

close all;
clear all;
tic
profile on

%% creat the list for unprocessed files
% get folder names
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab/Mast_Lab_002';
imgfolder = 'resource';
img_path = fullfile(folder_path, imgfolder);

foldernedted = dir(img_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = 'raw_output';
% inputfolder = 'raw_output_ometif';
inputfiles = dir(fullfile(img_path, inputfolder, '*.ome.tiff')); 
inputfiles = removedot({inputfiles.name}');
inputfiles = strrep(inputfiles, '.ome.tiff', '.ometiff');
inputfiles_noext = rmext(inputfiles);

% display(inputfiles_noext);
% inputfiles_noext = inputfiles_noext(1:389);
% inputfiles_noext = inputfiles_noext(1:4);
inputfiles_noext = inputfiles_noext(1:254);

filtercount = 14;
% define the filter
filters = {'01_tif_images'; '02_crop_rotate'; '03_crop_rotate_resized'; ...
            '04_BWbrain'; '05_BWoutlinergb'; ...
            '06_SelectedROI'; '07_SelectedBWraw';...
            '08_BWsmth'; '09_BWsmthoutlinergb'; '10_BWsmthadj';...
            '11_SelectedBrainGrey'; '12_SelectedBrainRGB';...
            '13_crop_rotate_resized_4x'; '14_SelectedBrainRGB_4x'};
fileExt = {'.tif'; '.tif'; '.tif'; ... 
            '.tif'; '.tif'; ...
            '.tif'; '.tif'; ...
            '.mat'; '.tif'; '.tif'; ...
            '.tif'; '.tif'; ...
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

% check the existance of finetuning folder
if any(strcmp(foldernested_nodot, 'finetuning')) == 0
            mkdir(fullfile(folder_path, 'finetuning'));
end 

%% check finetuning output folders
ftFolder = fullfile(folder_path, 'finetuning');

ftsteps = {'01_dapi_binary'; '02_488'; '03_647'; ...
        '04_bwedge'; '05_bwedge_dilation'; '06_bwedge_rmbkg'; '07_BW';};

ftFolder_folderlist = dir(ftFolder);
ftFoldernested = {ftFolder_folderlist.name}';
ftFoldernested_nodot = removedot(ftFoldernested); 

ftstepscount = size(ftsteps, 1);

for m = 1:ftstepscount
    foldername = ftsteps{m};
    % the existance of folder
    if any(strcmp(ftFoldernested_nodot, foldername)) == 0
            mkdir(fullfile(ftFolder, foldername));
    end
end

idxresultsMat_raw = cell2mat(idxresults);
idxfilename = logical(sum(idxresultsMat_raw, 2));
idxresultsMat = idxresultsMat_raw(idxfilename, :);
idxlocation = find(idxfilename);

% create input file dir
filenames = {};
filename_noext = inputfiles_noext(idxfilename);
filenames{1} = fullfile(img_path, inputfolder, strcat(filename_noext, '.ome.tiff'));

% generate input filename array 
for m = 1:filtercount
    foldername = filters{m};
    ext = fileExt{m};
    filenames{m+1} = fullfile(folder_path, foldername, strcat(filename_noext, ext)); 
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
        expandsize = [30, 30];
        exI = padarray(I_TIF_resized, expandsize, 0, 'both');
        fprintf('\nbrainsegpar: %d', brainsegpar(idxlocation(m), :)); 
        % set options: 
        % option 1: parameter for the brain segmentation
        % option 2: ftStatus_show: show finetuning img on: TRUE; off: FALSE(default)
        % option 3: ftStatus_save: save finetuning img on: TRUE; off: FALSE(default)
        % option 4: ftFolder: dir for finetuning img
        % option 5: ftFile: curret image name
        
        % finetune folder path
        ftFile = strcat(char(filename_noext(m)), '.tif');
        
        options = {brainsegpar(idxlocation(m), :), false, true, ftFolder, ftFile};
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
    
    expandsize = [30, 30];
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
        close(m)
    else

    end

    fprintf('\nFilter %d end\n', filter_order);
    
    continue
    
    % ================================================================================================
    % Filter 06: folder: SelectedROI

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    % house keeping variables
    code = brainROIcode(idxlocation(m), :);
    code = code(code>0);
    fprintf('\ncode: %d %d\n', code);

    cc = bwconncomp(brainsegI);
    L = labelmatrix(cc);
    brainsegI_selected = ismember(L, code);

    % house keeping variables
    stats = extendedproperty(brainsegI_selected);

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************     
        imgsmth3DOLrgb = outlineoverlap(sum3cI, brainsegI_selected);
        figure(m)
        imshow(imgsmth3DOLrgb); 
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
        close(m)
        % ********************************
    else        
        
    end

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 07: folder: SelectedBWraw

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************
        imwrite(brainsegI_selected, outputfilename);
        % ********************************
    else        
        brainsegI_selected = imread(outputfilename);
    end

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 08: bw2bwary.m & smthbwary.m

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});

    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter ************** 
        bwI3D = bw2bwary(brainsegI_selected);
        if (size(bwI3D, 1) == 0 & size(bwI3D, 2) == 0)
            bwI3D = zeros(size(brainsegI_selected));
        end
        fprintf('\nsmthpar: %s', smthpar(idxlocation(m), :));  
        options = {true, smthpar(idxlocation(m), :)};
        bwI3Dsmth = smthbwary(bwI3D, options);
        parsave(outputfilename, bwI3Dsmth);
        % ********************************

    else
        data = load(outputfilename);
        bwI3Dsmth = data.variable;
    end

    fprintf('\nFilter %d end\n', filter_order);
    
    % ================================================================================================
    % Filter 09: folder: BWsmthoutlinergb 
    % outlineoverlap3D.m & extendedproperty3D.m

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);

    stats3D = extendedproperty3D(bwI3Dsmth);
    
    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************
        % expandsize = [30, 30];
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
    % Filter 10: folder: BWsmthoutlinergb
    % 10_BWsmthadj
    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************
        bwIsmth = max(bwI3Dsmth, [], 4);

        fprintf('\nexpand level: %d', expandlevel(idxlocation(m), :)); 
        explvl = expandlevel(idxlocation(m), :);
        se = strel('disk', explvl, 0);
        bwIsmth = imdilate(bwIsmth, se);
        bwIsmth = imfill(bwIsmth, 'holes');
        bwIsmth = imerode(bwIsmth, se);
        imwrite(bwIsmth, outputfilename);
        % figure
        % imshow(bwIsmth, []);
        % ********************************
    else        
        bwIsmth = imread(outputfilename);
        bwIsmth = uint16(bwIsmth/255);
    end

    fprintf('\nFilter %d end\n', filter_order);


    % % ================================================================================================
    % Filter 11: folder: SelectedBrainGrey
    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    % figure
    % imshow(bwIsmth, []);

    cc = bwconncomp(bwIsmth);
    borderstats = regionprops('table', cc, 'BoundingBox');   
    

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************        
        braingrey = sum3cI.*uint16(bwIsmth);
        
        if height(borderstats) > 0    
            border = findmaxbw(borderstats.BoundingBox);
            braingrey = imcrop(braingrey, border);
        end
        
        expandsize = [5, 5];
        braingrey = padarray(braingrey, expandsize, 0, 'both');
        imwrite(braingrey, outputfilename);
        % figure
        % imshow(braingrey, []);
        % ********************************
    else        
        
    end

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 12: folder: SelectedBrainRGB
    
    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************
        expandsize = [30, 30];
        sum3cI = padarray(I_TIF_resized, expandsize, 0, 'both');
        brainrgb = sum3cI.*uint16(repmat(bwIsmth, [1, 1, 3])); 

        imgsize = size(brainrgb);
        for n = 1:imgsize(3)
            Iv = reshape(brainrgb(:, :, n), 1, []);
            Ivnoz = Iv(Iv>0);
            top = sort(Ivnoz, 'descend');
            top1 = mean(top(1, 1:round(size(Ivnoz,2)*0.01)));
            bottom = sort(Ivnoz, 'ascend');
            bottom1 = mean(bottom(1, 1:round(size(Ivnoz,2)*0.01)));
            brainrgb(:, :, n) = histnml(brainrgb(:, :, n), top1, bottom1); 
        end
        
        if height(borderstats) > 0    
            border = findmaxbw(borderstats.BoundingBox);
            brainrgb = imcrop(brainrgb, border);
        end

        expandsize = [5, 5];
        brainrgb = padarray(brainrgb, expandsize, 0, 'both');

        imwrite(brainrgb, outputfilename, 'tif');
        % figure
        % imshow(brainrgb, []);
        % ********************************
    else        

    end

    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 13: imresize.m

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    inputfilename = filenames{3}{m};
    outputfilename = filenames{filter_order+1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);
    
    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter ************** 
        I_TIF = imread(inputfilename);
        I_TIF_resized_4x = imresize(I_TIF, 0.4);
        imwrite(I_TIF_resized_4x, outputfilename, 'tif');
        % ********************************

    else       
        I_TIF_resized_4x = imread(outputfilename);
    end    
    I_TIF = [];
    fprintf('\nFilter %d end\n', filter_order);

    % ================================================================================================
    % Filter 14: 14_SelectedBrainRGB_4x

    filter_order = filter_order + 1;
    fprintf('\nFilter %d %s start\n', filter_order, filters{filter_order});
    
    % generate and construct filename
    outputfilename = filenames{filter_order + 1}{m};
    fprintf('\nFilter %d output filename: %s\n', filter_order, outputfilename);

    increased_factor = 4;

    if (idxresultsMat(m, filter_order) == 1)

        % **** Apply filter **************
        expandsize = [30*increased_factor, 30*increased_factor];
        sum3cI = padarray(I_TIF_resized_4x, expandsize, 0, 'both');
        sum3cI_size = size(sum3cI);
        bwIsmth_resized_4x = imresize(bwIsmth, sum3cI_size(1:2));
        
        brainrgb_4x = sum3cI.*uint16(repmat(bwIsmth_resized_4x, [1, 1, 3])); 

        imgsize = size(brainrgb_4x);
        for n = 1:imgsize(3)
            Iv = reshape(brainrgb_4x(:, :, n), 1, []);
            Ivnoz = Iv(Iv>0);
            top = sort(Ivnoz, 'descend');
            top1 = mean(top(1, 1:round(size(Ivnoz,2)*0.01)));
            bottom = sort(Ivnoz, 'ascend');
            bottom1 = mean(bottom(1, 1:round(size(Ivnoz,2)*0.01)));
            brainrgb_4x(:, :, n) = histnml(brainrgb_4x(:, :, n), top1, bottom1); 
        end
        
        cc = bwconncomp(bwIsmth_resized_4x);
        borderstats = regionprops('table', cc, 'BoundingBox'); 

        if height(borderstats) > 0    
            border = findmaxbw(borderstats.BoundingBox);
            brainrgb_4x = imcrop(brainrgb_4x, border);
        end

        expandsize = [5, 5];
        brainrgb_4x = padarray(brainrgb_4x, expandsize, 0, 'both');

        imwrite(brainrgb_4x, outputfilename, 'tif');
        % figure
        % imshow(brainrgb_4x, []);
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
    bwI3Dsmth = [];
    bwIsmth = [];
    braingrey = [];
    brainrgb = [];
    Iv = [];
    Ivnoz = [];
    top = [];
    top1 = [];
    bottom = [];
    bottom1 = [];

    I_TIF_resized_4x = [];
    brainrgb_4x = [];
    bwIsmth_resized_4x = [];

end
delete(gcp('nocreate'))
profile off
toc
