function filename = removedot(filename)
% removethumb removes hidden files and folders starting with "." or ".."
    regexp_crit = '^[^.]+'; % the pattern of general expression
    rxResult = regexp(filename, regexp_crit); % pick the string follow the rule
    nodot = (cellfun('isempty', rxResult)==0); % convert to logicals
    filename = filename(nodot); % use logicals select filenames
    
end