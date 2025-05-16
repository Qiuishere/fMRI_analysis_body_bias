% model specification and fitting:
% input: regressors(conditions) + brain data
% output: betas for each condition and nuisance regressors
clear
Set_Up;

useCluster = 1;

%% make directory
for thesub =  Subs
    
    subId = ['sub-' sprintf('%03d', thesub)];
    Dirs = get_directories_for_thesub(thesub);

    
    for thetype = 1 % 1: length(Task)
        
        % get how many runs are in this task
        fileThisType = dir(fullfile(Dirs.behav, Task(thetype).nameInBehav, '*.mat'));

        taskType = Task(thetype).Type;
        % create output directory
        resultDir     =  fullfile(homeDir, Dirs.betas, taskType);
        if ~exist( resultDir, 'dir')
            mkdir( resultDir);
        end
        
        delete([resultDir, '/SPM.mat']) % to prevent the prompt window
        
        batch = [];
        batch{1}.spm.stats.fmri_spec.dir = {resultDir};
        batch{1}.spm.stats.fmri_spec.timing.units = 'secs';
        batch{1}.spm.stats.fmri_spec.timing.RT = 1.5; % spm will consider delay caused by slice timing with this.
        batch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
        batch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
        
        %% get brain data
        
        data4D = cell(Task(thetype).NRuns,1);
        
        for therun =  1:length(fileThisType)
            
            therunInReality = str2num(fileThisType(therun).name(end-4));
            
            %% put scans in each run
            
            niiName = [subId '_task-' Task(thetype).nameInBids '_run-' num2str(therunInReality) '_space-MNI152NLin2009cAsym_desc-preproc_bold_smoothed.nii*'];
            thefile = dir(fullfile(homeDir, Dirs.brain, niiName));
            
            data4D{therun} = fullfile(homeDir, Dirs.brain, thefile.name);
            
            % Gunzip if necessary
            [~,fileName,ext] = fileparts(data4D{therun});
            if strcmp(ext,'.gz')
                if isunix
                    cmd = ['gunzip ' data4D{therun}];
                    system(cmd);
                elseif ispc
                    warning('gunzip in Matlab is EXTREMELY slow!')
                    gunzip(data4D{therun});
                end
                data4D{therun} = erase(data4D{therun}, '.gz');
            end
            
            frames = spm_select('expand' , data4D{therun});
            
            batch{1}.spm.stats.fmri_spec.sess(therun).scans = cellstr(frames);
            
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
        jobName = 'Estimation';
        
        if useCluster
            req_mem   = 10^9 *5; % in GBbytes
            req_etime = 3600 *1; % seconds/hour * hour
            subjobs{thetype} = qsubfeval(@run_spm_jobs, batch, jobName, jobDir, 'memreq',  req_mem,  'timreq',  req_etime, 'backend', 'torque');
            
            % monitor job
            %         for j = subjobs
            %             jid = qsublist('getpbsid',j);
            %             cmd = sprintf('qstat %s', jid);
            %             unix(cmd)
            %         end
        else
            % run in matlab
            run_spm_jobs(batch,jobName,jobDir);
        end
        %% Compress the file and delete the expanded
        %     for therun = 1: NRuns(thetype)
        %         gzip(data4D{therun});
        %         delete(data4D{therun});
        %     end
        %
        
    end
end