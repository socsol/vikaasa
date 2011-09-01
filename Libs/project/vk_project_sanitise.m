%% VK_PROJECT_SANITISE Set default values for the project, if missing.
%
% SYNOPSIS
%   This function checks a project for consistency, and updates any erroneous
%   information as necessary.
%
% USAGE
%   % Check that a project is ok:
%   project = vk_project_sanitise(project);
%
% FIELDS
%   The following fields should be in every project.  Default values are in
%   brackets.
%
%  - `alpha' (0.9): the level of transparency used when plotting areas and
%    surfaces.
%  - `addnlabels' (empty cell array of length `numaddnvars'): the labels for
%    the additional variables.  Should be a cell array with one column, and one
%    row per variable.
%  - `addnsymbols' (empty cell array of length `numaddnvars'): the symbols for
%    the additional variables.  Should be a cell array in column form.
%  - `addneqns' (empty cell array of length `numaddnvars'): the right-hand
%    sides of the eqautions for the additional variables.  Should be a cell
%    array in column form.
%  - `addnignore' (a column vector of zeros, of length `numaddnvars'): whether
%    or not to ignore each additional variable.  A one means it will be
%    ignored.
%  - `autosave' (0): whether to auto-save kernel results after computing a
%    viability kernel or not.
%  - `controlalg' (`ZeroControl'): a string representing the control algorithm
%    to be used for kernel computation.  Should be the name of a function
%    residing in the ``ControlAlgs'' folder.
%  - `controldefault' (0): the value of the ``default control'' to use if
%    `use_controldefault' is set to 1.
%  - `c' (0.005): The absolute maximum size of the scalar control.
%  - `controlbounded' (0): whether or not to use the control-bounding
%    functionality (see vk_control_bound).
%  - `controlenforce' (0): wheter or not to enforce the `c' setting (see
%    vk_control_enforce).
%  - `controlsymbol' (`u'): a string giving the symbol to use to represent the
%    choice of control.
%  - `controltolerance' (1e-3): the tolerance to use with numerical
%    cost-minimising control algorithms (see vk_options).
%  - `custom_cost_fn' (empty string): a string representing the right-hand side
%    of a custom cost function (see the section in the manual on
%    cost-minimising controls).
%  - `custom_constraint_set_fn' (empty string): a string giving the custom
%    constraint set function (CCSF) for the problem, if there is one.
%  - `debug' (0): whether to display additonal debugging information or not.
%  - `diff_eqns' (an empty cell array of length `numvars'): a column of cells
%    giving the system's dynamics for the viability problem.
%  - `discretisation' (a column vector of length `numvars' with value 11 in
%    every field): the discretisation to use in seeking viable points.
%  - `drawbox' (0): whether to draw a box around points when plotting or not.
%  - `h' (1): the step-size to use with Euler's method for solving differential
%    equations.
%  - `holdfig' (0): Whether to hold figures, so that subsequent plots are
%    superimposed over previous ones.
%  - `K' (row vector of zeros, of length `2*numvars'): the rectangular
%    constraint set.
%  - `labels' (empty cell array, of length `numvars', in column form): labels
%    for the dynamic variables.
%  - `layers' (1): used by vk_kernel_inside to determine whether inside the
%    kernel or not.
%  - `parallel_processors' (2): number of processors to use in parallel when
%    `use_parallel' is set to 1.
%  - `plotcolour' (`[1 1 0]'): colour to plot viability kernels in.
%  - `plottingmethod' (``qhull''): a string giving the current plotting method.
%    See vk_plot for more information on admissible plotting methods.
%  - `progressbar' (1): whether to display a progress bar while performing
%    computations or not.
%  - `sim_controlalg' (``ZeroControl''): a string representing the name of a
%    function to use for simulation.  Should be a functon residing in either the
%    ``ControlAlgs'' or the ``VControlAlgs'' folders.
%  - `sim_hardlower' (empty array): an array of indices giving the index
%    numbers of variables that hard hard lower constraints.
%  - `sim_hardupper' (empty array): an array of indices giving the index
%    numbers of variables that hard hard upper constraints.
%  - `sim_iterations' (10): the ``time horizon'' for simulations.
%  - `sim_line_colour' (`[0 0 1]'): the colour to plot lines in simulation plots.
%  - `sim_line_width' (2): the width of the lines to plot.
%  - `sim_method' (``ode''): a string giving the method to use for simulation.
%    Should be one of ``ode'' or ``euler''.
%  - `sim_use_nearest' (0): whether to make sure that simulations start from
%    points in the discretised constraint set $K_\delta$ or not.
%  - `sim_showpoints' (0): whether to show coloured dots indicating the
%    viability of the system in simulation plots and time profiles.
%  - `sim_showkernel' (0: whether to display kernel slices in time profiles or
%    not.
%  - `sim_start' (column vector of zeros of length `numvars'): the initial
%    state for simulation.
%  - `sim_stopsteady' (0): whether or not to stop simulations when a
%    near-steady state is achieved.
%  - `sim_timeprofile_cols' (2): the number of columns to display time profiles
%     in within a figure.
%  - `slices' (empty array): the slice array.  See vk_kernel_slice.
%  - `steps' (1): the number of forward-looking steps.  Used by multi-step
%    forward-looking cost-minimisation algorithms.
%  - `stoppingtolerance' (1e-3): used to calculate velocity at which the system
%    will be considered ``near-steady''.  See vk_viable.
%  - `symbols' (empty cell array of length `numvars'): column array of cells,
%    each containing a string representing the symbol to be used in equations to
%    represent that variable.
%  - `use_controldefault' (0): whether or not to use a default control with
%    forward-looking cost-minimising algorithms.
%  - `use_custom_cost_fn' (0): whether to use a custom cost function with
%    cost-minimising algorithms.  If not, then norm-minimisation will be used.
%  - `use_custom_constraint_set_fn' (0): whether or not to use a custom
%    constraint set function to augment the rectangular constraint set.
%  - `use_parallel' (0): whether or not to use parallel processors when
%    computing viability kernels.
%
% See also: vikaasa, vk_project_new

