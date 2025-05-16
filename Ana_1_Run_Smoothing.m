%% Subject input
% function Run_Smoothing(sub)
clear
Set_Up;

useCluster = 1;


%% Constant
kernel= 1.5*voxelSize;


%% Smoothing

for thesub = Subs
    % get all the runs
    Dirs = get_directories_for_thesub(thesub);
    
    cd(Dirs.brain)
    allRuns = dir( '*_bold.nii*');
    cd(homeDir)
    
    req_mem   = 10^9 *5; % in GB
    req_etime = 3600 *1; % seconds/hour * hour
    
    for therun = 1: length(allRuns)
        datafile4D = fullfile(Dirs.brain, allRuns(therun).name);
        if useCluster
            subjobs{therun} = qsubfeval(@smoothing, datafile4D, kernel, jobDir, 'memreq',  req_mem,  'timreq',  req_etime);
            
            % monitor job
            for j = subjobs
                jid = qsublist('getpbsid',j);
                cmd = sprintf('qstat %s', jid);
                unix(cmd)
            end
        else
            smoothing(datafile4D, kernel, jobDir);
        end
    end
    
end

%% DONE :)