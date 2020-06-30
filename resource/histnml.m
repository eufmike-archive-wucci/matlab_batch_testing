function img = histnml(I, top, bottom)
    img = double((I - bottom))/double(top - bottom) * 255;
    img = round(img);
%     figure
%     imshow(img, []);
%     impixelinfo;
    img = uint8(img);
end
