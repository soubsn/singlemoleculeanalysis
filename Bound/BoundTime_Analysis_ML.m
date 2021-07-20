function TRACKMATEtracker = BoundTime_Analysis_ML

skip_filter_input = inputdlg('Would you like to skip filtering tests?','Existing Data?',[1 50],{'N'});
if skip_filter_input{1} == 'N' || skip_filter_input{1} == 'n'
    input_GMM_clustering = inputdlg({'Intensities components','Time Interval','Truncation Point'}, 'Options',...
        [1 50; 1 50; 1 50], {'4', '0.5', '1.5'});
    time_int = str2num(input_GMM_clustering{2});
    truncation_pt = str2num(input_GMM_clustering{3});
    %% 
    Fileist = dir(fullfile(cd, '**','*_classified*.mat'));
    FileList = struct('name', {Fileist(1:end).name});
    FileList= struct2table(FileList);
    FileList=table2array(FileList);
    filenames=natsortfiles(FileList);
     num_files = length(filenames);
     Tracks_cell = cell(num_files,1);
     training_cell = cell(num_files,1);
     for i = 1:num_files
             ld=importdata(filenames{i});
             Tracks_cell{i}=ld.Tracks_pred2;
             training_cell{i}=ld.TrainingFinal2;
     end
    
    tracks_conc = vertcat(Tracks_cell{:}); % all the track information
    num_tracks = length(tracks_conc);
    disp(num2str(num_tracks));
 
    
    On_time_final = (tracks_conc(:,14))*time_int; %time information
    cat_training = vertcat(training_cell{:}); % training information? not too much
    intensities_final =  cat_training(:,6) ;  % Intensity per Track?
    
    %% 
%      filenames_training = uigetfile('*training.mat', 'Pick the training.mat files','Multiselect', 'on');
%      filenames_training = filenames_training';
%      training_cell = cell(num_files, 1);
%  
%      for i = 1:num_files
%          ld=load(filenames_training{i});
%           training_cell{i}=ld.Track_mate_training;
%      end
%     
    

    %% 
%      filenames_class= uigetfile({'*mod_SVM*Totalpred7*.mat';'*mod_lin*.mat';'*mod_SVM_lin*.mat';'*mod_Tree*';'*mod_Bag.mat_3000trees_LeafSz50_Sam1_Preds4_MeanSP*';'*mod_Bag*MAX_STD_3*'}, 'Pick the classification .mat files','Multiselect', 'on');
%      filenames_class = filenames_class';
%      class_cell = cell(num_files, 1);
%      for i = 1:num_files
%          ld=importdata(filenames_class{i});
%          class_cell{i}=ld.Prediction_class;
%      end
%     classification_final = cell2mat(class_cell);
    %psfs_final = cell2mat(tracks_conc(:,4));
    %% 
%     class_isolate = find(classification_final);
    intensities_final_bound = intensities_final;
     tracks_final_bound = tracks_conc;
     On_time_final_bound = On_time_final;
%     disp('classification tracks')
    disp(length(intensities_final_bound))
    



    %% 
    intensities_models_tested = str2num(input_GMM_clustering{1});
    [BestModel_intensities, numComponents_intensities] = GMM_BIC ( intensities_final_bound,intensities_models_tested);


    idx_int = cluster(BestModel_intensities, intensities_final_bound);
    cluster_array_int = zeros(length( intensities_final_bound),numComponents_intensities);
    Int_clust = zeros(length( intensities_final_bound),numComponents_intensities);
    Int_values = cell(numComponents_intensities,1);

    for j = 1:numComponents_intensities
        cluster_array_int(:,j) = (idx_int==j);
        Int_clust(:,j) = cluster_array_int(:,j).* intensities_final_bound;
        Int_values{j} = nonzeros(Int_clust(:,j));
    end

    num_of_bins2 = ceil(sqrt(numel( intensities_final_bound))); 
    bin_width = (max( intensities_final_bound)-min( intensities_final_bound))/num_of_bins2;
    mean_intensities = zeros(numComponents_intensities,1);
    figure,
    for i=1:numComponents_intensities
        histogram(Int_values{i},'BinWidth',bin_width,'Normalization','count') %might want to incorporate bin width instead
        hold on
        mean_intensities(i) = mean(Int_values{i});
    end
    xlabel('Intensity (A.U)')
    ylabel('Counts')
    hold off
    single_intensities_ID = min(mean_intensities);
    if numComponents_intensities > 2
        unique_intensities = unique(mean_intensities);
        single_intensities_ID = unique_intensities(1);
    end

    Int_col = find(mean_intensities == single_intensities_ID);

    Single_molecules = Int_clust(:,Int_col);
    find_single_molecules = find(Single_molecules);
    %Quality_Tracks_seg_bound_single = Quality_Tracks_seg_bound_total(find_single_molecules,:);
    On_time_bound_single = On_time_final_bound (find_single_molecules,:);
    intensities_bound_single = intensities_final_bound (find_single_molecules, :);
    disp(mean(intensities_bound_single))
    disp(std(intensities_bound_single))
    tracks_bound_single = tracks_final_bound(find_single_molecules,:);
    if length (intensities_final_bound) < 100
        %Quality_Tracks_seg_bound_single = Quality_Tracks_seg_bound_total;
        On_time_bound_single = On_time_final_bound;
        intensities_bound_single = intensities_final_bound;
        tracks_bound_single =  tracks_final_bound;
    end

    %save( 'Quality_Tracks_seg_bound_single.mat', 'Quality_Tracks_seg_bound_single')
