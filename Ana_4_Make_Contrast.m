% make contrasts among conditions
% input:
% the betas produced by model fitting + contrasts (hypotheses)
% output:
% con.nii:  contrast of betas
% spmT.nii: all t values = con map/variance map
% spmT_thresholded.nii: t values above the threshold
% spmT_allcluster: binary mask of voxels above threshold


clear

Set_Up;
if theexp == 1
    Task([end-1:end]) = []; % train and test runs don't need univariate contrast
end

%% define contrasts for each task

% Task: 'RS','Localizer_Obj', 'Localizer_BM'
if theexp==1
    contrasts(1).name   = {'Interaction', 'MovingUp-MovingDown' ,'large-small'};
    contrasts(1).weight = {[1 -1 0 -1 1 0 0], [1 -1 0 1 -1 0 0], [-1 -1 2 -1 -1 2]}; %{'Front-Up','Front-Down','Front-otherside','Back-Up','Back-Down', 'Front-otherside',}
elseif theexp==3
    contrasts(1).name   = {'large-small'};
    contrasts(1).weight = { [1 1 -2 1 1 -2 0]}; %{'Front-Up','Front-Down','Front-otherside','Back-Up','Back-Down', 'Front-otherside',}
    % the order of conditions is determined by the onset file. the last is
    % null-trials
end

contrasts(2).name   = {'Body', 'Trunk', 'Limb', 'Car'};
contrasts(2).weight = {[1 -1 0 0], [2 -1 -1 0], [-1 -1 2 0], [-1 2 0 -1]};% {'1-body','2-car','3-limb','4-scrambled'}

contrasts(3).name   = {'Biological motion'};
contrasts(3).weight = {[1 -1]};



%%
for thesub = 11
    
    Dirs = get_directories_for_thesub(thesub);

    for thetype = 2:length(Task)
        
        regreFile = dir(fullfile(homeDir, Dirs.nuisances, ['nuisance_' Task(thetype).Type '_run-*.mat']));
        load(fullfile(regreFile(1).folder, regreFile(1).name), 'R')
        Nnuisance = size(R,2);
        
        NrunThisType = length(dir(fullfile(homeDir, Dirs.behav, Task(thetype).nameInBehav, '*.mat')));

        % get SPM.mat from result after estimation                
                resultDir     =  fullfile(homeDir, Dirs.betas, Task(thetype).Type);        
        matlabbatch = [];
        matlabbatch{1}.spm.stats.con.spmmat = cellstr(strcat(resultDir,'/SPM.mat'));

        
        for thecontr = 1: length(contrasts(thetype).name)
            
            conName = contrasts(thetype).name{thecontr};
            
            % paddle the weight with zeros for nuisance regressors (block
            % effects, or the intercept of each run, are at the end of all the
            % regressors)
            
            weights = repmat([contrasts(thetype).weight{thecontr}, zeros(1,Nnuisance)],1,NrunThisType);
            matlabbatch{1}.spm.stats.con.consess{thecontr}.tcon.name = conName;
            matlabbatch{1}.spm.stats.con.consess{thecontr}.tcon.convec = weights;
            matlabbatch{1}.spm.stats.con.consess{thecontr}.tcon.sessrep = 'none';
            
            
            matlabbatch{1}.spm.stats.con.delete = 1;
            
            
            %% set parameters for the output results
            matlabbatch{2}.spm.stats.results.spmmat = cellstr(strcat(resultDir,'/SPM.mat'));
            matlabbatch{2}.spm.stats.results.conspec.titlestr = '';
            matlabbatch{2}.spm.stats.results.conspec.contrasts = thecontr;
            matlabbatch{2}.spm.stats.results.conspec.threshdesc = 'none';
            matlabbatch{2}.spm.stats.results.conspec.thresh = 0.01; 
            matlabbatch{2}.spm.stats.results.conspec.extent = 10;
            matlabbatch{2}.spm.stats.results.conspec.conjunction = 1;
            matlabbatch{2}.spm.stats.results.conspec.mask.none = 1;
            matlabbatch{2}.spm.stats.results.units = 1;
            matlabbatch{2}.spm.stats.results.export{1}.tspm.basename = strcat(conName,'_thresholded');
%             matlabbatch{2}.spm.stats.results.export{2}.jpg = true;
             
            spm_jobman('run',matlabbatch);
        end
    end
end