fprintf('TESTING CONSISTENCY OF VK_VIABLE AND VK_SIMULATE_EULER...\n');
fprintf('=========================================================\n\n');
fprintf('This test will load the disc=51 3D kernel and test the outcome of\n');
fprintf('viability-testing that point against the results of a\n');
fprintf('stop-when-steady Euler simulation.\n\n');

%% Goto vk root and setup path
cd ../;
addpath Tools ControlAlgs VControlAlgs;


%% Load viability kernel data.
load('Projects/3D_closed_economy_disc=51,tol=0.0001.mat');


%% Settings
% Position to test.
posn = sim_start

% control algorithm.
control_fn = @vk_control_minin1


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
    'steps', 1, ...
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

%% Run the viability algorithm
fprintf('\n1) Testing vk_viable algorithm ...\n');
fprintf('----------------------------------\n\n');
[viable, paths] = vk_viable(posn, constraint_set, delta_fn, controlmax, options);

viable_path = paths.posn_path;
viable_controlpath = transpose(paths.control_path);

fprintf('Point is viable: %i\n', viable);

fprintf('Path taken (sequence of column vectors):\n');
viable_path

fprintf('Controls applied (row of integers):\n');
viable_controlpath

fprintf('Differences between the differences in the third parameter, and the recorded control:\n');
viable_path(3, 2:end)-viable_path(3, 1:end-1) - viable_controlpath(1:end-1)


%% Setup distances -- copied from vk_4dgui
% This array gives the distance between points, in each direction.
distances = zeros(1, length(constraint_set)/2);
for i = 1:length(constraint_set)/2
    distances(i) = (constraint_set(2*i) - constraint_set(2*i - 1)) ...
        / (discretisation-1);
end


%% Run the simulation
fprintf('\n2) Testing vk_simulate_euler algorithm...\n');
fprintf('-----------------------------------------\n\n');
[~, sim_path, sim_normpath, sim_controlpath, ~] = vk_simulate_euler(...
    posn, sim_iterations, control_fn, V, distances, layers, constraint_set, ...
    delta_fn, controlmax, options);

fprintf('Path taken (sequence of column vectors):\n');
sim_path

fprintf('Controls applied (row of integers):\n');
sim_controlpath

fprintf('Norm value at each step (row of integers):\n');
sim_normpath

%% Test equality of results
fprintf('\n3) Testing equality of results...\n');
fprintf('---------------------------------\n\n');

fprintf('If all positions are the same, you should see a row of 1''s:\n');
all(sim_path == viable_path)

fprintf('All controls are the same: %i\n', all(sim_controlpath == viable_controlpath));

%% Norm test
fprintf('\n4) Testing that the norm values are correct...\n');
fprintf('----------------------------------------------\n\n');

syms u y pi ii
norm_vals = zeros(1, length(sim_normpath));
for i = 1:length(sim_normpath)
    norm_vals(i) = norm(subs(subs(subs(subs(...
        [-0.02*y - 0.35*(ii - pi), 0.002*y, u],...
        y,viable_path(1,i)),...
        pi,viable_path(2,i)),...
        ii,viable_path(3,i)),...
        u,sim_controlpath(i)));
end

norm_vals

fprintf('Difference between values (= norm_vals - sim_normpath):\n');
norm_vals - sim_normpath

fprintf('All norms are the same as those produced by vk_simulate_euler: %i\n', ...
    all(norm_vals == sim_normpath));


%% Path test
fprintf('\n5) Testing that the path is correct...\n');
fprintf('--------------------------------------\n\n');

path_vals = zeros(3, length(sim_normpath));
path_vals(:,1) = posn;
for i = 2:length(sim_normpath)
    diff = subs(subs(subs(subs(...
        [-0.02*y - 0.35*(ii - pi); 0.002*y; u],...
        y,path_vals(1,i-1)),...
        pi,path_vals(2,i-1)),...
        ii,path_vals(3,i-1)),...
        u,sim_controlpath(i-1));

    path_vals(:,i) = path_vals(:,i-1) + diff;
end

path_vals

fprintf('Path is the same as from vk_viable (should see a row of 1''s if so):\n');
all(path_vals == viable_path)

fprintf('Differences (= path_vals - viable_path):\n');
path_vals - viable_path


%% Control test
fprintf('\n6) Testing that the controls are indeed norm-minimising...\n');
fprintf('----------------------------------------------------------\n\n');

% Go through each of the positions given by and use an analytic solution
% derived with Maple.
control_vals = zeros(1, length(sim_normpath));
for i = 1:length(sim_normpath)
    uopt = subs(subs(subs(...
        -0.054*y-.98*ii+.98*pi, ...
        y,viable_path(1,i)),...
        pi,viable_path(2,i)),...
        ii,viable_path(3,i))

    if (uopt > 0.005)
        control_vals(i) = 0.005;
    elseif (uopt < -0.005)
        control_vals(i) = -0.005;
    else
        control_vals(i) = uopt;
    end
end

fprintf('Control values from the analytical solution:\n');
control_vals

fprintf('Difference from those given by vk_viable (= control_vals - viable_controlpath):\n');
control_vals - viable_controlpath