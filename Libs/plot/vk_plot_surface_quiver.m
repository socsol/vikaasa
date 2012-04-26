%% VK_PLOT_SURFACE_QUIVER Plot a 3D quiver plot of a kernel.
%
% SYNOPSIS
%   This function plots the trajectories of the system at the points given in a
%   kernel, or kernel slice in 3D space.  The current figure is used.
%
% USAGE
%   % You must specify points and dynamics; in whatever order 
%   p = vk_plot_surface_quiver(V, c, 1, 'points', points, 'dynamics', dynamics);
%
% See also: vk_plot, vk_plot_area_quiver

%%
%  Copyright 2012 Jacek B. Krawczyk and Alastair Pharo
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
function vk_plot_surface_quiver(V, colour, alpha, varargin)

    opts = struct(varargin{:});
    points = opts.points;
    dynamics = opts.dynamics;

    for i = 1:size(points,2)
        quiver3(points(1, i), points(2, i), points(3, i), ...
            dynamics(1, i), dynamics(2, i), dynamics(3, i), 0, 'Color', colour);
    end
end
