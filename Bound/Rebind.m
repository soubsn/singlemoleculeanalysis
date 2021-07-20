function [c,d,props] = Rebind
clear; close all
intensities_models_tested = 2;
tap=1;
te=pwd;
te1=split(te,'/');
te2=te1(1:(end-2),1);
te3=join(te2,"/");
  Fileist = dir(fullfile(te3{1,1},'*_CombinedResults.mat'));
    FileList = struct('name', {Fileist(1:end).name});
    FileList= struct2table(FileList);
    FileList=table2array(FileList);
    filenames_spot=natsortfiles(FileList);
    filenames_spot={Fileist.folder}.' + "/" + filenames_spot;
num_files_spot = length(filenames_spot);
pixel3 = inputdlg({'Start Frame', 'Reactivation','Total Frames'},'After how many frames is the reactivation',[1 80; 1 80; 1 80],{'1','100','500'});    
st = str2double(cell2mat(pixel3(1)));
re = str2double(cell2mat(pixel3(2)));
len = str2double(cell2mat(pixel3(3)));
Fileist = dir(fullfile(cd, '**','*_classified.mat'));
    FileList = struct('name', {Fileist(1:end).name});
    FileList= struct2table(FileList);
    FileList=table2array(FileList);
    filenamesa=natsortfiles(FileList);
numbers=zeros(length(filenamesa),1);
File=[];

for ap=1:length(filenamesa)
    file=string(filenamesa(ap,1));
    file=double(strsplit(file,'_'));
    file=file(~isnan(file));
    numbers(ap,1)=file(1,tap);
    File=vertcat(File,file);
    ld=importdata(filenamesa{ap});
    Tracks_cell{ap}=ld.Tracks_pred2(:,1:18);
    training_cell{ap}=ld.TrainingFinal2;
end
tracks_conc = vertcat(Tracks_cell{:});
  On_time_final_bound = tracks_conc;
 cat_training = vertcat(training_cell{:}); % training information? not too much
 intensities_final =  cat_training(:,6) ;
 intensities_final_bound = intensities_final;
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
   figure,
   num_of_bins2 = ceil(sqrt(numel( intensities_final_bound))); 
   bin_width = (max( intensities_final_bound)-min( intensities_final_bound))/num_of_bins2;
   mean_intensities = zeros(numComponents_intensities,1); 
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
    if size(On_time_final_bound,1) == size(find_single_molecules,1)
    On_time_bound_single = On_time_final_bound (find_single_molecules,:);
    intensities_bound_single = intensities_final_bound (find_single_molecules, :);
    for ap=1:length(filenamesa)
    ld=importdata(filenamesa{ap});
    Tracks=ld.Tracks_pred2;
    Tracks(:,19)=0;
    for keg=1:size(Tracks,1)
        t1=Tracks(keg,1:size(On_time_bound_single,2));
        t2=find(ismember(t1(:,18),On_time_bound_single(:,18),'rows'));
        if isempty(t2) == 0
        Tracks(keg,19) = 1;
        end
    end
    ld.Tracks_pred2=Tracks;
    save(filenamesa{ap},'ld')
    end
    else
       for ap=1:length(filenamesa)
            ld=importdata(filenamesa{ap});
            Tracks=ld.Tracks_pred2;
            Tracks(:,19)=1;
            ld.Tracks_pred2=Tracks;
            save(filenamesa{ap},'ld')
       end
    end
numbe=ischange(numbers,'linear');
nu=find(numbe == 1);
nu= vertcat(1, nu);
numb=numbers(nu,1);
if length(numb) ~= num_files_spot
    error('One of the result files has no bound spots')
end
react=(st:re:len);
le=length(react);
reb4 =[];
reb44=[];
rb4=[];
r4=[];
dt=[];
L2=[];
L3=[];
LL2=[];
LL3=[];
for aa=1:num_files_spot
    val=numb(aa);
    res1=find(File(:,tap) == val);
    numbe=ischange(res1,'Linear','MaxNumChanges',2);
    nu=find(numbe == 1);
    if isempty(nu) == 0
        filenames=filenamesa(res1(1:(nu-1)));
        File(res1(1:(nu-1)),:)= 0;
    else
    filenames=filenamesa(res1(1:end));
    File(res1(1:end),:) = 0;
    end
    
    if iscell(filenames) == 0
        num_files = 1;
    else
        num_files = length(filenames);
    end
result=cell(num_files,1);


ma=importdata(filenames_spot{aa});

    for a= 1:num_files
    if iscell(filenames) == 0
        da=importdata(filenames);
        filenames_2= strrep(filenames,'_classified.mat', '.mat');
        ka=te3{1,1}+"/"+filenames_2;
        ba=importdata(ka);
    else
    da=importdata(filenames{a});
    filenames_2= strrep(filenames{a},'_classified.mat', '.mat');
    ka=te3{1,1}+"/"+filenames_2;
    ba=importdata(ka);
    end
    db=da.Tracks_pred2(:,1:19);
    dc=padarray(db,1,0,'post');
    dt=vertcat(dt,dc);
    [d,~]=size(db);
    spo=ma.Values;
    [s,~]=size(spo);
    bad=ba.BoundingBox;
    c=1;
