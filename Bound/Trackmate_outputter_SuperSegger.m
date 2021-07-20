function test = Trackmate_outputter_SuperSegger
filenames_images = uigetfile('*seg.mat', 'Pick Binary Segmentation Files', 'Multiselect', 'on');
filenames_spots = uigetfile('*spots.csv', 'Pick spots.csv', 'Multiselect', 'on');
filenames_tracks = uigetfile('*tracks.csv', 'Pick tracks.csv', 'Multiselect', 'on');
num_files_images = length(filenames_images);
user_input_tracks = inputdlg({'What was the time interval','Min # of localizations for track',' # of localizations for Intensity','Intensity Thresh', 'Track Window' , 'Gap'},'Tracks Information',...
    [1 50; 1 50; 1 50; 1 50; 1 50; 1 50],{'1','4','4', '500', '3', '1'});
folder_save = strcat('Trackmate Analysis V8 ','_','Time_Int',num2str(user_input_tracks{1}),'_',num2str(user_input_tracks{4}),'_','Trkwd_',num2str(user_input_tracks{5}),'_','datpt_',num2str(user_input_tracks{2}),'_','GAP_', num2str(user_input_tracks{6}));
mkdir(folder_save);
time_scale = str2num(user_input_tracks{1});
data_point = str2num(user_input_tracks{2});
% speed_fac = str2num(user_input_tracks{7});
% quality_fac = str2num(user_input_tracks{8});
%data_point_psf = str2num(user_input_tracks{3});
data_point_intensity = str2num(user_input_tracks{3});
for j = 1:num_files_images
row=[];
column=[];
bin_image =open(filenames_images{1,j});
im=bin_image.mask_cell;
[si,ze]=size(im);
LB = 10;
f =(bwareaopen(im,LB));
f(1,:) = 1;
f(end,:) = 1;
f(:,1) = 1;
f(:,end) = 1;
f = imclearborder(f,8);
ff = bwconncomp(f);
stats = regionprops(ff,'PixelList');
l=length(stats);
amp = strel('sphere',1);
for L=1:l
    List = (stats(L).PixelList);
    m=zeros(si,ze);
    p=length(List);
    for P=1:p
        g=List(P,1);
        G=List(P,2);
        m(G,g)=1;
    end
    single=imdilate(m,amp);
    [Row, Column] = find (single ==1);
    row=vertcat(row,Row);
    %row=unique(row);
    column=vertcat(column,Column);
    %column=unique(column);
end
%% 
filename_spot = filenames_spots{1,j};
filename_track = filenames_tracks{1,j};
Table_Track = csvread(filename_track);
Table_Spot = csvread(filename_spot);
%% 
Quality_Tracks = Table_Track;%.data;
Quality_Tracks_seg = zeros(length(Quality_Tracks(:,1)),18);
for i = 1:length(Quality_Tracks(:,1))
    x_coord = round(Quality_Tracks(i,17));
    y_coord = round(Quality_Tracks(i,18));
    row_find = find (row(:,1) == y_coord);
    if isempty(row_find) ==1
        continue
    end
    if ismember (x_coord, column(row_find,1)) == 1
         Quality_Tracks_seg (i,:) = Quality_Tracks(i,:);
    else 
        continue
    end   
end
save_name_tracks_seg = strrep(filename_track, 'tracks.csv', 'seg.mat');   
%% 
Quality_Tracks_seg = Quality_Tracks_seg(any(Quality_Tracks_seg,2),:);
thresh_find = find (Quality_Tracks_seg(:,2)<data_point);
Quality_Tracks_seg(thresh_find,:) = [];
%% 
intensities_track = zeros(length(Quality_Tracks_seg(:,1)),1);
spot_widths_track = zeros(length(Quality_Tracks_seg(:,1)),1);
Track_mate_training = zeros(length(Quality_Tracks_seg(:,1)),13);
spot_dat = Table_Spot;%.data;
for i = 1:length(Quality_Tracks_seg(:,1))
    ID = Quality_Tracks_seg(i,1);
    ID_find = find(spot_dat(:,1)==ID);
    ID_spots = spot_dat(ID_find,:);
    [~, idx] = sort(ID_spots(:,2),1);
    rev_spots = ID_spots(idx,:);
    intensities_track_spot = rev_spots(:,5);
    mean_track_intensity_all = mean(intensities_track_spot(1:end,1));

    max_track_intensity = max(intensities_track_spot(1:end,1));
    Track_mate_training(i,1) = Quality_Tracks_seg(i,3);
    Track_mate_training(i,13) = max_track_intensity;
    Track_mate_training(i,2:6) = Quality_Tracks_seg(i,4:8);
    Track_mate_training(i,7:11) = Quality_Tracks_seg(i,9:13);
    Track_mate_training(i,12) = mean_track_intensity_all;
end
% mean_speed = mean(Quality_Tracks_seg(:,4));
% mean_qual = mean(Quality_Tracks_seg(:,9));
% frac_speed = speed_fac/mean_speed;
% frac_quality = quality_fac/mean_qual;
% Track_mate_training(:,2:6) = Track_mate_training(:,2:6)*frac_speed;
% Track_mate_training(:,7:11) = Track_mate_training(:,7:11)*frac_quality;
save_name_tracks = strrep(filename_track, '.tif_tracks.csv', '_data.mat');
data_tracks = struct ('Segmented_Tracks',Quality_Tracks_seg, 'Training', Track_mate_training);
save(strcat(folder_save,'/',save_name_tracks), 'data_tracks')
clear row column
end
cd(folder_save)
end