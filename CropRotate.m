function outI = CropRotate(inI)
    
    I = imlincomb(1/3, data(:, :, 1), 1/3, data(:, :, 2), 1/3, data(:, :, 3));
    
    BW = imbinarize(I, isodata(I)*0.3);
    stats = regionprops('table', BW, 'BoundingBox', 'Area');
    stats.idx = (1:height(stats))';
    stats = sortrows(stats, 'Area', 'descend');
        
    %BW = bwareafilt(BW, 1,'largest');   
    BW = imfill(BW,'holes');
    se = strel('disk',2, 0);
    BW = imdilate(BW, se);
    BW3D = repmat(BW, [1, 1, 3]);
    I_mod = data.*uint16(BW3D);
    
    
    
end