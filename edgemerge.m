function outI = edgemerge(I, method, iteration, level, fudgeFactor)
% for Canny repeating steps

    if ~exist('iteration'); iteration = 10; end
    if ~exist('level'); level = 1; end
    if ~exist('fudgeFactor'); fudgeFactor = 0.1; end

% option need to include matrix of method and fudgeFactor
    outI = [];    
    for i = 1:iteration   
        [~, threshold] = edge(I, method);
        edgeim = edge(I, method, threshold * fudgeFactor * i);   
        se = strel('disk', level, 0);
        edgeim = imdilate(edgeim, se);
        outI(:, :, i) = edgeim;
    end
    outI = uint8(sum(outI, 3));
end


    