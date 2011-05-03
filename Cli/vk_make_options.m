%% VK_MAKE_OPTIONS Creates an options structure from a project file.
%   This function is used to wrap TOOLS/VK_OPTIONS in VIKAASA.  It reads
%   options out of project and feeds them into VK_OPTIONS.
%
%   Standard usage:
%   options = VK_4DGUI_MAKE_OPTIONS(PROJECT, F)
%
%   PROJECT should be a VIKAASA project.
%   F should be a function, as created with VK_MAKE_DIFF_FN
%
%   Optionally, a waitbar can also be specified:
%   options = VK_4DGUI_MAKE_OPTIONS(project, f, wb, numcomputations, message)
%
% See also: VIKAASA, TOOLS/VK_OPTIONS
function options = vk_make_options(project, f, varargin)
    K = project.K;
    numvars = length(K)/2;
    c = project.c;
    symbols  = project.symbols;

    project.custom_constraint_set_fn
    if (project.use_custom_constraint_set_fn)
        fnparams = mat2cell(symbols, ...
            ones(1,size(symbols,1)),size(symbols,2))
        constraint_set_fn = inline(...
            project.custom_constraint_set_fn, ...
            fnparams{:});
        custom_constraint_set_opts = {...
            'use_custom_constraint_set_fn', 1, ...
            'custom_constraint_set_fn', constraint_set_fn};
    else
        custom_constraint_set_opts = {};
    end
        
    if (project.use_custom_cost_fn)        
        fnparams1 = mat2cell(symbols, ...
            ones(1,size(symbols,1)),size(symbols,2));
        fnparams2 = cellfun(@(x) [deblank(x), 'dot'], fnparams1, ...
            'UniformOutput', 0);
        
        cost_fn = inline(project.custom_cost_fn, ...
            fnparams1{:}, fnparams2{:});
        cost_fn2 = @(x,xdot) vk_cost_fn(cost_fn, x, xdot);
        cost_fn_opts = {'cost_fn', cost_fn2};
    else
        cost_fn_opts = {};
    end
    
    if (nargin > 3)        
        wb = varargin{1};        
        computations = varargin{2};
        message = varargin{3};
        start_time = tic;
        progress_fn = @(x) waitbar(x/computations, ...
                wb, [message, ' (', ...
                timeformat((computations-x)*toc(start_time)/x), ...
                ' remaining)']);
        cancel_test_fn = @() getappdata(wb, 'cancelling') > 0;
        wb_opts = {...
                'report_progress', 1, ...
                'progress_fn', progress_fn, ...
                'cancel_test', 1, ...
                'cancel_test_fn', cancel_test_fn};
    else
        wb_opts = {};
    end
       
    % sim_fn is determined by whether the drop-down is set to 'ode' or
    % 'euler'.
    if (strcmp(project.sim_method, 'euler'))
        sim_fn = @vk_simulate_euler;
    else
        sim_fn = @vk_simulate_ode;
    end
    
    % 'small' must be constructed by creating a vector of size 'stopping
    % tolerance' in every direction.
    small = norm(project.stoppingtolerance*ones(numvars,1));

    % This "options" structure sets additional properties.    
    options = vk_options(K, f, c, ...            
            'debug', project.debug, ...
            'steps', project.steps, ...
            'control_fn', eval(['@', project.controlalg]), ...
            'controlbounded', project.controlbounded, ...
            'controldefault', project.controldefault, ...
            'controlenforce', project.controlenforce, ...
            'controlsymbol', project.controlsymbol, ...
            'discretisation', project.discretisation, ...
            'parallel_processors', project.parallel_processors, ...
            'controltolerance', project.controltolerance, ...
            'sim_fn', sim_fn, ...
            'sim_stopsteady', project.sim_stopsteady, ...
            'small', small, ...
            'timediscretisation', project.timediscretisation, ...
            'use_controldefault', project.use_controldefault, ...
            'use_parallel', project.use_parallel, ...
            custom_constraint_set_opts{:}, wb_opts{:}, cost_fn_opts{:} ...
        );
end

%% Helper function that formatting seconds into something human readable.
function formatted = timeformat(seconds)

    if (seconds > 22896000)
        formatted = 'unknown time';
        return;
    elseif (seconds > 86400)
        denom = 86400;
        desc = ' days';        
    elseif (seconds > 3600)
        denom = 3600;        
        desc = ' hours';
    elseif (seconds > 60)
        denom = 60;
        desc = ' minutes';
    else
        denom = 1;
        desc = ' seconds';
    end
    
    formatted = sprintf('%.1f %s', seconds/denom, desc);
end
