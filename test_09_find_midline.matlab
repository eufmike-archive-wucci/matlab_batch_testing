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