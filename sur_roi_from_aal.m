%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create anatomical masks from AAL Atlas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% settings and preparation

% initialize
clearvars; close all; clc;
Set_Up;

get_group_mask;


% define masks 
 mask_names  =   {'EVC',            'V1',  'V2',         'visual_cortex',           'occipital',                'frontal', 'parietal', 'temporal', 'cerebellum'};
 mask_idx    =   { 17:18        ,   17,      18 , [17:22,  28:30,  34 : 36, 37:39, 7]  ,[19:23,27,30,37:39,41:42],  1:32,      57:70,      79:90,      91:116};
 w_source    =   [ 1            ,   1,       1,                    1,                       2,         2,          2,          2,       2                ];


 
% set directories
TemplateDir      =   fullfile(homeDir, 'Results', 'Masks', 'Templates');
m_paths{1}  =   fullfile( TemplateDir, 'brodmann.nii');
m_paths{2}  =   fullfile( TemplateDir, 'aal.nii');


% coregister to MNI space
reslice2mni       =   1;  % set to 1 to reslice to MNI space
mni_mask_p  =   fullfile(TemplateDir, 'Group_MNI_mask.nii'); 



%% start creating masks

% iterate over masks
for themask = 1:length(mask_names)
        %% first get the voxels in the roi from broadmann/aal
    % set info for current mask
    fname       =   sprintf( '%s_mask.nii', mask_names{themask});
    indices     =   mask_idx{ themask};
    roi_path      =   m_paths{ w_source(themask)};
    if strfind(roi_path,'parcels')
        roi_path = fullfile(roi_path,[mask_names{themask} '.hdr']);
    end
    
    % load AAL
    roi_hdr = spm_vol(        roi_path);    
    mask_vol = spm_read_vols(  roi_hdr);     
    
    % retrieve indices
    area_indices            =   ismember( mask_vol, indices);
    area_vol                =   zeros( size( mask_vol));
    area_vol( area_indices) =   1;
    
    % set mask properties
    area_vol    =   uint8( area_vol);
    roi_hdr.dt    =   [2 0];
    
    % change header, save file
    roi_hdr.fname = fullfile(TemplateDir, fname);
    spm_write_vol( roi_hdr, area_vol);
    
    
    %% reslice to project space (mni)
    if reslice2mni
        
        
        % create a temporary copy of atlas for reslicing
        [p,f]   =   fileparts( roi_path);
        f2      =   sprintf( '%s2.nii', f);
        t_path  =   fullfile( p, f2);
        copyfile( roi_path, t_path);
        
        % set source (anatomical mask for intersecting roi)
        matlabbatch{1}.spm.spatial.coreg.estwrite.source{1}         =   t_path; % broadmann
        matlabbatch{1}.spm.spatial.coreg.estwrite.other{1}          =   roi_hdr.fname;
        
        % set reference (subject/mni whole brain mask)
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref{1}            =   mni_mask_p; % the group level mni 
        
        % set prefix r
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix   =   'realigned_';
        spm_jobman( 'run', matlabbatch);

  
        % delete intermidiate steps 
        delete( t_path);
    end
end

cd(homeDir)
% 1 Precentral_L
% 2 Precentral_R
% 3 Frontal_Sup_L
% 4 Frontal_Sup_R
% 5 Frontal_Sup_Orb_L
% 6 Frontal_Sup_Orb_R
% 7 Frontal_Mid_L
% 8 Frontal_Mid_R
% 9 Frontal_Mid_Orb_L
% 10 Frontal_Mid_Orb_R
% 11 Frontal_Inf_Oper_L
% 12 Frontal_Inf_Oper_R
% 13 Frontal_Inf_Tri_L
% 14 Frontal_Inf_Tri_R
% 15 Frontal_Inf_Orb_L
% 16 Frontal_Inf_Orb_R
% 17 Rolandic_Oper_L
% 18 Rolandic_Oper_R
% 19 Supp_Motor_Area_L
% 20 Supp_Motor_Area_R
% 21 Olfactory_L
% 22 Olfactory_R
% 23 Frontal_Sup_Medial_L
% 24 Frontal_Sup_Medial_R
% 25 Frontal_Mid_Orb_L
% 26 Frontal_Mid_Orb_R
% 27 Rectus_L
% 28 Rectus_R
% 29 Insula_L
% 30 Insula_R
% 31 Cingulum_Ant_L
% 32 Cingulum_Ant_R

% 33 Cingulum_Mid_L
% 34 Cingulum_Mid_R
% 35 Cingulum_Post_L
% 36 Cingulum_Post_R
% 37 Hippocampus_L
% 38 Hippocampus_R
% 39 ParaHippocampal_L      *
% 40 ParaHippocampal_R      *
% 41 Amygdala_L
% 42 Amygdala_R

% 43 Calcarine_L
% 44 Calcarine_R
% 45 Cuneus_L
% 46 Cuneus_R
% 47 Lingual_L
% 48 Lingual_R
% 49 Occipital_Sup_L
% 50 Occipital_Sup_R
% 51 Occipital_Mid_L
% 52 Occipital_Mid_R
% 53 Occipital_Inf_L
% 54 Occipital_Inf_R
% 55 Fusiform_L
% 56 Fusiform_R

% 57 Postcentral_L
% 58 Postcentral_R
% 59 Parietal_Sup_L
% 60 Parietal_Sup_R
% 61 Parietal_Inf_L
% 62 Parietal_Inf_R
% 63 SupraMarginal_L
% 64 SupraMarginal_R
% 65 Angular_L
% 66 Angular_R
% 67 Precuneus_L
% 68 Precuneus_R
% 69 Paracentral_Lobule_L
% 70 Paracentral_Lobule_R

% 71 Caudate_L
% 72 Caudate_R
% 73 Putamen_L
% 74 Putamen_R
% 75 Pallidum_L
% 76 Pallidum_R
% 77 Thalamus_L
% 78 Thalamus_R

% 79 Heschl_L
% 80 Heschl_R
% 81 Temporal_Sup_L
% 82 Temporal_Sup_R
% 83 Temporal_Pole_Sup_L
% 84 Temporal_Pole_Sup_R
% 85 Temporal_Mid_L
% 86 Temporal_Mid_R
% 87 Temporal_Pole_Mid_L
% 88 Temporal_Pole_Mid_R
% 89 Temporal_Inf_L
% 90 Temporal_Inf_R

% 91 Cerebelum_Crus1_L
% 92 Cerebelum_Crus1_R
% 93 Cerebelum_Crus2_L
% 94 Cerebelum_Crus2_R
% 95 Cerebelum_3_L
% 96 Cerebelum_3_R
% 97 Cerebelum_4_5_L
% 98 Cerebelum_4_5_R
% 99 Cerebelum_6_L
% 100 Cerebelum_6_R
% 101 Cerebelum_7b_L
% 102 Cerebelum_7b_R
% 103 Cerebelum_8_L
% 104 Cerebelum_8_R
% 105 Cerebelum_9_L
% 106 Cerebelum_9_R
% 107 Cerebelum_10_L
% 108 Cerebelum_10_R

% 109 Vermis_1_2
% 110 Vermis_3
% 111 Vermis_4_5
% 112 Vermis_6
% 113 Vermis_7
% 114 Vermis_8
% 115 Vermis_9
% 116 Vermis_10