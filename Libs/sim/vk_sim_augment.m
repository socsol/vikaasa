%% VK_SIM_AUGMENT Augment the simulation structure in the given project
%
% SYNOPSIS
%   Where a project has specified additional variables, this function works
%   to augment the `sim_state' information to include those variables as well.
%
% USAGE
%   % Augment the kernel, store the result in V, using data from p:
%   sim_state = vk_sim_augment(p);
%
%   % Specifying some other simulation:
%   sim_state = vk_sim_augment(p, sim_state);
%
% Requires: vk_kernel_augment, vk_kernel_augment_constraints

%%
%  Copyright 2011 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%`
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
function sim_state = vk_sim_augment(project, varargin)

    %% sim_state can optionally be specified.
    if (nargin > 1)
        sim_state = varargin{1};
    else
        sim_state = project.sim_state;
    end

    %% Augment the V and K variables.
    sim_state.V = vk_kernel_augment(project, sim_state.V);
    sim_state.K = vk_kernel_augment_constraints(project, sim_state.K);

    %% Augment V with zeros to begin with:
    sim_state.path = vk_sim_augment_path(path, project.numvars, project.numaddnvars, ...
        project.addnignore, project.addneqns, project.symbols);
    
    %[sim_state.path; zeros(project.numaddnvars, size(sim_state.path, 2))];
%
%    %% For each non-ignored index, fill in the gaps:
%    for i = transpose(find(~project.addnignore))
%        fn = inline(project.addneqns{i}, project.symbols{:});
%        for col = 1:size(sim_state.path, 2)
%            args = num2cell(sim_state.path(1:project.numvars, col));
%            sim_state.path(i+project.numvars, col) = fn(args{:});
%        end
%    end
%
%    %% Now remove all the ignored rows in reverse:
%    for i = sort(transpose(find(project.addnignore))+project.numvars, 'descend')
%        sim_state.path = [sim_state.path(1:i-1,:); sim_state.path(i+1:end,:)];
%    end

end
