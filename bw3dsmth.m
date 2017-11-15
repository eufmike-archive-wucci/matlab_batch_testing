function [outI, stats] = bw3dsmth(I)
    %% build label map (bw3D)
    cc = bwconncomp(I);
    L = labelmatrix(cc);
    
    bw3D = [];
    for i = 1:cc.NumObjects
        bw3D(:, :, :, i) = ismember(L, i);
    end
    
    stats = extendedproperty3D(bw3D);
    
    %% smooth multi-layer BW
    
    outbw3D = smth3dobj(bw3D);

    outI = outbw3D;
end