%% VK_PLOT_AREA_QUIVER Plots a 2D set of trajectories
%
% SYNOPSIS
%   This function plots a 2D kernel as a quiver plot, using the `quiver'
%   function.
%
% USAGE
%   % Points and dynamics must be provided
%   vk_plot_area_scatter(V, colour, 1, points, dynamics)
%
% See also: quiver

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
function vk_plot_area_quiver(V, colour, alpha, varargin)

    opts = struct(varargin{:});
    points = opts.points;
    dynamics = opts.dynamics;

    for i = 1:size(points, 2)
        quiver(points(1, i), points(2, i), dynamics(1, i), dynamics(2, i), ...
            0, 'Color', colour);
    end
end
