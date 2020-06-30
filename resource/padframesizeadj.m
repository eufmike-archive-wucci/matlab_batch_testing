function I_pad = padframesizeadj(I, framesize)
    imgsize = size(I);
    padsize = framesize - imgsize;
    I_pad = padarray(I, padsize , 0, 'post');
end