% Test the viability kernel code

fprintf('\n\nTesting Viability Code\n');
fprintf('----------------------\n');

fprintf('\nParameters:\n\n');

% Labels for axes.
labels = char( ...
  'output gap', ...
  'inflation',  ...
  'interest rate')

% Constraint set -- also used for axis()
constraint_set = ...
[-0.1, 0.1, ...  % output gap
 0.01, 0.03, ... % inflation
 0, 0.07]        % interest rate

% Differential equations.  Need to be strings.
fnx = '-0.02*x-0.35*(z-y)'
fny = '0.002*x'

% Discretisation.
discretisation = 10

% The function will return an m x 3 matrix, where m is the number of viable
% points -- i.e., each row represents a point in 3D space.
try
  V;
  fprintf('\n\nV already defined; skipping algorithm.\n');
catch exception
  fprintf('\n\nRUNNING ALGORITHM ...');
  V = vk_compute(constraint_set, char(fnx, fny), discretisation);
  fprintf(' done\n');
end

% Create a scatter plot.
figure;
scatter3(og, inf, int);
axis(constraint_set);
xlabel('output gap');
ylabel('inflation');
zlabel('interest rate');

% Compare to surface plotted by plot_viability_surface.
figure;
vk_plot_surface(V, constraint_set, labels);

% Create a slice through the x-axis at x = 0.06.
SV = vk_slice(V, [1, 0.06, 0.01]);

% Scatter-plot of the slice.
figure;
scatter(SV(:,1), SV(:,2));
axis(constraint_set(3:6));
xlabel('inflation');
ylabel('interest rate');

% Compare with area plotted by plot_viability_slice.
h = figure;
vk_make_figure_slice(V, [1, 0.06, 0.01], constraint_set, labels, h);
