%% VK_PLOT_SURFACE_PATHS Plot a 3D graph of all the viable trajectories
%
% SYNOPSIS
%   This function 3D phase diagrams of all the viable (and possibly non-viable)
%   points in the kernel. 
%
% USAGE
%   % You must specify viable_paths.
%   p = vk_plot_surface_paths(V, c, 1, 'viable_paths', vp);
%
%   % You can also optionally specify nonviable_points.  They will be rendered
%   % in the inverse colour to c.
%   p = vk_plot_surface_paths(V, c, 1, 'viable_paths', ps, 'nonviable_paths', nvp);
%
% See also: vk_plot, vk_plot_area_paths

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
function vk_plot_surface_paths(V, colour, alpha, varargin)

    opts = struct(varargin{:});
    viable_paths = opts.viable_paths;

    if isfield(opts, 'width')
      width = opts.width;
    else
      width = 1;
    end

    if isfield(opts, 'showpoints')
      showpoints = opts.showpoints;
    else
      showpoints = 0;
    end

    if isfield(opts, 'slices')
      slices = opts.slices;
    else
      slices = [];
    end

    vk_plot_surface_paths_helper(viable_paths, slices, showpoints, colour, width);

    if isfield(opts, 'nonviable_paths')
        c = 1 - colour;
        vk_plot_surface_paths_helper(opts.nonviable_paths, slices, showpoints, c, width);
    end
      
end

function vk_plot_surface_paths_helper(paths, slices, showpoints, colour, width)
    for i = 1:length(paths)
      path = paths{i};
      
      if length(path.T) > 0
          vk_plot_path(path.T, vk_kernel_slice_path(path.path, slices), ...
              path.viablepath, showpoints, colour, width);
      end
    end
end
