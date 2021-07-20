function tr = BoundTime_Learn
    %learn_input = inputdlg({'Use Combined training data set?'}, 'Training',[1 100], {'Combined'}); 
     learn_input{1} = 'Combined'  ; 
    
    
    pred_used = inputdlg({'Spot Width','Mean Speed', 'Max Speed', 'Min Speed', 'Median Speed','Sigma Speed','Mean Quality', 'Max Quality', 'Min Quality', 'Median Quality', 'Sigma Quality','Mean Total Intensity', 'Max Intensity'}, 'Predictors', ...
        [1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100], {'0','1','1','1','1','0','0','1','0','0','0','0','0'});
    pred_used_2 = str2num(cell2mat(pred_used));
    pred_var = find(pred_used_2);
    
    if learn_input{1} == 'Combined'
        filename_trainer = uigetfile('*trained_combined.mat','Pick training file');
        Trainer = importdata(filename_trainer);
        Trainer_variables = Trainer;
        Trainer_variables = Trainer_variables(:,pred_var); %(:,1:6);%(:,1:5);
    %Trainer_variables(:,5) = Trainer(:,7);
        filename_classification = uigetfile('*classification_combined.mat','Pick Classification file');
        Classification = importdata(filename_classification);
    else
        pred_used = inputdlg({'Spot Width','Mean Speed', 'Max Speed', 'Min Speed', 'Median Speed','Sigma Speed','Mean Quality', 'Max Quality', 'Min Quality', 'Median Quality', 'Sigma Quality','Mean Total Intensity', 'Max Intensity'}, 'Predictors', ...
        [1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100; 1 100], {'0','1','1','1','1','0','0','1','0','0','0','0','0'});
        pred_used_2 = str2num(cell2mat(pred_used));
        pred_var = find(pred_used_2);
    
    %Classification = Classifica  tion'; 
    
        filename_trainer = uigetfile('*data.mat','Pick training file');
        Trainer = importdata(filename_trainer);
        Trainer_variables = Trainer.Training; %(:,1:6);%(:,1:5);
        Trainer_variables = Trainer_variables(:,pred_var);
        filename_classification = uigetfile('*Trackmate classification*.mat','Pick Classification file');
        Classification = importdata(filename_classification);
        Classification = Classification';
    end
    %tree = fitctree (Trainer_variables, Classification,'OptimizeHyperparameters','auto');
    %% 
    %learn_classifier = inputdlg({'Algorithm?'}, 'Learner', [1 100], {'Linear, SVM, Tree, Bag'});
    learn_classifier{1} ='Bag'; 
    pred_used_len = length(pred_var);
    if strcmpi('Linear',learn_classifier{1})  
        
        Mdl =fitcdiscr(Trainer_variables, Classification,'DiscrimType','linear', 'OptimizeHyperparameters','auto', 'HyperparameterOptimizationOptions',...
              struct('MaxObjectiveEvaluations',100, 'Repartition', 1));
        filename_learned_model = strrep(filename_classification, 'classification_combined','mod_lin');
        filename_learned_model = strcat(filename_learned_model,'Totalpred',num2str(pred_used_len),'.mat');
        save(filename_learned_model, 'Mdl')
    elseif strcmpi('SVM',learn_classifier{1})
    
        Mdl = fitcsvm(Trainer_variables,Classification,'OptimizeHyperparameters','auto','Standardize',true,...
         'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
          'expected-improvement-plus','MaxObjectiveEvaluations',100));
        filename_learned_model = strrep(filename_classification, 'classification_combined','mod_SVM');
        filename_learned_model = strcat(filename_learned_model,'Totalpred',num2str(pred_used_len),'.mat');
        save(filename_learned_model, 'Mdl')
    
    elseif strcmpi('Tree',learn_classifier{1})
         Mdl = fitcensemble(Trainer_variables,Classification,'OptimizeHyperparameters','auto',...
        'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
        'expected-improvement-plus','MaxObjectiveEvaluations',100));
        filename_learned_model = strrep(filename_classification, 'classification_combined','mod_Tree');
        filename_learned_model = strcat(filename_learned_model,'Totalpred',num2str(pred_used_len),'.mat');
         save(filename_learned_model, 'Mdl')   
    
    elseif strcmpi('Bag',learn_classifier{1})
        bag_input = inputdlg({'Trees?','Leaf Size', 'Predictor Samples','InFraction'}, 'Number of Trees', [1 100; 1 100; 1 100; 1 100], {'600', '15', '2', '0.75'});
        Mdl = TreeBagger(str2num(bag_input{1}),Trainer_variables,Classification,'InBagFraction',str2num(bag_input{4}),'MinLeafSize',str2num(bag_input{2}),'NumPredictorsToSample',str2num(bag_input{3}), 'OOBPred','on','OOBPredictorImportance','on');
        filename_learned_model = strrep(filename_classification, 'classification_combined','mod_Bag');
        filename_learned_model = strcat(filename_learned_model,'_',bag_input{1},'trees','_','LeafSz',bag_input{2},'_','Sam',bag_input{3},'_','BagFr',bag_input{4},'_','Preds',num2str(pred_used_len),'.mat');
        figure, 
        plot(oobError(Mdl)) 
        
        save(filename_learned_model, 'Mdl') 
    end
end