%% SATISFICECOSTMIN Satisficing control algorithm that uses CostMin at the edge
%   This algorithm is similar to SatisficeMaxMin, except that it uses CostMin
%   to determine what control to use when at the kernel edge.
%
% See also: TOOLS/VK_SIMULATE_EULER, TOOLS/VK_SIMULATE_ODE, TOOLS/VK_VIABLE, VCONTROLALGS/SATISFICEMAXMIN

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
function u = SatisficeCostMin(info, x, K, f, c, varargin)

    options = vk_options(K, f, c, varargin{:});

    V = info.V;
    distances = info.distances;
    layers = info.layers;

    norm_fn = options.norm_fn;
    cost_fn = options.cost_fn;
    next_fn = options.next_fn;
    small = options.small;

    % Default -- gets overwritten below, if necessary.
    u = ZeroControl(x, K, f, c, options);

    % If doing nothing causes us to move a negligible amount, then stop.
    if (norm_fn(f(x, u)) < small)
        return;
    end

    % Otherwise, check to see whether we are on edge.
    [inside, edge] = vk_kernel_inside(x, V, distances, layers);

    % If we are on edge, we take our control choice from CostMin.
    if (~inside)
        u = CostMin(x, K, f, c, options);
    end
end