%    if aa == 1
    for b=1:le
        r5=[];
        f1=[];
        one=react(b);
        try two=react(b+1)-1;
        catch me
            two= react(b) + (re-1);
        end
        para=[one two];
        r1{a,1}(b,1)={para};
        for c=1:d
            if db(c,15) >= one && db(c,15)<= two && db(c,16) <= two && db(c,19) == 1
               f1=vertcat(f1,db(c,:)); 
            end
        end
        r1{a,1}(b,2)={f1};
        [r,~]=size(f1);
        r=r-1;
        if r >= 1
            r2 = [f1(:,14) f1(:,15) f1(:,16)];
            [rr,~]=size(r2);
            for rrr =1:rr
                try L1(rrr,:)=r2(rrr+1,2)-r2(rrr,3);
                catch ME
                    continue
                end   
            end
            r3 = [{r} {r2} {L1}];
            L2=vertcat(L2,r2(:,1));
            L3=vertcat(L3,L1);
            r33 = [{r} {r2(:,1)} {L1}];
            r4 =vertcat(r4,r33);
            r5 =vertcat(r5,r3);
            clear r3 r2 r33 L1
        elseif r == 0
            r3=[{0} {[]}];
            r33= [{0} {0} {0}];
            r4 =vertcat(r4,r33);
            r5 =vertcat(r5,r3);
            clear r3 r2 r33 L1
        end   
    end
    r7{a}=r5;
    clear r5
 %   end
    
        for aaa= 1:s
        t1=spo{aaa,6};
            if isequal(t1,bad)
            row=aaa;
                break
            else
                c=c+1;
                if c > s
                    row=0;
                    clear c
                    break
                end
            end
        end
        if row == 0
            reb7{a}=[];
            continue
        end
    location = spo{row,4};
        if location == 0
            reb7{a}=[];
        continue
        end
    [sl,~]=size(location);
    for mn=1:sl
        rb1=[];
    location(mn,1) = round((location(mn,1)) - (ceil(bad(1,1))));
    location(mn,2) = round((location(mn,2)) - (ceil(bad(1,2))));
    subimy =[location(mn,2)-3:location(mn,2)+3];
    subimy2=repmat(subimy,7,1);
    subimy3=reshape(subimy2,1,[]);
    subimy3=transpose(subimy3);
    subimx =[location(mn,1)-3:location(mn,1)+3];
    subimx2=repmat(subimx,1,7);
    subimx2=transpose(subimx2);
    sub=[subimx2,subimy3];
        for b=1:le
        reb5=[];
        fill=[];
        one=react(b);
        try two=react(b+1)-1;
        catch me
            two= react(b) + (re-1);
        end
        para=[one two];
        result{aa,1}{a,1}{mn,1}(b,1)={para};
        k=0;
            for c=1:d
            if db(c,15) >= one && db(c,15)<= two && db(c,16) <= two && db(c,19) == 1
                if ismember(round(db(c,17)),sub(:,1)) && ismember(round(db(c,18)),sub(:,2))
                fill=vertcat(fill,db(c,:));
                end
            else 
                k=k+1;
            end
            end
        result{aa,1}{a,1}{mn,1}(b,2)={fill};
        [reb,~]=size(fill);
        reb=reb-1;
            if reb >= 1
            reb2 = [fill(:,14) fill(:,15) fill(:,16)];
            [rr,~]=size(reb2);
            for rrr =1:rr
                try L1(rrr,:)=reb2(rrr+1,2)-reb2(rrr,3);
                catch ME
                    continue
                end
            end
            reb3 = [{reb} {reb2}];
            reb33 = [{reb} {reb2(:,1)} {L1}];
            LL2=vertcat(LL2,reb2(:,1));
            LL3=vertcat(LL3,L1);
            reb4 =vertcat(reb4,reb3);
            reb44 =vertcat(reb44,reb3);
            rb1=vertcat(rb1,reb3);
            reb5 =vertcat(reb5,reb3);
            clear reb3 reb2 L1 reb33
            elseif reb == 0
            reb3=[{0} {[]}];
            reb4 =vertcat(reb4,reb3);
            rb1=vertcat(rb1,reb3);
            reb5 =vertcat(reb5,reb3);
            clear reb3 reb2 L1 reb33
            end   
        end
        reb6{mn,1}=reb5;
        reb6{mn,2}=bad;
        try rb2=cell2mat(rb1(:,1));
        catch ME
            continue 
        end
        te= any(rb2 > 0);
        if te == 1
            rb4=vertcat(rb4,rb1);
        else
            rb1= rb1(1,:);
            rb4=vertcat(rb4,rb1);
        end
    end
    reb7{a}=reb6;
    clear reb6
    end
    reb8{aa}=reb7;
    clear reb7
end
rb=cell2mat(reb4(:,1));

