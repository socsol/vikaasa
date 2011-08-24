%% VK_KERNEL_AUGMENT Augment the kernel with 'additional variable' data.
%
% SYNOPSIS
%   Where a project has specified additional variables, these are evaluated for
%   each point in the kernel.
%
% USAGE
%   % Augment the kernel, store the result in V, using data from p:
%   V = vk_kernel_augment(p);
%
%   % Using the viability kernel V, and taking other options from p:
%   V = vk_kernel_augment(p, V);
%
% See also: vk_kernel_augment_constraints

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
function V = vk_kernel_augment(project, varargin)

    %% V can optionally be specified.
    if (nargin > 1)
        V = varargin{1};
    else
        V = project.V;
    end

    %% Augment V with zeros to begin with:
    V = [V, zeros(size(V, 1), project.numaddnvars)];

    %% For each non-ignored index, fill in the gaps:
    for i = transpose(find(project.addnignore == false))
        fn = inline(project.addneqns{i}, project.symbols{:});
        for row = 1:size(V, 1)
            args = num2cell(transpose(V(row,1:project.numvars)));
            V(row, project.numvars+i) = fn(args{:});
        end
    end

    %% Then, for each ignored variable, remove the column:
    for i = sort(transpose(find(project.addnignore))+project.numvars, 'descend')
        V = [V(:,1:i-1), V(:,i+1:end)];
    end
end
