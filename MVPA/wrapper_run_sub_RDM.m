%% define conditions to decode

clear
cd ..
Set_Up;
taskType = 'RS';
useCluster = 1;

onsetFile = fullfile(['Results/Onsets/sub-' sprintf('%03d',Subs(1))], ['onset_' taskType '_run-1.mat' ]);
load(onsetFile, 'names')
Condis = names(1:end-1);
Ncondi= length(Condis);

% Condis = {'Front-L', 'Front-R', 'Back-L', 'Back-R'};
ROIs = {'V1', 'Body','Limb'};
Nroi = length(ROIs);
Nsub = length(Subs);

analysis = 'searchlight';
metric = 'decoding';

%% start to decode
% acc= zeros(Ncondi,Ncondi,Nsub,Nroi);

for thesub = 1:Nsub
    if useCluster
        req_mem   = 10^9 *200; % in GB
        req_etime = 3600 *4; % seconds/hour * hour
         subjobs{thesub} = qsubfeval(@get_sub_decoding, taskType, Subs, thesub, ROIs, Condis, metric,analysis,'memreq',  req_mem,  'timreq',  req_etime);
%                 subjobs{thesub} = qsubfeval(@get_sub_RDM,taskType, Subs, thesub, ROIs,metric, 'memreq',  req_mem,  'timreq',  req_etime);

        % monitor job
%         for j = subjobs
%             jid = qsublist('getpbsid',j);
%             cmd = sprintf('qstat %s', jid);
%             unix(cmd)
%         end
    else
%         run_sub_MVPA(taskType, Subs, thesub, ROIs, Condis,metric)
        get_sub_RDM(taskType, Subs, thesub, ROIs,metric)
    end
end

