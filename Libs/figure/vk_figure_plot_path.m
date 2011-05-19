%% VK_FIGURE_PLOT_PATH Draw a trajectory into a viability kernel window.
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function vk_figure_plot_path(T, path, viablepath, showpoints, varargin)

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

        if (viablepath(3,i) == 1)
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
