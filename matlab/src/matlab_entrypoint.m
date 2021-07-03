function matlab_entrypoint(varargin)

% This function serves as the entrypoint to the matlab part of the
% pipeline. Its purpose is to parse the command line arguments, then call
% the main function that actually does the work.


%% Parse the inputs and parameters

% Matlab's input parser is very convenient. We will add all arguments as
% "optional", providing default values when appropriate.
P = inputParser;

% Our example code takes a single 3D nifti T1 as input. This argument
% is expected to contain the fully qualified path and filename.
addOptional(P,'t1_niigz','')

% We also want a corresponding segmentation.
addOptional(P,'seg_niigz','')

% We also take a single numerical parameter. Note that when arguments are
% passed to compiled Matlab via command line, they all come as strings; so
% we will need to convert this to a numeric format later.
addOptional(P,'diameter_mm','30');

% When processing runs on XNAT, we generally have the project, subject,
% session, and scan labels from XNAT available in case we want them. Often
% the only need for these is to label the QA PDF.
addOptional(P,'project','UNK_PROJ');
addOptional(P,'subject','UNK_SUBJ');
addOptional(P,'session','UNK_SESS');
addOptional(P,'scan','UNK_SCAN');

% Finally, we need to know where to store the outputs.
addOptional(P,'out_dir','/OUTPUTS');

% Parse
parse(P,varargin{:});

% Display the command line parameters - very helpful for running on XNAT,
% as this will show up in the outlog.
disp(P.Results)


%% Run the actual pipeline
matlab_main(P.Results);


%% Exit
% But only if we're running the compiled executable. If we're testing in a
% matlab session, exiting is not helpful.
if isdeployed
	exit
end

