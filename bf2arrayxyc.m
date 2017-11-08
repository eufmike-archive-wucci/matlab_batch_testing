function I_TIF = bf2arrayxyc(I)
% BF2ARRAYXYC convert multiple-channel 2D image from BIOFORMATS(bfmatlab)
% to a 3D array. I_TIF = BF2ARRAYXYC(I) takes the first element of BIOFORMATS 
% structure which includes pixel intensity, then store into a standalone
% matrix, I_TIF, with the equivalent size of I. 
%
% This function is not designed for hyperstacks in Z or time.

    numChannels = size(I{1,1}, 1);
    I_TIF = zeros([size(I{1,1}{1,1}) numChannels], class(I{1,1}{1,1}));
    for j = 1:numChannels
        I_TIF(:, :, j) = double(I{1, 1}{j, 1});
    end

end