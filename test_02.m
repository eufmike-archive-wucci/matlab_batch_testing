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

profile on -history
BW = imbinarize(I, isodata(I)*0.3);
BW = bwareafilt(BW, 1,'largest');   
BW = imfill(BW,'holes');
se = strel('disk',2, 0);
BW = imdilate(BW, se);
BW3D = repmat(BW, [1, 1, 3]);
I_mod = data.*uint16(BW3D);
profile off
profile viewer
figure
imshow(I_mod(:, :, 1), [])