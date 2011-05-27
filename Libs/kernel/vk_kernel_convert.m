%% VK_KERNEL_CONVERT Converts viability kernels from an old format to new
%   Takes a cell array of axes, and a multi-dimensional array of points,
%   `dispgrid'. `dispgrid' represents the viability kernel.  If there is a
%   zero in the (i, j, k)th element of dispgrid, then the point [ax1(i),
%   ax2(j), ax3(k)] was identified as viable.
%
%   The replacement format, V is a $n \times dim$ array, where $n$ is the of
%   viable points; $dim$ is the number of dimensions.  Each row thus represents
%   a viable point directly.
%
% USAGE
%   % Standard usage:
%   V = vk_convert({xax, yax, zax}, dispgrid)
%
% See also: kernel

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
function V = vk_kernel_convert(axes, dispgrid)
  % This will be populated below.
  V = zeros(numel(dispgrid), ndims(dispgrid));

  % The recursive call will populate V.
  [counter, V] = vk_convert_recursive(0, V, [], axes, dispgrid);

  % Eliminate unfilled rows from V.
  V = V(1:counter, :);

% This function is a helper for  vk_convert.
function [counter, V] = ...
    vk_convert_recursive(counter, V, coords, axes, dispgrid)
  if (length(axes) == 3) % Do a 3D conversion quickly.
    for i = 1:size(dispgrid, 1)
      for j = 1:size(dispgrid, 2)
        for k = 1:size(dispgrid, 3)
          if (dispgrid(i,j,k) == 0)
            counter = counter + 1;
            V(counter, :) = [coords, axes{1}(i), axes{2}(j), axes{3}(k)];
          end
        end
      end
    end
  elseif (length(axes) > 1) % Recursive version, for neq 3 axes.
    % Split the grid into a cell array of rows.
    rows = mat2cell(dispgrid, ones(1,size(dispgrid, 1)));

    % Loop through each one and make a recursive call.
    for i = 1:length(rows)
      subgrid = shiftdim(rows{i}, 1);
      [counter, V] = vk_convert_recursive(counter, V, ...
          [coords, axes{1}(i)], axes(2:length(axes)), subgrid);
    end
  else % Flat version for just one axis.
    for i = 1:length(dispgrid)
      if (dispgrid(i) == 0)
        counter = counter + 1;
        V(counter, :) = [coords, axes{1}(i)];
      end
    end
  end