rb(rb<1)=[];
m=tabulate(cell2mat(reb4(:,1)));
m2=find(m(:,1) ~= 0);
m1=sum(m(m2,3));
txt="Odds of Rebinding Event = " + m1;
figure
histogram(cell2mat(reb4(:,1)),'BinWidth',1,'Normalization','pdf','BinLimits',[0 10])%,'BinLimits',[0 10]
xlabel('Rebinding Events')
ylabel('Average')
title('Rebinding Events Spot Filtered')
a5=get(gca,'Xtick');
A5=a5(1,end-3);
a6=get(gca,'Ytick');
A6=a6(1,end-1);
text(A5,A6,txt)
ylim([0 1])
s=tabulate(cell2mat(reb4(:,1)));
Result=struct();
Result.Timing=reb8;
Result.RebindingEvents=reb4;
Result.Tabulate=s;
file=split(filenames_spot(1),'_');
savenames= file{1,1} + "_rebind.mat";
save(savenames,'Result')
savefig = Fileist(1).folder + "/Rebind_Events_Spot_Filtered.pdf";
saveas(gcf,savefig)
tit='Track Length Spot Filtered';
if isempty(LL2) == 1
    est2 =0;
    ci2= [0,0];
    se2=0;
else
[est2, ci2, se2] = Fitting_Rebounding (LL2, 0.5, 2, tit);
savefig = Fileist(1).folder + "/Track_Length_Spot_Filtered.pdf";
saveas(gcf,savefig)
end
LL4=LL3*0.5;
LL4(LL4<0)=[];
tit= 'Track Interval Length Spot Filtered';
if isempty(LL4) == 1
    est4 =0;
    ci4= [0,0];
    se4=0;
else
[est4, ci4, se4] = Fitting_Rebounding (LL4, 0.5, 0, tit);
savefig = Fileist(1).folder + "/Interval_Length_Spot_Filtered.pdf";
saveas(gcf,savefig)
end
m=tabulate(cell2mat(r4(:,1)));
m2=find(m(:,1) ~= 0);
m1=sum(m(m2,3));
txt="Odds of Rebinding Event = " + m1;
figure
histogram(cell2mat(r4(:,1)),'BinWidth',1,'Normalization','pdf','BinLimits',[0 10])
xlabel('Rebinding Events')
ylabel('Average')
title('Rebinding Events')
a5=get(gca,'Xtick');
A5=a5(1,end-3);
a6=get(gca,'Ytick');
A6=a6(1,end-1);
text(A5,A6,txt)
ylim([0 1])
savefig = Fileist(1).folder + "/Rebind_Events.pdf";
saveas(gcf,savefig)
tit='Track Length';
[est, ci, se] = Fitting_Rebounding (L2, 0.5, 2, tit);
savefig = Fileist(1).folder + "/Track_Length.pdf";
saveas(gcf,savefig)
L4=L3*0.5;
L4(L4 <0)=0;
tit= 'Track Interval Length';
[est3, ci3, se3] = Fitting_Rebounding (L4, 0.5, 0, tit);
savefig = Fileist(1).folder + "/Interval_Length.pdf";
saveas(gcf,savefig)
% figure
% m=tabulate(cell2mat(rb4(:,1)));
% m2=find(m(:,1) ~= 0);
% m1=sum(m(m2,3));
% txt="Odds of Rebinding Event = " + m1;
% histogram(cell2mat(rb4(:,1)),'BinWidth',1,'Normalization','pdf','BinLimits',[0 10])%,'BinLimits',[0 10]
% xlabel('Rebinding Events')
% ylabel('Average')
% title('Rebinding Events Spot Filtered')
% a5=get(gca,'Xtick');
% A5=a5(1,end-3);
% a6=get(gca,'Ytick');
% A6=a6(1,end-1);
% text(A5,A6,txt)
% ylim([0 1])
% file=split(filenames_spot(1),'_');
% savenames= file{1,1} + "_rebind.mat";
% save(savenames,'Result')
% savefig = Fileist(1).folder + "/Rebind_Events_Spot_Filtered.pdf";
% saveas(gcf,savefig)

disp(['Track Length Filtered:',num2str(est2)])
disp(['Track Length Filtered SE:',num2str(se2)])
disp(['Track Interval Filtered:',num2str(est4)])
disp(['Track Interval Filtered SE:',num2str(se4)])
disp(['Track Interval Filtered CI LOW:', num2str(ci4(1))])
disp(['Track Interval Filtered CI HIGH:', num2str(ci4(2))])
disp(['Track Length :',num2str(est)])
disp(['Track Length SE:',num2str(se)])
disp(['Track Interval :',num2str(est3)])
disp(['Track Interval SE:', num2str(se3)])
disp(['Track Interval CI LOW:', num2str(ci3(1))])
disp(['Track Interval CI HIGH:', num2str(ci3(2))])
[t,tt]=ecdf(LL4,'function','survivor');
[c,d,props] = bestexpfit(tt,t);
disp(props)
 end



