%% VK_FIGURE_TIMEPROFILES_PLOT Plot time profiles for a given simulation.
%
% SYNOPSIS
%   Places time profile subplots into the given figure handle.  If there are
%   already subplots present, they are not overwritten (i.e., `hold on' is
%   set).
%
% USAGE
%   % Create a handle, and plot time profiles into it:
%   h = figure;
%   vk_figure_timeprofiles_plot(labels, K, discretisation, c, V, ...
%       plotcolour, line_colour, width, simulation, h);
%
%   All values are as in the projects.
%
% Requires:  vk_kernel_distances, vk_kernel_slice, vk_plot_path
%
% See also: vk_figure_timeprofiles_plot_make, vk_project_new

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
function handle = vk_figure_timeprofiles_plot(labels, K, discretisation, c, V, ...
    plotcolour, line_colour, width, showpoints, showkernel, plottingmethod, ...
    alpha_val, cols, simulation, handle)

    T = simulation.T;
    path = simulation.path;
    normpath = simulation.normpath;
    controlpath = simulation.controlpath;
    viablepath = simulation.viablepath;

    %% Construct the distances.
    distances = vk_kernel_distances(K, discretisation);

    %% Set handle as the active figure (for plotting in below)
    figure(handle);

    numplots = size(path, 1) + 2;
    rows = ceil(numplots/cols);

    for i = 1:size(path, 1)
        %% Select the correct subplot, and hold any current contents.
        subplot(rows, cols, i);
        hold on;

        %% Plot the kernel cross-sections through time if this is checked.
        if (showkernel)
            %% Vt is the kernel slice in time ...
            Vt = zeros(size(V, 1)*length(T), 2);
            cnt = 0;

            %% Construct Vt
            for j = 1:length(T)
                slices = zeros(size(path, 1) - 1, 3);
                for k = 1:i-1
                    slices(k, :) = [k, path(k,j), distances(k)];
                end

                for k = i+1:size(path, 1)
                    slices(k-1, :) = [k, path(k,j), distances(k)];
                end

                %% S should be a single column vector of values.
                S = vk_kernel_slice(V, slices);
                sort(S);
                plot(T(j)*ones(length(S),1),S, 'Color', plotcolour);
                if (length(S) > 0)
                  plot(T(j), S(1), '^',  'Color', plotcolour);
                  plot(T(j), S(end), 'v',  'Color', plotcolour);
                end
                %Vt(cnt + 1:cnt + size(S, 1), :) = [T(j)*ones(size(S, 1), 1), S];
                %cnt = cnt + size(S, 1);
            end

            %Vt = Vt(1:cnt, :);

            %% Plot the kernel-in-time by using vk_plot_area:
            %vk_plot_area(Vt, plotcolour, plottingmethod, alpha_val);
        end

        %% Plot the rectangular constraint set boundaries in red.
        plot(T, K(2*i - 1) * ones(1, length(T)), ...
            'Color', 'r', 'LineWidth', 1);
        plot(T, K(2*i) * ones(1, length(T)), ...
            'Color', 'r', 'LineWidth', 1);

        %% Plot the path of this variable
        vk_plot_path(T, [T; path(i, :)], viablepath, showpoints, line_colour, width);
        title(labels{i});
        axis tight;
    end

    %% Plot the system velocity.
    subplot(rows, cols, numplots-1);
    hold on;
    plot(T, normpath, 'Color', line_colour, 'LineWidth', width);
    plot(T, simulation.small * ones(1, length(T)), ...
        'Color', 'r', 'LineWidth', 1);
    if (showpoints)
        % Ind should give the steady points.
        ind = find(viablepath(5, :));
        plot(T(ind), normpath(ind), '.g');
    end
    title('velocity');
    axis tight;

    if (length(controlpath) == length(T))
        subplot(rows, cols, numplots);
        hold on;
        plot(T, c * ones(1, length(T)), ...
            'Color', 'r', 'LineWidth', 1);
        plot(T, -c * ones(1, length(T)), ...
            'Color', 'r', 'LineWidth', 1);
        plot(T, controlpath, 'Color', line_colour, 'LineWidth', width);
        title('control');
        axis tight;
    end
end
