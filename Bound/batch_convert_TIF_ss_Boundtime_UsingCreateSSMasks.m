clear
fileNames = uigetfile('*.vsi','Multiselect','on','Pick Image Files');
 FileList = dir(fullfile(cd, '**','*fixedseg.mat'));
 if isempty(FileList) == 1
     FileList = dir(fullfile(cd, '**','*_seg.mat'));
 end
    FileList2 = struct('folder', {FileList(1:end).folder});
    FileList2= struct2table(FileList2);
    FileList2=table2array(FileList2);
    BF_file2=natsortfiles(FileList2);
    FileList = struct('name', {FileList(1:end).name});
    FileList= struct2table(FileList);
    FileList=table2array(FileList);
    BF_file=natsortfiles(FileList);
    BF_File=BF_file2 + "/" + BF_file;
number_of_files=length(fileNames); % pick the number of files to convert
%parpool
for k=1:number_of_files
    tic
    rd=bfopen(fileNames{1,k});
    rd2=rd{1,1};
    LOW=zeros(length(rd2(:,1)),1);
    MED=zeros(length(rd2(:,1)),1);
    for i=1:length(rd2(:,1))
        LOW(i)=min(rd2{i,1},[],'all');
        MED(i)=median(rd2{i,1},'all');
    end
    low=median(LOW);
    med=median(MED);
    imageread=importdata(BF_File{k,1});
    imageread=imageread.mask_cell;
    imageread=bwareaopen(imageread,20);
    imageread(1,:) = 1;
    imageread(end,:) = 1;
    imageread(:,1) = 1;
    imageread(:,end) = 1;
    imageread=imclearborder(imageread);
    se = strel('sphere', 1);
    [x,y]=size(imageread);
    image_label = bwlabel(imageread,8);
    stats = regionprops(image_label,imageread,'PixelList','PixelIdxList');
    l=length(stats);
    for L=1:l
        List = (stats(L).PixelList);
        ll='_'+string(L);
        m=zeros(x,y);
        p=length(List);
        for P=1:p
            g=List(P,1);
            G=List(P,2);
            m(G,g)=1;
        end
        single=imdilate(m,se);
        pix=regionprops(single,'PixelList','BoundingBox','MinorAxisLength','MajorAxisLength','Orientation','Centroid');
        single2=single(1:183,:);
        for i=1:length(rd2(:,1))
           sed=double(rd2{i,1});
           s=sed.*single2;
           s=imcrop(sed,pix.BoundingBox);
           s2=s;
           [pix2,pix3]=find(s);
           dime=size(s);
           for x2=1:dime(1,1)
               for y2=1:dime(1,2)
                   if s2(x2,y2) == 0
                    r=((med-(0.12*med)) + ((med+(0.1*med))-(med-(0.12*med)))* rand(1,1));
                    s2(x2,y2)=r;
                   end   
               end
           end
           fi=fspecial('average',2);
           ss=imfilter(s2,fi,'symmetric','conv');
          
           for ii=1:length(pix2)
               ss(pix2(ii),pix3(ii))= s(pix2(ii),pix3(ii));
           end
            s3=uint16(s);
           files= strrep(fileNames{k},'.vsi', ll + '.mat');
           pix.image=k;
           pix.cell=L;
           save(files,'pix')
           filename= strrep(fileNames{k},'.vsi', ll + '.tif');
           imwrite(s3,filename,'WriteMode','append');
           s3=[];
           s=[];
           s2=[];
           ss=[];
        end
    end
    toc
end
%             rr1=ObjCell{x, 3}{1, 10};  Find orientation or pix(x).Orientation
%             rr2=(ObjCell{x, 3}{1, 9})'; Find centroid or pix(x).Centroid
%             R=[cosd(rr1) +sind(rr1); -sind(rr1), cosd(rr1)];
%             r3=(R*(Pos2'-rr2)+rr2); Pos2 = track location
%             e1 =(r3(1) - rr2(1));
%             e2= (ObjCell{x, 3}{1, 1}/2);
%             e = [e1 e2];
%             E= vertcat(E,e);