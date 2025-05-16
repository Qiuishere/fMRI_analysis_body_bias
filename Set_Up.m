theexp = 2;

homeDir = '/project/3018068.01' ;
cd(homeDir);
TR = 1.5; % secs
voxelSize = [2 2 2];

% add tools
addpath /home/predatt/qiuhan/Documents/Toolboxs/spm12/
addpath /home/predatt/qiuhan/Documents/Toolboxs/spm12/toolbox/AAL3
addpath (genpath('/home/predatt/qiuhan/Documents/Toolboxs/TDT' ))
addpath /home/common/matlab/fieldtrip/qsub
addpath (genpath('/home/predatt/qiuhan/Documents/Toolboxs/fmri_TimoFlesch'))
 
addpath ./BodyBias-Qiu/Functions/Utils
addpath ./Scripts/Functions

spm('defaults','fmri');
spm_jobman('initcfg');


% directories
jobDir='./SPM_jobs';



% variable to use
% for piloting:
[Task(1:5).Type]    = deal('RS', 'Localizer_Obj', 'Localizer_BM', 'Train', 'Test');
[Task(1:5).Type]    = deal('RS', 'Localizer_Obj', 'Localizer_BM', 'Train', 'Test-angle');

[Task.nameInBehav]  = deal('Test', 'Localizer_Obj', 'Localizer_BM', 'Train', 'Test');
[Task.nameInBids]   = deal('test', 'objloc' ,'bmloc', 'train', 'test'); 
[Task.NRuns]        = deal( 5,2,1,2, 5);


if theexp == 2 % for second piloting
    Task([4,5]) = [];
    Task(1).NRuns = 8;
elseif theexp ==3 
    Task([1,4]) = [];
    Task(3).NRuns = 8;
elseif theexp ==4
    Task(2:end) = [];
end



% Subjects to run
if theexp == 1
    Subs = [1 4 5 7 8 9 6 17]; % Excluded subs: 3 (didn't understand the task)
elseif theexp == 2  % after adding two large change conditions
    Subs = [2 11 12 14 15];
elseif theexp == 3 || theexp == 4  % MVPA on only the first posture
    Subs = [1 4 5 7 8 9 6 17 2 11 12 14 15];
end
Nsub = length(Subs);