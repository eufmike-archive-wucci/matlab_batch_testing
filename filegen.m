function [inputfls, outputfls, numFrames] = filegen(filters, order, path, fileresults, inExt, outExt)
    filenames = fileresults{order};

    inputfolder = filters(order-1);
    outputfolder = filters(order);
    % construct filenames
    inputfls = fullfile(path, inputfolder, strcat(filenames, inExt));
    outputfls = fullfile(path, outputfolder, strcat(filenames, outExt));

    % number of image need to be processed
    numFrames= numel(filenames);
    
end
