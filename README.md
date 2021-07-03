# Demo singularity container for Matlab

Set up with shell wrapper so prep and finalize/PDF code can be shell script, which is easier.

    Singularity
    src/
        pipeline_entrypoint.sh
        pipeline_main.sh
    matlab/
        src/
            matlab_entrypoint.m
            matlab_main.m
        build/
        bin/


## Reading and writing Nifti files in Matlab

A popular toolbox for reading and writing Nifti files that's available on Matlab
Central has a lot of insidious bugs, is not being maintained, and should not be 
used. Matlab's own functions for Nifti files are quite limited. Here is an
alternative: https://github.com/VUIIS/spm_readwrite_nii

