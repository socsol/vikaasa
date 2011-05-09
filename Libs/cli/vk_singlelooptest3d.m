function vk_singlelooptest3d(point)

fprintf('============\n');
fprintf('RUNNING TEST\n');
fprintf('============\n');

setup = struct;

% number of dimensions
setup.numvars = 3;

% control var's index
setup.controlsymbol = 'u';
setup.controldefault = 0;
setup.tolerance = 1e-4;

%specify constraint sets for each dimension
setup.constraint_set = [-0.04, 0.04, 0.01, 0.03, 0, 0.07];

setup.discretisation = 50;

setup.control_discretisation = 100;

% normvars = zeros(1,setup.numvars)
% for i = [1:setup.controlvar-1, setup.controlvar+1:setup.numvars]
%   normvars(i) = (setup.constraint_set(i * 2) - setup.constraint_set(i * 2 - 1)) / 1000;
% end

setup.small = norm(setup.tolerance * ones(1, 3));

%specify system dynamics
fnx = inline('-0.02*x - 0.35*(z-y)', 'x','y','z', 'u');
fny = inline('0.002*x', 'x', 'y','z', 'u');
fnz = inline('u', 'x', 'y','z', 'u');

setup.diff_eqns = {fnx; fny; fnz};

% The cost function needs to be able to take a column vector and return a number.
setup.cost_fn = @(u) norm(u, 2);

setup.wnorm_fn = @setup.cost_fn;

% The min function needs to provide constrained minimisation.  The
% first argument is a function to minimise; the second and third
% arguments give the minimum and maximum values allowed as inputs to
% the function.
%setup.min_fn = @(f, minimum, maximum) ...
%    vk_fminbnd(f, minimum, maximum, setup.control_discretisation);
min_fn_opts = struct;
min_fn_opts.TolX = setup.tolerance;
setup.min_fn = @(f, min, max) fminbnd(f, min, max, min_fn_opts);

% The zero function is probably just a wrapper around fzero, but with
% tolerance explicitly specified.
setup.zero_fn = @(f, limits) fzero(f, limits, min_fn_opts);

% The delta function takes a column vector, and applies the vector to each
% equation to create a new column vector, which is returned.
setup.delta_fn = @(vector, u) vk_delta_fn(setup.diff_eqns, vector, u);

% The equal function takes a function of our expected diff_eqn form, a
% a vector, a number and an index, and tries to set the function equal to
% the 

% Specify the max for the remaining variable.
setup.controlmax = 0.005;

% Maximum loops allowed
setup.maxloops = 1000;

disp(setup);

%set axis discretisation
% ax = zeros(setup.numvars,setup.discretisation);
% for i = 1:setup.numvars
%   ax(i,:) = linspace(setup.constraint_set(2*i - 1), setup.constraint_set(2*i), setup.discretisation)
% end

[viable, paths] = vk_viable(point, setup);
%[viable, paths] = vk_viable_redo3d29jul(point, setup);

fprintf('VIABLE: %i\n', viable);
if (~viable)
  fprintf('Exited on:');
  disp(paths.exited);
end

cnt = size(paths.control_path,1);

figure;
subplot(2,3,1);
plot(1:cnt, paths.posn_path(:,1));
xlabel('time');
ylabel('output gap');
axis([1, min(cnt, setup.constraint_set(1),setup.constraint_set(2)]);

subplot(2,3,2);
plot(1:cnt, paths.posn_path(:,2));
xlabel('time');
ylabel('inflation');
axis([1, cnt, setup.constraint_set(3),setup.constraint_set(4)]);

subplot(2,3,3);
plot(1:cnt, paths.posn_path(:,3));
xlabel('time');
ylabel('interest rate');
axis([1, cnt, setup.constraint_set(5),setup.constraint_set(6)]);

% subplot(2,4,4);
% plot(1:cnt, paths.posn_path(:,4));
% xlabel('time');
% ylabel('exchange rate');
% axis([1, cnt, setup.constraint_set(7),setup.constraint_set(8)]);

% subplot(3,4,5);
% plot(1:cnt, velpath(:,1));
% xlabel('time');
% ylabel('change in OG');
% %axis([1, cnt, xmin, xmax]);
% 
% subplot(3,4,6);
% plot(1:cnt, velpath(:,2));
% xlabel('time');
% ylabel('change in pi');
% %axis([1, cnt, xmin, xmax]);               

subplot(2,3,5);
plot(1:cnt, paths.control_path);
xlabel('time');
ylabel('u');
axis([1, cnt, -setup.controlmax, setup.controlmax]);

% subplot(3,4,8);
% plot(1:cnt, velpath(:,4));
% xlabel('time');
% ylabel('change in e');
% %axis([1, cnt, xmin, xmax]);     
% 
% subplot(3,4,9);
% plot(1:cnt, abs(velpath(:,1)) + abs(velpath(:,2)) + abs(velpath(:,4)));
% xlabel('time');
% ylabel('disutility');
% %axis([1, cnt, qmin, qmax]);
% 
% subplot(3,4,10);
% plot(1:cnt, normpath(:));
% xlabel('time');
% ylabel('norm');
% %axis([1, cnt, qmin, qmax]);
% 
% subplot(3,4,11);
% plot(1:cnt, weighnormpath(:));
% xlabel('time');
% ylabel('weighted norm');
% %axis([1, cnt, qmin, qmax]);

disp(paths.posn_path);
