%% NORMMIN1STEP Fast 1-step norm-minimising control function
%
% SYNOPSIS
%   This function returns the control that minimises the norm of the
%   system velocity in one step.
%
%   It has the advantage that it is faster than using COSTMIN, but it is
%   less flexible.  Firstly, it cannot be used for more than one step.
%   Secondly, it uses 'controldefault' to avoid the issue of having to
%   optimise for the control-in-one-step.  This is fast, but it may not
%   make sense in a non-linear dynamic system.
%
% USAGE
%   % Standard use with required arguments:
%   u = NormMin1Step(x, K, f, c)
%
%   % With options passed in. options is either a list of name, value pairs,
%   % or a structure created by vk_options.
%   u = NormMin1Step(x, K, f, c, options);
%
% Requires:  vk_options
%
% See also: CostMin, CostSumMin

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
function min_control = NormMin1Step(x, K, f, c, varargin)

    options = vk_options(K, f, c, varargin{:});

    controldefault = options.controldefault;

    min_fn = options.min_fn;
    cost_fn = @norm;
    next_fn = options.next_fn;

    % Check that doing nothing doesn't produce exactly zero movement.
    % If it does, then we are already at a steady state.
    if (f(x, controldefault) == 0)
        min_control = controldefault;
    else
        % Otherwise, the 'best' control is found by minimizing the
        % size of the next change that the default control gives.
        cost_of_nextchange_fn = @(u) cost_fn( ...
            f(next_fn(x, u), controldefault));

        % Minimise our new cost function.
        min_control = ...
            min_fn(cost_of_nextchange_fn, -c, c);
    end
end
