%% VK_MAKE_SIMULATION Create the sim_state structure.
%   Makes a call to either TOOLS/VK_SIMULATE_EULER or TOOLS/VK_SIMULATE_ODE
%   and returns the results in a structure, along with the important input
%   arguments.
%
%   Standard Usage:
%   sim_state = VK_4DGUI_MAKE_SIMULATION(start, time_horizon, ...
%       control_fn, V, distances, layers, K, delta_fn, controlmax)
%
%   With additional options:
%   sim_state = VK_4DGUI_MAKE_SIMULATION(start, time_horizon, ...
%       control_fn, V, distances, layers, K, delta_fn, controlmax, OPTIONS)
%
%   'sim_state' should contain the following properties (see See
%   TOOLS/VK_SIMULATE_EULER for details)
%   - 'K': A constraint set, K
%   - 'c': The maximum allowed control.
%   - 'controlpath': A row-vector of control choices.
%   - 'distances': The distances vector.
%   - 'layers': The layers vector.
%   - 'normpath': A row-vector of norms.
%   - 'path': The state-space path.
%   - 'small': The velocity at which the system is considered steady.
%   - 'start': The starting point.
%   - 'T': A row-vector of times.
%   - 'time_horizon': The ending time (planned -- if 'sim_stopsteady' is
%     specified, this may not be the same as T(end)).
%   - 'V': A viability kernel
%   - 'viablepath': Information about the viability of each point.
%
% See also: VIKAASA, GUI, TOOLS/VK_SIMULATE_EULER, TOOLS/VK_SIMULATE_ODE
function sim_state = vk_make_simulation(project, varargin)

    %% Extract settings from project.
    start = project.sim_start;
    time_horizon = project.sim_iterations;
    V = project.V;
    distances = vk_make_distances(project.K, project.discretisation);
    layers = project.layers;
    K = project.K;
    f = vk_make_diff_fn(project);
    c = project.c;

    %% Build a control function from 'sim_controlalg'.
    info = struct( ...
      'V', V, ...
      'distances', distances, ...
      'layers', layers ...
    );
    control_fn = vk_eval_control_fn(project.sim_controlalg, info);

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
