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
function sim_state = vk_make_simulation(start, time_horizon, ...
    control_fn, V, distances, layers, K, f, c, varargin)  

    %% Make options
    options = vk_options(K, f, c, varargin{:});

    sim_fn = options.sim_fn;
    
    %% Run simulation
    [T, path, normpath, controlpath, viablepath] = sim_fn(start, time_horizon, ...
        control_fn, V, distances, layers, K, f, c, options);
    
    %% Make the sim_state
    sim_state = struct(...
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
        'small', options.small ...
    );    
end