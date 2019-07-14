%Enter Excel filename
xlsfile = '468coloc.xlsx';

%Select for image files
ProA = ch2;
ProB = ch3;
% ProAlevel = thr2mean;
% ProBlevel = thr2mean;
numrandtest = 10;

%Applying average threshold for each channel
PCClist1 = zeros(numfiles1,4);

for i=1:numfiles1
    ProAlevel = graythresh(ProA(:,:,i));
    ProBlevel = graythresh(ProB(:,:,i));
    ProABW = im2bw(ProA(:,:,i),ProAlevel);
    ProBBW = im2bw(ProB(:,:,i),ProBlevel);
    %Choosing the bigger mask
    if sum(ProABW(:)) > sum(ProBBW(:))
        Mask = ProABW;
    else
        Mask = ProBBW;
    end
    Mask = im2uint8(Mask)-254;
    %Applying mask to image
    ProA1(:,:,i) = ProA(:,:,i) + 1;
    ProB1(:,:,i) = ProB(:,:,i) + 1;
    ProAMask = ProA1(:,:,i).*Mask;
    ProBMask = ProB1(:,:,i).*Mask;
    A = im2double(ProAMask);
    A(A==0)=NaN;
    A = A - 0.0039;
    sizeA = size(A);
    numpxA = prod(sizeA);
    A = reshape(A',1,numpxA); %convert image to one-dimensional array
    A(isnan(A))=[];
    B = im2double(ProBMask);
    B(B==0)=NaN;
    B = B - 0.0039;
    sizeB = size(B);
    numpxB = prod(sizeB);
    B = reshape(B',1,numpxB); %convert image to one-dimensional array
    B(isnan(B))=[];
    PCCmask=corrcoef(A,B,'rows','complete'); %calculating PCC ignoring NaN values
    
    PCC = PCCmask(1,2);
    
    PCClist(i,1) = i;
    PCClist(i,2) = PCC;
    
    %Randomize px of B
    PCCshufflist = zeros(numrandtest,1);
    for j=1:numrandtest
        sizeBshuff = size(B);
        Bshuff = B(randperm(sizeBshuff(1,2)));
        PCCmaskshuff = corrcoef(A,Bshuff,'rows','complete'); %calculating PCC shuffle ignoring NaN values
        PCCshuff = PCCmaskshuff(1,2);
        PCCshufflist(j,1) = PCCshuff;
    end
    [h,p] = ttest(PCCshufflist,PCC);
    PCClist(i,3) = p;
    PCClist(i,4) = h;
end

% %Write to excel
% SUCCESS = xlsappend(xlsfile, PCClist); %Should return 1 when write to xls is successful
% if SUCCESS == 1
%     disp('Append to excel file successful');
%     disp(xlsfile);
% else
%     disp('Append to excel unsuccessful');
% end
