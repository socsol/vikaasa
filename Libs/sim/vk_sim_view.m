%% VK_SIM_VIEW Draw a two- or three-dimensional simulation trajectory
%
% SYNOPSIS
%   Draws a simulation trajectory, either into a new figure, or into an
%   existing one.
%
% USAGE
%   % Plot the simulation into a new figure and return a handle to it.
%   h = vk_sim_view(project);
%
%   % Plot the simulation in an existing figure.
%   vk_sim_view(project, h);
%
% Requires: vk_figure_data_insert, vk_figure_data_retrieve, vk_kernel_augment_constraints, vk_kernel_augment_slices, vk_plot_box, vk_plot_path, vk_plot_path_limits, vk_sim_augment
%
% See also: vk_figure_make, vk_figure_make_slice

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
function h = vk_sim_view(project, varargin)

    newfig = 0;
    if (nargin > 1)
        newfig = 1;
        h = varargin{1};
    else
        h = figure;

        title(['Simulation starting from ', ...
            num2str(transpose(project.sim_state.path(:,1))), ...
            ' for ', num2str(project.sim_state.T(end)), ...
            ' time intervals']);
    end

    figure(h);

    sim_state = vk_sim_augment(project);

    T = sim_state.T;
    path = sim_state.path;

    if (newfig)
        slices = vk_kernel_augment_slices(project);
    else
        [limits, slices] = vk_figure_data_retrieve(h);
    end

    K = vk_kernel_augment_constraints(project);
    labels = [project.labels; ...
        project.addnlabels(find(~project.addnignore))];
    if (~isempty(slices))
        slices = sortrows(slices, -1);
        for i = 1:size(slices, 1)
            path = [path(1:slices(i, 1)-1, :); path(slices(i, 1)+1:end, :)];
            K = [K(1:2*slices(i, 1)-2), ...
                K(2*slices(i, 1)+1:end)];
            labels = [labels(1:slices(i, 1)-1); ...
                labels(slices(i, 1)+1:end)];
        end
    end

    if (newfig)
        if (project.drawbox)
            limits = vk_plot_box(K);
        else
            limits = K;
        end
    end

    limits = vk_plot_path_limits(limits, path);

    viablepath = sim_state.viablepath;
    showpoints = project.sim_showpoints;

    vk_plot_path(T, path, viablepath, showpoints, ...
        project.sim_line_colour, project.sim_line_width);

    vk_figure_data_insert(h, limits, slices);
    axis(limits);
    grid on;

    xlabel(labels{1});
    ylabel(labels{2});
    if (length(limits) == 6)
        zlabel(labels{3});
        view(3);
    end

end
