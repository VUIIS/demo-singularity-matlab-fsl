# Starting point for a container should be reasonably trustworthy, in this case
# an official base Ubuntu image from Docker https://hub.docker.com/_/ubuntu
Bootstrap: docker
From: ubuntu:20.04


%help
  Demo of a singularity container that runs a Matlab program. FSL is also 
  included, as it's a handy resource for a lot of image processing and figure
  creation.
  Info and usage: /opt/pipeline/README.md


%setup

  # Create an installation directory for the codebase. We can often finagle this
  # in the 'files' section and forgo the 'setup' section entirely, but it's 
  # clearer this way.
  mkdir -p "${SINGULARITY_ROOTFS}"/opt/pipeline


%files

  # Copy all the code into the container's installation directory. We do this in
  # specific pieces to avoid bulk copying any extra junk we might have floating
  # around in the local working copy of the repository. This Singularity recipe
  # itself is put in the container automatically during the build, at 
  # /.singularity.d/Singularity
  #
  # The Matlab source code is not actually used, because we'll run the compiled
  # version with the Matlab Runtime instead. But the source code will be in the
  # container for reference. Don't let these get out of sync, i.e. don't change
  # the Matlab source code and then forget to recompile it before building the
  # container.
  src                          /opt/pipeline
  matlab                       /opt/pipeline
  README.md                    /opt/pipeline
  ImageMagick-policy.xml       /opt

  # If we're installing MCR and FSL from local copies, we need to copy those
  # into the container as well. We'll delete them after the installs.
  external/MATLAB_Runtime_R2019b_Update_6_glnxa64.zip   /opt/mcr_installer.zip
  external/fsl-6.0.4-centos7_64.tar.gz                  /opt/fsl_installer.zip
  
 
%labels
  Maintainer baxter.rogers@vanderbilt.edu


%post

  # Make sure we get the newest versions of OS packages and the package data. 
  # Note, this means if we build the container twice with some time in between, 
  # versions of things will likely be different. We could specify particular 
  # versions below if needed - easy (if tedious) to find out what they are in an
  # existing container.
  apt update

  # Misc tools needed for basic operations
  apt install -y wget unzip zip bc
  
  # ImageMagick and Ghostscript are very handy for making PDF QA reports.
  apt install -y ghostscript imagemagick
  
  # ImageMagick security policy needs to be more permissive
  # https://www.kb.cert.org/vuls/id/332928
  mv /opt/ImageMagick-policy.xml /etc/ImageMagick-6/policy.xml

  # xvfb is used to perform graphics operations "headless" to create figures,
  # images, etc. This pipeline will be run entirely on the virtual display,
  # although it's also possible to do X operations piecemeal/as needed.
  apt install -y xvfb

  # Matlab Runtime requires this Java runtime
  apt install -y openjdk-8-jre
  
  # Matlab Compiled Runtime installation. Uncomment the wget command to download 
  # the install package instead of using a local copy. The installed version of 
  # the runtime must match the Matlab version that was used to compile the code. 
  # Each version of the runtime has its own download URL and installed location:
  # https://www.mathworks.com/products/compiler/matlab-runtime.html
  mcr_url=https://ssd.mathworks.com/supportfiles/downloads/R2019b/Release/6/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019b_Update_6_glnxa64.zip
  mcr_location=/usr/local/MATLAB/MATLAB_Runtime/v97
  #wget -nv -P /opt ${mcr_url} -O mcr_installer.zip
  unzip /opt/mcr_installer.zip -d /opt/mcr_installer
  /opt/mcr_installer/install -mode silent -agreeToLicense yes
  rm -r /opt/mcr_installer /opt/mcr_installer.zip
  
  # Matlab executable must be run now to extract the CTF archive, because
  # now is the only time the container is writeable. The matlab entrypoint has
  # a bit at the beginning that makes this work.
  /opt/pipeline/matlab/bin/run_matlab_entrypoint.sh ${mcr_location} quit

  # FSL dependencies, h/t https://github.com/MPIB/singularity-fsl
  #            debian              ubuntu
  #            libjpeg62-turbo ->  libjpeg-turbo8
  #            libmng1         ->  libmng2
  apt install -y \
    wget python2-minimal libgomp1 ca-certificates \
    libglu1-mesa libgl1-mesa-glx libsm6 libice6 libxt6 \
    libjpeg-turbo8 libpng16-16 libxrender1 libxcursor1 \
    libxinerama1 libfreetype6 libxft2 libxrandr2 libmng2 \
    libgtk2.0-0 libpulse0 libasound2 libcaca0 libopenblas-base \
    language-pack-en bzip2 dc bc

  # FSL. The centos7 version suits for Ubuntu 14-20. For available versions, see
  # https://fsl.fmrib.ox.ac.uk/fsldownloads/manifest.csv . Uncomment the wget
  # line to download instead of installing from a local copy of the file.
  fslurl=https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-6.0.4-centos7_64.tar.gz
  #wget -nv -P /opt ${fslurl} -O fsl_installer.zip
  tar -zxf /opt/fsl_installer.zip -C /usr/local
  rm /opt/fsl_installer.zip

  # FSL setup so we can run the python installer
  export FSLDIR=/usr/local/fsl
  . ${FSLDIR}/etc/fslconf/fsl.sh
  export PATH=${FSLDIR}/bin:${PATH}
  
  # FSL python installer, needed for fsleyes among other things. This 
  # is normally done in the post_install phase when FSL's installer is run, but
  # we do it manually here. A clue that we forgot this is an imglob error at
  # runtime. Note that this requires an internet connection, as it downloads 
  # some pieces from fsl.fmrib.ox.ac.uk.
  ${FSLDIR}/etc/fslconf/fslpython_install.sh
  
  # Create a few directories to use as bind points when we run the container
  mkdir /INPUTS
  mkdir /OUTPUTS
  mkdir /workdir
  
  # Clean up unneeded packages and cache
  apt clean && apt -y autoremove
  
  
%environment

  # Matlab 
  # We set Matlab's default shell, in case we call any shell commands from 
  # Matlab. We also set the runtime's installed location, as it's needed to run
  # the compiled binary - note, this must match the mcr_location specified
  # above in the 'post' section. However we don't need to set the Matlab library
  # path here, because Matlab's auto-generated run_??.sh script does it for us.
  export MATLAB_SHELL=/bin/bash
  export MATLAB_RUNTIME=/usr/local/MATLAB/MATLAB_Runtime/v97

  # FSL
  # We set FSLDIR here, but the rest of FSL setup will have to be done at 
  # run time in the pipeline code:
  #       . ${FSLDIR}/etc/fslconf/fsl.sh
  #       export PATH=${FSLDIR}/bin:${PATH}
  export FSLDIR=/usr/local/fsl
  
  # Path
  # We add the src directory, which contains shell scripts etc; and the 
  # matlab/bin directory, which contains the compiled Matlab binary.
  export PATH=/opt/pipeline/src:/opt/pipeline/matlab/bin:${PATH}


%runscript

  # We just call our entrypoint, passing along all the command line arguments 
  # that were given at the singularity run command line.
  pipeline_entrypoint.sh "$@"

