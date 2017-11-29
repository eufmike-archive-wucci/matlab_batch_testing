function outI = bw2bwary(I)
    % BW2BWARY convert 2Dbw image into BWimage array with objs in each plane
    cc = bwconncomp(I);
    L = labelmatrix(cc);
    fprintf('\nsize %d\n', cc.NumObjects);

    bw3D = [];
    for i = 1:cc.NumObjects
        bw3D(:, :, :, i) = ismember(L, i);
    end    

    outI = bw3D;
end