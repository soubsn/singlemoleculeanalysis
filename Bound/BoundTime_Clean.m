function con = BoundTime_Clean
[filename_classifier,  path_classifier] = uigetfile('*mod*.mat','Pick Classifier file');
    pred_used_class = inputdlg({'Mean Speed', 'Max Speed', 'Min Speed','Median Speed','Max Quality',}, 'Predictors', ...
        [1 100; 1 100; 1 100; 1 100; 1 100], {'1','1','1','1','1'});
    pred_used_2_class = str2num(cell2mat(pred_used_class));
    pred_var_class = find(pred_used_2_class);
    
    classifier = importdata(strcat(path_classifier,filename_classifier));
    filename_new_data = uigetfile('*predictions.mat','Pick new data files', 'Multiselect', 'on');
    filename_new_data = filename_new_data';

    filename_tracks_combined = uigetfile('*tracks_training_combined_2.mat', 'Pick tracks combined file');
    Fraction_factors = inputdlg('Quality Factor', 'Fraction Factors', [1 100],{'2700'});
    tracks_combined = importdata(filename_tracks_combined);
    max_quality_values = (tracks_combined (:, 5));
      [Best_q, ~] = GMM_BIC_ML_log(max_quality_values,2, true);
      mu_q = Best_q.mu;
     if length (mu_q) > 1
      mu_q = unique(mu_q);
      mean_q = mu_q(2);
     else 
         mean_q = mu_q;
     end
      disp(mean_q);
      mean_q = exp(mean_q);
      
    for i = 1:length(filename_new_data)

        new_data = importdata(filename_new_data{i});
        new_data_2 = new_data.TrainingQ;
        
        
         frac_quality = str2num(Fraction_factors{1})/mean_q;
         
         new_data_2(:,5) = new_data_2(:,5)*frac_quality;
         new_data_3 = new_data_2;
        new_data_2 = new_data_2(:,pred_var_class);
        if isempty(new_data_2) == 1
            continue
        end
        tracks = importdata(filename_new_data{i});
        tracks_2 = tracks.Tracks_pred;
        new_data_var = new_data_2;%(:,1:5);
    %new_data_var(:,5) = new_data(:, 7);
        prediction_class = predict(classifier, new_data_3);
        if iscell(prediction_class) == 1
            prediction_class = cell2mat(prediction_class);
            prediction_class = str2num(prediction_class);
        end
        pred_isolate  = find(prediction_class (:,1) == 1);
        tracks_prediction = tracks_2(pred_isolate, :);
        new_data_4 = new_data_3(pred_isolate,:);
         filename_tracks_save = strrep(filename_new_data{i},'predictions', 'predictions_clean');
        data_tracks_pred = struct('Tracks_pred',tracks_prediction, 'Prediction_class', prediction_class,'Training_Scaled',new_data_2,'TrainingFinal',new_data_4);
        save (filename_tracks_save, 'data_tracks_pred');
    end
end