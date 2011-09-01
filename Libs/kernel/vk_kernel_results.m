%% VK_KERNEL_RESULTS Returns the results of a kernel approximation.
%
% SYNOPSIS
%   This function returns a cell array giving an overview of a kernel
%   approximation run.  It is the same information that is displayed in the
%   ``Kernel Results'' panel of the GUI.
%
% USAGE
%   % place the information into a cell.
%   results = vk_kernel_results(project);
%
% Requires: vk_timeformat

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
function results = vk_kernel_results(project)

    if (isfield(project, 'comp_datetime'))
        results = {...
                'Computation Begun at', project.comp_datetime; ...
                'Computation Time', vk_timeformat(project.comp_time); ...
                'Viable Points', size(project.V, 1); ...
                'Percentage Viable', 100 * size(project.V, 1) / ...
                    prod(project.discretisation);
        };
    else
        results = {'', 'No results'};
    end
end
