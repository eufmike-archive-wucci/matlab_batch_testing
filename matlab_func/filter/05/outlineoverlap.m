% Code for image_processing.m
% Filter 05
% By Mike Shih
% 01-01-2019

function img_ol_rgb = outlineoverlap(I, BW)  
    fprintf('\n function outlineoverlap.m start:');

    % fprintf('checkpoint1\n');
    BWoutline = bwperim(BW);
    SegoutR = im2uint8(I);
    SegoutG = im2uint8(I);
    SegoutB = im2uint8(I);
    SegoutR(BWoutline) = 255; 
    SegoutG(BWoutline) = 255;
    SegoutB(BWoutline) = 0;

    img_ol_rgb = cat(3, SegoutR, SegoutG, SegoutB);
    fprintf('\n function outlineoverlap.m end:\n');
end