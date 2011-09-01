%% VK_PROJECT_NEW Creates a new project structure.
%
% SYNOPSIS
%   This function returns a newly initialised project structure.
%
% USAGE
%   % Initialising a project, and storing it in p.
%   p = vk_project_new;
%
%   % Initialising a project, and setting fields at the same time:
%   p = vk_project_new( ...
%     'numvars, 3, ...
%     'symbols', {{'x'; 'y'; 'z'}}
%   );
%
% See also: vk_project_load, vk_project_sanitise

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
function project = vk_project_new(varargin)
    project = struct(varargin{:});

    if (~isfield(project, 'numvars'))
        project.numvars = 2;
    end

    project = vk_project_sanitise(project);
end

