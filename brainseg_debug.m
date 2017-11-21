function outI = brainseg_debug(I, isolevel, outputfolder)
    %% generate a binary for the whole tissue
    % the bw will be used for identifying the midline

    mixI = imlincomb(1/3, I(:, :, 1), 1/3, I(:, :, 2), 1/3, I(:, :, 3));
    bwI = imbinarize(mixI, isodata(mixI)*isolevel);
    bwI = bwareafilt(bwI, 1,'largest');   
    bwI = imfill(bwI,'holes');
    se = strel('disk',2, 0);
    bwI = imdilate(bwI, se);
    
    stats_total = regionprops(bwI, 'BoundingBox');
    midx = stats_total.BoundingBox(3)/2 + stats_total.BoundingBox(1); 
    midy = stats_total.BoundingBox(4)/2 + stats_total.BoundingBox(2);
    
    %% binary operation for brain area (other channels)
    % use the "edge_merge" function for finding edge 
    % the function merge at least two different edge detection method
    
    bI = []; 
    for i = 1:size(I, 3)
        bI(:, :, i) = imSmooth(I(:, :, i));
    end
    
    %% binary operation for brain area (DAPI)
    % use thresholding strategy for defining DAPI positive region
    bwIdapi = imbinarize(bI(:, :, 1), isodata(bI(:, :, 1))*0.5);
    imwrite(bwIdapi, fullfile(outputfolder, 'BWdapi.png')); 
    figure
    imshow(bwIdapi, []);

    %% binary operation for brain area (other channel)
    edgI = [];
    outI2_1 = edgemerge(I(:, :, 2), 'Canny'); 
    outI2_2 = edgemerge(I(:, :, 2), 'Roberts');
    
    edgI(:, :, 1) = imlincomb(1, outI2_1, 1, outI2_2);
    
    outI3_1 = edgemerge(I(:, :, 3), 'Canny');
    outI3_2 = edgemerge(I(:, :, 3), 'Roberts');
    edgI(:, :, 2) = imlincomb(1, outI3_1, 1, outI3_2);
    
    edgI = uint8(sum(edgI, 3));
    figure
    imshow(edgI, []);
    %% find brain area
    edgethrd = 0.12;
    objectcount = 0;
    while objectcount == 0
        bwedge = im2bw(edgI, edgethrd);
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
    
    outI = edgebwBrain;
end

   
