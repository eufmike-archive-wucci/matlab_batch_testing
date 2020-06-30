function img = padbyorigin(I, delta)
    
    I_pad = I;
    
    if delta(1) < 0 
        row_loc = 'pre';
        I_pad = padarray(I_pad, abs([delta(1) 0]), 0, row_loc);
    elseif delta(1) > 0
        row_loc = 'post';
        I_pad = padarray(I_pad, abs([delta(1) 0]), 0, row_loc);
    else
    end 
    
    if delta(2) < 0 
        row_loc = 'pre';
        I_pad = padarray(I_pad, abs([0 delta(2)]), 0, row_loc);
    elseif delta(2) > 0
        row_loc = 'post';
        I_pad = padarray(I_pad, abs([0 delta(2)]), 0, row_loc);
    else
    end 
    
    img = I_pad;
end
    
    
        
    
        
            