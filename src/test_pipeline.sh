#!/usr/bin/env bash
#
# Test the pipeline outside the container. Be sure the src directory is in the
# path.

# Just the PDF creation part
export label_info="TEST LABEL"
export out_dir=../OUTPUTS
make_pdf.sh
exit 0

# The entire thing
pipeline_entrypoint.sh \
    --t1_niigz ../INPUTS/t1.nii.gz \
    --seg_niigz ../INPUTS/seg.nii.gz \
    --diameter_mm 30 \
    --out_dir ../OUTPUTS
