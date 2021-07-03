#!/usr/bin/env bash
#
# Postprocessing, done after the other parts of the pipeline are run.
#
# For this example, all we do is move the output files around in a way that's
# friendly to XNAT/DAX.

echo Running $(basename "${BASH_SOURCE}")

# The primary output is the image with the hole in it, which we'll intend to
# store in an XNAT resource HOLED_IMAGE. Organizing it this way makes the setup
# in the dax processor yaml very simple.
mkdir "${out_dir}"/HOLED_IMAGE
mv "${out_dir}"/image.nii.gz "${out_dir}"/HOLED_IMAGE

# And similarly for the PDF
mkdir "${out_dir}"/PDF
mv "${out_dir}"/holed_image.pdf "${out_dir}"/PDF

