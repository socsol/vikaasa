%% VK_DIFF_FN Returns the vector of derivatives for a state-space and control
%   This function returns a column vector of derivatives.  You don't need
%   to use this function directly.  Instead, call VK_MAKE_DIFF_FN
%
% See also: VK_MAKE_DIFF_FN
function xdot = vk_diff_fn(f, x, u)
    args = num2cell(x);    
    xdot = f(args{:}, u);
end
