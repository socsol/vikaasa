%% VK_FIGURE_MAKE_SLICE Slices a viability kernel and then plots the result.
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
% Requires: vk_plot
%
% See also: vk_figure_make, vk_kernel_slice, vk_kernel_view

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
function vk_figure_make_slice(V, slices, K, labels, ...
    colour, method, box, alpha_val, handle)

    SV = vk_kernel_slice(V, slices);

    if (size(SV, 2) > 3 || size(V, 2) < 2)
        vk_error('Too many dimensions to plot.  Please select some more slices.');
    end

    % Construct the figure name
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
    figure(handle);
    title(figure_name);
    set(handle, 'Name', figure_name);


    % Sort by dimension from largest to smallest.
    if (size(slices, 1) > 1)
        slices = sortrows(slices, -1);
    end

    % Remove the info about the axis that has been sliced.
    for i = 1:size(slices, 1);
        slice_axis = slices(i, 1);
        labels = [...
            labels(1:slice_axis-1);
            labels(slice_axis+1:end)];
        K = [K(1:2*slice_axis-2), K(2*slice_axis+1:end)];
    end

    vk_plot(SV, colour, method, alpha_val);
    xlabel(labels{1});
    ylabel(labels{2});
    if (size(SV, 2) == 3)
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
