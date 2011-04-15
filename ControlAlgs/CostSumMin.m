%% COSTSUMMIN Find the control which minimises the sum of costs
%   This function finds the control that minimises the sum of cost function
%   realisations  for some set number of steps.
%
%   - The cost function is given in 'options.cost_fn'.
%   - The number of forward-looking steps is given by 'options.steps'.
%   - If 'options.use_controldefault' is set to 1, then the algorithm will
%     not bother finding an optimal control for the final step, but will
%     instead apply 'options.controldefault'.
%
%   Standard use, with required parameters:
%   u = COSTSUMMIN(x, constraint_set, delta_fn, controlmax)
%
%   With optional parameters.  OPTIONS is either a list of name,value
%   pairs, or a structure created by VK_OPTIONS.
%   u = COSTSUMMIN(x, constraint_set, delta_fn, controlmax, OPTIONS)
%
% See also: CONTROLALGS/COSTMIN, CONTROLALGS/NORMMIN1STEP, TOOLS/VK_OPTIONS
function u = CostSumMin(x, constraint_set, delta_fn, controlmax, varargin)

    % Create options structure if required
    options = vk_options(constraint_set, delta_fn, controlmax, varargin{:});

    steps = options.steps;
    min_fn = options.min_fn;    

    cost_of_nextchange_fn = @(u) vk_costsum_recursive(x, u, steps, ...
        constraint_set, delta_fn, controlmax, options);

    % Minimise our cost function.
    u = min_fn(cost_of_nextchange_fn, -controlmax, controlmax);    
end
    
%% Recursive helper function for COSTSUMMIN
%   This function computes the aggregate cost of continuing some number of
%   steps into the future, given a starting position (x) and a control
%   level (u).  If the constraint set is exited, costs become infinite.
function cost = vk_costsum_recursive(x, u, steps, constraint_set, ...
    delta_fn, controlmax, options)
    
    cost_fn = options.cost_fn;
    min_fn = options.min_fn;
    next_fn = options.next_fn;

    futurex = next_fn(x, u);

    % If there are future steps, we calculate the miniumum cost of all
    % future steps, given futurex.
    if (steps == 0)
        future_costs = 0;
    elseif (steps == 1 && options.use_controldefault)
        future_costs = cost_fn( ...
            next_fn(futurex, options.controldefault), ...
            delta_fn(futurex, options.controldefault));
    else
        future_cfn = @(u2) vk_costsum_recursive(...
            futurex, u2, steps - 1, ...
            constraint_set, delta_fn, controlmax, options);
        
        [min_control_int, future_costs] = ...
            min_fn(future_cfn, -controlmax, controlmax);        
    end

    % Then, we add the current cost and return.
    cost = cost_fn(next_fn(x, u), delta_fn(x, u)) + future_costs;
end