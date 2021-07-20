function tr = BoundTime_Test
    FileList = dir(fullfile(cd,'*_classified.mat'));
    t1=FileList(1).folder;
    t2=split(t1,'/');
    t3=t2(1:(end-2),1);
    t4=join(t3,"/");
    t5= {FileList.name}.';
    t6=split(t5,'_');
    for s=1:size(t6,2)
        s2=str2num(t6{1,s});
        if isempty(s2) == 1
            ss1{s}=t6{1,s};
            continue
        elseif isempty(s2) == 0
            s3=t6(:,s);
            s4=unique(s3);
            ss2=join(ss1,'_');
            ss2=ss2 +"_";
            s5=ss2+s4+".vsi";
            break
        end
    end
    kk1=t6(:,s);
    for sp1= 1:size(s4,1)
        k1=s4{sp1,1};
        kk2=cellfun(@(x) str2double(x)==str2double(k1),kk1,'UniformOutput',1);
        k2=find(kk2 == 1);
        ri{sp1}=k2;
    end
    f1= t4{1,1} + "/" + s5;
    kk2={FileList.folder}.' + "/" + {FileList.name}.';
    quest_tr = MFquestdlg ( [ 0.6 , 0.1 ] , 'Start from the Beginning?', 'Are you ready?','Yes', 'No', 'Yes');
    if length(quest_tr) == 3
        b4=1;
    else
       b2 = inputdlg({'Image','Cell'}, 'Where were you?', [1 50],{'2','1'});
       b3=cellfun(@(x) str2double(x)==str2double(b2{1,1}),s4,'UniformOutput',1);
       b4=find(b3==1);
%        b5=cellfun(@(x) str2double(x)==str2double(b2{2,1}),t6(:,4),'UniformOutput',1);
%        b6=find(b5==1);
%        b7=intersect(b4,b6);
    end
    kp=1;
    for b1=b4:length(f1)
    im=f1(b1,1);
    im1=bfopen(char(im));
    im2=im1{1, 1};
    num_images_st = length(im2);
    a= length(ri{b1});
    if length(quest_tr) == 3 || kp > 1
        b7=1;
        kp=kp+1;
    else
    b5=cellfun(@(x) str2double(x)==str2double(b2{2,1}),t6(:,4),'UniformOutput',1);
    b6=find(b5==1);
    [~,b7,~]=intersect(ri{b1},b6);
    kp=kp+1;
    end
    for b = b7:a
    ti=ri{b1}(b,1);
    ld = importdata(kk2(ti));
    ti2=FileList(ti).name;
    ti3=strrep(ti2,'_classified.mat','.mat');
    ti4=t4{1,1} + "/" + ti3;
    pix = importdata(ti4);
    xpix = ceil(pix.BoundingBox(1,1));
    ypix = ceil(pix.BoundingBox(1,2));
    Tracks = ld.Tracks_pred2  ;
    [num_tracks,~] = size(Tracks);
    Training_classification = []; %zeros(num_tracks,1);
    %% 
    disp(['cell:',ti2])
    disp(['Number of tracks:', num2str(num_tracks)])
    
    for i = 1:num_tracks
            track_iter = num2str(i);
            img_stack = [];
            x_coord_num = Tracks(i,17);
            x_coord_num = x_coord_num + xpix;
            y_coord_num = Tracks(i,18);
            y_coord_num = y_coord_num + ypix;
        x_coord = num2str(x_coord_num);
        y_coord = num2str(y_coord_num);
        rad_img = 10;
        frame_start = num2str(Tracks(i,15) + 1);
        frame_end = num2str(Tracks(i,16) + 1);
         vec_read = [Tracks(i,15) + 1:(Tracks(i,16) + 1) + 1];
         if (Tracks(i,16) + 1)  + 3 > num_images_st
             vec_read = [Tracks(i,15)+1: Tracks(i,16) + 1];
         end
         c=1;
        for k = vec_read(1):vec_read(end)
            img_tmp = im2{k,1};
            img_tmp_shp = insertShape(img_tmp,'circle',[x_coord_num y_coord_num rad_img], 'LineWidth', 1,'Color','cyan');
            frmae=string(vec_read(c));
            pos=[1 1];
            img_fr = insertText(img_tmp_shp,pos,frmae,'FontSize',14,'TextColor','white','BoxOpacity',0,'Font','SFCompactDisplay');
            img_gray = rgb2gray(img_fr);
            img_stack(:,:,k - (vec_read(1)-1)) = img_gray;
            c=c+1;
        end

         img_stack = uint16(img_stack);
         h1= implay(img_stack,5);

         h1.Visual.setPropertyValue('UseDataRange',true);
         h1.Visual.setPropertyValue('DataRangeMin',min(img_gray,[],'all'));
         h1.Visual.setPropertyValue('DataRangeMax',(max(img_tmp,[],'all')+100));
         h1.Visual.ColorMap.MapExpression = 'gray';
         h1.Parent.Position = [100 100 1000 1000];
         set(0,'showHiddenHandles','on');
         fig_handle = gcf ;  
         fig_handle.findobj ;% to view all the linked objects with the vision.VideoPlayer
         ftw = fig_handle.findobj ('TooltipString', 'Maintain fit to window');   % this will search the object in the figure which has the respective 'TooltipString' parameter.
         ftw.ClickedCallback(); 
        quest_tr = MFquestdlg ( [ 0.6 , 0.1 ] , 'Classification of Molecule', num2str(i),'Noise', 'Bound', 'Noise');
        switch quest_tr
            case 'Noise'
                
                Tracks(i,1:size(Tracks,2))=0;
            case 'Bound'
                
        end
        if isempty(quest_tr) == 1
            disp('Stopped')
            break
        end

        close(h1)
    end
    %% 
    ld.Tracks_pred2 = Tracks;
    input_save = inputdlg('Save?','Saving Classification',[1 50], {'Y'});
    if input_save{1} == 'Y' || input_save{1} =='y'
        save(kk2(ti),'ld');
    end
    end
    end
