%% VK_SIM_SIMULATE_EULER Simulate system trajectory using Euler approximation
%
% SYNOPSIS
%   This function simulates the path that the system would take over some
%   number of iterations, given a starting point, and using some specified
%   control algorithm.
%
% USAGE
%   % Standard usage:
%   [T, path, normpath, controlpath, viablepath] = vk_sim_simulate_euler(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  f, c)
%
%   Return arguments are:
%   - `T': Row-vector of time values, starting with zero.
%
%   - `path': $n \times |T|$ matrix.  Each column represents a the state-space
%     position of the system at the time in the correponding element in `T'.
%     Thus for instance, The first column will equal `x'.
%
%   - `normpath': A row-vector, of same length as `T', giving the value of
%     the norm (as specified by the `norm_fn' option in vk_options)
%     velocity of the system at each point in time.
%
%   - `controlpath': A row-vector, of same length as `T', giving the control
%     choice at each point in time.
%
%   - `viablepath': $5 \times |T|$ matrix.  Each column represents four
%     information flags (1 or 0) for that point in time:
%     (i) whether or not the point is inside the kernel, V (See
%        vk_kernel_inside for how this is computed);
%     (ii) whether or not the point is considered to be an ``edge' point (See
%        vk_kernel_inside for info on this);
%     (iii) whether or not the point is outside of the constraint set in a real
%        dimension;
%     (iv) whether or not the poimnt is outside the constraint set in a complex
%        dimension; and
%     (v) whether or not the system velocity is slow enough for the point to
%        be considered steady.
%
%   Input arguments are:
%   - `x': A column vector of length numvars, specifying the starting point
%     of the simulation.
%
%   - `time_horizon': A number greater than zero, specifying the end time of
%     the simulation.  The start time is always zero.
%
%   - `control_fn': A control algorithm.  See vk_control_wrap_fn.
%
%   - `V': A viability kernel.  This is used to give information about the
%     system trajectory in relation to the kernel (through the `viablepath'
%     return variable).  If you don't care about this, you can specify an
%     empty matrix, [] as the kernel.
%
%   - `distances': A row vector of length numvars, giving the distance
%     between points in `V' in each dimension.  See vk_kernel_inside for an
%     explanation of this.
%
%   - `layers': See vk_kernel_inside for an explanation.
%
%   - `K': A constraint set.  See vk_kernel_compute for the format of this.
%
%   - `f': A function that gives the velocity of each variable in the system,
%     given some state space vector, x and some control choice, `u'.
%
%   - `c': The absolute maximum size of the control.
%
%   % Usage with additional options:
%   [T, path, normpath, controlpath, viablepath] = vk_sim_simulate_euler(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  f, c, options)
%
%   `options' is either a structure created by vk_options, or a set of ('name',
%   value) pairs, or both.
%
% NOTES
%   An imporant option for vk_sim_simulate_euler is `sim_stopsteady', which
%   causes the simulation to terminate as soon as a steady state is
%   encountered, instead of waiting.
%
% See also: ControlAlgs, VControlAlgs, vk_kernel_compute, vk_kernel_inside,
%   vk_options, vk_sim_simulate_ode

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
function [T, path, normpath, controlpath, viablepath] = vk_sim_simulate_euler(...
    x, time_horizon, control_fn, V, distances, layers, ...
    K,  f, c, varargin)

    %% Create options structure
    options = vk_options(K, f, c, varargin{:});


    %% Options that we care about
    next_fn = options.next_fn;
    cancel_test = options.cancel_test;
    cancel_test_fn = options.cancel_test_fn;
    norm_fn = options.norm_fn;
    report_progress = options.report_progress;
    progress_fn = options.progress_fn;
    sim_stopsteady = options.sim_stopsteady;
    hardupper = options.sim_hardupper;
    hardlower = options.sim_hardlower;


    %% Create the bounded control function
    fn = vk_control_wrap_fn(control_fn, K, f, c, options);


    %% Set up information variables
    h = options.h;
    T = 0:h:time_horizon;
    iterations = length(T);

    % Time goes along the column axis.
    path = zeros(length(K)/2, iterations);
    normpath = zeros(1, iterations);
    controlpath = zeros(1, iterations);
    viablepath = zeros(5, iterations);


    %% Run simulation
    % First x is already set in function args.
    for i = 1:iterations

        %% Check to see if we need to cancel
        if (cancel_test && cancel_test_fn())
            break;
        end


        %% Get the control choice
        u = fn(x);


        %% Record pah and control choice
        path(:, i) = x;
        controlpath(i) = u;


        %% Record viability, etc. at this point
        [viablepath(1, i), viablepath(2, i)] = vk_kernel_inside(x, V, ...
            distances, layers);
        exited_on = vk_viable_exited(x, K, f, c, options);
        viablepath(3, i) = any(~isnan(exited_on(:,1)));
        viablepath(4, i) = any(~isnan(exited_on(:,2)));


        %% Record velocity and steadyness
        norm_val = norm_fn(f(x, u));
        steady = norm_val <= options.small;
        viablepath(5, i) = steady;
        normpath(i) = norm_val;


        %% Report to progress (bar) if necessary
        if (report_progress)
            progress_fn(T(i));
        end


        %% Stop if necessary
        if (sim_stopsteady && steady)
            break;
        end

        % Hard upper and lower bounds only count for real dimensions here.
        if (...
             (~isempty(hardupper) && any(exited_on(hardupper, 1) > 0)) ...
          || (~isempty(hardlower) && any(exited_on(hardlower, 1) < 0)) ...
        )
            break;
        end

        %% Iterate to next point.
        x = next_fn(x, u);
    end


    %% If we stopped early, we cut the items down to size.
    if (i < iterations)
        T = T(1:i);
        path = path(:, 1:i);
        normpath = normpath(1:i);
        controlpath = controlpath(1:i);
        viablepath = viablepath(:, 1:i);
    end
end
