function img_ol_rgb = outlineoverlap3D(I, BW_3D)  
    fprintf('\n function outlineoverlap3D.m start:');
    outline_3D_r = [];
    outline_3D_g = [];
    outline_3D_b = [];

    % fprintf('checkpoint1\n');
    for i = 1:size(BW_3D, 4)
        BW = BW_3D(:, :, :, i);
        BWoutline = bwperim(BW);
        SegoutR = im2uint8(I);
        SegoutG = im2uint8(I);
        SegoutB = im2uint8(I);
        SegoutR(BWoutline) = 255; 
        SegoutG(BWoutline) = 255;
        SegoutB(BWoutline) = 0;
        
        outline_3D_r = cat(3, outline_3D_r, SegoutR);
        outline_3D_g = cat(3, outline_3D_g, SegoutG);
        outline_3D_b = cat(3, outline_3D_b, SegoutB);
    end
    % fprintf('checkpoint2\n');
    outline_3D_r_max = max(outline_3D_r, [], 3); 
    outline_3D_g_max = max(outline_3D_g, [], 3);
    outline_3D_b_max = max(outline_3D_b, [], 3);

    img_ol_rgb = cat(3, outline_3D_r_max, outline_3D_g_max, outline_3D_b_max);
    figure 
    imshow(img_ol_rgb, []);
    
    fprintf('\n function outlineoverlap3D.m end:\n');
end