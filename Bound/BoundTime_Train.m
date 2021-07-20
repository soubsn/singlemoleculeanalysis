%function tr = BoundTime_Train
    [filename_data_tracks,path] = uigetfile('*data.mat', 'Pick tracks file', 'Multiselect', 'on');
    path2=split(path,'/');
    path3=path2(1:(end-3),1);
    path4=join(path3,'/');
    path5=append(path4,'/');
    fn=split(filename_data_tracks{1,1},'_');
    fn2=fn(1:(end-2),1);
    fn3=join(fn2,'_');
    fn4=append(fn3,'.vsi');
    fn5=append(path5{1,1},fn4{1,1});
    im1=bfopen(fn5);
    im2=im1{1, 1};
    num_images_st = length(im2);
    a= length(filename_data_tracks);
    for b = 1:a
    tracks_data_fil = importdata(filename_data_tracks{b});
    p2=strrep(filename_data_tracks{b},'_Trackdata','');
    p3=append(path5,p2);
    pix = importdata(p3{1,1});
    xpix = ceil(pix.BoundingBox(1,1));
    ypix = ceil(pix.BoundingBox(1,2));
    angle = pix.Orientation;
    Tracks = tracks_data_fil.Segmented_Tracks;
    Trainer = tracks_data_fil.Training;
    [num_tracks,~] = size(Trainer);
    Training_classification = []; %zeros(num_tracks,1);
    [si]=size(imresize(im2{1,1}, 2, 'nearest'));
    img2 =zeros(si);
    for l=1:length(pix.PixelList2)
        x=pix.PixelList2(l,1);
        y=pix.PixelList2(l,2);
        img2(y,x)=1;
    end
    img2 = imrotate(img2,-angle,'bicubic','loose');
    Pix=regionprops(img2,'Centroid');
    
    %% 
    disp(['Number of tracks:', num2str(num_tracks)])
    for i = 1:num_tracks
            track_iter = num2str(i);
            img_stack = [];
            x_coord_num3 = Tracks(i,17);
            y_coord_num3 = Tracks(i,18);
            %x_coord_num2 = cos(angle)*(x_coord_num3-pix.Centroid3(1,1)) - sin(angle)*(y_coord_num3-pix.Centroid3(1,2))+pix.Centroid3(1,2);
            x_coord_num = x_coord_num3 - pix.Centroid3(1,1) + Pix.Centroid(1,1);
            %y_coord_num2 = cos(angle)*(y_coord_num3-pix.Centroid3(1,2)) + sin(angle)*(x_coord_num3-pix.Centroid3(1,1))+pix.Centroid3(1,1); 
            y_coord_num = y_coord_num3 - pix.Centroid3(1,2) + Pix.Centroid(1,2);
        x_coord = num2str(x_coord_num);
        y_coord = num2str(y_coord_num);
        rad_img = 15;
        frame_start = num2str(Tracks(i,15) + 1);
        frame_end = num2str(Tracks(i,16) + 1);
         vec_read = [Tracks(i,15) + 1:(Tracks(i,16) + 1) + 1];
         if (Tracks(i,16) + 1)  + 3 > num_images_st
             vec_read = [Tracks(i,15)+1: Tracks(i,16) + 1];
         end
         c=1;
        for k = vec_read(1):vec_read(end)
            img = imresize(im2{k,1}, 2, 'nearest');
            [si]=size(img);
            mi=min(img,[],'all');
            img_tmp = imrotate(img,-angle,'bicubic','loose');
            img_tmp(img_tmp < mi*1.25) = double(mi*1.25);
            img_tmp_shp = insertShape(uint16(img_tmp),'circle',[x_coord_num y_coord_num rad_img], 'LineWidth', 1,'Color','cyan');
            frmae=string(vec_read(c));
            pos=[1 1];
            img_fr = insertText(img_tmp_shp,pos,frmae,'FontSize',14,'TextColor','white','BoxOpacity',0,'Font','SFCompact');
            img_gray = rgb2gray(img_fr);
            img_stack(:,:,k - (vec_read(1)-1)) = img_gray;
            c=c+1;
        end
         img_stack = uint16(img_stack);
         h1= implay(img_stack,5);

         h1.Visual.setPropertyValue('UseDataRange',true);
         h1.Visual.setPropertyValue('DataRangeMin',min(img_gray,[],'all'));
         h1.Visual.setPropertyValue('DataRangeMax',(max(img_tmp,[],'all')));
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
                class_input = 0;
            case 'Bound'
                class_input = 1;
        end
        if isempty(quest_tr) == 1
            disp('Stopped')
            close(h1)
            break
        end
        Training_classification(i) = class_input;%str2num(user_input{1});
        close(h1)
    end
    %% 

    filename_save = strrep(filename_data_tracks{b}, 'data','classification');
    input_save = inputdlg('Save?','Saving Classification',[1 50], {'Y'});
    if input_save{1} == 'Y' || input_save{1} =='y'
        save(filename_save,'Training_classification');
    end
    end