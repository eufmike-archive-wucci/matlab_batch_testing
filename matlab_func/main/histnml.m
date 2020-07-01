function img = histnml(I, top, bottom)
    img = double((I - bottom))/double(top - bottom) * 65535;
    img = round(img);
%     figure
%     imshow(img, []);
%     impixelinfo;
    img = uint16(img);
end
