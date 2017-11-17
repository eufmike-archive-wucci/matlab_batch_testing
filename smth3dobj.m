function outbw3d = smth3dobj(bw3d, options)
    se01 = options(1);
    se02 = options(2);
    se03 = options(3);
    se04 = options(4);
    se05 = options(5);
    se06 = options(6);

    outbw3d = [];
    for i = 1:size(bw3d, 4)
        
        se = strel('disk',se01);
        I = imclose(bw3d(:, :, :, i), se);
        I = imfill(I,'holes');
        
        se = strel('disk', se02,0);
        I = imdilate(I, se);  
        se = strel('disk', se03,0);
        I = imerode(I, se);
        
        
        method = 'Canny';   
        [~, threshold] = edge(I, method);
        I = edge(I, method, threshold, se04);
        I = imfill(I,'holes');

        se = strel('disk', se05,0);
        I = imdilate(I, se);    
        I = imfill(I,'holes'); 
        se = strel('disk', se06,0);
        I = imerode(I, se);

        outbw3d(:, :, :, i) = I;
        
    end
    
end
