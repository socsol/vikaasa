%% SATISFICEMAXMIN Satisficing Viabilty Control Algorithm
%   This control rule does nothing unless it finds itself are in an 'edge'
%   scenario, in which case either the max or min control available is used
%   -- whichever is less costly, according to the cost function.
%
%   To get the statisficing control rule for point x:
%   u = SatisficeMaxMin(info, x, K, f, c);
%
%   info is a structure that must contain:
%       - info.V: A viability kernel
%       - info.distances: An array of distances FIXME
%       - info.layers: How many layers of points before the algorithm
%         considers that it is in an 'edge' scenario.
%
% See also: TOOLS/VK_SIMULATE_EULER, TOOLS/VK_SIMULATE_ODE, TOOLS/VK_VIABLE
function u = SatisficeMaxMin(info, x, K, f, c, varargin)

    options = vk_options(K, f, c, varargin{:});
    
    V = info.V;    
    distances = info.distances;
    layers = info.layers;
    
    norm_fn = options.norm_fn;
    cost_fn = options.cost_fn;
    next_fn = options.next_fn;
    small = options.small;
    if (options.use_controldefault)
        controldefault = options.controldefault;
    else
        controldefault = 0;
    end
        
    % Default -- gets overwritten below, if necessary.
    u = ZeroControl(x, K, f, c, options);
    
    % If doing nothing causes us to move a negligible amount, then stop.
    if (norm_fn(f(x, u)) < small)
        return;
    end
        
    % Otherwise, check to see whether we are on edge.
    [inside, edge] = vk_inkernel(x, V, distances, layers);
       
    % If we are on edge, we need to exert either max, or min.
    if (~inside)        
        cost_min = cost_fn(...
            next_fn(next_fn(x, -c), controldefault), ...
            f(next_fn(x, -c), controldefault));
        cost_max = cost_fn(...
            next_fn(next_fn(x, c), controldefault), ...
            f(next_fn(x, c), controldefault));
        
        if (cost_min < cost_max)
            u = -c;
        else
            u = c;
        end
    end
end
