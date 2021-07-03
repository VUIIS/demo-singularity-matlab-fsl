#!/usr/bin/env bash
#
# Preprocessing, done before the Matlab part of the pipeline is run. For this
# example, all we do is copy the input file to a working location. A note of 
# style: containers should probably not ever change the input files directly,
# but rather copy them and work on them (and perhaps clean up afterwards).

# Copy the input nifti to the working directory (out_dir) with a hard-coded
# filename. Hardcoding filenames like this makes programming a lot easier, and
# the loss of flexibility is usually not a problem for a containerized pipeline
# working in its own private directory.
cp "${image_niigz}" "${out_dir}"/image.nii.gz
