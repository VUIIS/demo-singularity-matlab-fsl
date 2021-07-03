# Demo singularity container for Matlab

This example container takes a Nifti image as input, zeroes out a hole in it of
the specified diameter, and saves the result to a new Nifti file.

This is one way to organize a Matlab-based Singularity container - 
perhaps most easily conceived of as a series of wrappers around the main 
codebase:

    Singularity container
    |   X11 wrapper
    |   |   Primary entrypoint (shell script)
    |   |   |   Shell script preprocessing
    |   |   |   Matlab processing (compiled)
    |   |   |   |   Matlab entrypoint
    |   |   |   |       Matlab main function
    |   |   |   \           Matlab sub-functions / codebase
    \   \   \   Shell script postprocessing

Dependencies in terms of the actual files:

    Singularity
        src/pipeline_entrypoint.sh
            src/pipeline_main.sh
                src/preprocessing.sh
                matlab/bin/run_matlab_entrypoint.sh
                    matlab/bin/matlab_entrypoint
                    matlab/compile_matlab.sh             \  Used for compilation,
                        matlab/src/matlab_entrypoint.m   |  but not at container
                            matlab/src/matlab_main.m     |  runtime
                                matlab/src/*             /
                src/postprocessing.sh
                

The process of putting it together is described below. The scripts and code in
this repository are extensively commented, so if something isn't clear here,
it's probably explained in the example code.

## Matlab part

### Write the basic Matlab code

Write Matlab code that does what's needed. Put it in `matlab/src`.

A popular toolbox for reading and writing Nifti files that's available on Matlab
Central has a lot of insidious bugs and is not being maintained. Matlab's own 
functions for Nifti files are quite limited. Here is an alternative, which is
used in this example: 
https://github.com/VUIIS/spm_readwrite_nii

### Write the Matlab entrypoint

`matlab/src/matlab_entrypoint.m` exists to take command line arguments, parse 
them, and call the main code. A convenient way to set things up is to write a 
main function that takes a structure as its sole input, with the structure
containing whatever inputs are needed. See `matlab/src/matlab_main.m` for an 
example of this.

### Test the Matlab entrypoint

The script `matlab/src/test_matlab_entrypoint.m` is an example of how to do this.

### Compile the Matlab code

`matlab/compile_matlab.sh` shows how. Many compiled executables are likely to be
too large to store on github. Git LFS may be a solution.
https://docs.github.com/en/github/managing-large-files/working-with-large-files

### Test the compiled Matlab code

`matlab/test_compiled_matlab.sh`


