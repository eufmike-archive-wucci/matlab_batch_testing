function outI = brainseg(I, options)
    fprintf('\nbrainseg function start...');

    % brainseg create a binary for brain region
    % I: 3 channel raw image 
    % finetuning options: 
    % option 1: parameter for the brain segmentation
    % option 2: ftStatus_show: show finetuning img on: TRUE; off: FALSE(default)
    % option 3: ftStatus_save: save finetuning img on: TRUE; off: FALSE(default)
    % option 4: ftFolder: dir for finetuning img
    % option 5: ftFile: curret image name
  
    % check if options variable
    numvarargs = length(options);
    if numvarargs > 5
        error('myfuns:brainseg: TooManyInputs', ...
            'requires at most 5 optional inputs');
    end
    fprintf('\nvariable check finish...');

    % check if the second variable a dir when finetuning mode is on
    if (options{3} == 1) && (length(options{5}) == 0)
        error('myfuns:brainseg: Fourth Input must be a existing folder');
    end
    fprintf('\nfinetuning check finish...');

    % load options and save as variables
    optargs(1:numvarargs) = options(:); 
    [pars, ftStatus_show, ftStatus_save, ftFolder, ftFile] =  optargs{:};
    
    fprintf('\nParameters:\n');
    fprintf('%d, ', pars);
    fprintf('\nftStatus: %s', ftStatus_show);
    fprintf('\nftFolder: %s', ftStatus_save);
    fprintf('\nftFolder: %s', ftFolder);
    fprintf('\nftFolder: %s', ftFile);
    
    dapithrd = pars(1);
    edgethrd = pars(2);
    dillvl1 = pars(3);
    dapi2 = pars(4);
    dillvl2 = pars(5);
    erolvl1 = pars(6);
    bwcount = pars(7);
    fprintf('\narg set finish...');

    
    %% binary operation for brain area
    

    %% binary operation for brain area (DAPI)
    
    % smooth DAPI image
    fprintf('\nblur DAPI channel start...');
    
    bldaptI = imSmooth(I(:, :, 1));
    
    fprintf('\nblur DAPI channel end...');
    
    % use thresholding strategy for defining DAPI positive region
    fprintf('\ncreate DAPI binary start...');
    bwIdapi = imbinarize(uint16(bldaptI), 'adaptive', 'Sensitivity', dapithrd);
    
    % remove the biggest object which should be the outter frame (background)
    bwIdapi = bwareafilt(bwIdapi, 1);
    fprintf('\ncreate DAPI binary end...');
    
    % show image
    if ftStatus_show == 1
        figure
        imshow(bwIdapi, []);
    end;
    
    % save image
    if ftStatus_save == 1 
        imwrite(bwIdapi, fullfile(ftFolder, '01_dapi_binary', ftFile)); 
    end;
    
    fprintf('\nedge detection start...');
    
    %% binary operation for brain area (other channel)
    % use the "edge_merge" function for finding edge 
    % the function merge at least two different edge detection method
    edgI = [];
    outI2_1 = edgemerge(I(:, :, 2), 'Canny'); 
    outI2_2 = edgemerge(I(:, :, 2), 'Roberts');  
    edgI(:, :, 1) = imlincomb(1, outI2_1, 1, outI2_2);

    outI3_1 = edgemerge(I(:, :, 3), 'Canny');
    outI3_2 = edgemerge(I(:, :, 3), 'Roberts');
    edgI(:, :, 2) = imlincomb(1, outI3_1, 1, outI3_2);
    fprintf('\nedge detection end...');
    edgI = uint8(edgI);

    % save image
    if ftStatus_save == 1 
        imwrite(edgI(:, :, 1), fullfile(ftFolder, '02_488', ftFile)); 
        imwrite(edgI(:, :, 2), fullfile(ftFolder, '03_647', ftFile));
    end;
    
    fprintf('\nbrain detection start...');
    
    edgI = sum(edgI, 3);
    % whos('edgI');
    
    if ftStatus_show == 1
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
        if ftStatus_show == 1 
            figure
            imshow(bwedge, []);
        end;
        
        % colocalize with dapi
        bwedge = bitand(bwIdapi, bwedge);
        
        if ftStatus_show == 1
            figure
            imshow(bwedge, []);
        end;
        
        if ftStatus_save == 1
            imwrite(bwedge, fullfile(ftFolder, '04_bwedge', ftFile));
        end;
        
        % clean edge
        % refine edge and display
        fprintf('\nset se');
        fprintf('\nbw manipulation'); 
        se = strel('disk', dillvl1, 0);
        bwedge = imdilate(bwedge, se);
        
        if ftStatus_show == 1
            figure
            imshow(bwedge, []);
        end;
        
        bwedge = imcomplement(bwedge);
        
        if ftStatus_show == 1
            figure
            imshow(bwedge, []);
        end;
        
        if ftStatus_save == 1
            imwrite(bwedge, fullfile(ftFolder, '05_bwedge_dilation', ftFile));
        end;
        
        bwedge = bwareaopen(bwedge, 50);
        if ftStatus_show == 1
            figure
            imshow(bwedge, []);
        end;
        
        bwedge = imclearborder(bwedge); %remove background 
        if ftStatus_show == 1
            figure
            imshow(bwedge, []);
        end;
        
        if ftStatus_save == 1
            imwrite(bwedge, fullfile(ftFolder, '06_bwedge_rmbkg', ftFile));
        end;
        
        if dapi2 == 1,
            bwedge = bitand(bwIdapi, bwedge);
        end;
        
        if ftStatus_show == 1
            figure
            imshow(bwedge, []);
        end;
        
        fprintf('\ncolocalize with dapi');
        
        % select by size       
        fprintf('\nfilter by size');
        
        edgebwBrain = bwareafilt(bwedge, [1000, ]);
        
        if ftStatus_show == 1
            figure
            imshow(edgebwBrain, []);
        end;
        
        se = strel('disk', dillvl2, 0);
        edgebwBrain = imdilate(edgebwBrain, se);
        se = strel('disk', erolvl1, 0);
        edgebwBrain = imerode(edgebwBrain, se);

        edgebwBrain = bwareafilt(edgebwBrain, bwcount);
        edgebwBrain = imfill(edgebwBrain, 'holes');
        
        if ftStatus_show == 1
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
    if ftStatus_save == 1
        imwrite(edgebwBrain, fullfile(ftFolder, '07_BW', ftFile));
    end;
    
    cc = bwconncomp(edgebwBrain);
    L = labelmatrix(cc);
    % if options{1} == 1, fprintf('\nsize: %d\n', cc.NumObjects), end;

    outI = edgebwBrain;
    fprintf('\nbrainseg function end...\n');
end
