%% VK_INIT Initialise the VIKAASA environment
%

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
vk_version = '0.10.3';
vk_copyright = fileread('../NOTICE');
if (size(vk_copyright, 2) == 1)
    vk_copyright = transpose(vk_copyright);
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
