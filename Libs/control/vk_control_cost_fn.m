%% VK_CONTROL_COST_FN compose cost functions that take vector parameters.
%
% SYNOPSIS
%   This function is needed by certain cost-minimising control functions in
%   VIKAASA in order to be able to minimise using an un-named vector of
%   variables, instead of a tuple.
%
%   This function is used by VIKAASA to transform a cost function which takes a
%   tuple of named variables into a function that instead takes a pair of
%   vectors.
%
% USAGE
%   % Evaluate the cost of being in state x, with velocity xdot:
%   cost = vk_control_cost_fn(cost_fn, x, xdot)
%
%   % Construct a cost function, given cost_fn:
%   cfn = @(x, xdot) vk_control_cost_fn(cost_fn, x, xdot)
%
%   `cost_fn' should be a handle to a function that takes $2n$ parameters,
%   where $n$ is the number of variables in the state space.  The first $n$
%   variables should represent the state space, and the second $n$ variables
%   should give the velocities.   For instance, if there were three variables
%   in the state space, then the following might be a valid cost function:
%
%   % Construct a cost function for use in vk_control_cost_fn:
%   cost_fn = @(x,y,z,xdot,ydot,zdot) x^2 + y^2 + z^2 + norm([xdot, ydot, zdot]);
%
% See also: vk_control_eval_fn

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
function cost = vk_control_cost_fn(cost_fn, x, xdot)
    vars = num2cell([x;xdot]);
    cost = cost_fn(vars{:});
end