else 
    filenames_tracks = uigetfile('*TrackMate_tracks_bound_single.mat', 'Pick the segmented tracks .mat files','Multiselect', 'on');
    tracks_load = load(filenames_tracks);
    tracks_bound_single = tracks_load.tracks_bound_single;
    %On_time_bound_single = cell2mat(tracks_bound_single(:,5));
    %intensities_bound_single = cell2mat(tracks_bound_single(:,3));
     filename_On_time_final = uigetfile('*TrackMate_On_time_bound_single.mat', 'Pick On time bound single file');
        On_time_load = load(filename_On_time_final);
         On_time_bound_single = On_time_load.On_time_bound_single;
     filename_intensities_final = uigetfile('*TrackMate_intensities_bound_single.mat', 'Pick intensities bound single file');
         intensities_load = load(filename_intensities_final);
         intensities_bound_single = intensities_load.intensities_bound_single;
     time_input = inputdlg({'Time Interval', 'Truncation Point'}, 'Time Settings', [1 50;1 50], {'1', '3'});
     time_int = str2num(time_input{1});
     truncation_pt = str2num(time_input{2});
end

%% 
figure,
histogram(On_time_bound_single,'BinMethod','sqrt','Normalization','pdf');
input_test = inputdlg('Would you like to test for two exponentials?','Two Exponentials',[1 50],{'N'});
if input_test{1} == 'Y' | input_test{1}== 'y' 
    
        Trackmate_Analysis_Step2 (On_time_bound_single)
    
    
else
    histogram(On_time_bound_single,'BinMethod','sqrt','Normalization','pdf');
    input_outlier = inputdlg('Eliminate Outliers?', 'Outlier Removals', [1 50], {'Y'});
    if input_outlier{1} =='Y' || input_outlier{1}=='y'
    TF = isoutlier (On_time_bound_single, 'quartiles','ThresholdFactor',5.0);

    On_time_bound_single_filtered = On_time_bound_single(TF~=1,1);
    %Quality_Tracks_seg_bound_single_filtered = Quality_Tracks_seg_bound_single(TF~=1,:);
    intensities_bound_single_filtered = intensities_bound_single (TF~=1,1);
    tracks_bound_single_filtered = tracks_bound_single(TF~=1,1);
    [est_filtered, ci_filtered, se_filtered,sample_size] = Fitting_truncExponential (On_time_bound_single_filtered, time_int,truncation_pt);
    trackD=struct();
    trackD.Track_Duration=est_filtered;
    trackD.Confidence_Interval=ci_filtered;
    trackD.Strandard_Error=se_filtered;
    trackD.Sample_size=sample_size;
    save('Track_Durations.mat','trackD');
    %save( 'Quality_Tracks_seg_bound_single_filtered.mat', 'Quality_Tracks_seg_bound_single_filtered')
    input_err = inputdlg({'Do you want to calculate bound time?'}, 'Error Calculator', [1 50], {'Y'});
    if input_err{1} == 'Y' || input_err {1} == 'y'
        input_bleach = inputdlg({'Bleach Time', 'Variation in bound time (decimal)', 'Variation in bleach' },'Errors', [1 50; 1 50;1 50], {'20', '0.5', '0.5'});
        [Tbound_filt, Tbound_ci_filt, Tbound_err_filt] = Bound_time_estimator (On_time_bound_single_filtered, est_filtered, str2num(input_bleach{1}),  str2num(input_bleach{2}),str2num(input_bleach{3}), truncation_pt);
        waitfor(msgbox({num2str(Tbound_filt),strcat(num2str(Tbound_ci_filt(1)), ':', num2str(Tbound_ci_filt(2))), num2str(Tbound_err_filt)}, 'Bound Time'));
        
        input_save_filter = inputdlg('Save Results?', 'Save', [1 50], {'Y'});
    
        if input_save_filter{1} == 'Y' | input_save_filter{1} == 'y'
        %Results = [Tbound_filt, Tbound_ci_filt, Tbound_err_filt];
        
