%% VK_KERNEL_AUGMENT_CONSTRAINTS Augment the kernel constraint set.
%
% SYNOPSIS
%   Where additional values are specified, construct dummy constraint set
%   values around them, using all possible combinations of the real constraint
%   set.
%
% USAGE
%   % Augment the constraint set, store the result in K, using data from p:
%   K = vk_kernel_augment_constraints(p);
%
%   % Specifying K, but taking other variables from p:
%   K = vk_kernel_augment_constraints(p, K);
%
% See also: vk_kernel_augment

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
function K = vk_kernel_augment_constraints(project, varargin)

    %% K can optionally be specified
    if (nargin > 1)
        K = varargin{1};
    else
        K = project.K;
    end

    %% Create a cell array by splitting up the elements in K:
    args = transpose(mat2cell(K, 1, 2*ones(1, project.numvars)));

    %% Create meshes from the args:
    meshargs = cell(project.numvars, 1);
    [meshargs{:}] = ndgrid(args{:});

    %% Augment K with zeros to begin with:
    K = [K, zeros(1, 2*project.numaddnvars)];

    %% For each non-ignored index, fill in the gaps:
    for i = transpose(find(project.addnignore == false))
        vfn = vectorize(inline(project.addneqns{i}, project.symbols{:}));
        vals = vfn(meshargs{:});
        K(2*(project.numvars+i) - 1) = min(vals(:));
        K(2*(project.numvars+i)) = max(vals(:));
    end
end
