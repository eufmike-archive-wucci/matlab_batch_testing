function outbw3d = smthbwary(bw3d, options)
    % brainseg create a binary for brain region
    % I: 3 channel raw image 
    % finetuning options: 
    % 1. ftStatus: finetuning mode, on: TRUE; off: FALSE(default);
    % 2. ftFolder: finetuning output folder, must be a existing folder;

    fprintf('\nfunction smthbwary.m start...');
    
    % check if options variable
    numvarargs = length(options);

    if numvarargs > 2
        error('myfuns:smthbwary: TooManyInputs', ...
            'requires at most 3 optional inputs');
    end

    % check if the second variable a dir when finetuning mode is on
    if (options{1} == 1) && (length(options{2}) ~= 6)
        error('myfuns:smthbwary: missing parameters inputs');
    end

    % set default inputs
    optargs = {false, [20, 6, 4, 20, 6, 1]};
    ftStatus = optargs{1};
    pars = optargs{2}; 

    fprintf('\nParameters:\n');
    fprintf('%d, ', pars);
    se01 = pars(1);
    se02 = pars(2);
    se03 = pars(3);
    se04 = pars(4);
    se05 = pars(5);
    se06 = pars(6);

    outbw3d = [];
    fprintf('\nsize: %d', size(bw3d, 4));

    for i = 1:size(bw3d, 4)
        
        se = strel('disk',se01);
        I = imclose(bw3d(:, :, :, i), se);
        I = imfill(I,'holes');
        
        se = strel('disk', se02, 0);
        I = imdilate(I, se);  
        se = strel('disk', se03, 0);
        I = imerode(I, se);
        
        
        method = 'Canny';   
        [~, threshold] = edge(I, method);
        I = edge(I, method, threshold, se04);
        I = imfill(I,'holes');

        se = strel('disk', se05,0);
        I = imdilate(I, se);    
        I = imfill(I,'holes'); 
        se = strel('disk', se06,0);
        I = imerode(I, se);

        outbw3d(:, :, :, i) = I;
        
    end
    fprintf('\nfunction smthbwary.m end...\n');
end
