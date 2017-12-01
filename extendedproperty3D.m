function table = extendedproperty3D(I)
    fprintf('\nfunction extendedproperty3D.m start...');
    table = [];
    for m = 1:size(I, 4)
        % fprintf('\nround: %d', m);
        stats = regionprops('table', I(:, :, :, m), 'Area', 'BoundingBox', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength',...
            'Orientation', 'Perimeter');
        % stats.SubarrayIdx = [];
        % stats.ConvexHull = [];
        % stats.ConvexImage = [];
        % stats.Image = [];
        % stats.FilledImage = [];
        % stats.Extrema = [];
        % stats.PixelIdxList = [];
        % stats.PixelList = [];
        % stats.Circularity = (4*pi*stats.Area)./((stats.Perimeter).^2);
        % stats.Aspectratio = stats.MajorAxisLength./stats.MinorAxisLength; 
        % stats.Roundness = (4*stats.Area)./(pi*(stats.MajorAxisLength).^2);
        % stats
        table = vertcat(table, stats);
    end
    t = size(table);
    height = t(1);
    table.idx = (1:height)'; 
    table.Circularity = (4*pi*table.Area)./((table.Perimeter).^2);
    table.Aspectratio = table.MajorAxisLength./table.MinorAxisLength; 
    table.Roundness = (4*table.Area)./(pi*(table.MajorAxisLength).^2);

    fprintf('\nfunction extendedproperty3D.m end...\n');
end
 
