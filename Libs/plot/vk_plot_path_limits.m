%% VK_PLOT_PATH_LIMITS Calculate the extended limits of a kernel
%
% SYNOPSIS
%   When a path is being plotted, it is possible that it will travel outside of
%   the constraint set in doing so.  This function calculates the size of the
%   necessary display window.
%
% USAGE
%   % Given some limits, e.g., produced by vk_plot_box, see if they need to be
%   % expanded.
%   limits = vk_plot_path_limits(limits, path);
%
%   - `path' is a simulation path, as produced by vk_sim_make.
%
% See also: vk_plot_path, vk_plot_box, vk_sim_make

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
function limits = vk_plot_path_limits(limits, path)
    for j = 1:length(limits) / 2
        limits(2*j - 1) = min([limits(2*j - 1), path(j, :)]);
        limits(2*j) = max([limits(2*j), path(j, :)]);
    end

    limits = real(limits);
end
