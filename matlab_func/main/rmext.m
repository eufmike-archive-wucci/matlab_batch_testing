% This file complied all required directory operation for
% "image_processing.m." Following functions are included:
%
% RMEXT removes extension. 
%

function filels = rmext(filels)
% RMEXT removes extension for one "dot." "filels" is an cell array of file names.  
% This function can reconstructed into a struct with filepath, name and
% ext in the future.
    for i = 1:length(filels)
       [filepath,name,ext] = fileparts(char(filels{i}));
       filels{i} = name;
    end
end


