%% VK_VIABLE_ODE Determines viability of a point using and ODE solver
%
% The algorithm attempts to bring the system to a steady state by applying
% some control (specified in settings).
function varargout = vk_viable_ode(posn, constraint_set, delta_fn, ...
    controlmax, options)

    numvars = options.numvars;    
    maxloops = options.maxloops;
        
    % This is our time discretisation variable.
    h = options.timediscretisation;
    
    norm_fn = options.norm_fn;
    ode_solver = options.ode_solver;
    
    cfn = @(x) options.control_fn(x, ...
            constraint_set, delta_fn, controlmax, options);
        
    odefun = @(t,x) delta_fn(x, cfn(x));
   
    % If we are returning two variables, the second one will be the path
    % that the variable took.
    if (nargout > 1)
        recordpath = true;

        % This is will be filled with column vectors.  However, we will
        % transpose it before returning.
        posn_path = zeros(numvars, maxloops);

        % This is just a column.
        control_path = zeros(maxloops,1);
    else
        recordpath = false;
    end
    
    % If we are to pretest ...
    if (options.pretestposn)
        exited = options.exited_fn(posn, constraint_set);
        if (~isempty(exited))            
            viable = false;
            maxloops = 0; % So as to skip the looping, below.
            posn_path(:, 1) = posn;
            control_path(1) = options.controldefault;
        end
    end

    cnt = 0;
    for l = 1:maxloops
        [T, Y] = ode_solver(odefun, [0, 5], posn);
        
        Y1 = Y(1:end-1, :);
        Y2 = Y(2:end, :);
        Ydiff = Y2 - Y1;
        
        T1 = T(1:end-1);
        T2 = T(2:end);
        Tdiff = T2 - T1;
        
        viable = -1;
        for i = 1:size(Y, 1)-1
            x = transpose(Y(i, :));
            
            if (~isempty(options.exited_fn(x, constraint_set)))
                viable = 0;
                break;
            end
            
            if (norm_fn(Ydiff(i)/Tdiff(i)) <= options.small)
                viable = 1;
                break;
            end            
        end

        % If we get to the last value, then we test to see if it is inside.
        if (viable == -1)
            x = transpose(Y(end, :));
            if (~isempty(options.exited_fn(x, constraint_set)))
                viable = 0;
            end
        end
        
        % If viable is 1 or 0, we are done.
        if (viable == 1 || viable == 0)
            break;
        end                
        
        if (l == maxloops)
            fprintf('Maxloops exceeded\n');
            viable = false;
        end                
        
        % Update posn for next iteration.
        posn = transpose(Y(end, :));
    end
        
    % Return the viability of the point.
    varargout{1} = viable;

    % Potentially return extra info too, if requested.
    if (nargout > 1)
        paths = struct;
        paths.posn_path = posn_path(:, 1:l);
        paths.control_path = control_path(1:l, :);
        
        if (viable == false)
            paths.exited = vk_exited(posn, constraint_set);
        end

        varargout{2} = paths;
    end
end
