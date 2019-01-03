% folder_path = '/Users/michaelshih/Documents/wucci_data/batch_test/BWoutlinergb';
% foldernedted = dir(folder_path);
% foldernested = {foldernedted.name}';
% foldernested_nodot = removedot(foldernested); 

% for i = 1:1	
% 	I = imread(fullfile(folder_path, foldernested_nodot{i}));
% 	figure
% 	imshow(I);
% end

%%

copyfile(fullfile(docroot, 'techdoc','creating_guis',...
   'examples','simple_gui*.*')),fileattrib('simple_gui*.*', '+w');

guide simple_gui.fig;

edit simple_gui.m


cd '/Users/michaelshih/Documents/MATLAB/GUICodeTest'
