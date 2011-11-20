%% VK_SIM_SIMULATE_ODE Simulate system trajectory using an ODE solver
%
% SYNOPSIS
%   Simulates the path that the system would take over some number of
%   periods, given a starting point, and using some specified control
%   algorithm.
%
%   This function takes and returns identical arguments to
%   vk_sim_simulate_euler, but it uses an ODE solver (e.g., `ode45')
%   instead of an Euler approximation.  This means that it is generally
%   slower, but more accurate for most purposes.
%
%   The ODE solver that this function uses is given by the `ode_solver_name'
%   option (see vk_options).  By default this is set to `ode45'.  See the
%   examples below for how you could change this to use a different solver.
%
%   It is also possible to entirely replace the wrapper by specifying the
%   `ode_solver' option.  See the examples.
%
% USAGE
%   % Standard usage:
%   [T, path, normpath, controlpath, viablepath] = VK_SIM_SIMULATE_ODE(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  f, c)
%
%   % With optional extras added:
%   [T, path, normpath, controlpath, viablepath] = VK_SIM_SIMULATE_ODE(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  f, c, OPTIONS)
%
%   See vk_sim_simulate_euler for a description of all the arguments.
%
% EXAMPLES
%   % Use ode23 instead of ode45:
%   [T, path, normpath, controlpath, viablepath] = vk_sim_simulate_ode(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  f, c, 'ode_solver_name', 'ode23');
%
%   % Or, with other options:
%   options = vk_options(K,  f, c, ...
%       'ode_solver_name', 'ode23', ...
%       'stepsize', 0.5, ...
%       'sim_stopsteady', 1);
%   [T, path, normpath, controlpath, viablepath] = vk_sim_simulate_ode(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  f, c, options);
%
%   % Use a custom-made ODE solver:
%   myodesolver = @(fn, T, x0) somefunction(fn, x0);
%   [T, path, normpath, controlpath, viablepath] = vk_sim_simulate_ode(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  f, c, 'ode_solver', myodesolver);
%
% Requires: vk_control_wrap_fn, vk_kernel_inside, vk_options, vk_sim_simulate_ode_helper, vk_viable_exited
%
% See also: vk_kernel_compute, vk_sim_simulate_euler

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
function [T, path, normpath, controlpath, viablepath] = vk_sim_simulate_ode(...
    start, time_horizon, control_fn, V, distances, layers, ...
    K, f, c, varargin)

    %% Create options structure
    options = vk_options(K, f, c, varargin{:});

    %% Options we care about here
    ode_solver = options.ode_solver;
    norm_fn = options.norm_fn;
    small = options.small;
    hardupper = options.sim_hardupper;
    hardlower = options.sim_hardlower;
    numcontrols = options.numcontrols;

    %% Create the function for use with the ODE solver.
    control_fn = vk_control_wrap_fn(control_fn, K, f, c, options);
    odefun = @(t, x0) vk_sim_simulate_ode_helper(f, control_fn, x0(1:end-numcontrols));

    %% Run the ODE solver.
    [T, Y] = ode_solver(odefun, [0, time_horizon], [start;zeros(numcontrols, 1)]);

    % The final "numcontrols"-columns of Y gives the cumulative control
    % choices.  To decode this then, we need to subract the differences.
    path = transpose(Y(:, 1:end-numcontrols));

    % Check to see if any 'hard' constraints were violated.  If they were, then
    % truncate path and T accordingly.
    if (~isempty(hardupper) || ~isempty(hardlower))
        for i = 1:length(T)-1
            x = path(:, i);
            exited_on = vk_viable_exited(x, K, f, c, options);

            if (  (~isempty(hardupper) && any(exited_on(hardupper, 1) > 0)) ...
               || (~isempty(hardlower) && any(exited_on(hardlower, 1) < 0)))
                path = path(:, 1:i+1);
                T = T(1:i+1);
                break;
            end
        end
    end


    %% Construct information arrays from results.
    % Work out the size of the movements from the differences, relative to
    % the time differences.
    normpath = zeros(1, length(T));
    controlpath = zeros(numcontrols, length(T));
    Y1 = Y(1:end-1, :);
    Y2 = Y(2:end, :);
    Ydiff = Y2 - Y1;

    T1 = T(1:end-1);
    T2 = T(2:end);
    Tdiff = T2 - T1;

    pathdiff = transpose(Ydiff(:, 1:end-numcontrols));
    controldiff = transpose(Ydiff(:, end-numcontrols+1:end));

    for i = 1:length(T)-1
        normpath(i) = norm_fn(pathdiff(:, i) / Tdiff(i));
        controlpath(:, i) = controldiff(:, i) / Tdiff(i);
    end

    % We need to redo the last one.
    final_diff = odefun(T(end), transpose(Y(end, :)));
    normpath(end) = norm_fn(final_diff(1:end-numcontrols));
    controlpath(:, end) = final_diff(end-numcontrols+1:end);

    viablepath = zeros(5, length(T));
    for i = 1:length(T)
        x = path(:, i);
        [viablepath(1, i), viablepath(2, i)] = vk_kernel_inside(x, V, ...
            distances, layers);
        exited_on = vk_viable_exited(x, K, f, c, options);
        viablepath(3, i) = any(~isnan(exited_on(:,1)));
        viablepath(4, i) = any(~isnan(exited_on(:,2)));
        viablepath(5, i) = normpath(i) <= small;
    end

    % T should be returned as a row vector.
    T = transpose(T);
end

%% A function that returns the state space, augmented by the control choice.
function ret = vk_sim_simulate_ode_helper(f, control_fn, x)
    u = control_fn(x);
    ret = [f(x, u); u];
end
