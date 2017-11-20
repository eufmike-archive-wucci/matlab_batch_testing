folder_path = '/Volumes/MacProHD1/Dropbox/WUCCI_dropbox/Mast_lab_02/';
foldernedted = dir(folder_path);
foldernested = {foldernedted.name}';
foldernested_nodot = removedot(foldernested); 

% create input file list
inputfolder = 'raw_images';
inputfiles = dir(fullfile(folder_path, inputfolder, '*.ome.tiff')); 
inputfiles = removedot({inputfiles.name}');
inputfiles = strrep(inputfiles, '.ome.tiff', '.ometiff');
inputfiles_noext = rmext(inputfiles);

inputfilename = fullfile(folder_path, inputfolder, strcat(inputfiles_noext, '.ome.tiff'));

for m = 1:1
	reader = bfGetReader(inputfilename{m});
	omeMeta = reader.getMetadataStore();
	stackSizeX = omeMeta.getPixelsSizeX(0).getValue(); % image width, pixels
	stackSizeY = omeMeta.getPixelsSizeY(0).getValue(); % image height, pixels
	stackSizeZ = omeMeta.getPixelsSizeZ(0).getValue(); % number of Z slices
	ChannelCount = omeMeta.getChannelCount(0); %  number of channels
	ChannelCount = uint8(ChannelCount);
	
	for n = 1:ChannelCount;
		x = n-1; 
		eval(['channelname_', num2str(n), '= omeMeta.getChannelName(0,' num2str(x),');']);
		eval(['channelname_', num2str(n), '= channelname_', num2str(n), '.toCharArray'';']);
		disp(eval(['channelname_', num2str(n)]));
	end

end

