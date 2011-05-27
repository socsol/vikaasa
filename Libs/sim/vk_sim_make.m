%% VK_SIM_MAKE Create the `sim_state' structure.
%
% SYNOPSIS
%   Makes a call to either vk_sim_simulate_euler or vk_sim_simulate_ode
%   and returns the results in a structure, along with the important input
%   arguments.
%
% USAGE
%   % Standard Usage:
%   sim_state = vk_sim_make(project)
%
%   % With additional options:
%   sim_state = vk_sim_make(project, options)
%
%   The `project' should be a standard VIKAASA project structure.
%
%   `options' can be a structure created with vk_options, or a series of
%   name:value pairs, or both (the former before the latter).
%
%   `sim_state' should contain the following properties (see See
%   vk_sim_simulate_euler for more details):
%   - `K': A constraint set.
%   - `c': The maximum control size.
%   - `controlpath': A row-vector of control choices.
%   - `distances': The distances vector.
%   - `layers': The layers vector.
%   - `normpath': A row-vector of norms.
%   - `path': The state-space path.
%   - `small': The velocity at which the system is considered steady.
%   - `start': The starting point.
%   - `T': A row-vector of times.
%   - `time_horizon': The ending time (planned -- if `sim_stopsteady' is
%     specified, this may not be the same as `T(end)').
%   - `V': A viability kernel
%   - `viablepath': Information about the viability of each point.
%
% See also: vikaasa, project, sim, vk_sim_simulate_euler, vk_sim_simulate_ode

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
function sim_state = vk_sim_make(project, varargin)

    %% Extract settings from project.
    start = vk_sim_start(project);
    time_horizon = project.sim_iterations;
    V = project.V;
    distances = vk_kernel_distances(project.K, project.discretisation);
    layers = project.layers;
    K = project.K;
    f = vk_diff_make_fn(project);
    c = project.c;

    %% Build a control function from 'sim_controlalg'.
    info = struct( ...
      'V', V, ...
      'distances', distances, ...
      'layers', layers ...
    );
    control_fn = vk_control_make_fn(project.sim_controlalg, info);

    %% Make options.
    options = vk_options(K, f, c, varargin{:});

    %% The simulation function to use.
    sim_fn = options.sim_fn;

    %% Print debugging information
    if (project.debug)
        % Output the settings to the screen for debugging.
        K
        f
        c
        options
    end

    %% Run the simulation
    cl = fix(clock);
    tic;
    fprintf('RUNNING SIMULATION\n');
    success = 0; err = 0;
    try

        [T, path, normpath, controlpath, viablepath] = sim_fn(start, time_horizon, ...
            control_fn, V, distances, layers, K, f, c, options);

        if (options.cancel_test_fn())
            fprintf('CANCELLED\n');
        else
            fprintf('FINISHED\n');
            success = 1;
        end
    catch
        err = lasterror();
        fprintf('ERROR: %s\n', err.message);
        T = 0;
        path = 0;
        normpath = 0;
        controlpath = 0;
        viablepath = 0;
    end

    comp_time = toc;
    comp_datetime = ...
        sprintf('%i-%i-%i %i:%i:%i', cl(1), cl(2), cl(3), cl(4), cl(5), cl(6));

    %% Make the sim_state
    sim_state = struct(...
        'success', success, ...
        'error', err, ...
        'T', T, ...
        'path', path, ...
        'normpath', normpath, ...
        'controlpath', controlpath, ...
        'viablepath', viablepath, ...
        'start', start, ...
        'time_horizon', time_horizon, ...
        'V', V, ...
        'K', K, ...
        'distances', distances, ...
        'layers', layers, ...
        'c', c, ...
        'small', options.small, ...
        'comp_time', comp_time, ...
        'comp_datetime', comp_datetime ...
    );
end
