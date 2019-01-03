function outI = brainseg_debug(I, options)
    % brainseg create a binary for brain region
    % I: 3 channel raw image 
    % finetuning options: 
    % 1. ftStatus: finetuning mode, on: TRUE; off: FALSE(default);
    % 2. ftFolder: finetuning output folder, must be a existing folder;
    
    % check if options variable
    numvarargs = length(options);
    if numvarargs > 2
        error('myfuns:brainseg_debug: TooManyInputs', ...
            'requires at most 3 optional inputs');
    end

    % check if the second variable a dir when finetuning mode is on
    if (options{1} == 1) && (exist(options{2}) == 0)
        error('myfuns:brainseg_debug: Fourth Input must be a existing folder');
    end

    % set default inputs
    optargs = {false, 'empty'};
    optargs(1:numvarargs) = options; 
    [ftStatus, ftFolder] =  optargs{:};
    
    %% binary operation for brain area (other channels)
    % use the "edge_merge" function for finding edge 
    % the function merge at least two different edge detection method
    
    bI = []; 
    for i = 1:size(I, 3)
        bI(:, :, i) = imSmooth(I(:, :, i));
    end

    %% binary operation for brain area (DAPI)
    % use thresholding strategy for defining DAPI positive region
    bwIdapi = imbinarize(uint16(bI(:, :, 1)), isodata(bI(:, :, 1))*1);
    bwIdapi = bwareafilt(bwIdapi, 1);
    if options{1} == 1, imwrite(bwIdapi, fullfile(ftFolder, '02_BWdapi.png')), end;

    %% binary operation for brain area (other channel)
    edgI = [];
    outI2_1 = edgemerge(I(:, :, 2), 'Canny'); 
    outI2_2 = edgemerge(I(:, :, 2), 'Roberts');  
    edgI(:, :, 1) = imlincomb(1, outI2_1, 1, outI2_2);
    

    outI3_1 = edgemerge(I(:, :, 3), 'Canny');
    outI3_2 = edgemerge(I(:, :, 3), 'Roberts');
    edgI(:, :, 2) = imlincomb(1, outI3_1, 1, outI3_2);
    
    if options{1} == 1, imwrite(edgI(:, :, 1), fullfile(ftFolder, '03_488.png')), end;
    if options{1} == 1, imwrite(edgI(:, :, 2), fullfile(ftFolder, '04_647.png')), end;

    edgI = uint8(sum(edgI, 3));

    %% find brain area
    edgethrd = 0.12;
    objectcount = 0;
    while objectcount == 0
        bwedge = imbinarize(edgI, edgethrd);
        % clean edge
        % refine edge and display
         se = strel('disk',4,0);
         bwedge = imdilate(bwedge, se);    
         bwedge = imcomplement(bwedge);
         bwedge = bwareaopen(bwedge, 500);
         bwedge = imclearborder(bwedge); %remove background 
        
        % colocalize with dapi
        edgebwBrain = bitand(bwIdapi, bwedge);
        % select by size
        edgebwBrain = bwareafilt(edgebwBrain, [10000, ]);
        
        % return unber of objects
        cc = bwconncomp(edgebwBrain);
        objectcount = cc.NumObjects;
        edgethrd = edgethrd - 0.02;
        
    end
    if options{1} == 1, imwrite(edgebwBrain, fullfile(ftFolder, '05_BW.png')), end;
    outI = edgebwBrain;

end

   
