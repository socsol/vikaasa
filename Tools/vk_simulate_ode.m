%% VK_SIMULATE_ODE Simulate system trajectory using a MATLAB ODE solver
%   Simulates the path that the system would take over some number of
%   periods, given a starting point, and using some specified control
%   algorithm.
%
%   This function takes and returns identical arguments to
%   TOOLS/VK_SIMULATE_EULER, but it uses an ODE solver (e.g., ODE45)
%   instead of an Euler approximation.  This means that it is generally
%   slower, but more accurate for most purposes.
%
%   The ODE solver that this function uses is given by the 'ode_solver_name'
%   option.  This is a string, which TOOLS/VK_OPTIONS takes to construct a
%   wrapper around the specified ODE solver.  By default this is set to
%   'ode45'.  See the examples below for how you could change this to use a
%   different solver.
%
%   It is also possible to entirely replace the wrapper by specifying the
%   'ode_solver' option.  See the examples.
%
%   Standard usage:
%   [T, path, normpath, controlpath, viablepath] = VK_SIMULATE_ODE(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  delta_fn, controlmax)
%
%   With optional extras added:
%   [T, path, normpath, controlpath, viablepath] = VK_SIMULATE_ODE(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  delta_fn, controlmax, OPTIONS)
%
%   See TOOLS/VK_SIMULATE_EULER for a description of all the arguments.
%
% Examples
%   % Use ode23 instead of ode45:
%   [T, path, normpath, controlpath, viablepath] = VK_SIMULATE_ODE(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  delta_fn, controlmax, 'ode_solver_name', 'ode23');
%
%   % Or, with other options:
%   options = vk_options(K,  delta_fn, controlmax, ...
%       'ode_solver_name', 'ode23', ...
%       'stepsize', 0.5, ...
%       'sim_stopsteady', 1);
%   [T, path, normpath, controlpath, viablepath] = VK_SIMULATE_ODE(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  delta_fn, controlmax, options);
%
%   % Use a custom-made ODE solver:
%   myodesolver = @(fn, T, x0) somefunction(fn, x0);
%   [T, path, normpath, controlpath, viablepath] = VK_SIMULATE_ODE(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  delta_fn, controlmax, 'ode_solver', myodesolver);
%   
% See also: CONTROLALGS, VCONTROLALGS, TOOLS, TOOLS/VK_COMPUTE,
%   TOOLS/VK_INKERNEL, TOOLS/VK_OPTIONS, TOOLS/VK_SIMULATE_EULER
function [T, path, normpath, controlpath, viablepath] = vk_simulate_ode(...
    start, time_horizon, control_fn, V, distances, layers, ...
    K, delta_fn, controlmax, varargin)

    %% Create options structure
    options = vk_options(K, delta_fn, controlmax, varargin{:});
    
    
    %% Options we care about here
    ode_solver = options.ode_solver;
    bound_fn = options.bound_fn;
    norm_fn = options.norm_fn;
    small = options.small;
    
    
    %% Create the function for use with the ODE solver.
    odefun = @(t, x0) delta_fn(x0, ...
        bound_fn(x0, ...
            control_fn(x0, K, delta_fn, controlmax, options), ...
            K, delta_fn, controlmax, options));            
            
        
    %% Run the ODE solver.
    [T, Y] = ode_solver(odefun, [0, time_horizon], start);
    path = transpose(Y);
    
    
    %% We don't bother to record the control path.
    % To do so would require re-evaluating all of the control choices
    % again.
    controlpath = 0; 
    
    
    %% Construct information arrays from results.
    % Work out the size of the movements from the differences, relative to
    % the time differences.
    normpath = zeros(1, length(T));
    Y1 = Y(1:end-1, :);
    Y2 = Y(2:end, :);
    Ydiff = Y2 - Y1;

    T1 = T(1:end-1);
    T2 = T(2:end);
    Tdiff = T2 - T1;
    
    for i = 1:length(T)-1       
        normpath(i) = norm_fn(Ydiff(i, :) / Tdiff(i));
    end
    % We need to redo the last one.
    normpath(end) = norm_fn(odefun(T(end), path(:, end)));
    
    viablepath = zeros(4, length(T));    
    for i = 1:length(T)
        x = path(:, i);
        [viablepath(1, i), viablepath(2, i)] = vk_inkernel(x, V, ...
            distances, layers);
        viablepath(3, i) = ~isempty(vk_exited(x, K, delta_fn, controlmax, options));
        viablepath(4, i) = normpath(i) <= small;
    end
end