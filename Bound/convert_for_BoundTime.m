filenames_images = uigetfile('*_binary.tif', 'Pick Binary Images', 'Multiselect', 'on');
num_files_images = length(filenames_images);
for a= 1:num_files_images
    im1=filenames_images{a};
    im2=imread(im1);
    %im3=struct('mask_cell',im2);
    mask_cell=im2;
    save_name_tracks = strrep(im1, '_binary.tif', '_seg.mat');
    save(save_name_tracks,'mask_cell')
end