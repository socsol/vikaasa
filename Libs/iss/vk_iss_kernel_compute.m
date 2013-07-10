function [V, NV, viable_paths, nonviable_paths] = vk_iss_kernel_compute(K, ...
                                                  f, c, varargin)

    options = vk_options(K, f, c, varargin{:});


    %% iss_solve
    cost_fn = @(u, varargin) u * u';

    % The ISS delta_fn is a slightly different format.
    delta_fn = @(u,x,t) f(x',u')';

    discretisation = options.discretisation;

    vectors = cell(1,options.numvars);
    state_lb = zeros(1, options.numvars);
    state_ub = zeros(1, options.numvars);
    state_step = zeros(1, options.numvars);

    for d = 1:options.numvars
        vectors{d} = linspace(K(2*d - 1), K(2*d), discretisation(d));
        state_step(d) = (K(2*d) - K(2*d - 1)) / (discretisation(d) - 1);
        
        state_lb(d) = vectors{d}(1) - state_step(d);
        state_ub(d) = vectors{d}(end) + state_step(d);
    end

    conf = iss_conf(state_lb, state_ub, ...
                    'StateStepSize', state_step, ...
                    'TimeStep', 1', ...
                    'DiscountRate', 0.1, ...
                    'ControlLB', -c, ...
                    'ControlUB', c, ...
                    'UserConstraintFunctionFile', @vk_iss_constraints);

    % Add the basic set-up to the config.
    conf.vk_K = K;
    conf.vk_f = f;
    conf.vk_c = c;
    conf.vk_opts = options;

    fprintf(1, 'Running InfSOCSol ...\n');

    tic
    [ocm ignore1, ignore2, flags] = iss_solve(delta_fn, cost_fn, state_lb, ...
                                              state_ub, conf);
    toc


    %% iss_sim

    % Work out which coordinates got "bad" flags
    flagged_coords = zeros(conf.TotalStates, options.numvars + 1);

    % Lists of viable and non-viable points and trajectories
    V = zeros(conf.TotalStates, options.numvars);
    viable_paths = cell(conf.TotalStates, 1);
    viable_count = 0;

    NV = zeros(conf.TotalStates, options.numvars);
    nonviable_paths = cell(conf.TotalStates, 1);
    nonviable_count = 0;

    viable_fn = @vk_iss_viable;
    T = cumsum([0, conf.Options.SimulationTimeStep]);

    fprintf(1, 'Running InfSim ...\n');
    tic
    for StateNum = 1:conf.TotalStates
        StateVect=SnToSVec(StateNum,conf.CodingVector,conf.Dimension);
        row = (StateVect-1) .* conf.Options.StateStepSize + state_lb;
        flag = flags(StateNum);
        
        fprintf([num2str(row), '\n']);
        
        % Skip if the flag has any of these values
        if flag == 0 || flag == -2 || flag == -3
            continue;
        end
        
        % Check for viability as well
        if viable_fn(0, row, 0, conf) > 0
            continue;
        end
        
        [simulated_value, path, deltapath, controlpath] = iss_sim(row, ocm, delta_fn, ...
                                                     viable_fn, state_lb, ...
                                                     state_ub, conf);
        
        paths = struct;
        paths.T = T;
        paths.path = path';
        paths.controlpath = [controlpath', zeros(options.numcontrols, 1)];
        paths.viablepath = zeros(5, length(paths.T));
        paths.normpath = zeros(1, length(paths.T));
        
        deltapath = [deltapath', f(paths.path(:,end), paths.controlpath(:,end))];
        
        for i = 1:length(paths.T)
            exited_on = vk_viable_exited(paths.path(:,i), K, f, c, options);
            paths.viablepath(3, i) = any(~isnan(exited_on(:,1)));
            paths.viablepath(4, i) = any(~isnan(exited_on(:,2)));
            
            paths.normpath(i) = options.norm_fn(deltapath(:,i));
            paths.viablepath(5, i) = paths.normpath(i) <= options.small;
        end
        
        
                
        if simulated_value == 0
            viable_count = viable_count + 1;
            V(viable_count, :) = row;
            viable_paths{viable_count} = paths;
        else
            nonviable_count = nonviable_count + 1;
            NV(nonviable_count, :) = row;
            nonviable_paths{nonviable_count} = paths;
        end
    end

    V = V(1:viable_count, :);
    viable_paths = viable_paths(1:viable_count);

    NV = NV(1:nonviable_count, :);
    nonviable_paths = nonviable_paths(1:nonviable_count);

    toc
end


