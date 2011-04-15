load('4D_small_open_economy_disc=11,tol=0.001.mat');

slices = [slice1, slice1plane(slice1), (constraint_set(2*slice1) - constraint_set(2*slice1 - 1))/discretisation];


x = [0; 0.02; 0.03; 0];
delta_fn = @test_delta3;

cfn = @(x, V, constraint_set, delta_fn, controlmax, ...
             options) vk_control_minsum(x, constraint_set, delta_fn, ...
             controlmax, options);

options = vk_options(constraint_set, delta_fn, controlmax, ...
    'steps', 2, ...
    'controltolerance', 1e-17);

vk_make_simulation(x, 20, cfn, V, 11, labels, plotcolour, 'qhull', ...
    constraint_set, delta_fn, controlmax, slices, options);