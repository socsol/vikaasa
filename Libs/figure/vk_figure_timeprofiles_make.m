%% VK_FIGURE_TIMEPROFILES_MAKE Construct a time profile figure from a project
%
% USAGE
%   % Plot the time profiles using the 'sim_state' field in 'project' in a new
%   % figure, returned as 'handle'.
%   handle = vk_figure_timeprofiles_make(project);
%
%   % Plot the time profile in a pre-existing figure, h.
%   vk_figure_timeprofiles_make(project, 'handle', h);
%
%   % Plot the time profile in a pre-existing figure, but use a different
%   % simulation to the one in the project:
%   handle = figure;
%   sim = vk_sim_make(project);
%   vk_figure_timeprofiles_make(project, 'simulation', sim, 'handle', handle);
%
% Requires: vk_figure_timeprofiles_plot

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
function handle = vk_figure_timeprofiles_make(project, varargin)
    opts = struct(varargin{:});

    if (isfield(opts, 'handle'))
        handle = opts.handle;
    else
        handle = figure;
    end

    if (isfield(opts, 'simulation'))
        sim_state = opts.simulation;
    else
        sim_state = project.sim_state;
    end

    labels = project.labels;
    K = project.K;
    discretisation = project.discretisation;
    c = project.c;
    if (isfield(project, 'V'))
        V = project.V;
    else
        V = [];
    end

    sim_line_colour = project.sim_line_colour;
    plotcolour = project.plotcolour;
    width = project.sim_line_width;
    showpoints = project.sim_showpoints;
    showkernel = project.sim_showkernel;
    plottingmethod = project.plottingmethod;
    alpha_val = project.alpha;

    handle = vk_figure_timeprofiles_plot(labels, K, discretisation, c, V, ...
        plotcolour, sim_line_colour, width, showpoints, showkernel, plottingmethod, ...
        alpha_val, sim_state, handle);
end
