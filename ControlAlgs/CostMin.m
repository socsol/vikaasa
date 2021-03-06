%% COSTMIN Apply the control that minimises the specified cost function.
%
% SYNOPSIS
%   This function attempts to minimise the cost function at some number of
%   steps in the future.  The function can work with any arbitrary number
%   of forward-looking steps, but becomes exponentially slower for each
%   one.
%
% NOTES
%   - The cost function is given in `options.cost_fn'.
%   - The number of forward-looking steps is given by `options.steps'.
%   - If `options.use_controldefault' is set to 1, then the algorithm will
%     not bother finding an optimal control for the final step, but will
%     instead apply 'options.controldefault'.
%
% USAGE
%   % Standard use with required arguments:
%   u = CostMin(x, K, f, c)
%
%   See `ControlAlgs' for informaton on the required parameters, and the
%   return value.
%
%   % With additional options structure passed in.  'options' is either a list
%   % of name,value pairs, or a structure created by vk_options.
%   u = CostMin(x, K, f, c, options)
%
% Requires: vk_costmin_recursive, vk_options
%
% See also: ControlAlgs, options

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
function u = CostMin(x, K, f, c, varargin)

    % Get the options structure.
    options = vk_options(K, f, c, varargin{:});

    steps = options.steps;
    min_fn = options.min_fn;

    cost_fn = @(u) vk_costmin_recursive(x, u, steps, K, ...
        f, c, options);

    % Minimise our new cost function.
    u = min_fn(cost_fn, -c, c);
end


%% Helper function for COSTMIN
function cost = vk_costmin_recursive(x, u, steps, ...
    K, f, c, options)

    min_fn = options.min_fn;
    next_fn = options.next_fn;

    futurex = next_fn(x,u);

    if (steps > 1)
        cost_fn = @(u) vk_costmin_recursive(...
            futurex, u, steps - 1, ...
            K, f, c, options);
        [min_control, cost] = min_fn(cost_fn, -c, c);
    else % steps = 1
        cost_fn = options.cost_fn;

        if (options.use_controldefault)
            cost = cost_fn( ...
                next_fn(futurex, options.controldefault), ...
                f(futurex, options.controldefault));
        else
            % Optimise by minimising the cost of the next change.
            future_cfn = @(u2) cost_fn(...
                next_fn(futurex, u2), ...
                f(futurex, u2));
            [min_control_int, cost] = ...
                min_fn(future_cfn, -c, c);
        end
    end
end
