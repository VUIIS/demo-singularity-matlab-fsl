function outimg_nii = matlab_main(inp)

% This example pipeline loads the input image, puts a hole in the middle,
% and writes it back out. This main function contains the entire pipeline
% for this simple example, but for something more complex we probably want
% to break it up into more functions/files.
%
% Nifti read/write is handled this way:
% https://github.com/VUIIS/spm_readwrite_nii

% Read the image
V = spm_vol(inp.image_niigz);
if numel(V)>1
	error('Expected a 3D Nifti image');
end
[Y,XYZ] = spm_read_vols(V);

% Reshape to 1D for easier operation (e.g. the columns of Yr now match the
% columns of the voxel mm coords in XYZ)
origsize = size(Y);
Yr = Y(:)';

% Find the center of the image in mm
ctr = (max(XYZ,2)-min(XYZ,2)) / 2;

% Compute the squared distance from center for each voxel
dst = (XYZ-ctr).^2;

% Find voxels within the specified distance and zero them out
inds = dst <= inp.diameter_mm;
Yr(inds) = 0;

% Reshape to the original size
Yout = reshape(Yr',origsize);

% Write to a file in the specified output directory. We are hard-coding the
% output filename here - simple and convenient, but we could do something
% more versatile if we needed to. The output filename is passed as a return
% value in case we want it.
Vout = V;
outimg_nii = fullfile(inp.out_dir,'holed_image.nii');
Vout.fname = outimg_nii;
spm_write_vol(Vout,Yout);


