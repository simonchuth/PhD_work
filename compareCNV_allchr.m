chrArea = zeros(22,3);
for chr = 1:22
    logi = maindataT(:,5)==chr;
    data1 = maindataT(logi,:);
    logi = maindataN(:,5)==chr;
    data2 = maindataN(logi,:);
    minpos = min(data1(:,1)) - 1;
    rdminpos = round(minpos,-3);
    maxpos = max(data1(:,2));
    rdmaxpos = round(maxpos,-3);
    chrpos = (1:((rdmaxpos-rdminpos)/1000));
    chrpos = chrpos * 1000;
    chrpos = chrpos + minpos;
    
    CNV1 = dataextract(data1,rdminpos,rdmaxpos,chrpos);
    CNV2 = dataextract(data2,rdminpos,rdmaxpos,chrpos);
    [H,P] = ttest2(CNV1',CNV2');
    [H1,P1]=ttest(CNV1');
    [H2,P2]=ttest(CNV2');
    CNV1mean = CNVmean(CNV1);
    CNV2mean = CNVmean(CNV2);
    CNVdiff = CNV1mean-CNV2mean;
    suitylimval = suitylim(CNVdiff,CNV1mean,CNV2mean);
    %set certain suitylimval
        suitylimval = [-0.3 0.5]; 

    zeroline = zeros(1,size(chrpos,2));
    f = figure;
    c = P;
    scatter(chrpos,CNVdiff,3,c);
    hold on
    scatter(chrpos,zeroline,1,'k','filled');
    xlim([rdminpos, rdmaxpos]);
    ylim(suitylimval);
    title(sprintf('Chromosome %d CNV', chr))
    xlabel('Location')
    ylabel('Delta Segment Mean')
    chrArea(chr,1) = mean(abs(CNVdiff)); 

    f1 = figure;
    c = P1;
    scatter(chrpos,CNV1mean,3,c);
    hold on
    scatter(chrpos,zeroline,1,'k','filled');
    xlim([rdminpos, rdmaxpos]);
    ylim(suitylimval);
    title(sprintf('Chromosome %d CNV Tumour', chr))
    xlabel('Location')
    ylabel('Segment Mean')
    chrArea(chr,2) = mean(abs(CNV1mean));

    f2 = figure;
    c = P2;
    scatter(chrpos,CNV2mean,3,c);
    hold on
    scatter(chrpos,zeroline,1,'k','filled');
    xlim([rdminpos, rdmaxpos]);
    ylim(suitylimval);
    title(sprintf('Chromosome %d CNV Normal', chr))
    xlabel('Location')
    ylabel('Segment Mean')
    chrArea(chr,3) = mean(abs(CNV2mean))

    imagename = sprintf('Chromosome %d CNV diff.tif', chr);
    data1name = sprintf('Chromosome %d CNV Tumour.tif', chr);
    data2name = sprintf('Chromosome %d CNV Normal.tif', chr);
    saveas(f,imagename);
    saveas(f1,data1name);
    saveas(f2,data2name);
    fprintf('Chromosome %d done\n',chr);
    close all
    clear data1 data2 CNV1 CNV2 chrpos logi 
end
  
save('ChrArea.mat','chrArea')

function CNVmeanoutput = CNVmean(CNV)
    CNVsize = size(CNV,1);
    CNVmeanoutput = zeros(CNVsize,1);
    parfor i = 1:CNVsize
        temp = CNV(i,:);
        temp(isnan(temp))=[];
        tempmean = mean(temp);
        CNVmeanoutput(i) = tempmean;
    end
end


function chrsegmean = dataextract(CNV,rdminpos,rdmaxpos,chrpos)
    disp('Data extract start')
    datasize = size(CNV,1);
    if datasize>5000
        numit = ceil(datasize/5000);
    else
        numit = 1;
    end
    
    for k = 1:numit
        tic;
        fprintf('data extract %d out of %d\n',k,numit)
        chrsegmeantemp = zeros((rdmaxpos - rdminpos)/1000,5000);
        parfor j = 1:5000
            CNVtemp = CNV;
            if k ==numit
                tempdata = zeros(5000,5);
                tempdata(1:datasize-(k-1)*5000,:) = CNVtemp((k-1)*5000+1:datasize,:);
            else
                tempdata = CNVtemp((k-1)*5000+1:k*5000,:);
            end
            tempchrposarray = chrpos-rdminpos;
            startpos = tempdata(j,1) - rdminpos;
            stoppos = tempdata(j,2) - rdminpos;
            findpos = (tempchrposarray(:)>=startpos)&(tempchrposarray(:)<= stoppos);
            segmentmean = tempdata(j,4);
            temphold = findpos .* segmentmean;
            chrsegmeantemp(:,j) = temphold;
        end   
        chrsegmeantemp(chrsegmeantemp==0) = NaN;
	
%%%%%%%%%%%%%%%%%%%%
	maxsize = 0;
	for p=1:size(chrsegmeantemp,1)
		temp = chrsegmeantemp(p,:);
		temp(isnan(temp))=[];
		tempsize = size(temp,2);
		if tempsize > maxsize
			maxsize = tempsize;
		else
			%do nothing
		end
	end
	
	tempholder = zeros(size(chrsegmeantemp,1),maxsize);	
	for p=1:size(chrsegmeantemp,1)
		temp = chrsegmeantemp(p,:);
		temp(isnan(temp))=[];
		tempholder(p,1:size(temp,2))=temp;
	end
	clear chrsegmeantemp
%%%%%%%%%%%%%%%%%%%%%%
	if k==1	    
        	startpos = 1;
        	endpos = size(tempholder,2);
	else
		startpos = size(chrsegmean,2)+1;
		endpos = size(chrsegmean,2) + size(tempholder,2);
	end
	
	chrsegmean(:,startpos:endpos) = tempholder;
        clear tempholder
        timeleft = (numit-k)*toc/60;
        fprintf('Time left %d minutes \n',timeleft)
    end
    disp('Data extract Done')
end

function ylimval = suitylim(dataset1,dataset2,dataset3)
    f_ymax = max(dataset1);
    f_ymin = min(dataset1);
    f1_ymax = max(dataset2);
    f1_ymin = min(dataset2);
    f2_ymax = max(dataset3);
    f2_ymin = min(dataset3);   
    ymax = max([f_ymax, f1_ymax, f2_ymax]) * 1.1;
    ymin = min([f_ymin, f1_ymin, f2_ymin]) * 1.1;
    ylimval = [ymin, ymax];
end