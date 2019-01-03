tic
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

clear all
% This is for testing the brainseg function
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab_current/test/';

foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = '03_crop_rotate_resized';
inputfiles = dir(fullfile(folder_path, inputfolder, '*.tif')); 
inputfiles = removedot({inputfiles.name}');
inputfiles_noext = rmext(inputfiles);

inputfilename = fullfile(folder_path, inputfolder, strcat(inputfiles_noext, '.tif'));

outputfolder = fullfile(folder_path, 'test_edge');

fprintf('\nLoop start\n');

for m = 2:2
	fprintf('\nLoading file...\n');
	I = imread(inputfilename{m});
	imwrite(I, fullfile(outputfolder, '01_resized.png'));

	fprintf('\npadarray\n');
    expandsize = [30, 30];
    exI = padarray(I, expandsize, 0, 'both');
    
    fprintf('\nbrainseg\n');
    % set the option for brainseg 
    options = {true, outputfolder, [1, 19, 1, 1, 2, 0, 10]}; % finetuning mode
    bwI = brainseg(exI, options); 

    expandsize = [30, 30];
    sum3cI = padarray(I, expandsize, 0, 'both');
    sum3cI = imlincomb(1/3, sum3cI(:, :, 1), 1/3, sum3cI(:, :, 2), 1/3, sum3cI(:, :, 3));

    imgOLrgb = outlineoverlap(sum3cI, bwI); 
    stats = extendedproperty(bwI);
    figure(m)
    imshow(imgOLrgb); 
    hold on
    for n = 1: height(stats);
        t = text(stats.Centroid(n, 1), stats.Centroid(n, 2), num2str(stats.idx(n)));
        t.Color = 'red';
        t.FontSize = 20;
    end
    hold off
    % cc = bwconncomp(bwI);
    % L = labelmatrix(cc);
    % bwIselect = ismember(L, [1,2]);

    % imgOLrgb = outlineoverlap(sum3cI, bwIselect); 
    % figure(m)
    % imshow(imgOLrgb); 

    % close(m)

	% fprintf('\n2D bw -> 3D bw\n');
	% bwI3D = bw2bwary(bwI); 
 %    bwI3DDim = size(bwI3D);
 %    fprintf('\nSize: %d, %d, %d, %d\n', bwI3DDim);
 %    stats = extendedproperty3D(bwI3D);

 %    fprintf('\nSmoothing\n');
	% options = {true, [20, 6, 4, 20, 7, 1]};
	% fprintf('\nmode: %d\n', options{1});
	% fprintf('\nmode: %d, %d, %d, %d, %d, %d\n', options{2});
	% bwI3Dsmth = smthbwary(bwI3D, options);

	% fprintf('\nsaving...\n');
	% output = fullfile(folder_path, 'test_edge', '07_smoothed.mat');
	% save(output, 'bwI3Dsmth');    

	% expandsize = [30, 30];
 %    sum3cI = padarray(I, expandsize, 0, 'both');
 %    sum3cI = imlincomb(1/3, sum3cI(:, :, 1), 1/3, sum3cI(:, :, 2), 1/3, sum3cI(:, :, 3));
 %    imgOLrgb = outlineoverlap3D(sum3cI, bwI3Dsmth); 
 %    figure
	% imshow(imgOLrgb, []);


end
toc