function tr = BoundTime_Combine
   filenames_CL = uigetfile('*classification.mat', 'Pick the classification.mat files','Multiselect', 'on');
    filenames_CL = filenames_CL';
    num_files_CL = length(filenames_CL);
    Tracks_cell_CL = cell(num_files_CL,1);
    filenames_TR = uigetfile('*data.mat', 'Training','Multiselect', 'on');
    filenames_TR = filenames_TR';  
    Tracks_cell_TR = cell(num_files_CL,1);
    for i = 1:num_files_CL
             ld = importdata(filenames_CL{i});
             ld_TR = importdata(filenames_TR{i});
             classify_CL = ld;%.Training_classification;
             training_TR = ld_TR.Training;%Track_mate_training;
             class_len = length(classify_CL);
             training_TR_rev = training_TR(1:class_len,:);
             Tracks_cell_CL{i}=classify_CL';
             Tracks_cell_TR{i} = training_TR_rev;
             
    end
    
    tracks_classification_final = vertcat(Tracks_cell_CL{:});
    tracks_training_final = vertcat(Tracks_cell_TR{:});
    save('classification_combined.mat', 'tracks_classification_final')
    save('trained_combined.mat', 'tracks_training_final');
end