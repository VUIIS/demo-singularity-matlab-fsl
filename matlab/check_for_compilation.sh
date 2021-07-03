#!/usr/bin/env bash
#
# Check if any of the matlab source code is newer than the compiled executable.

files=`find src -name \* -type f`
for f in ${files}; do
    if [ "${f}" -nt bin/run_matlab_entrypoint.sh ]; then
        echo Source code newer than binary: "${f}"
        exit 1
    fi
done
