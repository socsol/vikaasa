%% VK_OPTIONS Create an options structure for use with the VIKAASA library.
%
% SYNOPSIS
%   This function generates an `options' structure which can be used with a
%   large number of VIKAASA library functions to modify their behaviour.
%
% USAGE
%   % Create an options structure that contains all of the default settings:
%   options = vk_options(K, f, c)
%
%   % Create an options structure, overriding the settings for the
%   % configuration variables, 'name1' and 'name2':
%   options = vk_options(K, f, c, ...
%       'name1', value1, ...
%       'name2', value2 [, ...])
%
%   % Update an existing options structure, changing one or more variables:
%   options = vk_options(K, f, c, options,
%       'name1', value1, ...
%       'name2', value2 [, ...])
%
%   Available options (default values in brackets):
%
%       - `bound_fn' (`vk_control_bound'): Function handle specifying the
%         function to use for bounding when the `controlbounded' option is set
%         to `1'.
%
%       - `cancel_test' (0): Whether to test to see if the user has
%         interrupted computation. (e.g., by pressing ``Cancel'' in the
%         VIKAASA GUI.  See VIKAASA)  If this option is set to `1', then the
%         handle specified by `cancel_test_fn' will be called from time to
%         time.
%
%       - `cancel_test_fn' (`@() 0'): This is a function that takes no
%         options, and returns either 0 to indicate that the system should
%         continue, or else 1 to indicate that computation should be
%         cancelled.  If `cancel_test' is set to `1', then this option is
%         used by vk_kernel_compute and vk_sim_simulate_euler/vk_sim_simulate_ode.
%
%       - `cell_fn' (`cellfun'): The ``cell function'' used by vk_kernel_compute
%         to divide up the first dimension of the discretised constraint set
%         sample when testing for viability.  This is an option because it is
%         possible to replace this function with a parallel version and thereby
%         make vk_compute operate on multiple processors.  The cell function
%         that is chosen needs to use the option `UniformOutput' set to zero
%         (see `cellfun' for more information).
%
%       - `controlbounded' (0): When set to 1, VIKAASA will attempt to
%         prevent the system from crashing by limiting the control choice
%         when close to the boundary.
%
%       - `controldefault' (0): The default control (should be a number in
%         $[-c, c]$) -- used in some cost-minimising control algorithms
%         when  `use_controldefault' is enabled (See CostMin for an example.)
%
%       - `controlenforce' (0): When set to 1, VIKAASA will check to ensure
%         that the control choice is within $[-c, c]$.
%
%       - `controlsymbol' (`u'): A string representing the symbol used to
%         denote the control in the differential equations.
%
%       - `controltolerance' (1e-3): Used by optimising control algorithms to
%         decide when enough samples of the cost-function have been made.
%         The smaller the number, the closer the control will be to the
%         ``true'' optimum (See CostMin for an example.)
%
%       - `cost_fn' (`@(x,xdot) norm(xdot)'): This function is used by
%         cost-minimising control algorithms such as CostMin to
%         determine what control to use.  The default behaviour of this
%         function is to consider the size of the velocity of the system,
%         `norm(xdot)' solely, which may be quite inferior in many cases.
%         This is therefore a very important option.  See the examples.
%
%       - `custom_constraint_set_fn' (`@(x) 1'): This function is used by
%         vk_kernel_inside if the `use_custom_constraint_set_fn' option is set
%         to 1.  If specified, it should give a function that returns 1
%         when the specified point is in the constraint set, and zero
%         otherwise.  This functionality can be used to specify
%         non-rectangular constraint sets.  See the examples.
%
%       - `debug' (0): Turn on ``debug mode.''  When this is enabled various
%         data are printed into the MATLAB(R) Command Window during execution.
%
%       - `discretisation' (column vector of `10's): State-space
%         discretisation.  There should be one value for each variable in the
%         viability problem.  When the kernel is being computed, the constraint
%         set is sampled for $\prod_{i=1}^n \delta_i$ points, each of which is
%         then individually tested for viability.  Lower discretisation is
%         faster, but less useful.  See
%
%       - `enforce_fn' (`vk_control_enforce'): The function to use when
%         `controlenforce' is set to 1.  See above.
%
%       - `h' (1): The step-size used in numerical approximation of the
%         differential equations.
%
%       - `maxloops' (46000): Maximum number of loops performed by vk_viable
%         before it gives up on a point.  This option is present to prevent
%         infinite loops.
%
%       - `min_fn' (`fminbnd'): The function used by cost-minimising algorithms
%         such as CostMin to find the control which entails the least cost, as
%         specified by the cost function (see the `cost_fn' option.)  The
%         default is to use `fminbnd' which uses a golden ratio search.  This
%         minimisation algorithm is therefore only suitable for cost functions
%         that have a single global minimum in the range $[-c, c]$.  By default
%         this function is sensitive to the `controltolerance' option.  See the
%         examples, below.  Also, note that VIKAASA comes with an alternative
%         minimisation function that does a linear search instead.  See
%         vk_fminbnd.
%
%       - `next_fn' (`@(x,u) x + h*f(x,u)'): This function is used by vk_viable
%         and vk_simulate_euler to work out the next point to consider.  By
%         default a 1st-order Euler approximation is used.
%
%       - `norm_fn' (`norm'): The function used to calculate the size of the
%         system velocity.  Used by vk_viable to decide when the system is slow
%         enough to be considered steady.  This function should take a single
%         argument, which is a (column) vector of velocities, and should return
%         a single numeric result.
%
%       - `numvars': Gives the number of variables in the viability problem.
%         This is usually calculated as half the length of the constraint set,
%         `K'.  You shouldn't change this unless you know what you are doing.
%
%       - `ode_solver' (defaults to a function handle making use of
%         `ode_solver_name'): A function handle used by vk_simulate_ode to
%         compute a numerical solution to the differential system of equations.
%         This function is by default rigged to interact with `cancel_test_fn'
%         and the `progress_fn', and has `MaxStep' equal to the `h' option.
%         Rather than changing this function, it may be best to change
%         `ode_solver_name'.
%
%       - `ode_solver_name' (`ode45'): This string specifies the name of
%         the function used by `ode_solver' (see above), without altering that
%         function's use of `MaxStep', etc.  Unless you are doing something
%         fancy, this is probably what you want to use.
%
%       - `parallel_processors' (2): Used in conjunction with `use_parallel',
%         this option specifies how many processors (or MATLAB workers) to
%         create.
%
%       - `progress_fn' (`@(x) 1'): A function that gets called periodically by
%         vk_kernel_compute and vk_sim_simulate_euler/vk_sim_simulate_ode when
%         `report_progress' is set to 1.  It takes one parameter, which is
%         either the number of points that have been assessed for viability
%         (under vk_kernel_compute), or otherwise the number of time-frames
%         that have been simulated.
%
%       - `report_progress' (0): Whether vk_kernel_compute and
%         vk_sim_simulate_euler/vk_sim_simulate_ode should call a progress
%         report function (specified by `progress_fn') to indicate how far they
%         are through their tasks.
%
%       - `steps' (1): The number of forward-looking steps used by finite-time
%         optimising control algorithms such as CostMin.
%
%       - `sim_fn' (vk_sim_simulate_ode):  The ``simulation function'' to
%         use.  This is only really an important option if you decide to use
%         vk_sim_make.  It should be either vk_simulate_ode or
%         vk_simulate_euler.
%
%       - `sim_hardupper' (`[]'): A column vector giving the indices of the
%         variables which have "hard" upper bounds.  When a hard upper bound is
%         violated, simulation is halted.
%
%       - `sim_hardlower' (`[]'): Same as `sim_hardupper', but for lower bounds.
%
%       - `sim_stopsteady' (0): Used by
%         vk_sim_simulate_euler/vk_sim_simulate_ode to decide whether
%         to continue the simulation on to the end, or to stop once the
%         near-steady state has been determined.
%
%       - `small' (1e-3): Used by vk_sim_simulate_euler/vk_sim_simulate_ode and
%         vk_viable to decide when to consider a system state to be
%         ``steady-enough'' to be viable.  This value is compared to the value
%         of function specified by the `norm_fn' option, evaluated over the
%         size of the differential equations at the given point.  If the
%         function value is less than or equal to the value of `small', then
%         the point will be considered viable.  Thus, a smaller value of
%         `small' is in theory more accurate, but may lead to much longer
%         computation times.
%
%       - `use_controldefault' (0): See `controldefault' above for an
%         explanation of this option.
%
%       - `use_custom_constraint_set_fn' (0): See the
%         `custom_constraint_set_fn' option for more information on this.
%
%       - `use_parallel' (0):  If set to 1, vk_kernel_compute will try to use a
%         parallel implementation of `cellfun' (either `parcellfun' or
%         `vk_cellfun_parfor') so as to compute viability kernels in parallel.
%         In MATLAB you need to have the Parallel Computing Toolbox for this to
%         work.  In GNU Octave parcellfun is available from Octave-Forge.
%
%       - `viable_fn' (vk_viable): This is the function used by
%         vk_kernel_compute to determine whether a point is viable or not.  The
%         default is to use vk_viable; however, this could potentially be
%         replaced with a different implementation.
%
%       - `zero_fn' (`fzero'): A function handle used by vk_control_bound to
%         solve situations where the control should be chosen to prevent the
%         system leaving the constraint set.  It is sensitive to the
%         `controltolerance' option.
%
% EXAMPLES
%   % Specifying a cost function:
%   options = vk_options( ...
%       'cost_fn', @(x, xdot) (x(1) - x(2))^2);
%
%   % Specifying a circular custom constraint set:
%   options = vk_options( ...
%       'custom_constraint_set_fn', @(x) (x(1)^2 + x(2)^2 < 100);
%
%   % Specifying an optimising function which is sensitive to controltolerance:
%   options = vk_options(options, ...
%       'min_fn', @(f, min, max) fminbnd(f, min, max, ...
%           struct('TolX', options.controltolerance)));
%
% Requires:  vk_cellfun_parfor, vk_control_bound, vk_control_enforce, vk_lsode_wrapper, vk_ode_outputfcn, vk_sim_simulate_ode, vk_viable
%
% See also: CostMin, CostSumMin, cellfun, fminbnd, fzero, norm, ode45, vikaasa, vk_compute, vk_fminbnd, vk_kernel_inside, vk_sim_simulate_euler

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
function options = vk_options(K, f, c, varargin)

    % If exactly four arguments are passed in, then the fourth argument
    % should be a structure.  We return this structure immediately.  This
    % is for the use of functions that take an optional 'options' parameter
    % that can be either a structure or name,value pairs.
    if(nargin == 4 && isstruct(varargin{1}))
        options = varargin{1};
        return;
    end

    % If there are an even number of variables, and the first optional
    % argument is a structure, then we are in the process of updating
    % options.
    if (mod(nargin,2) == 0 && isstruct(varargin{1}))
        defaults = varargin{1};
        options = struct(varargin{2:end});
    else
        % Where options are not specified, use the default values.
        defaults = struct(...
                'cancel_test', 0, ...
                'controlsymbol', 'u', ...
                'controlbounded', 0, ...
                'controldefault', 0, ...
                'controlenforce', 0, ...
                'controltolerance', 1e-3, ...
                'debug', false, ...
                'discretisation', 10*ones(length(K)/2, 1), ...
                'maxloops', 46000, ...
                'numvars', length(K)/2, ...
                'ode_solver_name', 'ode45', ...
                'parallel_processors', 2, ...
                'report_progress', 0, ...
                'steps', 1, ...
                'h', 1, ...
                'sim_hardupper', [], ...
                'sim_hardlower', [], ...
                'sim_stopsteady', 0, ...
                'small', 1e-3, ...
                'use_controldefault', 0, ...
                'use_custom_constraint_set_fn', 0, ...
                'use_parallel', 0 ...
            );

        % The options array is constructed from inputs.
        options = struct(varargin{:});
    end

    default_fields = fieldnames(defaults);
    for i = 1:size(default_fields, 1)
        df = default_fields{i};
        if (~isfield(options, df))
            options.(df) = defaults.(df);
        end
    end

    % The functions are then specified (if not given as input), based on
    % these values:

    % The norm function is used to measure the size of movements.  The
    % default is to use a norm where each axis is weighted relative to
    % the size of the constraint set.
    if (~isfield(options, 'norm_fn'))
        options.norm_fn = @norm;
    end

    % The cost function needs to be able to take a column vector and return
    % a number.  This function is then minimised to obtain the optimal
    % trajectory.
    if (~isfield(options, 'cost_fn'))
        options.cost_fn = @(x,dx) norm(dx);
    end

    % The min function needs to provide constrained minimisation.  The
    % first argument is a function to minimise; the second and third
    % arguments give the minimum and maximum values allowed as inputs to
    % the function.
    min_fn_opts = struct( ...
        'TolX', options.controltolerance, ...
        'FunValCheck', true, ...
        'abstol', options.controltolerance);
    if (~isfield(options, 'min_fn'))
        %options.min_fn = @(f, minimum, maximum) ...
        %    vk_fminbnd(f, minimum, maximum, controltolerance);

        options.min_fn = @(f, lb, ub) fminbnd(f, lb, ub, min_fn_opts);
    end

    % The zero function is probably just a wrapper around fzero, but with
    % tolerance explicitly specified.
    if (~isfield(options, 'zero_fn'))
        options.zero_fn = @(f, limits) fzero(f, limits, min_fn_opts);
    end

    % The bound function takes a control and tests to see if it is
    % trivially violating any constraint.  If it is, then the control is
    % adjusted appropriately.  This function also works out (in doing so)
    % whether a trajectory is non-viable (i.e., if it is violating a
    % constraint that can't be repaired).
    if (~isfield(options, 'bound_fn'))
        options.bound_fn = @vk_control_bound;
    end

    % This is the control algorithm to use.  This algorithm should accept
    % arguments: (x, K, f, c, varargin), and return a
    % control, u.
    if (~isfield(options, 'control_fn'))
        options.control_fn = @(x, K, f, c, varargin) 0;
    end

    % The function used to make sure that the control choice is within
    % [-c,c].
    if (~isfield(options, 'enforce_fn'))
        options.enforce_fn = @vk_control_enforce;
    end

    % The cell function is used by vk_kernel_compute.  It needs to take a
    % variable number of cell array inputs.
    if (~isfield(options, 'cell_fn'))

        % If we are computing the kernel in parallel, try to find a
        % function.
        if (options.use_parallel)
            % If parcellfun is available, use it.
            if (exist('parcellfun', 'file') == 2)
                options.cell_fn = @(varargin) ...
                    parcellfun(...
                        options.parallel_processors, ...
                        varargin{:}, 'UniformOutput', false);
            elseif (exist('parfor', 'builtin') == 5)
                options.cell_fn = @(varargin) ...
                    vk_cellfun_parfor(...
                        options.parallel_processors, ...
                        varargin{:}, 'UniformOutput', false);
            else
                warning('Parallel selected, but no parallel capabilities could be detected.');
            end
        end

        % Either parallel is not specified, or parallel functionality not
        % available.
        if (~isfield(options, 'cell_fn'))
            options.cell_fn = @(varargin) ...
                cellfun(varargin{:}, 'UniformOutput', false);
        end
    end

    % The viable_fn is the algorithm that we use to determine a point's
    % viability.
    if (~isfield(options, 'viable_fn'))
        options.viable_fn = @vk_viable;
    end

    % The custom constraint set function.  Called by VK_EXITED if
    % 'use_custom_constraint_set_fn' is 1.
    if (~isfield(options, 'custom_constraint_set_fn'))
        options.custom_constraint_set_fn = @(x) 1;
    end

    % A function to call that will tell the process in question whether to
    % cancel or not.  Default is never to cancel.
    if (~isfield(options, 'cancel_test_fn'))
        options.cancel_test_fn = @() 0;
    end

    % A function to call every step to report progress.  Default is a
    % dummy function.  Won't be used unless 'report_progress' (above) is 1.
    if (~isfield(options, 'progress_fn'))
        options.progress_fn = @(x) 1;
    end

    % A function to progress to the next step.
    if (~isfield(options, 'next_fn'))
        h = options.h;
        options.next_fn = @(x,u) x + h*f(x, u);
    end

    % ODE solver function.  By default we use ode45 or lsode, with the step
    % size set accordingly.
    if (~isfield(options, 'ode_solver'))
        if (exist('odeset'))
            ode_opts = odeset('MaxStep', options.h);

            % If we are being interactive, then we pass in the outputfcn
            % argument too.
            if (options.report_progress ...
                    || options.cancel_test ...
                    || options.sim_stopsteady)
                ode_opts = odeset(ode_opts, 'OutputFcn', @(t,y,flag) ...
                    vk_ode_outputfcn(t, y, flag, K, f, c, options));
            end

            options.ode_solver = eval(['@(varargin) ', ...
                options.ode_solver_name, '(varargin{:}, ode_opts)']);
        elseif (exist('lsode'))
            %% LSODE takes parameters in a different order from ODE45 and friends.
            %   We use vk_lsode_wrapper to deal with that.
            lsode_options('maximum step size', options.h);
            options.ode_solver = @vk_lsode_wrapper;
        else
            options.ode_solver = @(varargin) error('Could not find an ODE solver');
        end
    end

    if (~isfield(options, 'sim_fn'))
        options.sim_fn = @vk_sim_simulate_ode;
    end
end
