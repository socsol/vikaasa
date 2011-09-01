%% VK_OPTIONS_MAKE Creates an options structure from a project file.
%
% SYNOPSIS
%   This function is used to wrap vk_options in VIKAASA.  It reads
%   options out of project and feeds them into vk_options.
%
% USAGE
%   % Standard usage:
%   options = vk_options_make(project, f)
%
%   - `project' should be a VIKAASA project.
%   - `f' should be a function, as created with vk_make_diff_fn
%
%   % Optionally, a waitbar can also be specified:
%   options = vk_options_make(project, f, wb, numcomputations, message)
%
% Requires:  vk_control_cost_fn, vk_options, vk_sim_simulate_euler, vk_sim_simulate_ode, vk_timeformat
%
% See also: options, project

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
function options = vk_options_make(project, f, varargin)
    K = project.K;
    numvars = length(K)/2;
    c = project.c;
    symbols  = project.symbols;

    if (project.use_custom_constraint_set_fn)
        constraint_set_fn = inline(...
            project.custom_constraint_set_fn, ...
            symbols{:});
        custom_constraint_set_opts = {...
            'use_custom_constraint_set_fn', 1, ...
            'custom_constraint_set_fn', constraint_set_fn};
    else
        custom_constraint_set_opts = {};
    end

    if (project.use_custom_cost_fn)
        dotsymbols = cellfun(@(x) [x, 'dot'], symbols, 'UniformOutput', 0);

        cost_fn = inline(project.custom_cost_fn, ...
            symbols{:}, dotsymbols{:});
        cost_fn2 = @(x,xdot) vk_control_cost_fn(cost_fn, x, xdot);
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
                vk_timeformat((computations-x)*toc(start_time)/x), ...
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
        sim_fn = @vk_sim_simulate_euler;
    else
        sim_fn = @vk_sim_simulate_ode;
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
            'sim_hardupper', project.sim_hardupper, ...
            'sim_hardlower', project.sim_hardlower, ...
            'sim_stopsteady', project.sim_stopsteady, ...
            'small', small, ...
            'h', project.h, ...
            'use_controldefault', project.use_controldefault, ...
            'use_parallel', project.use_parallel, ...
            custom_constraint_set_opts{:}, wb_opts{:}, cost_fn_opts{:} ...
        );
end
