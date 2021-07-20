function test = Trackmate_outputter_SuperSegger_ss
folder = cd;
Fileist = dir(fullfile(folder, '**', '*spots*.csv'));
FileList = struct('name', {Fileist(1:end).name});
FileList= struct2table(FileList);
FileList=table2array(FileList);
FileList =natsortfiles(FileList);

[num_files_images,~]=size(FileList);
user_input_tracks = inputdlg({'What was the time interval','Min # of localizations for track',' # of localizations for Intensity','Gap Length'},'Tracks Information',...
    [1 50; 1 50; 1 50;1 50],{'1','4','4','2'});
folder_save = strcat('Trackmate Analysis V8 ','_','Time_Int',num2str(user_input_tracks{1}),'_','datapoints_',num2str(user_input_tracks{2}),'_','GAP_', num2str(user_input_tracks{4}));
mkdir(folder_save);
time_scale = str2num(user_input_tracks{1});
data_point = str2num(user_input_tracks{2});
% speed_fac = str2num(user_input_tracks{7});
% quality_fac = str2num(user_input_tracks{8});
%data_point_psf = str2num(user_input_tracks{3});
data_point_intensity = str2num(user_input_tracks{3});
Tracks_cell_TR = cell(num_files_images,1);
Tracks_cell_seg = cell(num_files_images,1);
for j = 1:num_files_images
Spots=[];
filename_spot = FileList(j);
filename_track = strrep(FileList(j),'_spots','_tracks');
Table_Track = csvread(filename_track{1,1});
Table_Spot = csvread(filename_spot{1,1});
%% 
Quality_Tracks = Table_Track;%.data;
Quality_Tracks_seg = Quality_Tracks;
Quality_Spot = Table_Spot;
thresh_find = find (Quality_Tracks_seg(:,2)<data_point);
Quality_Tracks_seg(thresh_find,:) = [];
for s=1:length(Quality_Tracks_seg(:,1))
    spot_find = find (Quality_Spot(:,1)==Quality_Tracks_seg(s,1));
    sp1 = Quality_Spot(spot_find,:);
    Spots = vertcat(Spots,sp1);
    clear sp1
end
%% 
Track_mate_training = zeros(length(Quality_Tracks_seg(:,1)),13);;
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
emp=isempty(Track_mate_training);
if emp ==1
    continue
end
Tracks_cell_TR{j} = Track_mate_training ;
Tracks_cell_seg{j} = Quality_Tracks_seg;
save_name_tracks = strrep(filename_track{1,1}, '.tif_tracks.csv', '_Trackdata.mat');
data_tracks2 = struct ('Segmented_Tracks',Quality_Tracks_seg, 'Training', Track_mate_training,'Segmented_Spots',Spots);
save(strcat(folder_save,'/',save_name_tracks), 'data_tracks2')
clear row column
end
 tracks_training_final = vertcat(Tracks_cell_TR{:});
 tracks_seg_final = vertcat(Tracks_cell_seg{:});
 save(strcat(folder_save,'/tracks_training_combined.mat'), 'tracks_training_final');
 save(strcat(folder_save,'/tracks_seg_combined.mat'), 'tracks_seg_final');
 save('tracks_training_combined.mat', 'tracks_training_final');
 save('tracks_seg_combined.mat', 'tracks_seg_final');
cd(folder_save)
quest_tr = MFquestdlg ( [ 0.6 , 0.1 ] , 'Do you want do continue analysis?', 'Continue?','Yes, Classify','Yes, Train', 'No', 'Yes, Classify');
if length(quest_tr) == 13
    BoundTime_Classify
elseif length(quest_tr) == 10
    BoundTime_Train
end
end