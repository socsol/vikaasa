%% VK_COST_FN compose cost functions of x, xdot 
%   Detailed explanation goes here
function cost = vk_cost_fn(cost_fn, x, xdot)
    vars = num2cell([x;xdot]);
    cost = cost_fn(vars{:});
end