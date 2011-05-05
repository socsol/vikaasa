%% VK_OPTIONS Create an options structure for use with VIKAASA toolbox.
%   This function is used to specify the options one wants to use with the
%   VIKAASA toolbox.
%
%   Create an options structure that contains all of the default
%   settings:
%   OPTIONS = VK_OPTIONS(K, f, c)
%
%   Create an options structure, overriding the settings for the
%   configuration variables, 'name1' and 'name2':
%   OPTIONS = VK_OPTIONS(K, f, c, ...
%       'name1', value1, ...
%       'name2', value2 [, ...])
%
%   Update an existing options structure, changing one or more variables:
%   OPTIONS = VK_OPTIONS(K, f, c, OPTIONS,
%       'name1', value1, ...
%       'name2', value2 [, ...])
%
%   Available options (default values in brackets):
%
%       - bound_fn (vk_bound): The function to use for bounding when
%         the 'controlbounded' option is set to '1'.  See below.
%
%       - cancel_test (0): Whether to test to see if the user has
%         interrupted computation. (e.g., by pressing 'Cancel' in the
%         VIKAASA GUI.  See VIKAASA)  If this option is set to 1, then the
%         'cancel_test_fn' will be called from time to time.
%
%       - cancel_test_fn (@() 0)  This is a function that takes no
%         options, and returns either 0 to indicate that the system should
%         continue, or else 1 to indicate that computation should be
%         cancelled.  If 'cancel_test' is set to 1, then this option is
%         used by TOOLS/VK_COMPUTE and TOOLS/VK_SIMULATE_*.
%
%       - cell_fn (CELLFUN): The 'cell function' used by TOOLS/VK_COMPUTE
%         to divide up the first dimension of the discretised constraint
%         set sample when testing for viability.  This is an option because
%         it is possible to replace this function with a parallel version
%         under GNU Octave, and thereby make TOOLS/VK_COMPUTE operate on
%         multiple processors.  The cellfun that is chosen needs to use the
%         option {'UniformOutput', 0}.  For instance:
%         cell_fn = @(varargin) cellfun(varargin, 'UniformOutput', 0);
%
%       - controlbounded (0): When set to 1, VIKAASA will attempt to
%         prevent the system from crashing by limiting the control choice
%         when close to the boundary.  See the manual for more details.
%
%       - controldefault (0): The default control (should be a number in
%         [-c, c]) -- used in some control algorithms
%         when  'use_controldefault' is enabled (See CONTROLALGS/COSTMIN
%         for an example.)
%
%       - controlenforce (0): When set to 1, VIKAASA will check to ensure
%         that the control choice is within [-c, c].
%
%       - controlsymbol ('u'): A string representing the symbol used to
%         denote the control in the differential equations.
%
%       - controltolerance (1e-3): Used by optimising control algorithms to
%         decide when enough samples of the cost-function have been made.
%         The smaller the number, the closer the control will be to the
%         'true' optimum (See CONTROLALGS/COSTMIN for an example.)
%
%       - cost_fn (@(x,xdot) norm(xdot)): This function is used by
%         cost-minimising control algorithms such as CONTROLALGS/COSTMIN to
%         determine what control to use.  The default behaviour of this
%         function is to consider the size of the velocity of the system,
%         norm(xdot) solely, which may be quite inferior in many cases.
%         This is therefore a very important option.  It can be modified
%         easily through VIKAASA.
%
%       - custom_constraint_set_fn (@(x) 1): This function is used by
%         TOOLS/VK_EXITED if the 'use_custom_constraint_set' option is set
%         to 1.  If specified, it should give a function that returns 1
%         when the specified point is in the constraint set, and zero
%         otherwise.  This functionality can be used to specify
%         non-rectangular constraint sets.  For instance:
%         custom_constraint_set_fn = @(x) (x(1)^2 + x(2)^2 < 100)
%
%       - debug (0): Turn on 'debug mode'.  When this is enabled various
%         data is printed into the MATLAB Command Window during execution.
%
%       - discretisation (10): State-space discretisation.  When the kernel
%         is being computed, the constraint set is divided into
%         discretisation^numvars points, each of which is then individually
%         tested for viability.  Lower discretisation is faster, but less
%         useful.
%
%       - enforce_fn (vk_enforce): The function to use when controlenforce
%         is set to 1.  See above.
%
%       - maxloops (46000): Maximum number of loops performed by
%         TOOLS/VK_VIABLE before it gives up on a point.  This option is
%         present to prevent infinite loops.
%
%       - min_fn (fminbnd): The function used by cost-minimising algorithms
%         such as CONTROLALGS/COSTMIN to find the control which entails the
%         least cost, as specified by the cost function (see the 'cost_fn'
%         option.)  The default is to use FMINBND which uses a golden ratio
%         search.  This minimisation algorithm is therefore only suitable
%         for cost functions that have a single global minimum in the range
%         [-c, c].  By default this function is sensitive
%         to the 'controltolerance' option. i.e.,
%         min_fn = @(f, min, max) fminbnd(f, min, max, ...
%             struct('TolX', options.controltolerance));
%
%         Also, note that VIKAASA comes with an alternative minimisation
%         function that does a linear search instead.  See
%         TOOLS/VK_FMINBND.
%
%       - next_fn (@(x,u) x + h*f(x,u)): This function is used by
%         VK_VIABLE and VK_SIMULATE_EULER to work out the next point to
%         consider.  By default a 1st-order Euler approximation is used.
%
%       - norm_fn (NORM): The function used to calculate the size of the
%         system velocity.  Used by TOOLS/VK_VIABLE to decide when the
%         system is slow enough to be considered steady.  This function
%         should take a single argument, which is a (column) vector of
%         velocities, and should return a single numeric result.
%
%       - numvars: This is usually calculated as half the length of the
%         constraint set.  You shouldn't change this unless you know what
%         you are doing.
%
%       - ode_solver (@ode45): Used by TOOLS/VK_SIMULATE_ODE to undertake
%         numerical analysis of the differential system of equations.  This
%         function is by default rigged to interact with 'cancel_test_fn'
%         and the 'progress_fn', and has 'MaxStep' equal to the 'stepsize'
%         option.
%
%       - ode_solver_name ('ode45'): This string can be used to change the
%         function used by 'ode_solver' (see above), without altering that
%         function's use of 'MaxStep', etc.  Unless you are doing something
%         fancy, this is probably what you want to use.
%
%       - parallel_processors (2): Used in conjunction with use_parallel,
%         this option specifies how many processors (or MATLAB workers to
%         create.
%
%       - progress_fn (@(x) 1): A function that gets called periodically by
%         TOOLS/VK_COMPUTE and TOOLS/VK_SIMULATE_* when 'report_progress'
%         is set to 1.  It takes one parameter, which is either the
%         number of points that have been assessed for viability (under
%         TOOLS/VK_COMPUTE), or otherwise the number of time-frames that
%         have been simulated (under TOOLS/VK_SIMULATE_*).
%
%       - report_progress (0): Whether TOOLS/VK_COMPUTE and
%         TOOLS/VK_SIMULATE_* should call a progress report function
%         (specified by 'progress_fn') to indicate how far they are through
%         their tasks.
%
%       - steps (1): The number of forward-looking steps used by
%         finite-time optimising control algorithms such as
%         CONTROLALGS/COSTSUMMIN.
%
%       - stepsize (1): The step-size used in numerical
%         approximation of the differential equations.  Usually denoted by
%         'h' in mathematical literature.
%
%       - sim_fn (TOOLS/VK_SIMULATE_ODE):  The 'simulation function' to
%         use.  This is only really an important option if you decide to
%         use TOOLS/VK_MAKE_SIMULATION.  It should be either
%         TOOLS/VK_SIMULATE_ODE or TOOLS/VK_SIMULATE_EULER.
%
%       - sim_stopsteady (0): Used by TOOLS/VK_SIMULATE_* to decide whether
%         to continue the simulation on to the end, or to stop once the
%         near-steady state has been determined.
%
%       - small (1e-3): Used by TOOLS/VK_SIMULATE_* and TOOLS/VK_VIABLE to
%         decide when to consider a system state to be 'steady-enough' to
%         be viable.  This value is compared to the value of function
%         specified by the 'norm_fn' option, evaluated over the size of the
%         differential equations at the given point.  If the function value
%         is less than or equal to the value of 'small', then the point
%         will be considered viable.  Thus, a smaller value of 'small' is
%         in theory more accurate, but may lead to much longer computation
%         times.
%
%       - use_controldefault (0): See 'controldefault' above for an
%         explanation of this option.
%
%       - use_custom_constraint_set_fn (0): See the
%         'custom_constraint_set_fn' option for more information on this.
%
%       - use_parallel (0):  If set to 1, VIKAASA will try to use a
%         parallel cellfun (either PARCELLFUN or VK_CELLFUN_PARFOR) so as
%         to compute viability kernels in parallel.  In MATLAB you need to
%         have the Parallel Computing Toolbox for this to work.  In GNU
%         Octave PARCELLFUN is available from OctaveForge.
%
%       - viable_fn (TOOLS/VK_VIABLE): This is the function used by
%         TOOLS/VK_COMPUTE to determine whether a point is viable or not.
%         The default is to use TOOLS/VK_VIABLE; however, this could
%         potentially be replaced with a different implementation.
%
%       - zero_fn (fzero): This function is used by TOOLS/VK_CORNERSOLN to
%         solve situations where the control should be chosen to prevent
%         the system leaving the constraint set.  It is sensitive to the
%         'controltolerance' option.
%
% See also: VIKAASA, CELLFUN, CONTROLALGS/COSTMIN, CONTROLALGS/COSTSUMMIN,
%   FMINBND, FZERO, NORM, ODE45, TOOLS/VK_COMPUTE, TOOLS/VK_CORNERSOLN,
%   TOOLS/VK_EXITED, TOOLS/VK_FMINBND, TOOLS/VK_SIMULATE_EULER,
%   TOOLS/VK_SIMULATE_ODE, TOOLS/VK_VIABLE
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
                'discretisation', 10, ...
                'maxloops', 46000, ...
                'numvars', length(K)/2, ...
                'ode_solver_name', 'ode45', ...
                'parallel_processors', 2, ...
                'report_progress', 0, ...
                'steps', 1, ...
                'stepsize', 1, ...
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
        %options.norm_fn = @(x) vk_wnorm(x, K);
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
        options.bound_fn = @vk_bound;
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
        options.enforce_fn = @vk_enforce;
    end

    % The cell function is used by vk_compute.  It needs to take a variable
    % number of cell array inputs.
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
        %options.viable_fn = @vk_viable_redo4d28aug;
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
        h = options.stepsize;
        options.next_fn = @(x,u) x + h*f(x, u);
    end

    % ODE solver function.  By default we use ode45 or lsode, with the step
    % size set accordingly.
    if (~isfield(options, 'ode_solver'))
        if (exist('odeset'))
            ode_opts = odeset('MaxStep', options.stepsize);

            % If we are being interactive, then we pass in the outputfcn
            % argument too.
            if (options.report_progress ...
                    || options.cancel_test ...
                    || options.sim_stopsteady)
                ode_opts = odeset(ode_opts, 'OutputFcn', @(t,y,flag) ...
                    vk_ode_outputfcn(t, y, flag, options.report_progress, ...
                    options.progress_fn, options.cancel_test, ...
                    options.cancel_test_fn, ...
                    options.sim_stopsteady, options.norm_fn, options.small));
            end

            options.ode_solver = eval(['@(varargin) ', ...
                options.ode_solver_name, '(varargin{:}, ode_opts)']);
        elseif (exist('lsode'))
            lsode_options('maximum step size', options.stepsize);
            options.ode_solver = @lsode;
        else
            options.ode_solver = @(varargin) error('Could not find an ODE solver');
        end
    end

    if (~isfield(options, 'sim_fn'))
        options.sim_fn = @vk_simulate_ode;
    end
end
