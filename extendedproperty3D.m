function table = extendedproperty3D(I)
n = size(I, 4);
table = [];
for i = 1:n
    img = I(:, :, i);
    stats = regionprops('table', img, 'all');
    stats.SubarrayIdx = [];
    stats.ConvexHull = [];
    stats.ConvexImage = [];
    stats.Image = [];
    stats.FilledImage = [];
    stats.Extrema = [];
    stats.PixelIdxList = [];
    stats.PixelList = [];
    stats.Circularity = (4*pi*stats.Area)./((stats.Perimeter).^2);
    stats.Aspectratio = stats.MajorAxisLength./stats.MinorAxisLength; 
    stats.Roundness = (4*stats.Area)./(pi*(stats.MajorAxisLength).^2);
    table = vertcat(table, stats);
end
 
