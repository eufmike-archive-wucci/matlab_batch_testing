tic
data = imread(inName);
toc

I = [];
tic 
I = imlincomb(1/3, data(:, :, 1), 1/3, data(:, :, 2), 1/3, data(:, :, 3));
toc
figure
imshow(I, [])
d

I = [];
tic
I = double(data);
I = sum(I, 3)./3;
toc
figure
imshow(I, [])

profile on 
I = imlincomb(1/3, inI(:, :, 1), 1/3, inI(:, :, 2), 1/3, inI(:, :, 3));
    
    BW = imbinarize(I, isodata(I)*0.3);
    cc = bwconncomp(BW);
    stats = regionprops('table', cc, 'BoundingBox', 'Area'); 
    stats.idx = (1:height(stats))';
    stats = sortrows(stats, 'Area', 'descend');
    BW2 = ismember(labelmatrix(cc), stats.idx(1));
    
    %BW = bwareafilt(BW, 1,'largest');   
    BW2 = imfill(BW2,'holes');
    se = strel('disk',2, 0);
    BW2 = imdilate(BW2, se);
    BW3D = repmat(BW2, [1, 1, 3]);
    I_mod = inI.*uint16(BW3D);
profile off
profile viewer
figure
imshow(I_mod(:, :, 1), [])

%% test function
inName = inputfilename{i};
Img = imread(inName);

outI = CropRotate(Img);