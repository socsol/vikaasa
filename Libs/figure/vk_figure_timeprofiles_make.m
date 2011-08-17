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
        sim_state = vk_sim_augment(project, opts.simulation);
    else
        sim_state = vk_sim_augment(project);
    end

    labels = [project.labels; project.addnlabels];
    K = vk_kernel_augment_constraints(project);
    discretisation = [project.discretisation; max(project.discretisation)*ones(project.numaddnvars, 1)];
    c = project.c;

    %% Work out what is being ignored.
    ignoreindices = sort(find(project.addnignore), 'descend') + project.numvars;

    if (~isempty(ignoreindices))
        for i = ignoreindices
            K = [K(1:(2*i-2)), K((2*i+1):end)];
            discretisation = [discretisation(1:i-1); discretisation(i+1:end)];
            sim_state.path = [sim_state.path(1:i-1, :); sim_state.path(i+1:end, :)];
            labels = [labels(1:i-1); labels(i+1:end)];
        end
    end

    if (isfield(project, 'V'))
        V = vk_kernel_augment(project);

        if (~isempty(ignoreindices))
            for i = ignoreindices
                V = [V(:, 1:i-1), V(:, i+1:end)];
            end
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
