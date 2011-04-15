

%% Goto vk root and setup path
cd ../

addpath Tools ControlAlgs;

%% Load viability kernel data.
load('Projects/vk_4dgui_default.mat');

%% Options
control_fn = @NormMinMultistep;
discretisation = 11;
steps = 2;
controltolerance = 0.00001;
stoppingtolerance = 0.0001;

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

%% Create function that can be used with this mesh
u = @(x, y, z) control_fn([x;y;z], ...
    constraint_set, delta_fn, controlmax, options);

%% Make the volume data
vol = arrayfun(u, xmesh, ymesh, zmesh);

%% Create a figure to display the volume as slices
figure;
axis(constraint_set);
xlabel(labels(1, :));
ylabel(labels(2, :));
zlabel(labels(3, :));
view(3);

hold on;
        
slice(xmesh, ymesh, zmesh, vol, ...
    linspace(constraint_set(1), constraint_set(2), 3), ...
    constraint_set(3) + (constraint_set(4) - constraint_set(3))/2, ...
    constraint_set(5) + (constraint_set(6) - constraint_set(5))/2, ...
    'nearest');

% colormap(transpose(vertcat(...
%     linspace(0, 1, discretisation), ...
%     linspace(1, 0, discretisation), ...
%     linspace(1, 0, discretisation))));

colormap('autumn');

% Create a second figure to display the area where the control is negative
%figure;
%axis(constraint_set);
%view(3);
%
%hold on;
%colormap('autumn');

isosurface(xax, yax, zax, vol, 0);

colorbar;
grid on;
camlight;
lighting gouraud;

%% Knowing what the control value is at every point, work out deltas

d = @(x,y,z,u) delta_fn([x;y;z], u);

vectors = arrayfun(d, xmesh, ymesh, zmesh, vol, 'UniformOutput', 0);

xvel = cellfun(@(x) x(1), vectors);
yvel = cellfun(@(x) x(2), vectors);
zvel = cellfun(@(x) x(3), vectors);


%% Make a cone plot

figure;
axis(constraint_set);
xlabel(labels(1, :));
ylabel(labels(2, :));
zlabel(labels(3, :));
view(3);
hold on;

hcones = coneplot(xax, yax, zax, xvel, yvel, zvel, xmesh, ymesh, zmesh,1);        
set(hcones,'FaceColor','red','EdgeColor','none');

isosurface(xax, yax, zax, vol, 0);


camproj perspective; 
grid on;
camlight;
lighting gouraud;

%% Plot the norms

figure;
axis(constraint_set);
xlabel(labels(1, :));
ylabel(labels(2, :));
zlabel(labels(3, :));
view(3);
hold on;

norms = arrayfun(@(x,y,z) norm([x;y;z]), xvel, yvel, zvel);

slice(xmesh, ymesh, zmesh, norms, ...
    linspace(constraint_set(1), constraint_set(2), 3), ...
    constraint_set(3) + (constraint_set(4) - constraint_set(3))/2, ...
    constraint_set(5) + (constraint_set(6) - constraint_set(5))/2, ...
    'nearest');

isosurface(xax, yax, zax, norms, 0.0001);
%isosurface(xax, yax, zax, norms, 0.0025);
%isosurface(xax, yax, zax, norms, 0.005);
%isosurface(xax, yax, zax, norms, 0.01);
%isosurface(xax, yax, zax, norms, 0.02);

colormap('autumn');
colorbar;

