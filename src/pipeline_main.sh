#!/usr/bin/env bash
#
# Main pipeline. We'll call the matlab part from here. The benefit of wrapping
# everything in a shell script like this is that we can more easily use shell
# commands to move files around, use FSL for some pre- or post-processing, and 
# use fsleyes after the matlab has finished to create a QA PDF.
