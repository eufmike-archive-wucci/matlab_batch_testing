function [outI, stats] = bw3dsmth(I, options)
    %% build label map (bw3D)
    cc = bwconncomp(I);
    L = labelmatrix(cc);
    
    bw3D = [];
    for i = 1:cc.NumObjects
        bw3D(:, :, :, i) = ismember(L, i);
    end
    
    stats = extendedproperty3D(bw3D);
    
    %% smooth multi-layer BW
    display(options);
    outbw3D = smth3dobj(bw3D, options);

    outI = outbw3D;
end