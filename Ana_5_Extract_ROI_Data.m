

clear

Set_Up;

if theexp == 1
    Task(end-1:end) = []; % train and test runs don't need univariate contrast
end
% 'RS','Localizer_Obj', 'Localizer_BM'

contrasts(1).name   = {'Interaction', 'MovingUp-MovingDown' };
contrasts(2).name   = {'Body', 'Trunk', 'Limb', 'Car'};
contrasts(3).name   = {'Biological motion'};
% set parameters
% alpha = 0.05;
% tMin = icdf('t', 1-alpha, 388);   % t cut-off
Nvox_max = 200;

betas = nan(Nsub,6,Task(1).NRuns);

for thesub = 1:length(Subs)
    subId = ['sub-' sprintf('%03d', Subs(thesub))];
    Dirs = get_directories_for_thesub(Subs(thesub));
    
    %% first, get the mask for intersection
    usemask = 1;
    
    themask = 'EBA';
    MaskFile = fullfile(homeDir,'Results', 'Masks',  'Templates', ['realigned_' themask, '_mask.nii']);
    voxMask = spm_read_vols(spm_vol(MaskFile),1);
    
    
    %% Second, get the significant clusters from localzier's contrast
    useloc = 1;
    if useloc
    theloc     = 1;% {'Body', 'Trunk', 'Limb', 'Car'};
    locName    = contrasts(2).name{theloc}; 
    locDir     = fullfile(homeDir,Dirs.betas, 'Localizer_Obj');
    roi_tFile  = fullfile(locDir, sprintf( 'spmT_%04g_%s_thresholded.nii', theloc, locName) );
    voxLoc     = spm_read_vols(spm_vol(roi_tFile),1);
    
    % intersect the mask and localzier to find common areas
    vox_count(thesub,1) = numel(find(~isnan(voxLoc)));
    if usemask
        vox_ind    = find(~isnan(voxLoc) & (voxMask ==1 )); % use 1.5 because AAL mask has 2 inside the area, 1 outside the area, and intrapolate near the boundary
    else
        vox_ind    = find(~isnan(voxLoc));
    end
    
    vox_count(thesub,2)   =   numel(vox_ind);
    if vox_count(thesub,2) >= Nvox_max
        Nvox = Nvox_max;
    else Nvox = vox_count(thesub,2);
    end

    
    % select top voxels
    [~,vox_ind_sorted]  =   sort( voxLoc(vox_ind),'descend');
    vox_ind_nVoxels                     =   vox_ind_sorted(1:Nvox);
    vox2use                             =   vox_ind(vox_ind_nVoxels);
    vol_roi                             =   false( size( voxLoc));
    vol_roi(vox2use)   =   true;
    
    % write the roi into a nii
    roi = spm_vol(roi_tFile);
    roi.fname = fullfile(Dirs.masks, [locName, '.nii']);
    spm_write_vol( roi, vol_roi);

    else
        vox2use = find(voxMask ==1 );
        vox_count(thesub,1) = numel(vox2use);
    end
    
    %% get betas of RS in these voxels
    
    % get parameters
    NrunThisType = length(dir(fullfile(homeDir, Dirs.behav, Task(1).nameInBehav, '*.mat')));
    regreFile = dir(fullfile(homeDir, Dirs.nuisances, ['nuisance_' Task(1).Type '_run-*.mat']));
    load(fullfile(regreFile(1).folder, regreFile(1).name));
    Nnuisance = size(R,2);
    onsetFile = dir(fullfile(homeDir, Dirs.onsets, ['onset_' Task(1).Type '_run-*.mat']));
    load(fullfile(onsetFile(1).folder, onsetFile(1).name), 'names')
    Ncondi = length(names);
    
    for therun = 1:NrunThisType
        
        for thecondi = 1:Ncondi-1
%             regressor_names = design_from_spm ([Dirs.betas, '/RS']); % beta_dir is directory of SPM model
            theid = (therun-1) * (Ncondi + Nnuisance) + thecondi;
            betaFile = fullfile(homeDir, Dirs.betas, Task(1).Type, sprintf( 'beta_%04g.nii', theid));
            
            nontrialid = (therun-1) * (Ncondi + Nnuisance) + Ncondi % the last condition is null trials
            nontrialFile = fullfile(homeDir, Dirs.betas, Task(1).Type, sprintf( 'beta_%04g.nii', nontrialid));
            volume = spm_read_vols(spm_vol(betaFile),1) - spm_read_vols(spm_vol(nontrialFile),1);
            
            betas(thesub,thecondi,therun) = nanmean(volume(vox2use));
        end
        
    end
    
end


%% plot betas of four conditions

if theexp==1
    sub_mean = squeeze(nanmean(betas,3));
interaction = sub_mean * [1 -1 -1 1 0]';
    gravity     = sub_mean * [1 -1 0 0 0]';
    Condis = {'Front-Up', 'Front-Down', 'Back-Up', 'Back-Down','single'};
    
elseif theexp==2
    betas = betas(:,[1 2 4 5 3 6],:); % swap the large condition to the end
        sub_mean = squeeze(nanmean(betas,3));
    interaction = sub_mean * [1 -1 -1 1 0 0]';
    gravity     = sub_mean * [1 -1 0 0 0 0]';
    Condis = {'Front-Up', 'Front-Down','Back-Up', 'Back-Down', 'Front-Back', 'Back-Front' };
end
x = 1:(Ncondi -1);

longTable = (reshape(shiftdim(betas,1),size(betas,2),[]))';
T = array2table(longTable);
T.Properties.VariableNames = Condis;
T.runNo = repmat((1:size(betas,3))',length(Subs),1);
T.subject = reshape(repmat(1:length(Subs),size(betas,3),1),height(T),1);
% writetable(T, ['Results/',locName, '_roi_betas_exp' num2str(theexp) '.csv'])
figure;
subplot(1,5,1:3)
h1 = plot(x, sub_mean,'-o','MarkerSize',8, 'MarkerFaceColor', [1 1 1]);
% legend(cellfun(@num2str, num2cell(Subs),'UniformOutput',false))
[h1(:).LineWidth] = deal(2);
xticks(x);
xticklabels(Condis);
xtickangle(30)
xlim([0 length(x)+1]);
% ylim([0 inf])
% title([' ROI: ' locName])

subplot(1,5,4);
h2 = plot(5, interaction, 'o','MarkerSize',8, 'MarkerFaceColor', [1 1 1]);
[h2(:).LineWidth] = deal(2);
ylim([-range(interaction), range(interaction)])
title('Interaction')


subplot(1,5,5);
h3 = plot(5, gravity, 'o','MarkerSize',8, 'MarkerFaceColor', [1 1 1]);
[h3(:).LineWidth] = deal(2);
ylim([-range(gravity), range(gravity)])
title('Gravity')

%%
figure;
for thesub = 1: length(Subs)
    subplot(1,length(Subs),thesub)
    h1 = plot(x, squeeze(betas(thesub,:,:)),'-o','MarkerSize',8, 'MarkerFaceColor', [1 1 1]);
    legend(cellfun(@num2str, num2cell(1:size(betas,3)),'UniformOutput',false))
    [h1(:).LineWidth] = deal(2);
    xticks(x);
    xticklabels(names(1:end-1));
    xlim([0 Ncondi]);
    ylim([0 inf])
    title(['Sub-' num2str(Subs(thesub))])
end

