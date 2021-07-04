# Demo singularity container for Matlab

This example container takes a Nifti image as input, zeroes out a hole in it of
the specified diameter, and saves the result to a new Nifti file. Quick,
pointless, and easy to tell whether it worked right.

This is one way to organize a Matlab-based Singularity container - 
perhaps most easily conceived of as a series of wrappers around the main 
codebase. Done this way, it's fairly easy to work on each piece in isolation,
problem-solving from the inside out.

This container also includes an installation of FSL, which has a lot of handy
tools including fsleyes to make the QA PDF. The FSL parts could be removed from
the Singularity file if FSL isn't used, to end up with a smaller container.

    Singularity container
    |   Primary entrypoint (shell script)
    |   |   X11 wrapper
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
                src/copy_inputs.sh
                src/preprocessing.sh
                matlab/bin/run_matlab_entrypoint.sh
                    matlab/bin/matlab_entrypoint
                        / matlab/src/matlab_entrypoint.m \  Used for compilation,
                        |     matlab/src/matlab_main.m   |  but not at container
                        \         matlab/src/*           /  runtime
                src/postprocessing.sh
                src/make_pdf.sh
                src/finalize.sh

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

Couple of things to note in the entrypoint code are the quit/exit sections at
beginning and end. The one at the beginning allows the executable to run during 
the container build, without actually doing anything - this is needed to extract
the CTF archive into the container at the only time the container is writeable.
The one at the end exits matlab when the function is finished. Without it, the 
running Matlab process will stop, but not release execution back to the calling 
script.

### Test the Matlab entrypoint

The script `matlab/src/test_matlab_entrypoint.m` is an example of how to do
this. The appropriate Matlab must be installed on the testing computer.

### Compile the Matlab code

`matlab/compile_matlab.sh` shows how. Many compiled executables are likely to be
too large to store on github. Git LFS may be a solution.
https://docs.github.com/en/github/managing-large-files/working-with-large-files

### Test the compiled Matlab code

`matlab/test_compiled_matlab.sh`. The appropriate Matlab Runtime must be
installed on the testing computer.


## Shell script part

All of this could be done in the matlab part, if desired. If so, parsing inputs
should be done following the example in `matlab/src/matlab_entrypoint.m`. But 
it's often easier to move files, create the QA PDF, etc using shell script and 
FSL. So that's what we are doing in this example. All this code is in the `src`
directory.

### Main entrypoint

This is `src/pipeline_entrypoint.sh`. It uses bash to parse the command line
inputs and export them to environment variables so they're accessible. Then it
calls the primary main shell script `src/pipeline_main.sh` which in turn calls
everything else. The main script is run in xvfb to provide a virtual display,
often needed by matlab and required for fsleyes.

### Copy inputs

We copy input files to the output/working directory so we don't mess them up. We
generally assume the output directory starts out empty and will not be 
interfered with by any other processes - certainly this is true for XNAT/DAX.

### Preprocessing

For this example, there is no preprocessing before the matlab part. But initial 
FSL steps or similar could be put here: `src/preprocessing.sh`.

### Postprocessing

There isn't any postprocessing for this example, but any sort of non-matlab 
work needed after the matlab part is done could be performed here: 
`src/postprocessing.sh`.

### PDF creation

All assessors on VUIIS XNAT require a PDF QA report of some sort. For this
example, a display of the segmented ROIs overlaid on the T1 is created using
fsleyes and ImageMagick, `src/make_pdf.sh`.

### Finalizing the output

All Niftis must be compressed for storage on XNAT, and outputs can be organized
in an easily understandable way: `src/finalize.sh`.


## Documentation

Write an informative README - so tedious, yet so helpful. Here's an excellent 
example: https://github.com/MASILab/PreQual

Alternatively, git-ify some documentation like this:
https://github.com/VUIIS/dax/tree/main/docs

to get something like this:
https://dax.readthedocs.io/en/latest/


## Building the container

Be sure the Matlab code is newly compiled, see above. You can run 
`matlab/check_for_compilation.sh` first to make sure there's no source code
newer than the compiled executable.

Then from the root directory of the working copy of the repo, run

    singularity build <container_name>.simg Singularity

Good practice: before you build, create a release on github (if using github).
Be sure that tag is checked out in your working copy of the repo. Give the 
container a versioned name like `demo-singularity-matlab_v1.0.0.simg` that 
matches the repository name and release version.

External binaries such as Matlab Runtime and FSL can be included by copying 
local copies into the container in the Singularity file's `%files` section. This 
tends to be a little faster when multiple builds are needed during debugging,
and this is what's being done in the example Singularity file. Alternatively, 
these can be downloaded from their source at build time - there are some 
commented-out sections in the Singularity file showing how that is done.


## Running the container

See `test_singularity_container.sh` for an example run command and some
important info.
