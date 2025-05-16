%% NOTES
%%%%%%%% function to run the t-test on the contrast creaded for phase 1 and 2 %%%%%%%%
%% SUBJ INFO
%number=[113;117;170;175;189;220;225;239;260;264;268;279;...
%    283;287;301;306;310;343;361;388;391;395;403;407;410];

% to be fixed: 113,117 => problems in 1st level!

% no phase1: 113,170,175
% no phase2: 117
% no tot: 260,124,194

%% Info contrast
% ph1 pm 0 => 1)SU75 vs SU25 cue, 2)50 vs 75/25 cue, 3)SU75_taste vs SU25_taste,
%             4)SU50_taste vs SU25_taste, 5)SU75_taste vs SU50_taste,
%             6)SW75_taste vs SW25_taste, 7)SW50_taste vs SW25_taste, 
%             8)SW75_taste vs SW50_taste, 9)SU75_vsSU25_taste vs SW75_vsSW25_taste, 
%             10)certain(75) vs uncertain(50) taste, 11)likely(75) vs not likely(25) taste, 
%             12)all taste SU, 13)all taste SW, 14)SU vs SW taste

% ph1 pm 1/2 => 1)SU75 vs SU25 cue, 2)50 vs 75/25 cue, 3)SU taste vs SW taste (or thinking),
%               4)SU confidence, 5)SW confidence, 6)average confidence, 
%               7)confidence SU vs confidence SW

% ph2 pm 0 => 1)SU and SW cue, 2)SU vs Neutral Cue, 3)SW vs Neutral Cue, 4)SU Taste,
%             5)SW Taste, 6)SU Expected vs Unexpected, 7)SW Expected vs Unexpected, 
%             8)All expected, 9)All unexpected, 10)SU vs SW taste, 11)Expected vs unexpected, 
%             12)SU (exp, unexp) vs neutral, 13)SW (exp, unexp) vs neutral, 
%             14)SU (exp) vs neutral, 15)SW (exp) vs neutral, 16)SU exp vs SW exp, 
%             17)SU unexp vs SW unexp

% ph2 pm 1 => 1)SU and SW Cues, 2)SU vs Neutral Cue, 3)SW vs Neutral Cue, 4)Pleasantness Taste

% ph2 pm 2 => 1)SU and SW Cues, 2)SU vs Neutral Cue, 3)SW vs Neutral Cue, 4)Pleasantness SU exp,
%             5)Pleasantness SU unexp, 6)Pleasantness SW exp, 7)Pleasantness SW unexp

% ph2 pm 3 => 1)SU and SW Cues, 2)SU vs Neutral Cue, 3)SW vs Neutral Cue,
%             4)Pleasantness when cue was SU, 5)Pleasantness when cue was SW

%% CODE INFO
% subj = [407, 410];  % subjects' vector
% cont= 'SWconf';        % name of the contrast to be runned
% 
% phase = 1; % 1 or 2
% pm = 2;    % ph1: 0,1,2 - ph2: 0,1,2,3

%% Paths
% /data/em725/SS_MRI/mri_dicom/prces_data : where the processed data ara
% /data/em725/SS_MRI/mri_dicom/prces_data/2levelAn : where to save the processed data
% /home/em725/Documents/MATLAB/script_SUSW : where the scripts are

%% Function
function seclev_SUSW_120219(subj,cont,phase,pm)
%% SCRIPT
clear matlabbatch
spm('defaults','fmri');
spm_jobman('initcfg');

%% Addpath of where the analysis are and where the scans are (change this if needed)
addpath '/Users/elenamainetto/Documents/MATLAB/SUSW/MRI_data/2levelAn' % scripts
addpath '/Users/elenamainetto/Documents/MATLAB/SUSW/MRI_data'          % scans

%% Make dir
secondlvldir = ['/Users/elenamainetto/Documents/MATLAB/SUSW/MRI_data/2levelAn/PH',num2str(phase),'pm',num2str(pm),cont]; % where to save the 1 level analysis    
mkdir(secondlvldir); % make the folder for each contrast
cd(secondlvldir);
delete SPM.mat;

%% Select contrast
% phase=1 / pm=0  :
if phase == 1 && pm==0 && strcmp(cont,'SU75vsSU25cue')==1 % if all of this is true(==1) then...
   contSel= 'con_0001';
elseif phase == 1 && pm==0 && strcmp(cont,'50vs7525cue')==1
   contSel= 'con_0002';
elseif phase == 1 && pm==0 && strcmp(cont,'SU75vsSU25taste')==1
   contSel= 'con_0003';
elseif phase == 1 && pm==0 && strcmp(cont,'SU50vsSU25taste')==1
   contSel= 'con_0004';
