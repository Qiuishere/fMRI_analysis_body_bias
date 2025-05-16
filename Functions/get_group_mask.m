% get the voxels of everyone




for thesub = 1:length(Subs)
    subId = ['sub-' sprintf('%03d', Subs(thesub))];
    Dirs = get_directories_for_thesub(Subs(thesub));
    file = dir(fullfile(Dirs.betas, 'Test', 'mask.nii'));
        
    aa = spm_read_vols(spm_vol(fullfile(file.folder,file.name)),1);
    id(:,:,:,thesub) = isnan(aa);    
end

ave = mean(id,4);% voxels with nan in everyone will give a mean of 1
vol  =   ones( size(ave));
vol(ave ==1)   =   nan;

% write the roi into a nii
roi = spm_vol(fullfile(file.folder,file.name));
roi.fname = fullfile('Results/Masks', 'Templates',  'Group_MNI_mask.nii');
spm_write_vol( roi, vol);