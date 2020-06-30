function filename = removethumb(filename)
    regexp_crit = 'Thumbs'; % the pattern of general expression
    rxResult = regexp(filename, regexp_crit); % pick the string follow the rule
    nothb = (cellfun('isempty', rxResult)==1); % convert to logicals
    filename = filename(nothb); % use logicals select filenames
    
end