elseif phase == 1 && pm==0 && strcmp(cont,'SU75vsSU50taste')==1
   contSel= 'con_0005';
elseif phase == 1 && pm==0 && strcmp(cont,'SW75vsSW25taste')==1
   contSel= 'con_0006';
elseif phase == 1 && pm==0 && strcmp(cont,'SW50vsSW25')==1
   contSel= 'con_0007';
elseif phase == 1 && pm==0 && strcmp(cont,'SW75vsSW50_taste')==1
   contSel= 'con_0008';
elseif phase == 1 && pm==0 && strcmp(cont,'SU75vsSU25vsSW75vsSW25_taste')==1
   contSel= 'con_0009';
elseif phase == 1 && pm==0 && strcmp(cont,'certain_vs_uncertain_taste')==1
   contSel= 'con_0010';
elseif phase == 1 && pm==0 && strcmp(cont,'likely_vs_notlikely_taste')==1
   contSel= 'con_0011';
elseif phase == 1 && pm==0 && strcmp(cont,'SU_taste')==1
   contSel= 'con_0012';
elseif phase == 1 && pm==0 && strcmp(cont,'SW_taste')==1
   contSel= 'con_0013';
elseif phase == 1 && pm==0 && strcmp(cont,'SUvsSW_taste')==1
   contSel= 'con_0014';
elseif phase == 1 && pm==0 && strcmp(cont,'SU50vsSW50_taste')==1
   contSel= 'con_0015';
elseif phase == 1 && pm==0 && strcmp(cont,'Interaction')==1
   contSel= 'con_0016';
elseif phase == 1 && pm==0 && strcmp(cont,'exp_vs_unexp_SW')==1
   contSel= 'con_0017';
elseif phase == 1 && pm==0 && strcmp(cont,'exp_vs_unexp_SU')==1
   contSel= 'con_0018';
   
% phase=1 / pm=1 (taste) || pm=2 (thinking):
% % elseif phase == 1 && pm==1 || pm==2 && strcmp(cont,'SU75vsSU25cue')==1
% %    contSel= 'con_0001';
% % elseif phase == 1 && pm==1|| pm==2 && strcmp(cont,'50vs7525cue')==1
% %    contSel= 'con_0002';
elseif phase == 1 && pm==1|| pm==2 && strcmp(cont,'SUvsSW_taste')==1
   contSel= 'con_0003';
elseif phase == 1 && pm==1|| pm==2 && strcmp(cont,'SUconf')==1
   contSel= 'con_0004';
elseif phase == 1 && pm==1 || pm==2 && strcmp(cont,'SWconf')==1
   contSel= 'con_0005';
elseif phase == 1 && pm==1 || pm==2 && strcmp(cont,'average_conf')==1
   contSel= 'con_0006';
elseif phase == 1 && pm==1 || pm==2 && strcmp(cont,'SUvsSWconf')==1
   contSel= 'con_0007';
   
% phase=2 / pm=0:
elseif phase == 2 && pm==0 && strcmp(cont,'SUandSWcue')==1
   contSel= 'con_0001';
elseif phase == 2 && pm==0 && strcmp(cont,'SUvsNcue')==1
   contSel= 'con_0002';
elseif phase == 2 && pm==0 && strcmp(cont,'SWvsNcue')==1
   contSel= 'con_0003';
elseif phase == 2 && pm==0 && strcmp(cont,'SUtaste')==1
   contSel= 'con_0004';
elseif phase == 2 && pm==0 && strcmp(cont,'SWtaste')==1
   contSel= 'con_0005';
elseif phase == 2 && pm==0 && strcmp(cont,'exp_vs_unexp_SU')==1
   contSel= 'con_0006';
elseif phase == 2 && pm==0 && strcmp(cont,'exp_vs_unexp_SW')==1
   contSel= 'con_0007';
elseif phase == 2 && pm==0 && strcmp(cont,'exp')==1
   contSel= 'con_0008';
elseif phase == 2 && pm==0 && strcmp(cont,'unexp')==1
   contSel= 'con_0009';
elseif phase == 2 && pm==0 && strcmp(cont,'SUvsSWtaste')==1
   contSel= 'con_0010';
elseif phase == 2 && pm==0 && strcmp(cont,'exp_vs_unexp')==1
   contSel= 'con_0011';
elseif phase == 2 && pm==0 && strcmp(cont,'SUvsN')==1
   contSel= 'con_0012';
elseif phase == 2 && pm==0 && strcmp(cont,'SWvsN')==1
   contSel= 'con_0013';
elseif phase == 2 && pm==0 && strcmp(cont,'SUexp_vs_N')==1
   contSel= 'con_0014';
