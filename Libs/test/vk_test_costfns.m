%% Cost function realisations.


%% Goto vk root and setup path
cd ../

addpath Tools ControlAlgs;

%% Load viability kernel data.
load('Projects/vk_4dgui_default.mat');

%% Options
discretisation = 11;
steps = 2;
control_fn = @CostMinMultistep;

cost_functions = {...
    @(y, pi, i, dy, dpi, di) norm([dy, dpi, di]), ... Norm-min
    @(y, pi, i, dy, dpi, di) y^2 + (i - pi)^2, ... Quadratic costs
    @(y, pi, i, dy, dpi, di) y^2 + (i - pi)^2 + norm([dy, dpi, di]), ... Both
};

%% Make the delta_fn -- cut-pasted from vk_4dgui

% Arguments
args = mat2cell(symbols,ones(1,size(symbols,1)),size(symbols,2));

% Create inline functions for the differential equations.
diff_eqn_strs = diff_eqn;

diff_eqns = cell(size(diff_eqn_strs,1), 1);
for i = 1:size(diff_eqn_strs,1)
    diff_eqns{i} = inline(diff_eqn_strs(i,:), args{:}, controlsymbol);
end

delta_fn = @(x,u) vk_delta_fn(diff_eqns, x, u);


%% Make options -- cut-pasted from vk_4dgui
options = vk_options(constraint_set, delta_fn, controlmax, ...
    'debug', 0, ...
    'steps', steps, ...
    'control_fn', control_fn, ...
    'controlsymbol', controlsymbol, ...
    'discretisation', discretisation, ...
    'numvars', numvars, ...
    'controltolerance', controltolerance, ...
    'sim_fn', @vk_simulate_euler, ...
    'sim_stopsteady', 1, ...
    'stoppingtolerance', stoppingtolerance, ...
    'timediscretisation', timediscretisation ...
    );


%% Create axes
xax = linspace(constraint_set(1), constraint_set(2), discretisation);
yax = linspace(constraint_set(3), constraint_set(4), discretisation);
zax = linspace(constraint_set(5), constraint_set(6), discretisation);

%% Create a mesh
[xmesh,ymesh,zmesh] = meshgrid(xax, yax, zax);

%% Empty vars for the loop to populate
control = cell(1, length(cost_functions));
xvel = cell(1, length(cost_functions));
yvel = cell(1, length(cost_functions));
zvel = cell(1, length(cost_functions));
cost = cell(1, length(cost_functions));

d = @(x,y,z,u) delta_fn([x;y;z], u);

%% Loop through cost functions, and work out the minimised costs.
for i = 1:length(cost_functions)
    i
    cost_fn = cost_functions{i};
    options.cost_fn = @(x, dx) vk_cost_fn(cost_fn, x, dx);

    u = @(x, y, z) control_fn([x;y;z], ...
        constraint_set, delta_fn, controlmax, options);

    control{i} = arrayfun(u, xmesh, ymesh, zmesh);

    vectors = arrayfun(d, xmesh, ymesh, zmesh, control{i}, 'UniformOutput', 0);
    xvel{i} = cellfun(@(x) x(1), vectors);
    yvel{i} = cellfun(@(x) x(2), vectors);
    zvel{i} = cellfun(@(x) x(3), vectors);

    cost{i} = arrayfun(cost_fn, ...
        xmesh, ymesh, zmesh, ...
        xvel{i}, yvel{i}, zvel{i});
end


%% Loop through the results and display a chart of the costs.
for i = 1:length(cost_functions)
    figure;
    title(['Costs ', num2str(i)]);
    axis(constraint_set);
    xlabel(labels(1, :));
    ylabel(labels(2, :));
    zlabel(labels(3, :));
    view(3);

    hold on;

    slice(xmesh, ymesh, zmesh, cost{i}, ...
        linspace(constraint_set(1), constraint_set(2), 3), ...
        constraint_set(3) + (constraint_set(4) - constraint_set(3))/2, ...
        constraint_set(5) + (constraint_set(6) - constraint_set(5))/2, ...
        'nearest');

    colormap('autumn');
end