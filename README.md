# Demo singularity container for Matlab

Set up with shell wrapper so prep and finalize/PDF code can be shell script, which is easier.

    Singularity
    src/
        pipeline_entrypoint.sh
        pipeline_main.sh
    matlab/
        src/
            matlab_entrypoint.m
            matlab_main.m
        build/
        bin/

