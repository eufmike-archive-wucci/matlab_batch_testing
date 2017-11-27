Image = uint16(bI(:, :, 1)); 
bwIdapi = imbinarize(Image, 'adaptive', 'Sensitivity', 0.05);
if options{1} == 1, figure, imshow(bI(:, :, 1), []); end;
if options{1} == 1, figure, imshow(bwIdapi, []); end;

