# Starting point for a container should be reasonably trustworthy, in this case
# an official base Ubuntu image from Docker https://hub.docker.com/_/ubuntu
Bootstrap: docker
From: ubuntu:20.04


%help
  Demo of a singularity container that runs a Matlab program.
  Info and usage: /opt/demo/README.md


%setup

  # Create an installation directory for the codebase. We can often finagle this
  # in the 'files' section and forgo the 'setup' section entirely, but it's 
  # clearer this way.
  mkdir -p "${SINGULARITY_ROOTFS}"/opt/demo


%files

  # Copy all the code into the container's installation directory. We do this in
  # specific pieces to avoid bulk copying any extra junk we might have floating
  # around in the local working copy repository. This Singularity recipe itself
  # is put in the container automatically during the build, at 
  # /.singularity.d/Singularity
  #
  # The Matlab source code is not actually used, because we'll run the compiled
  # version with the Matlab Runtime instead. But the source code will be in the
  # container for reference. Don't let these get out of sync, i.e. don't change
  # the Matlab source code and then forget to recompile it before building the
  # container.
  src                          /opt/demo
  matlab                       /opt/demo
  README.md                    /opt/demo

 
%labels
  Maintainer baxter.rogers@vanderbilt.edu


%post

  # Find the newest file in the matlab source code
  files=(/opt/demo/matlab/src/*) newest_src=${files[0]}
  for f in "${files[@]}"; do
    if [[ $f -nt $newest_src ]]; then
      newest_src=$f
    fi
  done
  
  # Find the newest file in the matlab binaries directory
  files=(/opt/demo/matlab/bin/*) newest_bin=${files[0]}
  for f in "${files[@]}"; do
    if [[ $f -nt $newest_bin ]]; then
      newest_bin=$f
    fi
  done
  
  # If the source code is newer than the binary, we probably forgot to compile,
  # so bail
  if [[ $newest_src -nt $newest_bin ]]; then
      echo Source code newer than binary
      exit 1
  fi

  # Make sure we get the newest versions of OS packages. Note, this means if we
  # build the container twice with some time in between, versions of things will
  # likely be different. We could specify specific versions below if needed - 
  # easy (if tedious) to find out what they are in an existing container.
  apt-get update

  # Misc tools needed for basic operations
  apt-get install -y wget unzip zip bc
  
  # Ghostscript and ImageMagick are very handy for making PDF QA reports. Note,
  # older but still recent versions of ImageMagick had security issues needing
  # modifications to /etc/ImageMagick-6/policy.xml before PDFs could be created,
  # https://usn.ubuntu.com/3785-1/. Newer versions are workable out of the box.
  apt-get install -y ghostscript imagemagick
  
  # xvfb is used to perform graphics operations "headless" to create figures,
  # images, etc. This pipeline will be run entirely on the virtual display,
  # although it's also possible to do X operations piecemeal/as needed.
  apt-get install -y xvfb

  # Matlab Runtime requires this Java runtime
  apt-get install -y openjdk-8-jre
  
  # FSL 6.0.4 requires these two additional packages
  apt-get install -y libopenblas-base language-pack-en
  
  # Download the Matlab Compiled Runtime installer, install, clean up. We are 
  # using 2019b here, meaning the Matlab code has to be compiled with 2019b as
  # well. Each version of the runtime has its own specific download URL:
  # https://www.mathworks.com/products/compiler/matlab-runtime.html
  mkdir /MCR
  wget -nv -P /MCR \
      https://ssd.mathworks.com/supportfiles/downloads/R2019b/Release/6/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019b_Update_6_glnxa64.zip
  unzip -qq /MCR/MATLAB_Runtime_R2019b_Update_6_glnxa64.zip \
      -d /MCR/MATLAB_Runtime_R2019b_Update_6_glnxa64
  /MCR/MATLAB_Runtime_R2019b_Update_6_glnxa64/install \
      -mode silent -agreeToLicense yes
  rm -r /MCR/MATLAB_Runtime_R2019b_Update_6_glnxa64 \
      /MCR/MATLAB_Runtime_R2019b_Update_6_glnxa64.zip
  rmdir /MCR

  # FSL. We need 6.0.4 for the b02b01_1.sch topup schedule. See
  # https://fsl.fmrib.ox.ac.uk/fsldownloads/manifest.csv
  # And, the centos7 version suits for Ubuntu 14-20.
  fslver=6.0.4
  cd /usr/local
  wget -nv https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-${fslver}-centos7_64.tar.gz
  tar -zxf fsl-${fslver}-centos7_64.tar.gz
  rm fsl-${fslver}-centos7_64.tar.gz

  # FSL setup
  export FSLDIR=/usr/local/fsl
  . ${FSLDIR}/etc/fslconf/fsl.sh
  export PATH=${FSLDIR}/bin:${PATH}
  
  # Run the FSL python installer. A clue that we forgot this is an imglob error at runtime
  ${FSLDIR}/etc/fslconf/fslpython_install.sh
  
  # Create input/output directories for binding
  mkdir /INPUTS && mkdir /OUTPUTS

  # Singularity-hub doesn't work with github LFS (it gets the pointer info instead 
  # of the actual file) so we get the compiled matlab executable via direct download.
  rm /opt/gf-fmri/matlab/bin/spm12.ctf
  wget -nv -P /opt/gf-fmri/matlab/bin https://github.com/baxpr/gf-fmri/raw/master/matlab/bin/spm12.ctf

  # We need to run the matlab executable now to extract the CTF, because
  # now is the only time the container is writeable
  /opt/gf-fmri/matlab/bin/run_spm12.sh /usr/local/MATLAB/MATLAB_Runtime/v97 quit


%environment

  # Matlab 
  # We set Matlab's default shell, in case we call any shell commands from 
  # Matlab. However we don't need to set the Matlab library path here, because 
  # Matlab's auto-generated run_??.sh script does it for us.
  MATLAB_SHELL=/bin/bash

  # FSL
  # We set FSLDIR here, but the rest of FSL setup will have to be done at 
  # runtime in the pipeline code:
  #       source ${FSLDIR}/etc/fslconf/fsl.sh
  #       export PATH=${FSLDIR}/bin:${PATH}
  export FSLDIR=/usr/local/fsl
  
  # Path
  # We add the src directory, which contains shell scripts etc; and the 
  # matlab/bin directory, which contains the compiled Matlab binary.
  export PATH=/opt/demo/src:/opt/demo/matlab/bin:${PATH}


%runscript

  # We just call our wrapper, passing along all the command line arguments that
  # were given at the singularity run command line.
  wrapper.sh "$@"

