%% VIKAASA_CLI Initialise the VIKAASA enviroment for use from the commandline.
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo

%% This sets up the paths, and defines the vk_version and vk_copyright variables.
run Libs/vk_init.m

%% Display that information
fprintf('%s\n', char('-'*ones(1, 79)));
fprintf(vk_copyright);
fprintf('%s\n\n', char('-'*ones(1, 79)));
fprintf('Type ''vk_help'' for more information.\n\n');
