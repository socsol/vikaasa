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

    %% If this is enabled, add an extra pseudo-element, composed from var3-var2.
    if (project.sim_showrealinterest)
        labels = [labels; {'real interest rate'}];

        % The additional constraint is just worked out as being the largest
        % possible and lowest possible value of r.
        K = [K, K(5)-K(4), K(6)-K(3)];

        % Just pick the largest discretisation.
        discretisation = [discretisation; max(discretisation(2), discretisation(3))];

        sim_state.path = [sim_state.path; sim_state.path(3,:)-sim_state.path(2,:)];
    end

    if (isfield(project, 'V'))
        V = project.V;

        if (project.sim_showrealinterest)
            V = [V, V(:,3)-V(:,2)];
        end
    else
        V = [];
    end

    sim_line_colour = project.sim_line_colour;
    sim_timeprofile_cols = project.sim_timeprofile_cols;
    plotcolour = project.plotcolour;
    width = project.sim_line_width;
    showpoints = project.sim_showpoints;
    showkernel = project.sim_showkernel;
    plottingmethod = project.plottingmethod;
    alpha_val = project.alpha;

    handle = vk_figure_timeprofiles_plot(labels, K, discretisation, c, V, ...
        plotcolour, sim_line_colour, width, showpoints, showkernel, plottingmethod, ...
        alpha_val, sim_timeprofile_cols, sim_state, handle);
end
