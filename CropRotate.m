function outI = CropRotate(inI)
    fprintf('\nfunction CropRotate.m start...')
    I = imlincomb(1/9, inI(:, :, 1), 4/9, inI(:, :, 2), 4/9, inI(:, :, 3));
    
    BW = imbinarize(I, isodata(I)*0.3);
    cc = bwconncomp(BW);
    stats = regionprops('table', cc, 'BoundingBox', 'Area'); 
    stats.idx = (1:height(stats))';
    stats = sortrows(stats, 'Area', 'descend');
    BW2 = ismember(labelmatrix(cc), stats.idx(1));   
    BW2 = imfill(BW2,'holes');
    se = strel('disk',2, 0);
    BW2 = imdilate(BW2, se);
    BW3D = repmat(BW2, [1, 1, 3]);
    I_mod = inI.*uint16(BW3D);
    
    I_mod = imcrop(I_mod, stats.BoundingBox(1, :));
    outI = imrotate(I_mod, 90, 'loose');
    fprintf('\nfunction CropRotate.m end...\n')
end