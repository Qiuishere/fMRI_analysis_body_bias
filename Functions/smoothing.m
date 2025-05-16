function smoothed4Dnii = smoothing(datafile4D,kernel,jobDir)
% smoothed4Dnii = smoothing(datafile4D,kernel,jobDir)
%
% SUMMARY
% Takes 4D data file and applies spatial smoothing with a Gaussian kernel
% of FWHM as specified.
%
% DESCRIPTION
% If the datafile is gzipped it will be gunzipped first.
%
% INPUTS
% - datafile4D : file name of 4D data
% - kernel     : FWHM of Gaussian smoothing kernel
% - jobDir     : char; job directory where SPM job file will be saved
% 
% OUTPUTS
% Unzipped smoothed 4D data file.
%
% -------------------------------------------------------------------------
% Ruben van den Bosch
% 

% Get file extension
[~,~,ext] = fileparts(datafile4D);

% Gunzip if necessary
if strcmp(ext,'.gz')
    if isunix
        cmd = ['gunzip ' datafile4D];
        system(cmd);
    elseif ispc
        warning('gunzip in Matlab is EXTREMELY slow!')
        gunzip(datafile4D);
    end
% Update datafile4D name
datafile4D = erase(datafile4D, '.gz');
end


% Define inputs and fill job
% -------------------------------------------------------------------------
%  1. Frames in 4D datafile
%  2. FWHM of smoothing kernel
%  3. prefix for smoothed data file

frames = spm_select('expand', datafile4D);
prefix = '_smoothed';

jobs{1}.spm.spatial.smooth.data     = cellstr(frames);
jobs{1}.spm.spatial.smooth.fwhm     = kernel;
jobs{1}.spm.spatial.smooth.dtype    = 0;
jobs{1}.spm.spatial.smooth.im       = 0;
jobs{1}.spm.spatial.smooth.prefix   = prefix;

% Save and run job
% -------------------------------------------------------------------------
jobName = 'smooth4D';
run_spm_jobs(jobs,jobName,jobDir)

% Rename smoothed data file
% -------------------------------------------------------------------------
[path,name,ext]  = fileparts(datafile4D);
outFile          = fullfile(path,[prefix name ext]);
smoothed4Dnii    = fullfile(path,[name '_smoothed' ext ]);
movefile(outFile, smoothed4Dnii);

% % Compress the file and delate the expanded
% gzip(datafile4D);
% delete(datafile4D);
end