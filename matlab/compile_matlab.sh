#!/bin/sh
#
# Compile the matlab code so we can run it without a matlab license. To create
# a linux container, we need to compile on a linux machine. That means a VM, if
# we are working on OS X.
#
# We require on our compilation machine:
#     Matlab 2019b, including compiler, with license
#
# The matlab version matters. If we compile with R2019b, it will only run under 
# the R2019b Runtime.

# Where is Matlab?
MATLAB_ROOT=/usr/local/MATLAB/R2019b

# We may need to add Matlab to the path on the compilation machine
PATH=${MATLAB_ROOT}/bin:${PATH}

# Compile. Use -a to include an entire directory and all its contents,
# recursively. We use this for our own code. Use -N to leave out toolboxes to
# reduce the size of the binary. Individual toolboxes can be added back in with
# -p if needed.
#
# Relative paths are specified here, assuming we're running this script from
# the matlab/build directory.
mcc -m -v src/matlab_entrypoint.m \
    -N \
    -p ${MATLAB_ROOT}/toolbox/images \
    -a src \
    -d bin

# We grant lenient execute permissions to the matlab executable and runscript so
# we don't have hiccups later.
chmod go+rx bin/matlab_entrypoint
chmod go+rx bin/run_matlab_entrypoint.sh

