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
                    'UserConstraintFunctionFile', @vk_iss_constraints, ...
                    'FminconOptions', {'Algorithm', 'sqp'});

    % Add the basic set-up to the config.
    conf.vk_K = K;
    conf.vk_f = f;
    conf.vk_c = c;
    conf.vk_opts = options;

    fprintf(1, 'Running InfSOCSol ...\n');

    [ocm ignore1, ignore2, flags] = iss_solve(delta_fn, cost_fn, state_lb, ...
                                              state_ub, conf);


    %% iss_sim

    % Work out which coordinates got "bad" flags
    flagged_coords = zeros(conf.TotalStates, options.numvars + 1);

    viable_fn = @vk_iss_viable;
    T = cumsum([0, conf.Options.SimulationTimeStep]);

    fprintf('Running InfSim ...\n');
    [value_cells, row_cells, path_cells] = options.cell_fn(@(flag, ...
                                                      state_num) ...
                                                      vk_iss_kernel_compute_cellfn(T, flag, state_num, ocm, delta_fn, viable_fn, state_lb, state_ub, conf), num2cell(flags), num2cell(1:conf.TotalStates));

    values = cell2mat(value_cells);
    
    viable_idx = find(values == 0);
    nonviable_idx = find(values > 0);
    
    % Lists of viable and non-viable points and trajectories
    V = zeros(length(viable_idx), options.numvars);
    viable_paths = cell(length(viable_idx), 1);
    viable_count = 0;

    NV = zeros(length(nonviable_idx), options.numvars);
    nonviable_paths = cell(length(nonviable_idx), 1);
    nonviable_count = 0;

    for i = viable_idx
        viable_count = viable_count + 1;
        V(viable_count, :) = row_cells{i};
        viable_paths{viable_count} = path_cells{i};
    end
    
    for i = nonviable_idx
        nonviable_count = nonviable_count + 1;
        NV(nonviable_count, :) = row_cells{i};
        nonviable_paths{nonviable_count} = path_cells{i};
    end
end

function [value, row, paths] = vk_iss_kernel_compute_cellfn(T, ...
                                                      flag, ...
                                                      state_num, ...
                                                      ocm, delta_fn, ...
                                                      viable_fn, ...
                                                      state_lb, ...
                                                      state_ub, ...
                                                      conf)

    K = conf.vk_K;
    f = conf.vk_f;
    c = conf.vk_c;
    options = conf.vk_opts;

    StateVect = SnToSVec(state_num, conf.CodingVector, conf.Dimension);
    row = (StateVect-1) .* conf.Options.StateStepSize + state_lb;
    paths = struct;
    
    fprintf([num2str(row), '\n']);
    
    % Skip if the flag has any of these values
    if flag == 0 || flag == -2 || flag == -3
        value = -1.0;
        return;
    end
    
    % Check for viability as well
    if viable_fn(0, row, 0, conf) > 0
        value = -1.0;
        return;
    end
    
    [value, path, deltapath, controlpath] = iss_sim(row, ocm, delta_fn, ...
                                                      viable_fn, state_lb, ...
                                                      state_ub, conf);
    
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
end
