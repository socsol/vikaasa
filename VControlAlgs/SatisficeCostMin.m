%% SATISFICECOSTMIN Satisficing control algorithm that uses CostMin at the edge
%   This algorithm is similar to SatisficeMaxMin, except that it uses CostMin
%   to determine what control to use when at the kernel edge.
%
% See also: TOOLS/VK_SIMULATE_EULER, TOOLS/VK_SIMULATE_ODE, TOOLS/VK_VIABLE, VCONTROLALGS/SATISFICEMAXMIN
function u = SatisficeCostMin(info, x, K, f, c, varargin)

    options = vk_options(K, f, c, varargin{:});

    V = info.V;
    distances = info.distances;
    layers = info.layers;

    norm_fn = options.norm_fn;
    cost_fn = options.cost_fn;
    next_fn = options.next_fn;
    small = options.small;

    % Default -- gets overwritten below, if necessary.
    u = ZeroControl(x, K, f, c, options);

    % If doing nothing causes us to move a negligible amount, then stop.
    if (norm_fn(f(x, u)) < small)
        return;
    end

    % Otherwise, check to see whether we are on edge.
    [inside, edge] = vk_kernel_inside(x, V, distances, layers);

    % If we are on edge, we take our control choice from CostMin.
    if (~inside)
        u = CostMin(x, K, f, c, options);
    end
end

