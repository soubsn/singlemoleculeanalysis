
function train = BoundTime
list1= {'Dwell Time','Rebinding','Photobleaching Control'};
ML_input=listdlg('Name','Trackmate Machine Learning','PromptString','What do you want to do?','ListString',list1,'SelectionMode','single','ListSize',[250,60]);
if ML_input == 3
    list2= {'Organize','Train','Combine','Learn','Classify','Analyse'};
    tr_input=listdlg('Name','Trackmate Machine Learning','PromptString','What now?','ListString',list2,'SelectionMode','single','ListSize',[250,113]);
    if tr_input == 1
        Trackmate_outputter_SuperSegger_ss
    end
    if tr_input == 2
        BoundTime_Train
    end
    if tr_input == 3
        BoundTime_Combine
    end
    if tr_input == 4
        BoundTime_Learn
    end
    if tr_input == 5 
        BoundTime_Classify
    end
    if tr_input == 6 
        BoundTime_Analysis_ML
    end
end
if ML_input == 1
    list3= {'Organize','Classify','Analyse','Test'};
    da_input=listdlg('Name','Trackmate Machine Learning','PromptString','What now?','ListString',list3,'SelectionMode','single','ListSize',[250,76]);  
    if da_input == 1
        Trackmate_outputter_SuperSegger_ss
    end
    if da_input == 2 
        BoundTime_Classify
    end
    if da_input == 3 
        BoundTime_Analysis_ML
    end
    if da_input == 4 
        Rebind
    end
    if da_input == 5 
        BoundTime_Test
    end
end
if ML_input == 2
    list3= {'Organize','Classify','Spot Count','STD Spot Count','Combine Spot Counts','Rebind','Test'};
    da_input=listdlg('Name','Trackmate Machine Learning','PromptString','What now?','ListString',list3,'SelectionMode','single','ListSize',[250,90]);  
    if da_input == 1
        Trackmate_outputter_SuperSegger_ss
    end
    if da_input == 2 
        BoundTime_Classify
    end
    if da_input == 3 
        spotcount_batch2_UsingCreateSSMasks
    end
    if da_input == 4 
        spotcount_batch2_STD_UsingCreateSSMasks
    end
    if da_input == 5 
        CombineResults
    end
    if da_input == 6 
        Rebind
    end
    if da_input == 7 
        BoundTime_Test
    end
    
end
end