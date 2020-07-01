function outI = autoscale8bit(I);
	img = I - min(min(I));  
    outI = img .* ((255)/max(max(img)));
end