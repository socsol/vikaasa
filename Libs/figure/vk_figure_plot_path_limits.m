%% VK_FIGURE_PLOT_PATH_LIMITS Calculate the extended limits of a kernel
%   When a path is being plotted, it is possible that it will travel outside of
%   the constraint set in doing so.  This function calculates the size of the
%   necessary display window.
%
% See also: VK_FIGURE_PLOT_PATH
%
% Copyright (C) 2011 by Jacek B. Krawczyk and Alastair Pharo
function limits = vk_figure_plot_path_limits(limits, path)
    for j = 1:length(limits) / 2
        limits(2*j - 1) = min([limits(2*j - 1), path(j, :)]);
        limits(2*j) = max([limits(2*j), path(j, :)]);
    end
end
