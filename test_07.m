tic
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';

% This is for testing the brainseg function
folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = 'crop_rotate_resized';
inputfiles = dir(fullfile(folder_path, inputfolder, '*.tif')); 
inputfiles = removedot({inputfiles.name}');
inputfiles_noext = rmext(inputfiles);

inputfilename = fullfile(folder_path, inputfolder, strcat(inputfiles_noext, '.tif'));

outputfolder = fullfile(folder_path, 'test_edge');

fprintf('\nLoop start\n');

for m = 1:1
	fprintf('\nLoading file...\n');
	I = imread(inputfilename{m});
	imwrite(I, fullfile(outputfolder, '01_resized.png'));

	fprintf('\npadarray\n');
    expandsize = [10, 10];
    exI = padarray(I, expandsize, 0, 'both');
    
    fprintf('\nbrainseg\n');
    % set the option for brainseg 
    options = {true, outputfolder}; % finetuning mode
    bwI = brainseg(exI, options); 
	
	fprintf('\n2D bw -> 3D bw\n');
	bwI3D = bw2bwary(bwI); 
    bwI3DDim = size(bwI3D);
    fprintf('\nSize: %d, %d, %d, %d\n', bwI3DDim);

    fprintf('\nSmoothing\n');
	options = {true, [20, 6, 4, 20, 6, 1]};
	fprintf('\nmode: %d\n', options{1});
	fprintf('\nmode: %d, %d, %d, %d, %d, %d\n', options{2});
	bwI3Dsmth = smthbwary(bwI3D, options);

	fprintf('\nsaving...\n');
	output = fullfile(folder_path, 'test_edge', '07_smoothed.mat');
	save(output, 'bwI3Dsmth');     

end
toc