elseif phase == 2 && pm==0 && strcmp(cont,'SWexp_vs_N')==1
   contSel= 'con_0015';
elseif phase == 2 && pm==0 && strcmp(cont,'SUexp_vs_SWexp')==1
   contSel= 'con_0016';
elseif phase == 2 && pm==0 && strcmp(cont,'SUunexp_vs_SWunexp')==1
   contSel= 'con_0017';
elseif phase == 2 && pm==0 && strcmp(cont,'SUvsSWcue')==1
   contSel= 'con_0018';
elseif phase == 2 && pm==0 && strcmp(cont,'Interaction')==1
   contSel= 'con_0019';   
   
% phase=2 / pm=1 :
% % elseif phase == 2 && pm==12 && strcmp(cont,'SUandSWcue')==1
% %    contSel= 'con_0001';
% % elseif phase == 2 && pm==1 && strcmp(cont,'SUvsNcue')==1
% %    contSel= 'con_0002';
% % elseif phase == 2 && pm==1 && strcmp(cont,'SWvsNcue')==1
% %    contSel= 'con_0003';
elseif phase == 2 && pm==1 && strcmp(cont,'Pleas_taste')==1
   contSel= 'con_0004';
   
% phase=2 / pm=2:
% % elseif phase == 2 && pm==2 && strcmp(cont,'SUandSWcue')==1
% %    contSel= 'con_0001';
% % elseif phase == 2 && pm==2 && strcmp(cont,'SUvsNcue')==1
% %    contSel= 'con_0002';
% % elseif phase == 2 && pm==2 && strcmp(cont,'SWvsNcue')==1
% %    contSel= 'con_0003';
elseif phase == 2 && pm==2 && strcmp(cont,'Pleas_SUexp')==1
   contSel= 'con_0004';
elseif phase == 2 && pm==2 && strcmp(cont,'Pleas_SUunexp')==1
   contSel= 'con_0005';
elseif phase == 2 && pm==2 && strcmp(cont,'Pleas_SWexp')==1
   contSel= 'con_0006';
elseif phase == 2 && pm==2 && strcmp(cont,'Pleas_SWunexp')==1
   contSel= 'con_0007';
   
% phase=2 / pm=3   :
% % elseif phase == 2 && pm==3 && strcmp(cont,'SUandSWcue')==1
% %    contSel= 'con_0001';
% % elseif phase == 2 && pm==3 && strcmp(cont,'SUvsNcue')==1
% %    contSel= 'con_0002';
% % elseif phase == 2 && pm==3 && strcmp(cont,'SWvsNcue')==1
% %    contSel= 'con_0003';
elseif phase == 2 && pm==3 && strcmp(cont,'Pleas_whenSUcue')==1
   contSel= 'con_0004';
elseif phase == 2 && pm==3 && strcmp(cont,'Pleas_whenSWcue')==1
   contSel= 'con_0005';
end 

%% Upload contrasts
scandir = '/Users/elenamainetto/Documents/MATLAB/SUSW/MRI_data/'; % where the data are
files= cell(length(subj),1);  % prepare an empty cell

for i=1:length(subj) % upload scans
    files{i}= [scandir,num2str(subj(i)),'/PH',num2str(phase),'/Phase',num2str(phase),'_hpf128_der0_rp1_pm',num2str(pm),'/',contSel,'.nii,1'];
end
%% Analysis SPM
% factorial design
matlabbatch{1}.spm.stats.factorial_design.dir = {secondlvldir}; % where to save the analyses
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = files; % contrast to be used

matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {}); % no covariate

% matlabbatch{1}.spm.stats.factorial_design.cov.c = [1          % covaiate exemple
%                                                    5];
% matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'detection sensitivity';
% matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
% matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;

matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
% model estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
% contrast manager
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = cont; % es: 'positive'
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

%% save and run jobfile
save ([secondlvldir,'/jobfile_',cont,'_PH',num2str(phase),'_hpf128_der0_rp1_pm',num2str(pm),'.mat'],'matlabbatch'); % check
spm_jobman('run',matlabbatch);

end
%% Bits of code
% matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {
%                                                           '/Users/elenamainetto/Documents/MATLAB/SUSW/MRI_data/',num2str(subj(1)),'/PH',num2str(phase),'/Phase',num2str(phase),'_hpf128_der0_rp1_pm',num2str(pm),'/con_0012.nii,1'
%                                                           '/Users/elenamainetto/Documents/MATLAB/SUSW/MRI_data/',num2str(subj(2)),'/PH',num2str(phase),'/Phase',num2str(phase),'_hpf128_der0_rp1_pm',num2str(pm),'/con_0012.nii,1'
%                                                           };