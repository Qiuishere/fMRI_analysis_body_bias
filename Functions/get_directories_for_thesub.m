
function Dirs = get_directories_for_thesub(thesub)

% thesub: subject number, in number not string format
% Dirs: a structure of all the related folders of this sub

subId = ['sub-' sprintf('%03d', thesub)];

Dirs.behav = ['BodyBias-Qiu/Data_Lab/' subId];
Dirs.brain = ['bids/derivatives/fmriprep/' subId '/func'] ;

Dirs.betas     = fullfile('Results', 'Betas',     subId);
Dirs.onsets    = fullfile('Results', 'Onsets',    subId);
Dirs.nuisances = fullfile('Results', 'Nuisances', subId);
Dirs.mvpa      = fullfile('Results', 'MVPA',      subId);
Dirs.masks     = fullfile('Results', 'Masks',     subId);


fn = fieldnames(Dirs);
for i = 1: numel(fn)
    if ~exist(Dirs.(fn{i}), 'dir' )
        mkdir(Dirs.(fn{i}));
    end
end

Dirs.homeDir = '/project/3018068.01';
