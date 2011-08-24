%% VK_PLOT_PATH Draw a trajectory into a viability kernel window.
%

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
function vk_plot_path(T, path, viablepath, showpoints, varargin)

    if (nargin > 4)
        colour = varargin{1};
        width = varargin{2};
    else
        colour = 'k';
        width = 2;
    end

    % First, draw a black line through the points.
    if (size(path,1) == 2)
        plot(path(1, :), path(2, :), ...
            '-', 'Color', colour, 'LineWidth', width);
    elseif (size(path,1) == 3)
        plot3(path(1, :), path(2, :), path(3, :), ...
            '-', 'Color', colour, 'LineWidth', width);
    else
        error ('Too many dimensions to plot the path.');
    end

    % Next, for each point, we draw a coloured marker:
    %  - Green, if in the kernel.
    %  - Blue on the edge of the kernel.
    %  - Orange, if outside the kernel.
    %  - Red if outside the constraint set.
    %
    % This info is contained in viablepath.  Row 1 is 1 iff the point is
    % inside of the kernel.  Row 2 is 1 iff the point is on the edge.  Row
    % 3 is 1 iff the point is outside of the constraint set.
    if (showpoints)
        num = size(path, 2);
    else
        num = 1;
    end

    hold on;
    for i = 1:num
        if (i == 1)
            marker = 'x';
            msize = 5;
        %elseif (T(i) == round(T(i)))
        %    marker = 'o';
        %    msize = 5;
        else
            marker  = 'o';
            msize = 5;
        end

        if (viablepath(4,i) == 1)
            colour = [0.5 0 0.7];
        elseif (viablepath(3,i) == 1)
            colour = 'r';
        elseif (viablepath(1,i) == 1)
            colour = 'g';
        elseif (viablepath(2, i) == 1)
            colour = 'b';
        else
            colour = [1 0.5 0];
        end

        if (size(path,1) == 2)
            plot(path(1, i), path(2, i), marker, ...
                'MarkerEdgeColor', colour, ...
                'MarkerFaceColor', colour, ...
                'MarkerSize', msize);
        elseif (size(path,1) == 3)
            plot3(path(1, i), path(2, i), path(3, i), marker, ...
                'MarkerEdgeColor', colour, ...
                'MarkerFaceColor', colour, ...
                'MarkerSize', msize);
        end
    end
