%% aggregate all subs
Set_Up
onsetFile = fullfile('Results/Onsets/sub-001', ['onset_' taskType '_run-1.mat' ]);
load(onsetFile, 'names')
Condis = names;
Ncondi= length(Condis);


% convert every metric to dissimilarity matrix (distance measure)
% note that correlation calculated by pdist.m has already been transformed
metric  = 'crossnobis';
for thesub = 1:Nsub
    Dirs = get_directories_for_thesub(Subs(thesub));
    thefile = fullfile(Dirs.mvpa, 'Test', [metric,'-subRDM.mat']);
    load(thefile)
    for theroi = 1:length(subRDM.ROIs)
        allRDM (:,:,thesub,theroi) = subRDM.rdm(:,:,theroi);
    end
%     load(fullfile(homeDir,'Results', ['sub-' num2str(thesub) '_' metric '.mat']))
%     for theroi = 1:Nroi
%          acc = (acc+1)/2;
% %          acc = acc-min(acc,[],'all');
% %          acc = acc/max(acc,[],'all');
%         Acc(:,:,thesub,theroi) = acc(:,:,theroi);
%     end
end
% allRDM = Acc;
% else % use decoding
% load(fullfile(homeDir, 'DecodingAcc.mat'))
% end
% normalize?

%% multidimensional scaling
figure;
for theroi = 1:Nroi
    
     meanRDM = mean(allRDM(:,:,:,theroi),3);
     % normalize them? 
      groupAcc_norm = (meanRDM-min(meanRDM(:)))/max(meanRDM(:));
      groupAcc_norm(logical(eye(length(Condis)))) = deal(0); %
    
    subplot(2, Nroi, theroi)
    colormap(gca, hot);
    imagesc(meanRDM,[min(meanRDM(~eye(size(meanRDM)))),max(meanRDM(~eye(size(meanRDM))))]);
    colormap(gca, hot);
    
    xticks(1:size(meanRDM,2));
    yticks(1:size(meanRDM,1));
    xticklabels(Condis);
    yticklabels(Condis);
    set(gca,'XAxisLocation','top','YAxisLocation','Left')
    
    title(ROIs{theroi})
    colorbar;
    
    subplot(2,Nroi, theroi+Nroi)
%      newCoordinate = mdscale(meanRDM,2);
    newCoordinate  = tsne(meanRDM,'Algorithm','exact','Standardize',true,'Perplexity',2);
    scatter(newCoordinate(1:3,1),newCoordinate(1:3,2),'b');hold on
    scatter(newCoordinate(4:6,1),newCoordinate(4:6,2),'b',"filled");
    scatter(newCoordinate(7:9,1),newCoordinate(7:9,2),'r');
    scatter(newCoordinate(10:12,1),newCoordinate(10:12,2),'r',"filled");
