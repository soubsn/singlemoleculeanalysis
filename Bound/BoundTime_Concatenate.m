function con = BoundTime_Concatenate
filenames_TR = uigetfile('*Trackdata.mat', 'Training','Multiselect', 'on');
        filenames_TR = filenames_TR'; 
        num_files_TR = length(filenames_TR);
        Tracks_cell_TR = cell(num_files_TR,1);
        Tracks_cell_seg = cell(num_files_TR,1);
        for i = 1:num_files_TR

                 ld_TR = importdata(filenames_TR{i});

                 training_TR = ld_TR.Training;%Track_mate_training;
                 seg_TR = ld_TR.Segmented_Tracks;
                 %class_len = length(classify_CL);
                 %training_TR_rev = training_TR(1:class_len,:);
                 %Tracks_cell_CL{i}=classify_CL';
                 Tracks_cell_TR{i} = training_TR ;
                 Tracks_cell_seg{i} = seg_TR;
        end


        tracks_training_final = vertcat(Tracks_cell_TR{:});
        tracks_seg_final = vertcat(Tracks_cell_seg{:});
        save('tracks_training_combined.mat', 'tracks_training_final');
        save('tracks_seg_combined.mat', 'tracks_seg_final');
end