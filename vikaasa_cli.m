%% VIKAASA_CLI Initialise the VIKAASA enviroment for use from the commandline.
%
% Requires: vk_help, vk_init
%
% See also: vikaasa

%%
%  Copyright 2011 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.

%% This sets up the paths, and defines the vk_version and vk_copyright variables.
run Libs/vk_init.m

%% Display that information
fprintf('%s\n', char('-'*ones(1, 79)));
fprintf(vikaasa_copyright);
fprintf('%s\n\n', char('-'*ones(1, 79)));
fprintf('Type ''vk_help'' for more information.\n\n');
