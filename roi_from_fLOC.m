% initialize
clearvars; close all; clc;
Set_Up;

get_group_mask;


% define masks
mask_names  =   { 'EBA', 'LOC' };
mask_idx    =   {   1,    1};
w_source    =   { 'body_parcels', 'object_parcels' };
sides = {'l', 'r'};
% set directories
TemplateDir      =   fullfile(homeDir, 'Results', 'Masks', 'Templates');
mni_mask_p  =   fullfile(TemplateDir, 'Group_MNI_mask.nii');



for themask = 1:length(mask_names)
    %% first get the voxels in the roi from broadmann/aal
    
    % set info for current mask
    for theside = 1:length(sides)
        filename    =   sprintf( '%s%s.hdr', sides{theside},mask_names{themask});
        indices     =   mask_idx{ themask};
        roi_path    =   fullfile( TemplateDir, w_source{themask}, filename);
        
%      % convert hdr to nii   
%          [pth, nm] = spm_fileparts(roi_path);
%       hdr = spm_vol(roi_path);
%     img = spm_read_vols(hdr);
%     hdr.fname = fullfile(pth, [nm, '.nii']); 
%     spm_write_vol(hdr,img);
    
    
        % load a template
        roi_hdr = spm_vol(        roi_path);
        mask_vol = spm_read_vols(  roi_hdr);
        
        % retrieve indices
        area_indices{theside}            =   ismember( mask_vol, indices);
        area_vol                =   zeros( size( mask_vol));
        area_vol(area_indices{theside}) =   1;
        
        % set mask properties
        area_vol    =   uint8( area_vol);
        roi_hdr.dt    =   [2 0];
        
        % change header, save file
        filename    =   sprintf( '%s%s_mask.nii', sides{theside},mask_names{themask});
        roi_hdr.fname = fullfile(TemplateDir, filename);
        spm_write_vol( roi_hdr, area_vol);
        
        
        %% realign with mni
        % set source (anatomical mask for intersecting roi)
        matlabbatch{1}.spm.spatial.coreg.estwrite.source{1}         =  roi_hdr.fname;
        
        % set reference (subject/mni whole brain mask)
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref{1}            =   mni_mask_p; % the group level mni
        
        % set prefix r
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix   =   'realigned_';
        spm_jobman( 'run', matlabbatch);
    end
    
    %%combine hemispheres into one mask
    combined_vol                =   zeros( size( mask_vol));
    combined_vol(area_indices{1}) =   1;
    combined_vol(area_indices{2}) =   1;
    combined_vol = uint8(combined_vol);
    roi_hdr.fname = fullfile(TemplateDir, [mask_names{themask} '_mask.nii']);
    spm_write_vol( roi_hdr, combined_vol);
    
    % set source (anatomical mask for intersecting roi)
    matlabbatch{1}.spm.spatial.coreg.estwrite.source{1}         =  roi_hdr.fname;
    
    % set reference (subject/mni whole brain mask)
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref{1}            =   mni_mask_p; % the group level mni
    
    % set prefix r
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix   =   'realigned_';
    spm_jobman( 'run', matlabbatch);
    
end
