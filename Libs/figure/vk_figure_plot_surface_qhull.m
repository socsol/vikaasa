%% VK_FIGURE_PLOT_SURFACE_QHULL Plot a 3D kernel using convex hull method.
%
% SYNOPSIS
%   Draws a 3D representation fo a kernel (or kernel slice) using the
%   `convhulln' function.  It uses the current figure.  The colour can
%   be either a string, or a triple, like `[1 1 0]'.  An alpha level
%   can optionally be specified.
%
% USAGE
%   % For some kernel V and colour, c:
%   vk_figure_plot_surface_qhull(V, c);
%
%   % Create a figure, and then plot a blue kernel in it:
%   h = figure;
%   vk_figure_plot_surface_qhull(V, 'b');
%
%   % Optionally specify an alpha setting of 0.5:
%   vk_figure_plot_surface_qhull(V, c, 0.5);
%
%
% See also: vk_figure_plot_surface
function vk_figure_plot_surface_qhull(V, colour, varargin)

    if (nargin > 2)
        alpha_val = varargin{1};
    else
        alpha_val = 1;
    end

    % T is a set of triangles that together trace a surface around
    % V.
    T = convhulln(V);

    % If lighting functionality exists, use it.  Otherwise, set
    % edges to black.
    if (exist('camlight'))
        camlight left;
        camlight right;
        lighting gouraud;
        edgecolour = 'none';
    else
        edgecolour = 'k';
    end

    for i = 1:length(T)
        p = patch(V(T(i,:), 1), V(T(i,:), 2), V(T(i,:), 3), ...
            colour);
        set(p, 'FaceColor', colour, 'EdgeColor', edgecolour);
        if (exist('alpha'))
            alpha(p, alpha_val);
        end
    end
end
