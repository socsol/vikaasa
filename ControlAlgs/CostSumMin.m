%% COSTSUMMIN Find the control which minimises the sum of costs
%   This function finds the control that minimises the sum of cost function
%   realisations  for some set number of steps.
%
%   - The cost function is given in 'options.cost_fn'.
%   - The number of forward-looking steps is given by 'options.steps'.
%   - If 'options.use_controldefault' is set to 1, then the algorithm will
%     not bother finding an optimal control for the final step, but will
%     instead apply 'options.controldefault'.
%
%   Standard use, with required parameters:
%   u = COSTSUMMIN(x, K, f, c)
%
%   With optional parameters.  OPTIONS is either a list of name,value
%   pairs, or a structure created by VK_OPTIONS.
%   u = COSTSUMMIN(x, K, f, c, OPTIONS)
%
% See also: CONTROLALGS/COSTMIN, CONTROLALGS/NORMMIN1STEP, TOOLS/VK_OPTIONS

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
function u = CostSumMin(x, K, f, c, varargin)

    % Create options structure if required
    options = vk_options(K, f, c, varargin{:});

    steps = options.steps;
    min_fn = options.min_fn;

    cost_of_nextchange_fn = @(u) vk_costsum_recursive(x, u, steps, ...
        K, f, c, options);

    % Minimise our cost function.
    u = min_fn(cost_of_nextchange_fn, -c, c);
end

%% Recursive helper function for COSTSUMMIN
%   This function computes the aggregate cost of continuing some number of
%   steps into the future, given a starting position (x) and a control
%   level (u).  If the constraint set is exited, costs become infinite.
function cost = vk_costsum_recursive(x, u, steps, K, ...
    f, c, options)

    cost_fn = options.cost_fn;
    min_fn = options.min_fn;
    next_fn = options.next_fn;

    futurex = next_fn(x, u);

    % If there are future steps, we calculate the miniumum cost of all
    % future steps, given futurex.
    if (steps == 0)
        future_costs = 0;
    elseif (steps == 1 && options.use_controldefault)
        future_costs = cost_fn( ...
            next_fn(futurex, options.controldefault), ...
            f(futurex, options.controldefault));
    else
        future_cfn = @(u2) vk_costsum_recursive(...
            futurex, u2, steps - 1, ...
            K, f, c, options);

        [min_control_int, future_costs] = ...
            min_fn(future_cfn, -c, c);
    end

    % Then, we add the current cost and return.
    cost = cost_fn(next_fn(x, u), f(x, u)) + future_costs;
end
