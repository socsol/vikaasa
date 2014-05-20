%% VK_KERNEL_MAKE_DYNAMICS Determines system dynamics at initial states
%
% SYNOPSIS
%   This function is used by plots that display system's dynamics,
%   such as vk_plot_area_quiver.
%
% See also: vk_plot_area_quiver, vk_plot_surface_quiver

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
function [points, dynamics] = vk_kernel_make_dynamics(project, paths)
    points = cellfun(@(p) p.path(:,1), paths, 'UniformOutput', 0);
    controls = cellfun(@(p) p.controlpath(:,1), paths, 'UniformOutput', 0);

    f = vk_diff_make_fn(project);

    % Run the diff_fn on the initial point, initial control pairs.
    dynamics = transpose( ...
      cell2mat( ...
        cellfun(@(x, u) transpose(f(x,u)), points, controls, 'UniformOutput', 0)));

    % We need to turn the points vector into a matrix of column vectors
    points = transpose(cell2mat(cellfun(@transpose, points, 'UniformOutput', 0)));
end
