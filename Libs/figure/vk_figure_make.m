%% VK_FIGURE_MAKE Plots a viability kernel.
%
% SYNOPSIS
%   This function will plot the given viability kernel in an existing figure,
%   as specified by the `handle'.  Based on the number of dimensions in the
%   kernel, vk_figure_make determines whether to plot an area or a volume.
%
% USAGE
%   % Standard usage:
%   vk_figure_make(V, K, labels, colour, method, box, alpha_val, handle)
%
%   - `V': The complete viability kernel.
%   - `K': The constraint set
%   - `labels': Labels for the axes
%   - `colour': The colour to draw th kernel
%   - `method': The method for drawing the kernel
%   - `box': Whether or not to draw a box around the kernel
%   - `alpha_val': The degree of transparency
%   - `handle': the handle to display the figure in.
%
% See also: vk_figure_plot_area, vk_figure_plot_surface, vk_kernel_view

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
function vk_figure_make(V, K, labels, colour, method, box, ...
    alpha_val, handle)

  if (size(V, 2) > 3 || size(V, 2) < 2)
      vk_error('Too many dimensions to plot.  Please select some slices.');
  end

  figure_name = 'Viability Kernel';

  figure(handle);
  title(figure_name);
  set(handle, 'Name', figure_name);

  xlabel(labels{1});
  ylabel(labels{2});
  if (size(V, 2) == 2)
      vk_figure_plot_area(V, colour, method, alpha_val);
  elseif (size(V, 2) == 3)
      zlabel(labels{3});
      vk_figure_plot_surface(V, colour, method, alpha_val);
      view(3);
  end

  if (box)
      limits = vk_figure_plot_box(K);
  else
      limits = K;
  end

  vk_figure_data_insert(handle, limits, []);
  axis(limits);
end
