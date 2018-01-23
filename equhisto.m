% cd '/Users/michaelshih/Documents/wucci_data/batch_test/';
% home
cd '/Users/michaelshih/Documents/wucci_data/batch_test/code/';

clear all
tic
profile on

%% creat the list for unprocessed files
% get folder names
% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/';
folder_path = '/Volumes/LaCie_DataStorage/Mast_Lab_current/';

foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = '03_crop_rotate_resized';
outputfolder = 'Mast_Lab_final';
outputsubfolder = '02_equhist_1';

inputfiles = dir(fullfile(folder_path, inputfolder, '*.tif')); 
inputfiles = removedot({inputfiles.name}');
% inputfiles = strrep(inputfiles, '.ome.tiff', '.ometiff');
inputfiles_noext = rmext(inputfiles);

inputfiles = fullfile(folder_path, inputfolder, strcat(inputfiles_noext, '.tif'));
outputfiles = fullfile(folder_path, outputfolder, outputsubfolder, strcat(inputfiles_noext, '.tif'));

numFiles = length(inputfiles);

if numFiles < 2
  parforArg = 0;
else
  parforArg = 4;
end
fprintf('\nnumber of workers: %d\n', parforArg);

topbottom = [0.01, 0.08; 0.01, 0.01; 0.01, 0.01];

parfor (m = 1:numFiles, parforArg)
% for m = 1:numFiles
	
	inputfilename = inputfiles{m};
	fprintf('\nfile name: %s\n', inputfilename);
	outputfilename = outputfiles{m}

	I_TIF_resized = imread(inputfilename);
	imgsize = size(I_TIF_resized);

	expandsize = [30, 30];
	I_TIF_resized = padarray(I_TIF_resized, expandsize, 0, 'both');

	for n = 1:imgsize(3)
		topp = topbottom(n, 1);
		bottomp = topbottom(n, 2);

	    Iv = reshape(I_TIF_resized(:, :, n), 1, []);
	    Ivnoz = Iv(Iv>0);
	    top = sort(Ivnoz, 'descend');
	    top1 = mean(top(1, 1:round(size(Ivnoz,2)*topp)));
	    bottom = sort(Ivnoz, 'ascend');
	    bottom1 = mean(bottom(1, 1:round(size(Ivnoz,2)*bottomp)));
	    I_TIF_resized(:, :, n) = histnml(I_TIF_resized(:, :, n), top1, bottom1); 
	end

    imwrite(I_TIF_resized, outputfilename, 'tif');

end


