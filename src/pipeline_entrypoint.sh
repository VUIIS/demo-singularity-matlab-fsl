#!/usr/bin/env bash
#
# Primary entrypoint for our pipeline. This just parses the command line 
# arguments, exporting them in environment variables for easy access
# by other shell scripts later. Then it calls the rest of the pipeline.
#
# Example usage:
# 
# pipeline_entrypoint.sh --image_niigz /path/to/image.nii.gz --diameter_mm 30

# This statement at the top of every bash script is helpful for debugging
echo Running $(basename "${BASH_SOURCE}")

# Initialize defaults for any input parameters where that seems useful
export diameter_mm=30
export project=TESTPROJ
export subject=TESTSUBJ
export session=TESTSESS
export scan=TESTSCAN
export out_dir=/OUTPUTS

# Parse input options
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        
        --image_niigz)
            # Our example code takes a single 3D nifti image as input. This
            # is expected to be the fully qualified path and filename.
            export image_niigz="$2"; shift; shift ;;

        --diameter_mm)
            # Diameter in mm of the hole we will punch in the image
            export diameter_mm="$2"; shift; shift ;;

        --project)
            # Along with subject, session, scan, labels from XNAT that we will
            # use to label the QA PDF
            export project="$2"; shift; shift ;;
        --subject)
            export subject="$2"; shift; shift ;;
        --session)
            export session="$2"; shift; shift ;;
        --scan)
            export scan="$2"; shift; shift ;;

        --out_dir)
            # Where outputs will be stored. Also the working directory
            export out_dir="$2"; shift; shift ;;

        *)
            echo "Input ${1} not recognized"
            shift ;;

    esac
done


# Now that we have all the inputs stored in environment variables, call the
# main pipeline. We run it in xvfb so that we have a virtual display available.
xvfb-run -n $(($$ + 99)) -s '-screen 0 1600x1200x24 -ac +extension GLX' \
    pipeline_main.sh
