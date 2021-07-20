function tr = BoundTime_TestClassifiedTracks
    filename_data_tracks = uigetfile('*classified.mat', 'Pick tracks file', 'Multiselect', 'on');
    disp (filename_data_tracks)
    %[filename_data_info,p1] = uigetfile('*.mat', 'Pick Image info file', 'Multiselect', 'on');
    [filename_img,  path_img] = uigetfile('*.vsi*','Pick Image');
    im1=bfopen(strcat(path_img,filename_img));
    im2=im1{1, 1};
    num_images_st = length(im2);
    a= length(filename_data_tracks);
    quest_re = MFquestdlg ( [ 0.6 , 0.1 ] , 'Include spots?', 'Include spots?','Testing', 'For Rebind','For Rebind' );
        switch quest_re
            case 'Testing'
                class_input = 0;
            case 'For Rebind'
                class_input = 1;
                filenames_spot = uigetfile('*_Results.mat', 'Pick the segmented tracks .mat files','Multiselect', 'off');
                ma=importdata(filenames_spot);
        end
    dt=[];
    for b = 1:a
    tracks_data_fil = importdata(filename_data_tracks{b});
    filenames_2= strrep(filename_data_tracks{b},'_classified.mat', '.mat');
    ba=importdata(filenames_2);
    pix = importdata(filenames_2);
    xpix = ceil(pix.BoundingBox(1,1));
    ypix = ceil(pix.BoundingBox(1,2));
    Tracks = tracks_data_fil.Tracks_pred2;
    Trainer = tracks_data_fil.TrainingFinal2;
    [num_tracks,~] = size(Trainer);
    dc=padarray(Tracks,1,0,'post');
    dt=vertcat(dt,dc);
    if class_input == 1
    spo=ma.Values;
    [s,~]=size(spo);
    bad=ba.BoundingBox;
    c=1;
        for aaa= 1:s
        t1=spo{aaa,11};
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
            location= [0 0];
        end
    location = spo{row,4};
        if location == 0
            location= [0 0];
        end
    end
    %% 
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
        rad_img = 5;
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
            if class_input == 1
                img_tmp_shp = insertText(img_tmp_shp,[round(location(:,1)),round(location(:,2))],'*','FontSize',6,'TextColor','yellow','BoxOpacity',0,'Font','SFCompactDisplay','AnchorPoint','Center');
            end
            img_fr = insertText(img_tmp_shp,pos,frmae,'FontSize',14,'TextColor','white','BoxOpacity',0,'Font','SFCompactDisplay');
            img_8=uint8(img_fr);
            img_gray = rgb2gray(img_fr);
            img_stack(:,:,k - (vec_read(1)-1)) = img_gray;
            img_st(k - (vec_read(1)-1))=im2frame(img_8);
            c=c+1;
         %img_stack(:,:,k - (vec_read(1)-1)) = imread(strcat(path_img,filename_img), k);
         %img_stack(:,:,k - (vec_read(1)-1)) = mat2gray(img_stack(:,:,k - (vec_read(1)-1)));
         %img_stack(:,:,k - (vec_read(1)-1)) = insertShape(img_stack(:,:,k - (vec_read(1)-1)),'circle',[x_coord_num y_coord_num rad_img]);
        end
        
            %waitfor(user_input)
        
         %img_stack=mat2gray(img_stack);
         img_stack = uint16(img_stack);
         h1= implay(img_st,5);

         h1.Visual.setPropertyValue('UseDataRange',true);
         h1.Visual.setPropertyValue('DataRangeMin',100);
         h1.Visual.setPropertyValue('DataRangeMax',250);
         h1.Visual.ColorMap.MapExpression = 'gray';
         %h1.Parent.Position = [300 100 700 700];
         set(0,'showHiddenHandles','on');
         fig_handle = gcf ;  
         fig_handle.findobj ;% to view all the linked objects with the vision.VideoPlayer
         ftw = fig_handle.findobj ('TooltipString', 'Maintain fit to window');   % this will search the object in the figure which has the respective 'TooltipString' parameter.
         ftw.ClickedCallback(); 
        quest_tr = MFquestdlg ( [ 0.6 , 0.1 ] , 'How does it look?', num2str(i),'Done?', 'Done?');
%         switch quest_tr
%             case 'Noise'
%                 class_input = 0;
%             case 'Bound'
%                 class_input = 1;
%         end
%         if isempty(quest_tr) == 1
%             disp('Stopped')
%             break
%         end
%         
%         %          opts.WindowStyle = 'Normal';
% %          user_input = inputdlg('Noise/Bound?', strcat(track_iter,',', x_coord,',', y_coord,',',frame_start,',',frame_end), [1 100], {'0'},opts);
% %          if user_input{1} == 'Stop' | user_input{1} == 'STOP'
% %             break
% %          end
%           
%         
%         Training_classification(i) = class_input;%str2num(user_input{1});
        close(h1)
        clear img_st
    end
    end
 end