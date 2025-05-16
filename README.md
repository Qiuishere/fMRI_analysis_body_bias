Preprocessing is done using fMRIprep. 
Univariate analysis uses Ana-1 ~ Ana-5. 
Multivariate analysis is in the folder MVPA


# Preprocessing in DCCN
How to pre-process
**Open Putty:**
- Set up a connection to a mentat005.nl, typing: _vncmanager_ to establish a VNC session. [https://hpc.dccn.nl/docs/cluster_howto/access-internal.html#ssh-login-with-putty](https://hpc.dccn.nl/docs/cluster_howto/access-internal.html#ssh-login-with-putty)
- Once it’s established, this step is not necessary any more.
**Open tiger:**
- Insert pw (*…)
- Move to project folder: _cd /project/3018068.01_
- Type all the next command there
**Bidsmapper (searches your input environment for dicoms to change into bids):**
- Activate virtual conda environment:
% module add bidscoin/3.0.6
% source activate /opt/bidscoin
- To map and create a bidsmap.yaml file (Supposedly, you need to do this only once):
% bidsmapper source-folder bids-folder
% bidsmapper raw bids
it automatically opens bids editor
In case you need to change the name of the files or something else, you can do so calling the bids editor: _bidseditor bids-folder_)
- To use a pre-existing map:
% bidsmapper source-folder bids-folder -b /path/to/bidsmap.yaml
% bidsmapper raw bids -b bids/code/bidscoin/bidsmap.yaml   or
% bidsmapper raw bids -t bidsmap_dccn
- **Once you are happy with the result, you can run the conversion (uses your yaml file to change the mapped dicoms):**
% bidscoiner source-folder bids-folder -b path/to/bidsmap.yaml
% bidscoiner raw bids  raw bids
**To check the output of bids coiner, you can use:**
- bids validator online, you only need to upload the bids folder. When there are errors but not crucial for proprecessing, to get fmriprep run, can skip the step of bids validation
**MRIqc**
- py /project/3018068.01/bids
**FMRIPREP (22.0.1)**
- to check the module available: _module avail_
- load: _module add fmriprep/20.2.7_
- run a job of preprocessing of each subject: _py bids_
- check available option: _module help fmriprep_ or _fmriprep_sub -h_
- skip bids validation (only after using bidsvalidator to confirm no major errors): _py bids -a " --skip-bids-validation —ignore fieldmaps"_
- output: derivatives
**SPM: smoothing**
- move: _cd project/3018068.01/Analysisi_scripts/MRI_preproc_smoothing_
- run on the terminal: _matlab_sub running_script.m_
- fill out the info requested
