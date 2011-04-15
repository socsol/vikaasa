%% VK_4DGUI_MAKE_OPTIONS Creates an options structure from GUI handles.
%   This function is used to wrap TOOLS/VK_OPTIONS in VIKAASA.  It reads
%   options out of handles.vk_state and feeds them into VK_OPTIONS.
%
%   Standard usage:
%   options = VK_4DGUI_MAKE_OPTIONS(hObject, handles, delta_fn)
%
%   Optionally, a waitbar can also be specified:
%   options = VK_4DGUI_MAKE_OPTIONS(hObject, handles, delta_fn, ...
%       wb, numcomputations, message)
%
% See also: VIKAASA, TOOLS/VK_OPTIONS
function options = vk_4dgui_make_options(hObject, handles, delta_fn, varargin)
    constraint_set = handles.vk_state.constraint_set;
    numvars = length(constraint_set)/2;
    controlmax = handles.vk_state.controlmax;
    symbols  = handles.vk_state.symbols;

    handles.vk_state.custom_constraint_set_fn
    if (handles.vk_state.use_custom_constraint_set_fn)
        fnparams = mat2cell(symbols, ...
            ones(1,size(symbols,1)),size(symbols,2))
        constraint_set_fn = inline(...
            handles.vk_state.custom_constraint_set_fn, ...
            fnparams{:});
        custom_constraint_set_opts = {...
            'use_custom_constraint_set_fn', 1, ...
            'custom_constraint_set_fn', constraint_set_fn};
    else
        custom_constraint_set_opts = {};
    end
        
    if (handles.vk_state.use_custom_cost_fn)        
        fnparams1 = mat2cell(symbols, ...
            ones(1,size(symbols,1)),size(symbols,2));
        fnparams2 = cellfun(@(x) [deblank(x), 'dot'], fnparams1, ...
            'UniformOutput', 0);
        
        cost_fn = inline(handles.vk_state.custom_cost_fn, ...
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
    if (strcmp(handles.vk_state.sim_method, 'euler'))
        sim_fn = @vk_simulate_euler;
    else
        sim_fn = @vk_simulate_ode;
    end
    
    % 'small' must be constructed by creating a vector of size 'stopping
    % tolerance' in every direction.
    small = norm(handles.vk_state.stoppingtolerance*ones(numvars,1));

    % This "options" structure sets additional properties.    
    options = vk_options(constraint_set, delta_fn, controlmax, ...            
            'debug', handles.vk_state.debug, ...
            'steps', handles.vk_state.steps, ...
            'control_fn', eval(['@', handles.vk_state.controlalg]), ...
            'controldefault', handles.vk_state.controldefault, ...
            'controlsymbol', handles.vk_state.controlsymbol, ...
            'discretisation', handles.vk_state.discretisation, ...
            'numvars', handles.vk_state.numvars, ...
            'controltolerance', handles.vk_state.controltolerance, ...
            'sim_fn', sim_fn, ...
            'sim_stopsteady', handles.vk_state.sim_stopsteady, ...
            'small', small, ...
            'timediscretisation', handles.vk_state.timediscretisation, ...
            'use_controldefault', handles.vk_state.use_controldefault, ...
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