%%
%  Copyright 2011 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
function project = vk_project_sanitise(project)
    %% Check if the project has any mis-named elements
    rename = struct(...
        'constraint_set', 'K', ...
        'diff_eqn', 'diff_eqns', ...
        'controlmax', 'c', ...
        'timediscretisation', 'h');

    fn = fieldnames(rename);
    for i = 1:size(fn, 1);
        if (isfield(project, fn{i}))
            project.(rename.(fn{i})) = project.(fn{i});
            project = rmfield(project, fn{i});
        end
    end

    %% Set numvars
    % Check if the project is missing a 'numvars' element.  If it is, then it
    % should contain 'vardata' instead.  If neither is present, assume that
    % 'numvars' is 2.
    if (~isfield(project, 'numvars'))
        if (isfield(project, 'vardata'))
            project.numvars = size(project.vardata, 1);
        else
            project.numvars = 2;
        end
    end

    numvars = project.numvars;

    %% Check that 'discretisation' is not length one.  If it is, repeat it.
    if (isfield(project, 'discretisation') ...
      && numvars > 1 ...
      && length(project.discretisation) == 1)
        project.discretisation = project.discretisation*ones(numvars, 1);
    end

    %% Check that 'symbols', 'labels' and 'diff_eqns' are cell arrays.
    %   Otherwise, call cellstr on them to convert.  Note that we always keep
    %   them in column form.
    cellarrs = {'symbols', 'labels', 'diff_eqns'};
    for i = 1:length(cellarrs)
        if (isfield(project, cellarrs{i}) && ~iscell(project.(cellarrs{i})))
            project.(cellarrs{i}) = cellstr(project.(cellarrs{i}));
        end
    end

    %% Check that the variable-length arguments are the correct size.
    %   If they aren't, chop/extend them.  All in column form.
    varlength = {'discretisation', 'symbols', 'labels', 'diff_eqns', 'sim_start'};
    for i = 1:length(varlength)
        if (isfield(project, varlength{i}) ...
          && length(project.(varlength{i})) ~= numvars)
            v = project.(varlength{i});
            usevars = min(numvars, length(v));
            padvars = max(0, numvars - length(v));
            if (iscell(v))
                project.(varlength{i}) = [v(1:usevars); cell(padvars, 1)];
            else
                project.(varlength{i}) = [v(1:usevars); zeros(padvars, 1)];
            end
        end
    end

    %% Check the constraint set is the right size.
    %   It needs to be of length 2*numvars.  It is kept in row form.
    if (isfield(project, 'K') && length(project.K) ~= 2*numvars)
        usevars = min(2*numvars, length(project.K));
        padvars = max(0, 2*numvars - length(project.K));

        project.K = [project.K(1:usevars), zeros(1, padvars)];
    end

    %% If numaddnvars is not defined, define it to be zero.
    if (~isfield(project, 'numaddnvars'))
        project.numaddnvars = 0;
    end

    %% Check that the fields associated with additional variables are correct length
    %   If defined, they should be the same length as numaddnvars.
    addnfields = {'addnlabels', 'addnsymbols', 'addneqns', 'addnignore'};
    for i = 1:length(addnfields)
        if (isfield(project, addnfields{i}))
            v = project.(addnfields{i});
            usevars = min(length(v), project.numaddnvars);
            padvars = max(0, project.numaddnvars - length(v));
            if (iscell(v))
                project.(addnfields{i}) = [v(1:usevars); cell(padvars, 1)];
            else
                project.(addnfields{i}) = [v(1:usevars); zeros(padvars, 1)];
            end
        end
    end

    project_default = struct(...
        'alpha', 0.9, ...
        'addnlabels', {cell(project.numaddnvars, 1)}, ...
        'addnsymbols', {cell(project.numaddnvars, 1)}, ...
        'addneqns', {cell(project.numaddnvars, 1)}, ...
        'addnignore', zeros(project.numaddnvars, 1), ...
        'autosave', 0, ...
        'controlalg', 'ZeroControl', ...
        'controldefault', 0, ...
        'c', 0.005, ...
        'controlbounded', 0, ...
        'controlenforce', 0, ...
        'controlsymbol', 'u', ...
        'controltolerance', 1e-3, ...
        'custom_cost_fn', '', ...
        'custom_constraint_set_fn', '', ...
        'debug', 0, ...
        'diff_eqns', {cell(numvars, 1)}, ...
        'discretisation', 11*ones(numvars, 1), ...
        'drawbox', 0, ...
        'h', 1, ...
        'holdfig', 0, ...
        'K', zeros(1, 2*numvars), ...
        'labels', {cell(numvars, 1)}, ...
        'layers', 1, ...
        'parallel_processors', 2, ...
        'plotcolour', [1 1 0], ...
        'plottingmethod', 'qhull', ...
        'progressbar', 1, ...
        'sim_controlalg', 'ZeroControl', ...
        'sim_hardlower', [], ...
        'sim_hardupper', [], ...
        'sim_iterations', 10, ...
        'sim_line_colour', [0 0 1], ...
        'sim_line_width', 2, ...
        'sim_method', 'ode', ...
        'sim_use_nearest', 0, ...
        'sim_showpoints', 0, ...
        'sim_showkernel', 0, ...
        'sim_start', zeros(numvars, 1), ...
        'sim_stopsteady', 0, ...
        'sim_timeprofile_cols', 2, ...
        'slices', [], ...
        'steps', 1, ...
        'stoppingtolerance', 1e-3, ...
        'symbols', {cell(numvars, 1)}, ...
        'use_controldefault', 0, ...
        'use_custom_cost_fn', 0, ...
        'use_custom_constraint_set_fn', 0, ...
        'use_parallel', 0 ...
    );

    %% Add any fields that are missing.
    dfn = fieldnames(project_default);
    for i = 1:length(dfn)
        if (~isfield(project, dfn{i}))
            project.(dfn{i}) = project_default.(dfn{i});
        end
    end
end
