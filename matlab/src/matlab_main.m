function [outt1_nii,outseg_nii] = matlab_main(inp)

% This example pipeline loads the input images, puts a hole in the middle,
% and writes them back out. This main function contains the entire pipeline
% for this simple example, but for something more complex we probably want
% to break it up into more functions/files.
%
% See matlab_entrypoint.m for the list of inputs that are expected in inp.
%
% Nifti read/write is handled this way:
% https://github.com/VUIIS/spm_readwrite_nii

% Convert the numerical argument from a string
diameter_mm = str2double(inp.diameter_mm);

% Read the images
Vt1 = spm_vol(inp.t1_niigz);
if numel(Vt1)>1
	error('Expected a 3D Nifti image for the T1');
end
[Yt1,XYZ] = spm_read_vols(Vt1);

Vseg = spm_vol(inp.seg_niigz);
Yseg = spm_read_vols(Vseg);

% Verify that their geometry matches
if any( abs(Vt1.mat(:)-Vseg.mat(:)) > 1e-6 ) ...
		|| any( Vt1.dim~=Vseg.dim )
	error('Dimension or geometry mismatch between T1 and segmentation')
end

% Reshape to 1D for easier operation (e.g. the columns of Yr now match the
% columns of the voxel mm coords in XYZ)
origsize = size(Yt1);
Yt1r = Yt1(:)';
Ysegr = Yseg(:)';

% Find the center of the image in mm
ctr = (max(XYZ,[],2)-min(XYZ,[],2))/2 + min(XYZ,[],2);

% Compute the squared distance from center for each voxel
dst = sum((XYZ-ctr).^2);

% Find voxels within the specified distance and zero them out
inds = dst <= diameter_mm.^2;
fprintf('Zeroing out %d of %d voxels\n',sum(inds),numel(inds));
Yt1r(inds) = 0;
Ysegr(inds) = 0;

% Reshape to the original size
Yt1out = reshape(Yt1r',origsize);
Ysegout = reshape(Ysegr',origsize);

% Write to a file in the specified output directory. We are hard-coding the
% output filename here - simple and convenient, but we could do something
% more versatile if we needed to, e.g. take a specific filename for the
% output file as an input argument. The output filename is passed as a
% return value in case we want it.
Vt1out = Vt1;
outt1_nii = fullfile(inp.out_dir,'holed_t1.nii');
Vt1out.fname = outt1_nii;
spm_write_vol(Vt1out,Yt1out);

Vsegout = Vt1;
outseg_nii = fullfile(inp.out_dir,'holed_seg.nii');
Vsegout.fname = outseg_nii;
spm_write_vol(Vsegout,Ysegout);
