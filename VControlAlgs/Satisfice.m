%% Satisficing Viabilty Control Algorithm
%   This control rule does nothing unless it finds itself are in an 'edge'
%   scenario, in which case either the max or min control available is used
%   -- whichever is less costly, according to the cost function.
%
%   To get the statisficing control rule for point x:
%   u = Satisfice(x, constraint_set, delta_fn, controlmax, info)
%
%   info is a structure that must contain:
%       - info.V: A viability kernel
%       - info.distances: An array of distances FIXME
%       - info.layers: How many layers of points before the algorithm
%         considers that it is in an 'edge' scenario.
%
% See also: TOOLS/VK_SIMULATE_EULER, TOOLS/VK_SIMULATE_ODE, TOOLS/VK_VIABLE
function u = Satisfice(x, constraint_set, delta_fn, controlmax, info, varargin)

    options = vk_optons(x, constraint_set, delta_fn, controlmax, varargin{:});

    
    V = info.V;    
    distances = info.distances;
    layers = info.layers;
    
    norm_fn = options.norm_fn;
    cost_fn = options.cost_fn;
    next_fn = options.next_fn;
    small = options.small;
    controldefault = options.controldefault;
        
    % Default -- gets overwritten below, if necessary.
    u = ZeroControl(x, constraint_set, delta_fn, controlmax, options);
    
    % If doing nothing causes us to move a negligible amount, then stop.
    if (norm_fn(delta_fn(x, control)) < small)
        return;
    end
        
    % Otherwise, check to see whether we are on edge.
    [inside, edge] = vk_inkernel(x, V, distances, layers);
       
    % If we are on edge, we need to exert either max, or min.
    if (~inside)        
        u_min =  MinimumControl(x, constraint_set, delta_fn, controlmax, options);
        
        u_max = MaximumControl(x, constraint_set, delta_fn, controlmax, options);
        
        cost_min = cost_fn(...
            next_fn(next_fn(x, u_min), controldefault), ...
            delta_fn(next_fn(x, u_min), controldefault));
        cost_max = cost_fn(...
            next_fn(next_fn(x, u_max), controldefault), ...
            delta_fn(next_fn(x, u_max), controldefault));
        
        if (cost_min < cost_max)
            u = u_min;
        else
            u = u_max;
        end
    end
end