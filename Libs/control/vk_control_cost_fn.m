%% VK_CONTROL_COST_FN compose cost functions of x, xdot 
%   This function is needed by certain cost-minimising control functions in
%   order to be able to minimise using an un-named vector of variables, instead
%   of a tuple.
%
%   cfn = VK_CONTROL_COST_FN(cost_fn, x, xdot)
%
%   cost_fn would be a function like: @(x,y,z,xdot,ydot,zdot) <function of
%   those vars>, whereas cfn will instead by a function of two variables: x and
%   xdot.
%
% See also: CONTROL, VK_CONTROL_EVAL_FN
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function cost = vk_control_cost_fn(cost_fn, x, xdot)
    vars = num2cell([x;xdot]);
    cost = cost_fn(vars{:});
end
