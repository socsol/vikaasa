%% COSTMINFMINCON Multi-step cost minimising control algorithm using `fmincon`.
%
% SYNOPSIS
%   This function performs forward-looking optimisation for an arbitrary number
%   of controls using `fmincon`, part of the MATLAB(R) Optimization Toolkit.
%
%   The function works by trying to find a vector of length m*(s+1), where m is
%   the number of controls, and s is the number of forward-looking steps (s+1
%   because the first control represents the current step).  This vector thus
%   represents a series of s+1 control choices.  This vector is fed into a
%   function which gives the series of state-space points that these controls
%   will cause the system to pass through, and then an optimal control vector
%   is sought out by looking for the vector that:
%
%   - does not violate the requirement that $\u(t) \in [-c, c]$; and
%   - does not cause a violation of the rectangular constraints at each step;
%     and
%   - minimises the provided cost function, when evaluated against the final
%     provided state-space point.
%
% USAGE
%   % Standard use with required arguments:
%   u = CostMinFMinCon(x, K, f, c)
%
%   See `ControlAlgs' for informaton on the required parameters, and the
%   return value.
%
%   % With additional options structure passed in.  'options' is either a list
%   % of name,value pairs, or a structure created by vk_options.
%   u = CostMinFMinCon(x, K, f, c, options)
%
% Requires: vk_options
%
% See also: CostMin

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
function u = CostMinFMinCon(x, K, f, c, varargin)

    % Get the options structure.
    options = vk_options(K, f, c, varargin{:});

    steps = options.steps;
    cost_fn = options.cost_fn;
    next_fn = options.next_fn;
    n = length(x);
    m = length(c);

    % A function which takes a concatonated vector of control choices, and
    % returns the set of state-space points that the system will pass through
    % as a result.
    loop = @(u) CostMinFMinCon_loop(x, u, steps, n, m, next_fn);

    % We want to minimise the cost of the last state.
    cost = @(u) CostMinFMinCon_cost(loop(u), u(end-m+1:end), cost_fn, next_fn, f);

    % Non-linear constraints attempt to ensure that control choices stay in the
    % constraint space.
    nonlcon = @(u) CostMinFMinCon_nonlcon(loop(u), K);

    lb = zeros((steps+1)*m, 1);
    ub = zeros((steps+1)*m, 1);

    for i = 0:steps
      start = 1+i*m;
      fin = i*m + m;
      lb(start:fin) = -c;
      ub(start:fin) = c;
    end

    opts = optimset( ...
        'TolX', options.controltolerance, ...
        'FunValCheck', 'on', ...
        'Algorithm', 'active-set', ...
        'Display', 'off');

    uall = fmincon(cost, zeros((steps + 1)*m, 1), [], [], [], [], lb, ub, nonlcon, opts);
    u = uall(1:m);

    % Apparently fmincon will occasionally produce control rules
    % that are outside of the bounds.
    u(u > c) = c(u > c);
    u(u < -c) = -c(u < -c);
end

function xs = CostMinFMinCon_loop(x0, u, steps, n, m, next_fn)
    xs = zeros(n, steps);

    x = x0;
    for i = 1:steps
      start = m*(i-1) + 1;
      x = next_fn(x, u(start:start+m-1));
      xs(:, i) = x;
    end
end

function m = CostMinFMinCon_cost(xs, un, cost_fn, next_fn, f)
  m = cost_fn(next_fn(xs(:, end), un), f(xs(:, end), un));
end

function [cin,ceq] = CostMinFMinCon_nonlcon(xs, K)
    n = size(xs, 1);
    p = size(xs, 2);

    % Create a vector of length 2*|x|*|u|; 2 because there is an upper and a
    % lower constraint for each dimension.
    cin = zeros(2*n*p, 1);

    % No equality constraints
    ceq = [];

    % Loop through the time values.
    for t = 1:p
        start = 2*n*(t - 1) + 1;
        for i = 1:n
            % Add the real parts of the exited fn to the vector.
            cin(start + 2*i-2) = real(K(2*i - 1) - xs(i,t));
            cin(start + 2*i-1) = real(xs(i,t) - K(2*i));
        end

        if any(cin(start:(start+2*n-1)) > 0)
            break;
        end
    end

    % Leave the rest of the values as zero.
end