%         fprintf(fid, num2str(Tbound_filt),strcat(num2str(Tbound_ci_filt(1)), ':', num2str(Tbound_ci_filt(2))), num2str(Tbound_err_filt));
%         fclose(fid);
        save_dir_input = inputdlg('Pick a name for the folder','Save Folder', [1 50], {'Analysis Files'});
        mkdir(save_dir_input{1}) 
        save(strcat(save_dir_input{1},'/','Results.mat'),'Results');
        save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_single_filtered.mat'),'On_time_bound_single_filtered')
        save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_single_filtered.mat'),'intensities_bound_single_filtered')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_bound_single_filtered.mat'),'tracks_bound_single_filtered')
        %save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_final.mat'),'On_time_final_bound')
        %save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_final.mat'),'intensities_final_bound')
        save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_single.mat'),'On_time_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_single.mat'),'intensities_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_bound_single.mat'),'tracks_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_TOTAL.mat'),'tracks_conc')
        %save(strcat(save_dir_input{1},'/','PMtracker_PSFS_TOTAL.mat'),'psfs_final')
        end
    else
        input_save_filter = inputdlg('Save Results?', 'Save', [1 50], {'Y'});
    
        if input_save_filter{1} == 'Y' | input_save_filter{1} == 'y'
        save_dir_input = inputdlg('Pick a name for the folder','Save Folder', [1 50], {'Analysis Files'});
        mkdir(save_dir_input{1}) 
        save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_single_filtered.mat'),'On_time_bound_single_filtered')
        save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_single_filtered.mat'),'intensities_bound_single_filtered')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_bound_single_filtered.mat'),'tracks_bound_single_filtered')
        %save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_final.mat'),'On_time_final_bound')
        %save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_final.mat'),'intensities_final_bound')
        save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_single.mat'),'On_time_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_single.mat'),'intensities_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_bound_single.mat'),'tracks_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_TOTAL.mat'),'tracks_conc')
        %save(strcat(save_dir_input{1},'/','PMtracker_PSFS_TOTAL.mat'),'psfs_final')
        end
    end

    
    else
        [est_original, ci_original, se_original] = Fitting_truncExponential (On_time_bound_single,time_int,truncation_pt);
        input_err = inputdlg({'Do you want to calculate bound time?'}, 'Error Calculator', [1 50], {'Y'});
    if input_err{1} == 'Y'| input_err {1} == 'y'
        input_bleach = inputdlg({'Bleach Time', 'Variation in bound time (decimal)', 'Variation in bleach' },'Errors', [1 50; 1 50;1 50], {'20', '0.5', '0.5'});
        [Tbound_original, Tbound_ci_original, Tbound_err_original] = Bound_time_estimator (On_time_bound_single, est_original, str2num(input_bleach{1}),  str2num(input_bleach{2}),str2num(input_bleach{3}), truncation_pt);
        waitfor(msgbox({num2str(Tbound_original),strcat(num2str(Tbound_ci_original(1)), ':', num2str(Tbound_ci_original(2))), num2str(Tbound_err_original)}, 'Bound Time'));
        input_save = inputdlg('Save Results?', 'Save', [1 50], {'Y'});
    
        if input_save{1} == 'Y' | input_save{1} == 'y'
        save_dir_input = inputdlg('Pick a name for the folder','Save Folder', [1 50], {'Analysis Files'});
        mkdir(save_dir_input{1}) 
        %Results = [Tbound_original, {Tbound_ci_original}, Tbound_err_original];
        %save(strcat(save_dir_input{1},'/','Results.mat'),'Results');
        save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_final.mat'),'On_time_final_bound')
        save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_final.mat'),'intensities_final_bound')
        save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_single.mat'),'On_time_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_single.mat'),'intensities_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_bound_single.mat'),'tracks_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_TOTAL.mat'),'tracks_conc')
        %save(strcat(save_dir_input{1},'/','PMtracker_PSFS_TOTAL.mat'),'psfs_final')
        end
    else
        input_save = inputdlg('Save Results?', 'Save', [1 50], {'Y'});
    
        if input_save{1} == 'Y' | input_save{1} == 'y'
        save_dir_input = inputdlg('Pick a name for the folder','Save Folder', [1 50], {'Analysis Files'});
        mkdir(save_dir_input{1}) 
        save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_final.mat'),'On_time_final_bound')
        save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_final.mat'),'intensities_final_bound')
        save(strcat(save_dir_input{1},'/','Trackmate_On_time_bound_single.mat'),'On_time_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_intensities_bound_single.mat'),'intensities_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_bound_single.mat'),'tracks_bound_single')
        save(strcat(save_dir_input{1},'/','Trackmate_tracks_TOTAL.mat'),'tracks_conc')
        %save(strcat(save_dir_input{1},'/','PMtracker_PSFS_TOTAL.mat'),'psfs_final')
        end
    end
    end

end
saveas(gcf,'BoundTime.pdf')


end    