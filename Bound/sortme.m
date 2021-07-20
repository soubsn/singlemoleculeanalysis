function []= sortme
 filenames = uigetfile('*_classified.mat', 'Pick the segmented tracks .mat files','Multiselect', 'on');  
 filenames = filenames';
 num_files = length(filenames);
 tot=[];
 r=zeros(num_files,1);
 for a= 1:num_files
    if iscell(filenames) == 0
        
        filenames_2= strrep(filenames,'_classified.mat', '.mat');
        ba=importdata(filenames_2);
    else
    filenames_2= strrep(filenames{a},'_classified.mat', '.mat');
        ba=importdata(filenames_2);
    end
    r(a,1)=ba.MajorAxisLength;
    r(a,2)=a;
   tot=vertcat(tot,ba.MajorAxisLength);
 end
 k=sort(tot);
 s=ceil(0.1*length(k));
 small=(k(s,1));
 large=(k(end-s,1));
 for a= 1:num_files
     if r(a,1) <= small
         saves = strrep(filenames{a},'classified.mat', 'classified_small.mat');
         da=importdata(filenames{a});
         save (saves, 'da');
     elseif r(a,1) >= small && r(a,1) <= large
         saves = strrep(filenames{a},'classified.mat', 'classified_medium.mat');
         da=importdata(filenames{a});
         save (saves, 'da');
     elseif r(a,1) >= large
         saves = strrep(filenames{a},'classified.mat', 'classified_large.mat');
         da=importdata(filenames{a});
         save (saves, 'da');
     end
 end
     
end