%% VK_FIGURE_PLOT_SURFACE_SCATTER Plot a 3D scatter plot of a kernel.
%
% SYNOPSIS
%   This function plots the points given in a kernel, or kernel slice
%   in 3D space.  The current figure is used.
%
% USAGE
%   % For some kernel, V and some colour, c:
%   p = vk_figure_plot_surface_scatter(V, c);
%
% See also: vk_figure_plot_surface

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
function vk_figure_plot_surface_scatter(V, colour, varargin)
    scatter3(V(:, 1), V(:, 2), V(:, 3), 10, colour);
end
