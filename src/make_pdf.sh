#!/usr/bin/env bash
#
# Use fsleyes to create a PDF QA report. This is entirely fidgety, but still
# is easier than doing it in Matlab.

echo Running $(basename "${BASH_SOURCE}")

# Initialize FSL
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}

# Some useful text to put on the PDF pages
thedate=$(date)
infostring="${project} ${subject} ${session} ${scan}"

# Work in output directory
cd ${out_dir}

# Binarize the segmentation and find its center of mass, as a starting point for
# slice placement in the visualization
fslmaths seg_niigz -bin mask
com=$(fslstats mask -c)
XYZ=(${com// / })

# Create an axial view of T1 with ROI overlay for a series of axial slices. 
# Offsets are specified in mm from the computed center of mass of the brain.
for sl in -40 -30 -20 -10 +0 +10 +20 +30 +40 +50 +60; do

    Z=$(echo "${XYZ[2]} + ${sl}" | bc -l)
    fsleyes render -of slice_${sl}.png \
        --scene ortho --worldLoc ${XYZ[0]} ${XYZ[1]} ${Z} \
        --layout horizontal --hideCursor --hideLabels --hidex --hidey \
        holed_t1 --overlayType volume \
        holed_seg --overlayType label --lut random_big --outline --outlineWidth 2

done

# Combine into single image using ImageMagick
montage -mode concatenate slice_*.png \
-tile 4x3 -quality 100 -background black -gravity center \
-border 20 -bordercolor black page1.png

# Resize and add text annotations. We choose a large but not ridiculous
# pixel size for the full page.
convert \
-size 2600x3365 xc:white \
-gravity center \( page1.png -resize 2400x \) -composite \
-gravity North -pointsize 48 -annotate +0+100 \
"Holed segmentation on holed T1" \
-gravity SouthEast -pointsize 48 -annotate +100+100 "${thedate}" \
-gravity NorthWest -pointsize 48 -annotate +100+200 "${infostring}" \
page1.png

# Convert to PDF
convert page1.png holed_image.pdf

# Clean up
rm page1.png mask.nii.gz slice_*.png