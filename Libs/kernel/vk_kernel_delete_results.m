%% VK_KERNEL_DELETE_RESULTS Delete the results of a kernel approximation from the project
%
% SYNOPSIS
%   This function deletes a kernel and associated computation info from
%   project.  The fields removed are:
%
%   - `V',
%   - `comp_datetime',
%   - `comp_time'.
%
% USAGE
%   % The resulting project will have no V field, etc.
%   project = vk_kernel_delete_results(project);

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
function project = vk_kernel_delete_results(project)
    project = rmfield(project, {'V', 'comp_datetime', 'comp_time'});
end
