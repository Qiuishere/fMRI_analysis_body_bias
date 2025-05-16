Set_Up
useCluster = 1;

resultDir     =  fullfile(homeDir, 'Results/Betas', 'AllSubCombined');

mkdir(resultDir)
delete([resultDir, '/SPM.mat']) % to prevent the prompt window

batch = [];
batch{1}.spm.stats.fmri_spec.dir = {resultDir};
batch{1}.spm.stats.fmri_spec.timing.units = 'secs';
batch{1}.spm.stats.fmri_spec.timing.RT = TR; % spm will consider delay caused by slice timing with this.
batch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
batch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

therun = 0;
thetype = 1;
taskType = Task(thetype).Type;

weight = [1 1 -2 1 1 -2 0]'; %{'Front-Up','Front-Down','Front-otherside','Back-Up','Back-Down', 'Front-otherside',}
WEI = [];

for thesub = 1:length(Subs)
    subId = ['sub-' sprintf('%03d', Subs(thesub))];
    Dirs = get_directories_for_thesub(Subs(thesub));
    %% get brain data
    fileThisType = dir(fullfile(Dirs.behav, Task(thetype).nameInBehav, '*.mat'));
    
    
    for run =  1:length(fileThisType)
        therun = therun+1;
        therunInReality = str2num(fileThisType(run).name(end-4));
        
        %% put scans in each run
        
        niiName = [subId '_task-' Task(thetype).nameInBids '_run-' num2str(therunInReality) '_space-MNI152NLin2009cAsym_desc-preproc_bold_smoothed.nii*'];
        thefile = dir(fullfile(homeDir, Dirs.brain, niiName));
        
        data4D{therun} = fullfile(homeDir, Dirs.brain, thefile.name);
%         
%         % Gunzip if necessary
%         [~,fileName,ext] = fileparts(data4D{therun});
%         if strcmp(ext,'.gz')
%             if isunix
%                 cmd = ['gunzip ' data4D{therun}];
%                 system(cmd);
%             elseif ispc
%                 warning('gunzip in Matlab is EXTREMELY slow!')
%                 gunzip(data4D{therun});
%             end
%             data4D{therun} = erase(data4D{therun}, '.gz');
%         end
%         
%         frames = spm_select('expand' , data4D{therun});
%         
%         batch{1}.spm.stats.fmri_spec.sess(therun).scans = cellstr(frames);
%         
        %% put conditions and nuisance regressors
        
        % put conditions onset, using multiple conditions to put only one
        % onsetFile
        onsetFile = fullfile(homeDir, Dirs.onsets,  ['onset_' taskType '_run-' num2str(therunInReality) '.mat']);
        batch{1}.spm.stats.fmri_spec.sess(therun).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        batch{1}.spm.stats.fmri_spec.sess(therun).multi = {onsetFile};
        
        % put regressor, using multiple regressor
        regreFile = fullfile(homeDir, Dirs.nuisances, ['nuisance_' taskType '_run-' num2str(therunInReality) '.mat']);
        batch{1}.spm.stats.fmri_spec.sess(therun).regress = struct('name', {}, 'val', {});
        batch{1}.spm.stats.fmri_spec.sess(therun).multi_reg = {regreFile}; %% put motion regressor here
        batch{1}.spm.stats.fmri_spec.sess(therun).hpf = 128;
        
        % put weight for the contrast
        load(regreFile)
        Nnuisance = length(names);
        WEI = [WEI, weight, zeros(1,Nnuisance)];

    end
end

batch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
batch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
batch{1}.spm.stats.fmri_spec.volt = 1;
batch{1}.spm.stats.fmri_spec.global = 'None';
batch{1}.spm.stats.fmri_spec.mthresh = 0.8;
batch{1}.spm.stats.fmri_spec.mask = {''};
batch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';


%% estimation=================
batch{2}.spm.stats.fmri_est.spmmat = {[resultDir '/SPM.mat']};
batch{2}.spm.stats.fmri_est.write_residuals = 0;
batch{2}.spm.stats.fmri_est.method.Classical = 1;


%% run jobs
% jobName = 'Estimation';
% 
% if useCluster
%     req_mem   = 10^9 *200; % in GBbytes
%     req_etime = 3600 *20; % seconds/hour * hour
%     subjobs{thetype} = qsubfeval(@run_spm_jobs, batch, jobName, jobDir, 'memreq',  req_mem,  'timreq',  req_etime, 'backend', 'torque');
%     
% else
%     % run in matlab
%     run_spm_jobs(batch,jobName,jobDir);
% end
