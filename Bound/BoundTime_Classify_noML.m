function tr = BoundTime_Classify
close all
% pred_var_class = [2;3;4;5;8];
%quest_tr = MFquestdlg ( [ 0.6 , 0.1 ] , 'New Classifying Document?', 'New','Yes', 'No', 'Yes');
% if length(quest_tr) == 3
%     folder='/Users/nicolassoubry/Analysis/Matlab';
%     te = dir(fullfile(folder, '**', '*mod*.mat'));
%     te2=struct2table(te);
%     te2.bytes=[];
%     te2.isdir=[];
%     te2.datenum=[];
%     te2 = movevars(te2, 'date', 'Before', 'folder');
%     [bi,~]=size(te);
%     list=string([1:bi]);
%     te2.N=[1:bi].';
%     te2 = movevars(te2, 'N', 'Before', 'name');
%     fig=uifigure;
%     ui=uitable(fig,'Data',te2);
%     pause(7)
%     res=listdlg('ListString',list,'SelectionMode','single');
%     close all
%     namer=te(res).folder + "/" + te(res).name;
% else
%     namer='/Users/nicolassoubry/Analysis/Matlab/mod_Bag.mat_1000trees_LeafSz50_Sam2_BagFr0.703_Preds5.mat'; %change this
% end
%classifier = importdata(namer);
Fileist = dir(fullfile(cd, '**', '*Trackdata.mat'));
FileList = struct('name', {Fileist(1:end).name});
FileList= struct2table(FileList);
FileList=table2array(FileList);
filename_new_data =natsortfiles(FileList);
% filename_tracks_combined = dir(fullfile(cd, '**', '*tracks_training_combined.mat'));
% tracks_combined = importdata(filename_tracks_combined.name  );
% mean_speed_values = tracks_combined(:, 2);
% try 
% [Best_sp, ~] = GMM_BIC_ML_log(mean_speed_values,2, false);
% mu_sp = Best_sp.mu;
% mu_sp = unique(mu_sp);
% mean_speed = min(mu_sp);
% catch me
%     try
%     [Best_sp, ~] = GMM_BIC_ML_log2(mean_speed_values,2, false);
%     mu_sp = Best_sp.mu;
%     mu_sp = unique(mu_sp);
%     mean_speed = min(mu_sp);
%     catch me
%     end
% mean_speed =mean(mean_speed_values);
% end
% disp(mean_speed);
% if length(quest_tr) == 3
% Fraction_factorsS = inputdlg('Speed Factor', 'Fraction Factors', [1 100],{'0.2492'});
% else
% Fraction_factorsS{1, 1} = '0.2492';
% end
% mean_speed = exp(mean_speed);
% Tracks_cell_TR = cell(length(filename_new_data),1);
% Tracks_cell_seg = cell(length(filename_new_data),1);
% spotted = cell(length(filename_new_data),1);
for i = 1:length(filename_new_data)
    spots=[];
    new_data = importdata(filename_new_data{i});
    new_data_2 = new_data.Training;
    spot = new_data.Segmented_Spots;
%     frac_speed = str2num(Fraction_factorsS{1})/mean_speed;
% 
%     new_data_2(:,2:6) = new_data_2(:,2:6)*frac_speed;
%     new_data_2 = new_data_2(:,pred_var_class);
    new_data_3 = new_data_2;
    new_data_3(:,6:7) = new_data.Training(:, [12,13]);
%     if isempty(new_data) == 1
%         continue
%     end
    tracks = importdata(filename_new_data{i});
    tracks_2 = tracks.Segmented_Tracks;
%     new_data_var = new_data_2;%(:,1:5);
%     prediction_class1 = predict(classifier, new_data_var);
%     if iscell(prediction_class1) == 1
%         prediction_class1 = cell2mat(prediction_class1);
%         prediction_class1 = str2num(prediction_class1);
%     end
%     pred_isolate  = find(prediction_class1 (:,1) == 1);
    tracks_prediction1 = tracks_2;
    new_data_4 = new_data_3;
    for s=1:length(tracks_prediction1(:,1))
    spot_find = find (spot(:,1)==tracks_prediction1(s,1));
    sp1 = spot(spot_find,:);
    spots = vertcat(spots,sp1);
    clear sp1
    end
    Tracks_cell_TR{i} = new_data_4 ;
    Tracks_cell_seg{i} = tracks_prediction1;
    spotted{i}=spots;
    data_tracks_pred1{i} = [{tracks_prediction1}, {new_data_2},{new_data_4},{spots}];
