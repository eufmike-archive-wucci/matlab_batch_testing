function stats = extendedproperty(I)
	fprintf('\nfunction extendedproperty.m start...');
	stats = regionprops('table', I, 'Area', 'BoundingBox', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength',...
		'Orientation', 'Perimeter');
	% stats.SubarrayIdx = [];
	% stats.ConvexHull = [];
	% stats.ConvexImage = [];
	% stats.Image = [];
	% stats.FilledImage = [];
	% stats.Extrema = [];
	% stats.PixelIdxList = [];
	% stats.PixelList = [];
	stats.Circularity = (4*pi*stats.Area)./((stats.Perimeter).^2);
	stats.Aspectratio = stats.MajorAxisLength./stats.MinorAxisLength; 
	stats.Roundness = (4*stats.Area)./(pi*(stats.MajorAxisLength).^2);
	t = size(stats);
    height = t(1);
    stats.idx = (1:height)'; 
	fprintf('\nfunction extendedproperty.m end...\n');
end