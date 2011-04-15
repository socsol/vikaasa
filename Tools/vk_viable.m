%% VK_VIABLE Determine the viability of a point, x
%   The algorithm attempts to bring the system to a near-steady state by
%   applying a bounded control.
%
%   The function returns one or two values.  The second value is a
%   structure that gives information about how the point was determined
%   viable or non-viable.
%
%   Standard usage:
%   isviable = VK_VIABLE(x, K, delta_fn, controlmax);
%
%   With an OPTIONS structure created by TOOLS/VK_OPTIONS:
%   isviable = VK_VIABLE(x, K, delta_fn, controlmax, OPTIONS);
%
%   Returning additional information:
%   [isviable, paths] = VK_VIABLE(x, K, delta_fn, controlmax, OPTIONS);
%
% See also: CONTROLALGS, TOOLS, TOOLS/VK_COMPUTE, TOOLS/VK_OPTIONS
function varargout = vk_viable(x, K, delta_fn, controlmax, varargin)

    %% Construct options
    options = vk_options(K, delta_fn, controlmax, varargin{:});

    
    %% Options of interest
    numvars = options.numvars;    
    maxloops = options.maxloops;
    cancel_test = options.cancel_test;
    small = options.small;
    
    norm_fn = options.norm_fn;
    next_fn = options.next_fn;
    cancel_test_fn = options.cancel_test_fn;
    
    
    %% Construct a control function
    % This control function will be bounded by the bound_fn, so that it
    % does not unnecessarily choose any control that causes an immediate
    % crash.  The bound_fn also returns non-viability of the point.
    control_fn = @(x) options.bound_fn(x, ...
        options.control_fn(x, K, delta_fn, controlmax, options), ...
        K, delta_fn, controlmax, options);
   
    
    %% Can additionall return the path taken in determining viability
    if (nargout > 1)
        recordpath = true;

        % This is will be filled with column vectors.  However, we will
        % transpose it before returning.
        path = zeros(numvars, maxloops);

        % This is just a column.
        control_path = zeros(maxloops,1);
    else
        recordpath = false;
    end

    
    %% Check if we pretest x for viability
    % If we do, and the point turns out to be non-viable, we set maxloops
    % to 0 to skip the main loop.
    if (options.use_custom_constraint_set_fn)
        exited_on = vk_exited(x, K, delta_fn, controlmax, options);
        if (~isempty(exited_on))            
            viable = false;
            maxloops = 0;
            path(:, 1) = x;
            control_path(1) = 0;
        end
    end

    
    %% The main loop
    for l = 1:maxloops
        
        %% Record the position.
        if (recordpath)
            path(:, l) = x;
        end       
                
        %% Find control for point x
        [u, crashed, exited_on] = control_fn(x);
                
        %% Record the new control.
        if (recordpath)
            control_path(l) = u;
        end
            
        %% Check stopping criteria
        % Either, the algorithm has decided that the point is or isn't
        % viable, the maximum number of loops has been reached, or the user
        % has intervened.
        if (crashed || (cancel_test && cancel_test_fn()))
            viable = false;
            break;
        elseif (l == maxloops)
            fprintf('Maxloops exceeded\n');
            viable = false;
            break;
        elseif (norm_fn(delta_fn(x, u)) <= small)
            viable = true;
            break;
        end
        
        %% Update x for next iteration.
        x = next_fn(x, u);
    end
        
    
    %% Return the viability of the point.
    varargout{1} = viable;
    
    %% Potentially return extra info too, if requested.
    if (nargout > 1)
        paths = struct;
        paths.path = path(:, 1:l);
        paths.control_path = control_path(1:l, :);
        
        if (viable == false)
            paths.exited_on = exited_on;
        end

        varargout{2} = paths;
    end
end