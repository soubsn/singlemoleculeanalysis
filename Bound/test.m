[filename_data_tracks,path] = uigetfile('*data.mat', 'Pick tracks file', 'Multiselect', 'on');
path2=split(path,'/');
path3=path2(1:(end-3),1);
path4=join(path3,'/');
path5=append(path4,'/');
[~,L]=size(filename_data_tracks);
for l=1:L
    tracks_data_fil = importdata(filename_data_tracks{l});
    n=filename_data_tracks{1, l};
    n=strrep(n,'_Trackdata.mat','.tif');
    n=append(path5{1,1},n);
    im1=bfopen(n);
    im2=im1{1, 1};
    num_images_st = length(im2);
    n=strrep(n,'.tif','.mat');
    pix = importdata(n);
    xpix = ceil(pix.BoundingBox(1,1));
    ypix = ceil(pix.BoundingBox(1,2));
    angle = pix.Orientation;
    Tracks = tracks_data_fil.Segmented_Tracks;
    Trainer = tracks_data_fil.Training;
    [num_tracks,~] = size(Trainer);
    Training_classification = [];
    disp(['Number of tracks:', num2str(num_tracks)])
    for i = 1:num_tracks
        track_iter = num2str(i);
        img_stack = [];
        x_coord_num3 = Tracks(i,17);
        y_coord_num3 = Tracks(i,18);
        x_coord_num2 = cosd(angle)*(x_coord_num3-pix.Centroid2(1,1))- sind(angle)*(y_coord_num3-pix.Centroid2(1,2))+pix.Centroid2(1,1);
        x_coord_num = x_coord_num2;
        y_coord_num2 = sind(angle)*(x_coord_num3-pix.Centroid2(1,1))+ cosd(angle)*(y_coord_num3-pix.Centroid2(1,2))+pix.Centroid2(1,2);
        y_coord_num = y_coord_num2;
        x_coord = num2str(x_coord_num);
        y_coord = num2str(y_coord_num);
        rad_img = 5;
        frame_start = num2str(Tracks(i,15) + 1);
        frame_end = num2str(Tracks(i,16) + 1);
        vec_read = [Tracks(i,15) + 1:(Tracks(i,16) + 1) + 1];
        if (Tracks(i,16) + 1)  + 3 > num_images_st
            vec_read = [Tracks(i,15)+1: Tracks(i,16) + 1];
        end
        c=1;
        for k = vec_read(1):vec_read(end)
            img_tmp = imresize(im2{k,1}, 2, 'nearest');
            img_tmp_shp = insertShape(img_tmp,'circle',[x_coord_num y_coord_num rad_img], 'LineWidth', 1,'Color','cyan');
            frmae=string(vec_read(c));
            pos=[1 1];
            img_fr = insertText(img_tmp_shp,pos,frmae,'FontSize',14,'TextColor','white','BoxOpacity',0,'Font','SFCompact');
            img_gray = rgb2gray(img_tmp_shp);
            img_stack(:,:,k - (vec_read(1)-1)) = img_gray;
            c=c+1;
         %img_stack(:,:,k - (vec_read(1)-1)) = imread(strcat(path_img,filename_img), k);
         %img_stack(:,:,k - (vec_read(1)-1)) = mat2gray(img_stack(:,:,k - (vec_read(1)-1)));
         %img_stack(:,:,k - (vec_read(1)-1)) = insertShape(img_stack(:,:,k - (vec_read(1)-1)),'circle',[x_coord_num y_coord_num rad_img]);
        end
        
            %waitfor(user_input)
        
         %img_stack=mat2gray(img_stack);
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
                class_input = 0;
            case 'Bound'
                class_input = 1;
        end
        if isempty(quest_tr) == 1
            disp('Stopped')
            break
        end
        Training_classification(i) = class_input;%str2num(user_input{1});
        close(h1)
    end
        filename_save = strrep(filename_data_tracks{l}, 'data','classification');
    input_save = inputdlg('Save?','Saving Classification',[1 50], {'Y'});
    if input_save{1} == 'Y' || input_save{1} =='y'
        save(filename_save,'Training_classification');
    end
end