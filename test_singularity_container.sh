#!/usr/bin/env bash
#
# Test the built singularity container. Also serves as an example of how to run
# it in general.
#
# --cleanenv and --contain are used to avoid any conflicts with environment
# variables or filesystems on the host. Better to explicitly bind what's needed.
#
# Matlab uses the home directory for caching, so it's important to bind it
# somewhere safe where other running Matlab processes won't cause collisions in
# the cache. Temp space is also provided. These both need to be bound
# somewhere, not left to be in the container, as the container most likely
# won't have space and a confusing memory error or crash will be the result.

singularity run --cleanenv --contain \
    --home INPUTS \
    --bind INPUTS:/tmp \
    --bind INPUTS:/INPUTS \
    --bind OUTPUTS:/OUTPUTS \
    demo.simg \
    --t1_niigz /INPUTS/t1.nii.gz \
    --seg_niigz /INPUTS/seg.nii.gz \
    --diameter_mm 30 \
    --out_dir /OUTPUTS
