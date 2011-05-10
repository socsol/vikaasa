%% VK_VIABLE_EXITED Indicate whether a point has exited the constraint set.
%   This function returns a list of axes on which the point has violated
%   the given constraint set.  If the number is negative, the lower bound
%   is violated; if the number is positive, the upper bound is violated.
%
%   It is also possible for this function to return zero in the list.  Zero
%   means that a custom constraint set function was used, in which case it
%   is impossible to know which axis the crash occurred on.
%
%   Standard usage:
%   exited_on = VK_VIABLE_EXITED(x, K, f, c);
%
%   With optional params:
%   exited_on = VK_VIABLE_EXITED(x, K, f, c, OPTIONS);
%
%   - 'exited_on' is a row-vector of numbers.  Each number is either zero,
%     or it represents an axis.  If the number is negative, then that
%     indicates that the lower bound was violated.  If it's positive then
%     the upper bound was violated.
%
% See also: VIABLE, VIABLE/VK_VIABLE, OPTIONS/VK_OPTIONS
function exited_on = vk_viable_exited(x, K, f, c, varargin)

    options = vk_options(K, f, c, varargin{:});
    
    % If we use the custom constraint set, check that first. If that
    % returns false, then give up.
    if (options.use_custom_constraint_set_fn)
        vars = num2cell(x);
        if (~options.custom_constraint_set_fn(vars{:}))
            exited_on = 0;
            return;
        end
    end

    exited_on = zeros(1, length(K));
    count = 0;
    for i = 1:length(K)/2
        if (x(i) < K(2*i  - 1))
            count = count + 1;
            exited_on(count) = -i;
        elseif (x(i) > K(2*i))
            count = count + 1;
            exited_on(count) = i;
        end
    end
    
    % Truncate.
    exited_on = exited_on(:, 1:count);
end
