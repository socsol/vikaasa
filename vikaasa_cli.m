%% VIKAASA_CLI Initialise the VIKAASA enviroment for use from the commandline.

%% This sets up the paths, and defines the vk_version and vk_copyright variables.
run Libs/vk_init.m

%% Display that information
fprintf('%s\n', char('-'*ones(1, 79)));
fprintf('VIKAASA Version %s\n', vk_version);
fprintf('%s.\n', vk_copyright);
fprintf('%s\n\n', char('-'*ones(1, 79)));
