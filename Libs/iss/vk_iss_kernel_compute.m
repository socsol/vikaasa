% VK_ISS_KERNEL_COMPUTE Determine the viability kernel using InfSOCSol
%
% SYNOPSIS
%   This has the same method signature as `vk_kernel_compute`, but
%   uses InfSOCSol (i.e.  the "exclusion algorithm") instead of the
%   normal "inclusion algorithm".

%%
%  Copyright 2014 Jacek B. Krawczyk and Alastair Pharo
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
function [V, NV, viable_paths, nonviable_paths] = vk_iss_kernel_compute(K, ...
                                                  f, c, varargin)

    options = vk_options(K, f, c, varargin{:});


    %% iss_solve
    cost_fn = @(u, varargin) u * u';

    % The ISS delta_fn is a slightly different format.
    delta_fn = @(u,x,t) f(x',u')';

    discretisation = options.discretisation;

    vectors = cell(1,options.numvars);
    state_lb = zeros(1, options.numvars);
    state_ub = zeros(1, options.numvars);
    state_step = zeros(1, options.numvars);

    for d = 1:options.numvars
        vectors{d} = linspace(K(2*d - 1), K(2*d), discretisation(d));
        state_step(d) = (K(2*d) - K(2*d - 1)) / (discretisation(d) - 1);

        state_lb(d) = vectors{d}(1) - state_step(d);
        state_ub(d) = vectors{d}(end) + state_step(d);
    end

    pool_size = 1;
    if options.use_parallel
        pool_size = options.parallel_processors;
    end

    conf = iss_conf(state_lb, state_ub, ...
                    'StateStepSize', state_step, ...
                    'TimeStep', options.h, ...
                    'Debug', options.debug, ...
                    'DiscountRate', 0.1, ...
                    'ControlDimension', options.numcontrols, ...
                    'PoolSize', pool_size, ...
                    'ControlLB', -c', ...
                    'ControlUB', c', ...
                    'MaxFunEvals', 400, ...
                    'TolFun', options.controltolerance, ...
                    'UserConstraintFunctionFile', @vk_iss_constraints);

    % Add the basic set-up to the config.
    conf.vk_K = K;
    conf.vk_f = f;
    conf.vk_c = c;
    conf.vk_opts = options;

    fprintf(1, 'Running InfSOCSol ...\n');

    [ocm ignore1, ignore2, flags] = iss_solve(delta_fn, cost_fn, state_lb, ...
                                              state_ub, conf);


    %% Simulation, using vk_kernel_compute

    % Create a VIKAASA control function using infsocsol
    control_fn = @(x, K, f, c, varargin) iss_odm_control(ocm, x', ...
                                                      state_lb, ...
                                                      state_ub, ...
                                                      conf)';

    % Run vk_viable with exclusion algorithm settings.
    [V, NV, viable_paths, nonviable_paths] = ...
        vk_kernel_compute(K, f, c, options, ...
                          'control_fn', control_fn, ...
                          'stop_fn', @vk_iss_viable_stop, ...
                          'maxloops', 200);
end