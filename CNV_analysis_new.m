%Import Data as "data"
%Start,End, Num of Probe, Segment Mean

imagename = 'HER2_positive_CNV.tif';

datasize = size(data,1);    %Set number of array
minpos = min(data(:,1)) - 1;
rdminpos = round(minpos,-3);
maxpos = max(data(:,2));
rdmaxpos = round(maxpos,-3);
chrsegmean = zeros((rdmaxpos - rdminpos)/1000,datasize);
results = zeros((rdmaxpos - rdminpos)/1000,4);
chrpos = (1:size(chrsegmean,1));
chrpos = chrpos * 1000;
chrpos = chrpos + minpos;


parfor j = 1:datasize
    tempdata = data;
    tempchrposarray = chrpos-rdminpos;
    startpos = tempdata(j,1) - rdminpos;
    stoppos = tempdata(j,2) - rdminpos;
    findpos = (tempchrposarray(:)>=startpos)&(tempchrposarray(:)<= stoppos);
    segmentmean = tempdata(j,4);
    temphold = findpos .* segmentmean;
    chrsegmean(:,j) = temphold;
    disp(j)
end   


parfor i = 1 : size(chrsegmean,1)
   temparray = chrsegmean(i,:);
   tempresults= zeros(1,4);
   temparray(temparray==0) = [];
   tempresults(1,1) = mean(temparray);
   standev = std(temparray);
   numelement = numel(temparray);
   tempresults(1,2) = standev;
   tempresults(1,3) = standev / sqrt(numelement);
   [H,P] = ttest(temparray);
   tempresults(1,4) = P;
   results(i,:) = tempresults;
end


zeroline = zeros(1,size(chrpos,2));
f1 = figure;
c = results(:,4);
%cgo = errorbar(chrpos,results(:,1),results(:,3),'vertical');
%cgo.LineStyle = 'none'; 
%hold on
scatter(chrpos,results(:,1),3,c);
hold on
scatter(chrpos,zeroline,1,'k','filled');
xlim([rdminpos, rdmaxpos]);
title('Chromosome 17 CNV')
xlabel('Location')
ylabel('Segment Mean')
saveas(f1,imagename);
