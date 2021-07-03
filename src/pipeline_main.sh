#!/usr/bin/env bash
#
# Main pipeline. We'll call the matlab part from here. The benefit of wrapping
# everything in a shell script like this is that we can more easily use shell
# commands to move files around, use FSL for some pre- or post-processing, and 
# use fsleyes after the matlab has finished to create a QA PDF.

echo Running $(basename "${BASH_SOURCE}")

# First, shell script based preprocessing
preprocessing.sh

# Then the matlab. It is written so that we must pass the inputs as command
# line arguments, although we could use matlab's getenv to pull them from the
# environment instead if desired.
run_matlab_entrypoint.sh "${MATLAB_ROOT}" \
    t1_niigz "${out_dir}"/t1.nii.gz \
    seg_niigz "${out_dir}"/seg.nii.gz \
    diameter_mm "${diameter_mm}" \
    project "${project}" \
    subject "${subject}" \
    session "${session}" \
    scan "${scan}" \
    out_dir "${out_dir}"

# Postprocessing
postprocessing.sh

# FSL based PDF creation
make_pdf.sh

# Finalize and organize outputs
finalize.sh
