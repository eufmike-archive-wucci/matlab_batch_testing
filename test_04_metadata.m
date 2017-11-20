cd '/Users/michaelshih/Documents/wucci_data/batch_test/code';
clear all;

folder_path_1 = '/Users/michaelshih/Documents/wucci_data/batch_test/raw_images';
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
	I1 = bfopen(inputfilename_1{m});
    metadata = I1{1, 2};
    subject = metadata.get('Subject');
	title = metadata.get('Title');

	metadataKeys = metadata.keySet().iterator();
	for i=1:metadata.size()
	  	key = metadataKeys.nextElement();
	  	value = metadata.get(key);
  		fprintf('%s = %s\n', key, value)
	end
end
