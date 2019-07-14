%imagenames as jx2 string array
%first column is imagename e.g. '1 Scr -CL.tif'
%second column is filename e.g. '*Scr_-CL*Ch0*'
numimg = size(imagenames,1);
for j = 1:numimg
    imagename = imagenames(j,1);
    Fnames=fullfile(pwd,imagenames(j,2));
    numtime = 96;


    Ffiles = dir(Fnames);
    numfile = size(Ffiles,1);
    filename = fullfile(Ffiles(1).folder,Ffiles(1).name);

    testimg = imread(filename);
    sizex = size(testimg,2);
    sizey = size(testimg,1);
    itstack = numtime+10;
    sizez = numfile*(itstack);
    combimg = zeros(sizey,sizex,sizez);
    combimg = uint16(combimg);
    [optimizer, metric] = imregconfig('monomodal');
    
    for i = 1:numfile
       tic
       filename = fullfile(Ffiles(i).folder,Ffiles(i).name);
       currimg = zeros(sizey,sizex,numtime);
       for p = 1:numtime
            currimg(:,:,p) = imread(filename,p);
       end
       
%        for q = 2:numtime
%             time1 = toc;
%             tform = imregtform(currimg(:,:,q), currimg(:,:,q-1), 'translation', optimizer, metric);
%             for l = q:numtime
%                 currimg(:,:,l) = imwarp(currimg(:,:,l),tform,'OutputView',imref2d(size(currimg(:,:,q-1))));
%             end
%             time2 = toc;
%             timeit = time2-time1;
%             clc
%             disp('Aligning image')
%             disp(q)
%             disp('Time left (min)')
%             disp((numtime-q)*timeit/60  + (numfile - i)*numtime*timeit/60 +(numimg-j)*numfile*numtime*timeit/60)
%        end
       
       k = (i-1)*itstack+1;
       combimg(:,:,k:(k+numtime-1)) = currimg(:,:,:);       
       time = toc;
       clc
       disp(imagename)
       disp('Reading and aligning image')
       disp('Time left (min)')
       disp((numfile-i)*time/60  + (5*(size(imagenames,1)-j))*time/60)
    end
    

    
%     disp('Start image transformation')
%     adj = combimg;
%     adj(adj==0)=[];
%     highthr = prctile(adj,99.9);
%     lowthr = prctile(adj,5);
%     highthr = double(highthr)/double(lowthr);
%     % thr1 = double(thr1)/double(thr);
%     newcombimg = double(combimg);
%     newcombimg = newcombimg / double(lowthr);
%     newcombimg(newcombimg < 1)=0;
%     newcombimg = newcombimg / highthr;
%     newcombimg(newcombimg > 1)=1;
% 
%     combimg = uint8(newcombimg * 255);
%     disp('Finish image transformation')

    %remove first n-1 slide
    % n=2;
    % combimgsize = size(combimg,3);
    % combimg=combimg(:,:,n:combimgsize);

    imwrite(combimg(:,:,1),imagename)
    combimgslide = size(combimg,3);
    if numfile > 0
        for k = 2:combimgslide
           imwrite(combimg(:,:,k),imagename,'WriteMode','append')
           clc
           disp(imagename)
           disp('Writing image')
           disp('slides left')
           disp(combimgslide-k)
           
           disp('Time left (min)')
           disp((numfile-i)*time/60  + (5*(size(imagenames,1)-j))*time/60)
        end

    else
        disp('Wrong file name')
    end


    
end
disp("Done!!!!!")

