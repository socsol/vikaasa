%% VK_FIGURE_MAKE Create a figure representing a viability kernel a variety of methods.
%
% SYNOPSIS
%   This function slices the given kernel and then plots it into the figure
%   provided by `handle'.  Aside from slicing, functionality is identical to
%   vk_figure_make.
%
% USAGE
%   % Standard usage:
%   vk_figure_make_slice(V, slices, K, labels, colour, method, box, alpha_val, handle)
%
%  - `V': The complete viability kernel
%  - `slices': A nx3 matrix of [axis, point,distance] triples (see vk_kernel_slice).
%  - `K': The constraint set
%  - `labels': Labels to display on the axes.
%  - `colour': The colour to draw the kernel.
%  - `method': Which method to use in drawing the kernel.
%  - `box': Whether or not to draw a box around the kernel.
%  - `alpha_val': The transparency to give the kernel (certain drawing methods only)
%  - `handle': The handle to display the figure in.
%
% Requires:  vk_error, vk_figure_data_insert, vk_kernel_slice, vk_plot, vk_plot_box
%
% See also: vk_figure_make, vk_kernel_view

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
function vk_figure_make(project, handle)

    V = vk_kernel_augment(project);
    K = vk_kernel_augment_constraints(project);
    labels = vk_kernel_augment_labels(project);
    colour = project.plotcolour;
    method = project.plottingmethod;
    box = project.drawbox;
    alpha_val = project.alpha;
    slices = vk_kernel_augment_slices(project);

    V = vk_kernel_slice(V, slices);

    if (size(V, 2) > 3 || size(V, 2) < 2)
        vk_error('Too many dimensions to plot.  Please select some more slices.');
    end

    if (length(method) > 6 && strcmp(method(end-6:end), '-smooth'))
        method = method(1:end-7);
        opts = {'smooth', 1};
    elseif (length(method) > 2 && any(strcmp(method(end-1:end), ...
        {'-.', '-o', '-x', '-+', '-*', '-s', '-d', '-v', '-^', '-<', ...
            '->', '-p', '-h'})))

        opts = {'marker', method(end)};
        method = method(1:end-2);
    elseif (length(method) >= 6 && strcmp(method(1:6), 'quiver'))
        [points, dynamics] = vk_kernel_make_dynamics(project, project.viable_paths);
        [points, dynamics] = vk_kernel_slice_dynamics(points, dynamics, slices);
        opts = { ...
            'points', points,  ...
            'dynamics', dynamics};
    elseif (length(method) >= 5 && strcmp(method(1:5), 'paths'))
        opts = { ...
            'slices', slices, ...
            'showpoints', project.sim_showpoints, ...
            'width', project.sim_line_width, ...
            'viable_paths', {project.viable_paths}};

        if strcmp(method(end-3:end), '-all') && isfield(project, 'nonviable_paths')
            opts = [opts, {'nonviable_paths', {project.nonviable_paths}}];
        end

        method = 'paths';
    else
        opts = {};
    end

    % Construct the figure name
    if (size(slices, 1) > 0)
        figure_name = 'Slice through ';
        for i = 1:size(slices, 1)
            if (isnan(slices(i,2)))
                figure_name = [figure_name, ...
                    labels{slices(i, 1)}, '=all'];
            else
                figure_name = [figure_name, ...
                    labels{slices(i, 1)}, '=', num2str(slices(i, 2))];
            end

            if (i < size(slices, 1))
                figure_name = [figure_name, ', '];
            end
        end
    else
        figure_name = 'Viability kernel';
    end
    figure(handle);
    title(figure_name);
    set(handle, 'Name', figure_name);

    % Remove the info about the axes that have been sliced.
    K = vk_kernel_slice_constraints(K, slices);
    labels = vk_kernel_slice_text(labels, slices);

    vk_plot(V, colour, method, alpha_val, opts{:});
    xlabel(labels{1});
    ylabel(labels{2});
    if (size(V, 2) == 3)
        zlabel(labels{3});
        view(3);
    end

    if (box)
        limits = vk_plot_box(K);
    else
        limits = K;
    end

    vk_figure_data_insert(handle, limits, slices);
    axis(limits);
end
