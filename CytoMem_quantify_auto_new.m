%xlsappend was written by Brett Shoelson, PhD, 8/30/2010
%Retrieved from
%http://www.mathworks.com/matlabcentral/fileexchange/28600-xlsappend on
%02/03/2017
%=========================================================================

%Enter Excel filename
xlsfile = 'newSF468mem.xlsx';

%Assign channels to correct targets
DAPI = ch1;
WBP2 = ch2;
WGA = ch3;
%DAPIlevel = thr1mean;
%WBP2level = thr2mean;
%WGAlevel = thr3mean;


array = zeros(numfiles1,14);
for i=1:numfiles1

   
    WBP2level = graythresh(WBP2(:,:,i));
    WBP2BW = im2bw(WBP2(:,:,i),WBP2level); %WBP2 mask
    WBP2BW = im2uint8(WBP2BW)-254;
    totalWBP2 = WBP2(:,:,i).*WBP2BW;   
   
    DAPIlevel = graythresh(DAPI(:,:,i)); 
    DAPIBW = im2bw(DAPI(:,:,i),DAPIlevel); %DAPI mask
    DAPIBW = im2uint8(DAPIBW)-254;
    nucWBP2 = totalWBP2(:,:).*DAPIBW;
    WBP2rem = totalWBP2 - nucWBP2;
    
    WGAlevel = graythresh(WGA(:,:,i));
    WGABW = im2bw(WGA(:,:,i),WGAlevel); %Membrane mask
    WGABW = im2uint8(WGABW)-254;
    memWBP2 = WBP2rem(:,:).*WGABW;
    cytoWBP2 = WBP2rem - memWBP2;

    SumtotalWBP2 = sum(totalWBP2(:));
    SumnucWBP2= sum(nucWBP2(:));
    SummemWBP2 = sum(memWBP2(:));
    SumcytoWBP2 = sum(cytoWBP2(:));
    percentnucWBP2 = SumnucWBP2/SumtotalWBP2;
    percentmemWBP2 = SummemWBP2/SumtotalWBP2;
    percentcytoWBP2 = SumcytoWBP2/SumtotalWBP2;
    
    sizecyto = sum(WBP2BW(:));
    sizenuc = sum(DAPIBW(:));
    sizerem = WBP2BW-DAPIBW;
    sizemem = sum(WGABW(:).*sizerem(:));
    
    denmem = SummemWBP2/sizemem;
    dennuc = SumnucWBP2/sizenuc;
    dencyto = SumcytoWBP2/sizecyto;
    
    array(i,:) = [i, SumtotalWBP2, SummemWBP2, SumnucWBP2, SumcytoWBP2, percentmemWBP2, percentnucWBP2, percentcytoWBP2, sizemem, sizenuc, sizecyto, denmem, dennuc, dencyto];
end

% Write to excel
SUCCESS = xlsappend(xlsfile, array); %Should return 1 when write to xls is successful
if SUCCESS == 1
    disp('Append to excel file successful');
    disp(xlsfile);
else
    disp('Append to excel unsuccessful');
end


