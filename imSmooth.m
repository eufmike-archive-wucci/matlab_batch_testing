function blurredimg = imSmooth(I, iteration)
% the kernel is the same as ImageJ
    if ~exist('iteration')
        iteration = 1;
    end
    
    m =ones(3);
    blurredimg = I;    
    for i = 1:iteration    
        blurredimg = conv2(blurredimg, m, 'same');
    end
end

    

