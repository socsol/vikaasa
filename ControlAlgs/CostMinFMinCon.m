%% COSTMINFMINCON Multi-step cost minimising control algorithm using `fmincon`.
%
% SYNOPSIS
%   This function performs forward-looking optimisation for an arbitrary number
%   of controls using `fmincon`, part of the MATLAB(R) Optimization Toolkit.
%   If minimises the system's cost function, or the norm of the system velocity
%   if no cost function is specified.
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
    len = length(c);
    
    % A function which takes a concatonated vector of control choices, and returns the nth vector
    xn = @(u) CostMinFMinCon_recursive(x, u, steps, len, next_fn);

    % We want to minimise the cost of the last state.
    cost = @(u) CostMinFMinCon_cost(xn(u), u(end-len+1:end), cost_fn, next_fn, f);

    % Non-linear constraints attempt to ensure that control choices stay in the
    % constraint space.
    nonlcon = @(u) CostMinFMinCon_nonlcon(x, K, c, next_fn, u);

    lb = zeros((steps+1)*len, 1);
    ub = zeros((steps+1)*len, 1);

    for i = 0:steps
      start = 1+i*len;
      fin = i*len + len;
      lb(start:fin) = -c;
      ub(start:fin) = c;
    end

    opts = optimset( ...
        'TolX', options.controltolerance, ...
        'FunValCheck', 'on', ...
        'Algorithm', 'active-set', ...
        'Display', 'off');
    uall = fmincon(cost, zeros((steps + 1)*len, 1), [], [], [], [], lb, ub, nonlcon, opts);
    u = uall(1:len);
end

function x = CostMinFMinCon_recursive(x0, u, n, len, next_fn)
    if (n == 0)
      x = next_fn(x0, u);
    else
      x = CostMinFMinCon_recursive(next_fn(x0, u(1:len)), u(len+1:end), n - 1, len, next_fn);
    end
end

function m = CostMinFMinCon_cost(xn, un, cost_fn, next_fn, f)
    m = real(cost_fn(next_fn(xn, un), f(xn, un)));
end

function [c,ceq] = CostMinFMinCon_nonlcon(x0, K, c, next_fn, u)
  n = length(x0);
  m = length(c);
  p = length(u)/length(c);

  % Create a vector of length 2*|x|*|u|; 2 because there is an upper and a
  % lower constraint for each dimension.
  c = zeros(2*n*p, 1);

  % Initial value of x.
  x = x0;

  % Loop through the time values.
  for t = 0:(p - 1)
    % Use the given control vector to work out the next state.
    x = next_fn(x, u(m*t + 1:m*t + m));
    % Loop through the dimensions.
    for i = 1:n
      c(2*n*t + 2*i - 1) = real(K(2*i - 1) - x(i));
      c(2*n*t + 2*i) = real(x(i) - K(2*i));
    end
  end

  % No equality constraints
  ceq = [];
end