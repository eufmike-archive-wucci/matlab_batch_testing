cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';
clear all;

folder_path_1 = '/Users/michaelshih/Documents/wucci_data/batch_test/BWbrain';
foldernedted = dir(folder_path_1);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 
inputfilename_1 = fullfile(folder_path_1, foldernested_nodot);

folder_path_2 = '/Users/michaelshih/Documents/wucci_data/batch_test/crop_rotate_resized';
foldernedted = dir(folder_path_2);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 
inputfilename_2 = fullfile(folder_path_2, foldernested_nodot);



for m = 1:1;
    I1 = imread(inputfilename_1{m});
    figure
    imshow(I1, []);

    I2 = imread(inputfilename_2{m});
    expandsize = [10, 10];
    Iback = padarray(I2, expandsize, 0, 'both');
    Iback = imlincomb(1/3, Iback(:, :, 1), 1/3, Iback(:, :, 2), 1/3, Iback(:, :, 3));
    figure
    imshow(Iback, []);

    
    options = [10, 6, 3, 10, 5, 2]

    A1 = [14:20];
    A2 = [5:6];
    A3 = [3:4];
    A4 = [14:20];
    A5 = 5;
    A6 = 2;
    options = combvec(A1, A2, A3, A4, A5, A6);
    display(options);

    parpool('local', 5)

    parfor n = 1:size(options, 2);
        [outI, stats] = bw3dsmth(I1, options(:, n));
        
        imgOLrgb = outlineoverlap3D(Iback, outI); 

        display(int2str(n));
        % figure
        % imshow(imgOLrgb, []);
        outputfilename = strcat('/Users/michaelshih/Documents/wucci_data/batch_test/test2/file_', int2str(n), '.tif');
        imwrite(imgOLrgb, outputfilename);

    end
    delete(gcp('nocreate'))
end

