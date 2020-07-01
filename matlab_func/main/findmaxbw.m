function xyBoundingBox = findmaxbw(boundingboxarray)
% the boundingbox must be in an array
    boundingboxarray(:, 5) = boundingboxarray(:, 1) + boundingboxarray(:, 3);
    boundingboxarray(:, 6) = boundingboxarray(:, 2) + boundingboxarray(:, 4);
    
    xymin = min(boundingboxarray(:, 1:2),[], 1);
    xymax = max(boundingboxarray(:, 5:6),[], 1);
    xylength = xymax - xymin;   
    xyBoundingBox = [xymin, xylength];    