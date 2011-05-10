%% NORMMIN1STEP Fast 1-step norm-minimising control function
%   This function returns the control that minimises the norm of the
%   system velocity in one step.
%
%   It has the advantage that it is faster than using COSTMIN, but it is
%   less flexible.  Firstly, it cannot be used for more than one step.
%   Secondly, it uses 'controldefault' to avoid the issue of having to
%   optimise for the control-in-one-step.  This is fast, but it may not
%   make sense in a non-linear dynamic system.
%
%   Standard use with required arguments:
%   u = NORMMIN1STEP(x, constraint_set, delta_fn, controlmax)
%
%   With options passed in. OPTIONS is either a list of 'name', value pairs,
%   or a structure created by VK_OPTIONS.
%   u = NORMMIN1STEP(x, constraint_set, delta_fn, controlmax, OPTIONS)
%
% See also: CONTROLALGS/COSTMIN, CONTROLALGS/COSTSUMMIN, TOOLS/VK_OPTIONS
function min_control = NormMin1Step(x, constraint_set, delta_fn, ...
    controlmax, varargin)

    options = vk_options(constraint_set, delta_fn, controlmax, varargin{:});

    controldefault = options.controldefault;
   
    min_fn = options.min_fn;
    cost_fn = @norm;
    next_fn = options.next_fn;

    % Check that doing nothing doesn't produce exactly zero movement.
    % If it does, then we are already at a steady state.
    if (delta_fn(x, controldefault) == 0)
        min_control = controldefault;
    else
        % Otherwise, the 'best' control is found by minimizing the
        % size of the next change that the default control gives.
        cost_of_nextchange_fn = @(u) cost_fn( ...
            delta_fn(next_fn(x, u), controldefault));

        % Minimise our new cost function.
        min_control = ...
            min_fn(cost_of_nextchange_fn, -controlmax, controlmax);            
    end
end