function outI = brainseg(I, options)
    fprintf('\nbrainseg function start...');

    % brainseg create a binary for brain region
    % I: 3 channel raw image 
    % finetuning options: 
    % 1. ftStatus: finetuning mode, on: TRUE; off: FALSE(default);
    % 2. ftFolder: finetuning output folder, must be a existing folder;

    % check if options variable
    numvarargs = length(options);
    if numvarargs > 3
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
    optargs = {true, 'empty', [0.9, 19, 1, 2, 0, 1, 10]};
    optargs(1:numvarargs) = options(:); 
    [ftStatus, ftFolder, pars] =  optargs{:};
    fprintf('\nftStatus: %d', ftStatus);
    fprintf('\nftFolder: %s', ftFolder);
    fprintf('\nParameters:\n');
    fprintf('%d, ', pars);
    dapithrd = pars(1);
    edgethrd = pars(2);
    dillvl1 = pars(3);
    dapi2 = pars(4);
    dillvl2 = pars(5);
    erolvl1 = pars(6);
    bwcount = pars(7);
    fprintf('\narg set finish...');

    %% binary operation for brain area (other channels)
    % use the "edge_merge" function for finding edge 
    % the function merge at least two different edge detection method
    fprintf('\nload image start...');
    
    bldaptI = imSmooth(I(:, :, 1));
    
    fprintf('\nload image end...');

    %% binary operation for brain area (DAPI)
    % use thresholding strategy for defining DAPI positive region
    % figure; imshow(bldaptI, []);
    fprintf('\ncreate DAPI image start...');
    % bwIdapi = imbinarize(im2double(bldaptI), isodata(bI(:, :, 1)));
    % bwIdapi = imbinarize(uint16(bldaptI), 'global');
    bwIdapi = imbinarize(uint16(bldaptI), 'adaptive', 'Sensitivity', dapithrd);

    bwIdapi = bwareafilt(bwIdapi, 1);
    fprintf('\ncreate DAPI image end...');
    if options{1} == 1, imwrite(bwIdapi, fullfile(ftFolder, '02_BWdapi.tif')), end;
    if options{1} == 1, 
        figure
        imshow(bwIdapi, []);
    end;

    fprintf('\nedge detection start...');
    %% binary operation for brain area (other channel)
    edgI = [];
    outI2_1 = edgemerge(I(:, :, 2), 'Canny'); 
    outI2_2 = edgemerge(I(:, :, 2), 'Roberts');  
    edgI(:, :, 1) = imlincomb(1, outI2_1, 1, outI2_2);
    % edgI1 = edgI(:, :, 1);

    outI3_1 = edgemerge(I(:, :, 3), 'Canny');
    outI3_2 = edgemerge(I(:, :, 3), 'Roberts');
    edgI(:, :, 2) = imlincomb(1, outI3_1, 1, outI3_2);
    % edgI2 = edgI(:, :, 2);
    fprintf('\nedge detection end...');
    edgI = uint8(edgI);

    % figure
    % imshow(edgI(:, :, 1), []);
    % figure
    % imshow(edgI(:, :, 2), []);
    if options{1} == 1, imwrite(edgI(:, :, 1), fullfile(ftFolder, '03_488.png')), end;
    if options{1} == 1, imwrite(edgI(:, :, 2), fullfile(ftFolder, '04_647.png')), end;
    % whos('edgI1');
    % whos('edgI2');
    fprintf('\nbrain detection start...');
    edgI = sum(edgI, 3);
    whos('edgI');
    if options{1} == 1, 
        figure
        imshow(edgI, []);
    end;
    

    %% find brain area
    objectcount = 0;
    x = 1;

    while objectcount < 1
        fprintf('\nwhileloop round %d', x);
        fprintf('\nedge detection binarize');
        bwedge = imbinarize(edgI, edgethrd);
        if options{1} == 1, 
            figure
            imshow(bwedge, []);
        end;
        % colocalize with dapi
        bwedge = bitand(bwIdapi, bwedge);
        if options{1} == 1, 
            figure
            imshow(bwedge, []);
        end;
        % clean edge
        % refine edge and display
        fprintf('\nset se');
        fprintf('\nbw manipulation'); 
        se = strel('disk', dillvl1, 0);
        bwedge = imdilate(bwedge, se);
        if options{1} == 1, 
            figure
            imshow(bwedge, []);
        end;
        
        bwedge = imcomplement(bwedge);
        if options{1} == 1, 
            figure
            imshow(bwedge, []);
        end;
        
        bwedge = bwareaopen(bwedge, 50);
        if options{1} == 1, 
            figure
            imshow(bwedge, []);
        end;
        
        bwedge = imclearborder(bwedge); %remove background 
        if options{1} == 1, 
            figure
            imshow(bwedge, []);
        end;
        if dapi2 == 1,
            bwedge = bitand(bwIdapi, bwedge);
        end
        if options{1} == 1, 
            figure
            imshow(bwedge, []);
        end;
        fprintf('\ncolocalize with dapi');
        
        % select by size       
        fprintf('\nfilter by size');
        
        edgebwBrain = bwareafilt(bwedge, [1000, ]);
        if options{1} == 1, 
            figure
            imshow(edgebwBrain, []);
        end;
        
        se = strel('disk', dillvl2, 0);
        edgebwBrain = imdilate(edgebwBrain, se);
        se = strel('disk', erolvl1, 0);
        edgebwBrain = imerode(edgebwBrain, se);

        edgebwBrain = bwareafilt(edgebwBrain, bwcount);
        edgebwBrain = imfill(edgebwBrain, 'holes');
        
        if options{1} == 1, 
            figure
            imshow(edgebwBrain, []);
        end;

        
        % figure; imshow(edgebwBrain, []);

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
    % figure; imshow(edgebwBrain, []);
    if options{1} == 1, imwrite(edgebwBrain, fullfile(ftFolder, '05_BW.png')), end;
    
    cc = bwconncomp(edgebwBrain);
    L = labelmatrix(cc);
    % if options{1} == 1, fprintf('\nsize: %d\n', cc.NumObjects), end;

    outI = edgebwBrain;
    fprintf('\nbrainseg function end...\n');
end
