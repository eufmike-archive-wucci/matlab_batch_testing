function outbw3d = smth3dobj(bw3d)
    
    outbw3d = [];
    for i = 1:size(bw3d, 4)
        se = strel('disk',10);
        I = imclose(bw3d(:, :, :, i), se);
        I = imfill(I,'holes');
        
        se = strel('disk', 6,0);
        I = imdilate(I, se);  
        se = strel('disk', 3,0);
        I = imerode(I, se);
        
        method = 'Canny';   
        [~, threshold] = edge(I, method);
        I = edge(I, method, threshold, 10);
        I = imfill(I,'holes');
        se = strel('disk', 5,0);
        I = imdilate(I, se);    
        I = imfill(I,'holes'); 
        se = strel('disk', 2,0);
        I = imerode(I, se);

        outbw3d(:, :, :, i) = I;
        
    end
    
end
