constraint_set = [0, 1, 0, 0.2];
delta_fn = @test_delta;
controlmax = 0.001;

options = vk_options (constraint_set, delta_fn, controlmax,...
    'steps', 2);

u1 = zeros(1, 100);
u2 = zeros(1, 100);
idx = 0;
for i = linspace(0, 1, 100)
    idx = idx + 1;
    x = [i; 0.06];
    u1(idx) = vk_control_minsum(x, constraint_set, delta_fn, controlmax, options);
    u2(idx) = vk_control_minin(x, constraint_set, delta_fn, controlmax, options);
end

figure;
hold on;
plot(linspace(0, 1, 100), u1, '-');
plot(linspace(0, 1, 100), u2, '--');