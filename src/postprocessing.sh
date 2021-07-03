#!/usr/bin/env bash
#
# Postprocessing, done after the other parts of the pipeline are run.
#
# For this example, all we do is gzip the output images (required for all
# Niftis on XNAT), and move the output files around in a way that's friendly to
# XNAT/DAX.

echo Running $(basename "${BASH_SOURCE}")

# gzip
gzip "${out_dir}"/holed_t1.nii
gzip "${out_dir}"/holed_seg.nii

# The primary outputs are the images with the hole in them, which we'll intend
# to store in an XNAT resources HOLED_<IMAGE>. Organizing it this way makes the
# output very clear and the setup in the dax processor yaml very simple.
mkdir "${out_dir}"/HOLED_T1
mv "${out_dir}"/holed_t1.nii.gz "${out_dir}"/HOLED_T1

mkdir "${out_dir}"/HOLED_SEG
mv "${out_dir}"/holed_seg.nii.gz "${out_dir}"/HOLED_SEG

# And similarly for the PDF
mkdir "${out_dir}"/PDF
mv "${out_dir}"/holed_image.pdf "${out_dir}"/PDF

