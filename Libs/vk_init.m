%% VK_INIT Initialise the VIKAASA environment.
%
% SYNOPSIS
%   This script initialises the variables `vikaasa_version', and
%   `vikaasa_copyright', which should be populated with the contents of the
%   VERSION and NOTICE files, respectively; and adds the directories containing
%   the VIKAASA library functions and control algorithms to the path.  It is
%   used by the `vikaasa' or `vikaasa_cli' commands.
%
% USAGE
%   % Run the script
%   vk_init
%   % Afterwards, this should display the version of vikaasa:
%   vikaasa_version
%
% See also: vikaasa, vikaasa_cli

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

%% Info
vikaasa_version = fileread('../VERSION');
if (size(vikaasa_version, 2) == 1)
    vikaasa_version = transpose(vikaasa_version);
end
vikaasa_copyright = fileread('../NOTICE');
if (size(vikaasa_copyright, 2) == 1)
    vikaasa_copyright = transpose(vikaasa_copyright);
end

%% Paths
cd ..
addpath(...
  pwd, ...
  fullfile(pwd, 'Libs'), ...
  fullfile(pwd, 'ControlAlgs'), ...
  fullfile(pwd, 'VControlAlgs'));

libs = dir(fullfile(pwd, 'Libs'));
for i = 1:length(libs)
    if (libs(i).isdir && ~strcmp(libs(i).name(1), '.'))
        addpath(fullfile(pwd, 'Libs', libs(i).name));
    end
end
