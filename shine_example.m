files = dir(fullfile('iaps_orig','*.jpg'));

% cell array of image matrices
for file_num = 1:numel(files)
   im{file_num} = imread(fullfile(files(file_num).folder, files(file_num).name));
end

% calculate average luminance within each image
im_ave_lum = cellfun(@(x) mean2(rgb2gray(x)), im, 'UniformOutput', 0);

% lumMatch according to the average of average luminance
lum = mean(cell2mat(im_ave_lum));
contrast = 70;      % can change contrast to make im more/less visually clear
im_lum = lumMatch(im, [], [lum contrast]);

% write each matrix of im_lum to file
for file_num = 1:numel(files)
   imwrite(im_lum{file_num}, fullfile('images', files(file_num).name));
end

    