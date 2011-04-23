
setup = struct;

% number of dimensions
setup.numvars = 4

% control var's index
setup.controlvar = 3

%specify constraint sets for each dimension
setup.constraint_set = [-0.04, 0.04, 0.01, 0.03, 0, 0.07, -0.1, 0.1]

setup.discretisation = 5
setup.control_discretisation = 100

normvars = zeros(1,setup.numvars)
for i = 1:setup.numvars
  normvars(i) = (setup.constraint_set(i * 2) - setup.constraint_set(i * 2 - 1)) / 1000;
end

setup.small = norm(normvars);


%specify system dynamics
fnx = inline('-0.2*y-0.5*(i-pi)+0.2*q', 'y','pi','i','q');
fny = inline('0.4*y', 'y', 'pi','i','q');
fnz = inline('0', 'y', 'pi','i','q');
fnq = inline('i-pi', 'y', 'pi','i','q');

setup.diff_eqns = {fnx; fny; fnz; fnq}

% The cost function needs to be able to take a column vector and return a number.
setup.cost_fn = @(u) norm(u, 2);

% The min function needs to provide constrained minimisation.  The first argument is a function to minimise;
% the second and third arguments give the minimum and maximum values allowed as inputs to the function.
%setup.min_fn = @(f, minimum, maximum) vk_fminbnd(f, minimum, maximum, setup.control_discretisation);
setup.min_fn = @fminbnd;

% The delta function takes a column vector, and applies the vector to each
% equation to create a new column vector, which is returned.
setup.delta_fn = @(vector) vk_delta_fn(setup.diff_eqns, vector);

% The cell function is used by vk_compute_new.
setup.cell_fn = @(a1, a2, a3, a4, a5, a6) cellfun(a1, a2, a3, a4, a5, a6, 'UniformOutput', false);
%setup.cell_fn = @(a1, a2, a3, a4, a5, a6) parcellfun(2, a1, a2, a3, a4, a5, a6, 'UniformOutput', false);

% The viable_fn is the algorithm that we use to determine a point's viability.
setup.viable_fn = @vk_viable;
%setup.viable_fn = @vk_viable_redo4d28aug;

% Specify the max for the remaining variable.
setup.controlmax = 0.01
setup.controldefault = 0

% Maximum loops allowed
setup.maxloops = 46000;

%run algorithm
V = vk_compute_new(setup);

h = figure;
distance = (setup.constraint_set(2) - setup.constraint_set(1)) / setup.discretisation;
vk_make_figure_slice(V, [1, 0, distance], setup.constraint_set, char('y', 'pi', 'i', 'q'), h);