%     legend(

    text(newCoordinate(:,1)+0.05,newCoordinate(:,2),Condis)
end


%% test the biases
figure;
for theroi = 1:Nroi
    dis_F_39 = mean([squeeze(allRDM(2,1,:,theroi)),squeeze(allRDM(5,4,:,theroi))],2); 
    dis_F_51 = mean([squeeze(allRDM(2,3,:,theroi)),squeeze(allRDM(5,6,:,theroi))],2); 
    dis_B_39 = mean([squeeze(allRDM(8,7,:,theroi)),squeeze(allRDM(11,10,:,theroi))],2); 
    dis_B_51 = mean([squeeze(allRDM(8,9,:,theroi)),squeeze(allRDM(11,12,:,theroi))],2); 

    [h,p] = ttest(dis_F_39,dis_F_51)
    [h,p] = ttest(dis_B_39,dis_B_51)
    [h,p] = ttest(dis_F_39 - dis_F_51,dis_B_39 - dis_B_51) %interaction
    subplot(1, Nroi, theroi)
        x = 1:4;
    plot(x, [dis_F_39,dis_F_51, dis_B_39, dis_B_51],'o','MarkerSize',5, 'MarkerFaceColor', [1 1 1]);
    title(ROIs{theroi})
    xticks(x);
    xticklabels({'Front-39', 'Front-51', 'Back-39', 'Back-51'});
    ylim = get(gca,'YLim');
    ylabel('decoding accuracy from 45 degrees')
%     text(x,ylim(1)*ones(size(x)), arrayfun(@num2str,p2zero(:,theroi),'UniformOutput' ,0))


% test whether the back is more scarce than front ( items more similar to
% each other )
Dis_F = squeeze(mean(mean(allRDM(1:6,1:6,:,theroi),1),2));
Dis_B = squeeze(mean(mean(allRDM(7:end,7:end,:,theroi),1),2));
[h,p] = ttest(Dis_B,Dis_F)
end

%% linear regression on the neural RDM
% thoeratical models
posture = [ones(1,6), 2* ones(1,6)];
facingDir = repmat([1 1 1 2 2 2],1,2);
visual = posture~=facingDir;
armHeight = repmat([1,2,3],1,4);

% construct DISSIMILARITY matrix
[hor,ver] = meshgrid(posture,posture);
Model_posture = double(hor ~=ver);
[Model_Front,Model_Back] = deal(Model_posture);
Model_Front(7:end,7:end) = deal(0);
Model_Back(1:6,1:6) = deal(0);

[hor,ver] = meshgrid(facingDir,facingDir);
Model_facing = double(hor ~=ver);

[hor,ver] = meshgrid(visual,visual);
Model_visu = double(hor ~=ver);

[hor,ver] = meshgrid(armHeight,armHeight);
Model_armHeight = double(hor ~=ver);

figure;
subplot(1,4,1); imagesc(Model_posture); title('Posture')
subplot(1,4,2); imagesc(Model_facing);  title('Facing-Dir')
subplot(1,4,3); imagesc(Model_visu);    title('Visual-Field')
subplot(1,4,4); imagesc(Model_armHeight);title('Arm-Height')
colormap(hot)

% get upper triangle;
getUpperTri = @(A) A(sub2ind(size(A), find(triu(ones(size(A)), 1))));
x = cellfun(@(x) getUpperTri(x), {Model_posture, Model_facing, Model_visu, Model_armHeight},'UniformOutput',0);
X = cell2mat(x);
[coeff,p] = deal(nan(Nsub,size(X,2)+1,size(allRDM,4)));

figure
for theroi = 1:size(allRDM,4)
    for thesub = 1:Nsub
        y = getUpperTri(allRDM(:, :, thesub,theroi));
        mdl = fitlm(X,y,'linear');
        coeff(thesub,:,theroi) = mdl.Coefficients.Estimate;
        p(thesub,:,theroi) = mdl.Coefficients.pValue;
    end
    for thecoeff = 2:size(p,2)
        [h,p20] = ttest(coeff(:,thecoeff,theroi),0);
        p2zero(thecoeff-1,theroi) = str2num(sprintf('%.2g' ,p20));
    end
    
    subplot(1,Nroi,theroi);
    x = 1:size(X,2);
    plot(x, coeff(:,2:end,theroi),'-o','MarkerSize',5, 'MarkerFaceColor', [1 1 1]);
    title(ROIs{theroi})
    xticks(x);
%     xticklabels({'Posture','Facing_Dir', 'Visual_Field', 'Arm_Height'});
    ylim = get(gca,'YLim');
     text(x,ylim(1)*ones(size(x)), arrayfun(@num2str,p2zero(:,theroi),'UniformOutput' ,0))
    
end

[h,pp] = ttest(coeff(:,2,1),coeff(:,3,1))

%% run a PCA
figure
for theroi = 1:Nroi
    themat = allRDM(:,:,:,theroi); % should normalize the pcs for each sub?
    thematWide = reshape(themat,[],Nsub);
    thematWide = thematWide';
    [pcs, score,latent] = pca(thematWide);
    
    Ncompo2plot = 4;
    
    for thepc = 1:Ncompo2plot % plot the first 5 components
        Compos(:,:,thepc,theroi) = reshape(pcs(:,thepc),size(allRDM,1),size(allRDM,2));
        subplot(Nroi,Ncompo2plot,(theroi-1)*Ncompo2plot+thepc)
        imagesc(Compos(:,:,thepc,theroi))
        colormap(hot)
    end
end



