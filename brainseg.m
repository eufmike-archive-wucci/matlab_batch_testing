function outI = brainseg(I, options)
    fprintf('\nbrainseg function start...');

    % brainseg create a binary for brain region
    % I: 3 channel raw image 
    % finetuning options: 
    % 1. ftStatus: finetuning mode, on: TRUE; off: FALSE(default);
    % 2. ftFolder: finetuning output folder, must be a existing folder;
    
    % check if options variable
    numvarargs = length(options);
    if numvarargs > 2
        error('myfuns:brainseg: TooManyInputs', ...
            'requires at most 3 optional inputs');
    end
    fprintf('\nvariable check finish...');

    % check if the second variable a dir when finetuning mode is on
    if (options{1} == 1) && (length(options{2}) == 0)
        error('myfuns:brainseg: Fourth Input must be a existing folder');
    end
    fprintf('\nfinetuning check finish...');

    % set default inputs
    optargs = {true, 'empty'};
    optargs(1:numvarargs) = options; 
    [ftStatus, ftFolder] =  optargs{:};
    fprintf('\nftStatus: %d', ftStatus);
    fprintf('\fftFolder: %s', ftFolder);
    fprintf('\narg set finish...');

    %% binary operation for brain area (other channels)
    % use the "edge_merge" function for finding edge 
    % the function merge at least two different edge detection method
    fprintf('\nload image start...');
    
    bldaptI = imSmooth(I(:, :, 1));
    
    fprintf('\nload image end...');

    %% binary operation for brain area (DAPI)
    % use thresholding strategy for defining DAPI positive region
    figure; imshow(bldaptI, []);
    fprintf('\ncreate DAPI image start...');
    % bwIdapi = imbinarize(im2double(bldaptI), isodata(bI(:, :, 1)));
    % bwIdapi = imbinarize(uint16(bldaptI), 'global');
    bwIdapi = imbinarize(uint16(bldaptI), 'adaptive', 'Sensitivity', 0.9);

    bwIdapi = bwareafilt(bwIdapi, 1);
    fprintf('\ncreate DAPI image end...');
    if options{1} == 1, imwrite(bwIdapi, fullfile(ftFolder, '02_BWdapi.png')), end;
    figure; imshow(bwIdapi, []);

    fprintf('\nedge detection start...');
    %% binary operation for brain area (other channel)
    edgI = [];
    outI2_1 = edgemerge(I(:, :, 2), 'Canny'); 
    outI2_2 = edgemerge(I(:, :, 2), 'Roberts');  
    edgI(:, :, 1) = imlincomb(1, outI2_1, 1, outI2_2);
    
    outI3_1 = edgemerge(I(:, :, 3), 'Canny');
    outI3_2 = edgemerge(I(:, :, 3), 'Roberts');
    edgI(:, :, 2) = imlincomb(1, outI3_1, 1, outI3_2);
    fprintf('\nedge detection end...');
    
    % if options{1} == 1, imwrite(edgI(:, :, 1), fullfile(ftFolder, '03_488.png')), end;
    % if options{1} == 1, imwrite(edgI(:, :, 2), fullfile(ftFolder, '04_647.png')), end;

    fprintf('\nbrain detection start...');
    edgI = uint8(sum(edgI, 3));

    figure
    imshow(edgI, []);

    %% find brain area
    edgethrd = 0.12;
    objectcount = 0;
    x = 1;
    while objectcount < 1
        fprintf('\nwhileloop round %d', x);
        fprintf('\nedge detection binarize');
        bwedge = imbinarize(edgI, edgethrd);
        figure
        imshow(bwedge, []);
        % clean edge
        % refine edge and display
        fprintf('\nset se');
        se = strel('disk',4,0);
        fprintf('\nbw manipulation');
        bwedge = imdilate(bwedge, se);    
        bwedge = imcomplement(bwedge);
        bwedge = bwareaopen(bwedge, 500);
        bwedge = imclearborder(bwedge); %remove background 
        figure
        imshow(bwedge, []);
        fprintf('\ncolocalize with dapi');
        % colocalize with dapi
        edgebwBrain = bitand(bwIdapi, bwedge);
        % select by size
        % edgebwBrain = bwareafilt(edgebwBrain, [40000, ]);
        fprintf('\nfilter by size');
        edgebwBrain = bwareafilt(edgebwBrain, 30);
        figure; imshow(edgebwBrain, []);

        % return number of objects
        fprintf('\ncount obejct number');
        cc = bwconncomp(edgebwBrain);
        objectcount = cc.NumObjects;
        fprintf('\nobejct number: %d', objectcount);
        edgethrd = edgethrd - 0.02;
        fprintf('\noedgethrd: %d', edgethrd);
        x = x+1
    end
    fprintf('\nbrain detection end...');
    figure; imshow(edgebwBrain, []);
    % if options{1} == 1, imwritÇe(edgebwBrain, fullfile(ftFolder, '05_BW.png')), end;
    
    cc = bwconncomp(edgebwBrain);
    L = labelmatrix(cc);
    % if options{1} == 1, fprintf('\nsize: %d\n', cc.NumObjects), end;

    outI = edgebwBrain;
    fprintf('\nbrainseg function end...\n');
end
