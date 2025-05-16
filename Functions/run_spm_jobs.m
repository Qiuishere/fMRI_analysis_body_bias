function run_spm_jobs(jobs,varargin)
% RUN_SPM_JOBS(jobs [,jobName,jobDir])
% 
% DESCRIPTION
% Function to run SPM jobs. If jobName AND jobDir are specified, the SPM
% job is saved in a job .m file with jobName + date in the jobDir
% directory (both must be specified). 
% 
% INPUT
% jobs      : cell array of SPM batch jobs
% 
% Optional:
% jobName   : char; name for saved job file
% jobDir    : char; path to directory to save job file in
% 
% -------------------------------------------------------------------------
% Ruben van den Bosch
% 

% Proces input arguments
% -------------------------------------------------------------------------
if nargin == 1
    savejob = false;
elseif nargin == 2
    error('jobName and jobDir must both be specified')
elseif nargin == 3
    savejob = true;
    jobName = varargin{1};
    jobDir  = varargin{2};
    assert(ischar(jobName) && ischar(jobDir),'jobName and jobDir should be of type char');
    assert(exist(jobDir,'dir') == 7,'jobDir should be an absolute path to an existing directory');
elseif nargin > 3
    error('Too many input arguments')
end
assert(iscell(jobs),'jobs should be of type cell');

% Filename for save job
if savejob
    jobFile = fullfile(jobDir,[jobName,'_',datestr(now,'yyyymmddTHHMMSS'),'.m']);
end

% Initialise job
jobId = cfg_util('initjob', jobs);

% If successful save and run job
sts = cfg_util('isjob_id', jobId);
if sts
    if savejob
        cfg_util('savejob', jobId, jobFile);
    end
    cfg_util('run', jobId);
else
    error('Error in initialising %s job.',jobName)
end
end