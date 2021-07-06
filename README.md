# Demo singularity container for Matlab plus FSL

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
Contrariwise, all the Matlab parts could be removed to end up with an FSL-only
container.

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
it's probably explained in the Singularity file or the example code.


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
beginning and end. The bit at the beginning allows the executable to run during 
the container build, without actually doing anything - this is needed to extract
the CTF archive into the container at the only time the container is writeable
(h/t https://twitter.com/annash128 for figuring that one out). The bit at the 
end exits matlab when the function is finished. Without it, the running Matlab 
process won't release execution back to the calling script when it's done.

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

All of the below procedures could be done in the matlab part, if desired,
instead of in shell script. If so, parsing inputs should be done following the
example in `matlab/src/matlab_entrypoint.m`. But it's often easier to move
files, create the QA PDF, etc using shell script and FSL. So that's what we are 
doing in this example. All this code is in the `src` directory.

All the shell scripts called from `src/pipeline_entrypoint.sh` "know" the 
environment variables that are exported there. This is a very convenient way to
pass along the input arguments, although it isn't entirely transparent, because
there's no hint in the shell scripts where the variables' values are coming from
unless we explain it in the comments.

### Main entrypoint

This is `src/pipeline_entrypoint.sh`. It uses bash to parse the command line
inputs and export them to environment variables so they're accessible. Then it
calls the primary shell script `src/pipeline_main.sh` which in turn calls
everything else. The main script is run in xvfb to provide a virtual display,
often needed by matlab and required for fsleyes.

### Copy inputs

We copy input files to the output/working directory so we don't mess them up. 
This also is an opportunity to rename them to something consistent. It's very
convenient to hard-code the filenames so we don't have to store and manipulate
filenames in environment variables or the like. Also, this makes it easy to
produce output files with consistent names - outputs of one pipeline may serve
as inputs to another, and it's much easier to manage this if filenames are the
same for every run, or at least consistent.

We generally assume the output directory starts out empty and will not be 
interfered with by any other processes - this is true for XNAT/DAX, but 
important to be aware of in other contexts.

### Preprocessing

For this example, there is no preprocessing before the matlab part. But initial 
FSL steps or similar could be put here: `src/preprocessing.sh`.

### Postprocessing

There isn't any postprocessing for this example either, but there could be: 
`src/postprocessing.sh`.

### PDF creation

All assessors on VUIIS XNAT require a PDF QA report of some sort. For this
example, a display of the segmented ROIs overlaid on the T1 is created using
fsleyes and ImageMagick, `src/make_pdf.sh`.

PDF creation can be done in Matlab instead. It's hard to make these look good. 
An example with some tricks, including a `.fig` file painstakingly made with 
Matlab's GUIDE, is
https://github.com/baxpr/connprep/blob/855dadc/src/connectivity_filter.m#L271
A way to show slices of functional images with a nice red/blue colormap is 
https://github.com/baxpr/connprep/blob/855dadc/src/make_network_maps.m

### Finalizing the output

All Niftis must be compressed for storage on XNAT, and outputs can be organized
in an easily understandable way: `src/finalize.sh`.


## Documentation

Write an informative README - so tedious, yet so helpful. Include the 
appropriate citations for all the methods and software you have used. Even 
essentially write the methods section for a paper that uses the pipeline. Here's
an excellent example: https://github.com/MASILab/PreQual

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

Good practice: before you build, create a release on github (if using github) or
at least tag the commit you are about to build. Give the container a versioned 
name like `demo-singularity-matlab-fsl_v1.0.0.simg` that matches the repository 
name and release version/tag.

External binaries such as Matlab Runtime and FSL can be included by copying 
local copies into the container in the Singularity file's `%files` section. This 
tends to be a little faster when multiple builds are needed during debugging,
or necessary for files that are not available to download, and this is what's 
being done in the example Singularity file. Alternatively, binaries or install
files can be downloaded from their source at build time - there are some 
commented-out sections in the Singularity file showing how that is done. (Thanks 
https://github.com/praitayini for exploring this in detail)


## Running the container

See `test_singularity_container.sh` for an example run command and some
important info.

### Inputs

Paths to files are relative to the container.

    --t1_niigz        A T1 image
    --seg_niigz       Its corresponding segmentation from e.g. slant pipeline
    --diameter_mm     Diameter of the hole to zero out, in mm (default 30)
    
    --project         Labels from XNAT, used only to annotate the QA PDF
    --subject         (default UNK_*)
    --session
    --scan
    
    --out_dir         Where outputs will be stored (default /OUTPUTS)

### Outputs

    PDF/holed_image.pdf           QA report
    HOLED_T1/holed_t1.nii.gz      T1 image with a hole in it
    HOLED_SEG/holed_seg.nii.gz    Segmentation with a hole in it


## Running the container with DAX

With a suitable configuration file, DAX (https://github.com/VUIIS/dax) can run this on a cluster.

Instructions are here: https://dax.readthedocs.io/en/latest/processors.html

An example is here: 
https://github.com/VUIIS/dax_yaml_processor_examples/blob/master/demo-matfsl_v1.0.0_processor.yaml

