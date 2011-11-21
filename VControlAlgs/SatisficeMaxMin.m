%% SATISFICEMAXMIN Satisficing Viabilty Control Algorithm
%
% SYNOPSIS
%   This control rule does nothing unless it finds itself are in an 'edge'
%   scenario, in which case either the max or min control available is used
%   -- whichever is less costly, according to the cost function.
%
% USAGE
%   % To get the statisficing control rule for point x:
%   u = SatisficeMaxMin(info, x, K, f, c);
%
%   `info' is a structure that must contain:
%       - `V': A viability kernel
%       - `distances': An array of distances FIXME
%       - `layers': How many layers of points before the algorithm
%         considers that it is in an 'edge' scenario.
%
% Requires:  vk_kernel_inside, vk_options
%
% See also: vk_simulate_euler, vk_simulate_ode, vk_viable

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
function u = SatisficeMaxMin(info, x, K, f, c, varargin)

    options = vk_options(K, f, c, varargin{:});

    V = info.V;
    distances = info.distances;
    layers = info.layers;

    norm_fn = options.norm_fn;
    cost_fn = options.cost_fn;
    next_fn = options.next_fn;
    small = options.small;
    if (options.use_controldefault)
        controldefault = options.controldefault;
    else
        controldefault = 0;
    end

    % Default -- gets overwritten below, if necessary.
    u = ZeroControl(x, K, f, c, options);

    % If doing nothing causes us to move a negligible amount, then stop.
    if (norm_fn(f(x, u)) < small)
        return;
    end

    % Otherwise, check to see whether we are on edge.
    [inside, edge] = vk_kernel_inside(x, V, distances, layers);

    % If we are on edge, we need to exert either max, or min.
    if (~inside)
        cost_min = cost_fn(...
            next_fn(next_fn(x, -c), controldefault), ...
            f(next_fn(x, -c), controldefault));
        cost_max = cost_fn(...
            next_fn(next_fn(x, c), controldefault), ...
            f(next_fn(x, c), controldefault));

        if (cost_min < cost_max)
            u = -c;
        else
            u = c;
        end
    end
end
