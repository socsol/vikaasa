%% VK_SIM_SIMULATE_EULER Simulate system trajectory using Euler approximation
%   This funciton simulates the path that the system would take over some
%   number of iterations, given a starting point, and using some specified
%   control algorithm.
%
%   Standard usage:
%   [T, path, normpath, controlpath, viablepath] = VK_SIM_SIMULATE_EULER(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  f, c)
%
%   Return arguments are:
%   - 'T': Row-vector of time values, starting with zero.
%
%   - 'path': numvars x length(T) matrix.  Each column represents a
%     the state-space position of the system at the time in the
%     correponding element in T.  Thus for instance, path(0,:) = x.
%
%   - 'normpath': A row-vector, of same length as T, giving the value of
%     the norm (as specified by the 'norm_fn' option in TOOLS/VK_OPTIONS)
%     velocity of the system at each point in time.
%
%   - 'controlpath': A row-vector, of same length as T, giving the control
%     choice at each point in time.
%
%   - 'viablepath': 4 x length(T) matrix.  Each column represents four
%     information flags (1 or 0) for that point in time:
%     1) Whether or not the point is inside the kernel, V.  See
%        TOOLS/VK_INKERNEL for how this is computed.
%     2) Whether or not the point is considered to be an 'edge' point.  See
%        TOOLS/VK_INKERNEL for info on this.
%     3) Whether or not the point is outside of the constraint set.
%     4) Whether or not the system velocity is slow enough for the point to
%        be considered steady.
%
%   Input arguments are:
%   - 'x': A column vector of length numvars, specifying the starting point
%     of the simulation.
%
%   - 'time_horizon': A number > 0, specifying the end time of the
%     simulation.  The start time is always 0.
%
%   - 'control_fn': See CONTROLALGS for a specification of this function.
%
%   - 'V': A viability kernel.  This is used to give information about the
%     system trajectory in relation to the kernel (through the 'viablepath'
%     return variable).  If you don't care about this, you can specify an
%     empty matrix, [] as the kernel.
%
%   - 'distances': A row vector of length numvars, giving the distance
%     between points in V in each dimension.  See TOOLS/VK_INKERNEL for an
%     explanation of this.
%
%   - 'layers': See TOOLS/VK_INKERNEL for an explanation.
%
%   - 'K': A constraint set.  See TOOLS/VK_COMPUTE for the format of this.
%
%   - 'f': A set of difference equations. See TOOLS/VK_COMPUTE for
%     the format of this.
%
%   - 'c': The absolute maximum size of the control.
%
%   Usage with additional options:
%   [T, path, normpath, controlpath, viablepath] = VK_SIM_SIMULATE_EULER(...
%       x, time_horizon, control_fn, V, distances, layers, ...
%       K,  f, c, OPTIONS)
%
%   OPTIONS is either a structure created by TOOLS/VK_OPTIONS, or otherwise
%   a set of (name, 'value') pairs.
%
%   An imporant option for VK_SIM_SIMULATE_EULER is 'sim_stopsteady', which
%   causes the simulation to terminate as soon as a steady state is
%   encountered, instead of waiting.
%
% See also: CONTROLALGS, VCONTROLALGS, KERNEL/VK_KERNEL_COMPUTE,
%   KERNEL/VK_KERNEL_INSIDE, OPTIONS/VK_OPTIONS, SIM/VK_SIM_SIMULATE_ODE
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
    
    
    %% Create the bounded control function
    fn = vk_control_wrap_fn(control_fn, K, f, c, options);
    
    
    %% Set up information variables
    h = options.timediscretisation;
    T = 0:h:time_horizon;
    iterations = length(T);    
    
    % Time goes along the column axis.
    path = zeros(length(K)/2, iterations);
    normpath = zeros(1, iterations);
    controlpath = zeros(1, iterations);
    viablepath = zeros(4, iterations);

    
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
        viablepath(3, i) = ~isempty(vk_viable_exited(x, K, f, c, options));
        
        
        %% Record velocity and steadyness
        norm_val = norm_fn(f(x, u));
        steady = norm_val <= options.small;
        viablepath(4, i) = steady;
        normpath(i) = norm_val;
                
        
        %% Report to progress (bar) if necessary
        if (report_progress)
            progress_fn(T(i));
        end
        
        
        %% Stop if necessary
        if (sim_stopsteady && steady)
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
