function outI = edgemerge(I, method, iteration, level, fudgeFactor)
    fprintf('\nedgemerge.m');
    if ~exist('iteration'); iteration = 10; end
    if ~exist('level'); level = 1; end
    if ~exist('fudgeFactor'); fudgeFactor = 0.1; end

    outI = [];    
    x = 1;
    for m = 1:iteration
        fprintf('\nforloop %d', x);   
        [~, threshold] = edge(I, method);
        edgeim = edge(I, method, threshold * fudgeFactor * m);   
        se = strel('disk', level, 0);
        edgeim = imdilate(edgeim, se);
        outI(:, :, m) = edgeim;
        x = x+1; 
    end
    outI = uint8(sum(outI, 3));
end


    