end 

% tracks_training_final = vertcat(Tracks_cell_TR{:});
% tracks_seg_final = vertcat(Tracks_cell_seg{:});
% if length(quest_tr) == 3
% pred_used_class = inputdlg({'Mean Speed', 'Max Speed', 'Min Speed','Median Speed','Max Quality',}, 'Predictors', ...
% [1 100; 1 100; 1 100; 1 100; 1 100], {'1','1','1','1','1'});
% Fraction_factorsQ = inputdlg('Quality Factor', 'Fraction Factors', [1 100],{'3.0102'});
% pred_used_2_class = str2num(cell2mat(pred_used_class));
% else
% Fraction_factorsQ{1, 1} = '3.0102';
% pred_used_2_class = [1;1;1;1;1];
% end
% pred_var_class = find(pred_used_2_class);
% max_quality_values = (tracks_training_final(:, 5));
% try
% [Best_q, ~] = GMM_BIC_ML_log(max_quality_values,2, true);
% mu_q = Best_q.mu;
% mean_q = max(mu_q);
% catch me
% mu_q = mean(log(max_quality_values));
% mean_q = mu_q;
% end
% disp(mean_q);
% frac_quality = str2num(Fraction_factorsQ{1})/mean_q;
for i = 1:length(Tracks_cell_TR)
    spots=[];
    mew_Data_2 = Tracks_cell_TR{i};
    spot = spotted{i};
%     mew_Data_2(:,5) = mew_Data_2(:,5)*frac_quality;
    mew_Data_3 = mew_Data_2;
%     mew_Data_2 = mew_Data_2(:,pred_var_class);
%     if isempty(mew_Data_2) == 1
%         continue
%     end
    Tracks_2 = Tracks_cell_seg{i};  
%     prediction_class2 = predict(classifier, mew_Data_2);
%     if iscell(prediction_class2) == 1
%         prediction_class2 = cell2mat(prediction_class2);
%         prediction_class2 = str2num(prediction_class2);
%     end
%     pred_isolate  = find(prediction_class2 (:,1) == 1);
    tracks_prediction2 = Tracks_2;
    mew_Data_4 = mew_Data_3;
    for s=1:length(tracks_prediction2(:,1))
    spot_find = find (spot(:,1)==tracks_prediction2(s,1));
    sp1 = spot(spot_find,:);
    spots = vertcat(spots,sp1);
    clear sp1
    end
    tracks_prediction1 = data_tracks_pred1{1, i}{1, 1};
    %prediction_class1 = data_tracks_pred1{1, i}{1, 2};
    new_data_2= data_tracks_pred1{1, i}{1, 3};
    new_data_4= data_tracks_pred1{1, i}{1, 4};
    %spots=data_tracks_pred1{1, i}{1, 5};
    filename_tracks_save = strrep(filename_new_data{i},'Trackdata', 'classified');
    data_tracks_pred2 = struct('Tracks_pred1',tracks_prediction1,'Tracks_pred2',tracks_prediction2,'Training_Scaled1',new_data_2,'Training_Scaled2',mew_Data_2,'TrainingFinal1',new_data_4,'TrainingFinal2',mew_Data_4,'Filtered_Spots',spots);
    save (filename_tracks_save, 'data_tracks_pred2');
end
quest_tr = MFquestdlg ( [ 0.6 , 0.1 ] , 'Do you want do continue analysis?', 'Continue?','Yes, Analyse','Yes, Rebind', 'No', 'Yes, Classify');
if length(quest_tr) == 12
    BoundTime_Analysis_ML
elseif length(quest_tr) == 11
    Rebind
end
end