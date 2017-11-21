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

for m = 1:1
	I = imread(inputfilename{m});
	figure
	imshow(I, []);
	imwrite(I, fullfile(outputfolder, '01_resized.png'));

    expandsize = [10, 10];
    exI = padarray(I, expandsize, 0, 'both');
    I_TIF = brainseg_debug(exI, 0.3, outputfolder); 
    figure
	imshow(I_TIF, []);
	imwrite(I_TIF, fullfile(outputfolder, '06_I_TIF.png'));
end