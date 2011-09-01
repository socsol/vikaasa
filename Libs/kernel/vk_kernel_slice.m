%% VK_KERNEL_SLICE Slice a viability kernel according to a slices array
%
% SYNOPSIS
%   Slices a viability kernel through any number of axes.
%
% USAGE
%   % Store the resulting sliced kernel in SV.
%   SV = vk_kernel_slice(V, slices);
%
%  `V' is the viability kernel; `slices' is a $n \times 3$ array of
%  `[dimension, point, distance]' rows.
%
%  - `dimension' ($> 0$): the index of the dimensions to eliminate.
%  - `point': the position to do the slice at. NaN means all points
%  - `distance' ($> 0$): the "width of the blade" -- i.e., the space to
%    either side of the point that will be considered within the range.
%
% See also: vk_kernel_make_slices

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
function SV = vk_kernel_slice(V, slices)

    % Order slices from largest to smallest dimension.  There is a bug in
    % Octave which causes this to break if there is only one slice.
    if (size(slices, 1) > 1)
        slices = sortrows(slices, -1);
    end

    % Call the helper function for each slice.
    SV = V;
    for i = 1:size(slices, 1)
        if (slices(i,1) <= size(SV,2))
            SV = vk_kernel_slice_helper(SV, slices(i,1), slices(i,2), slices(i, 3));
        else
            warning(['Could not slice through dimension ', num2str(slices(i,1)), ' -- dimension not present']);
        end
    end
end

% This function simply slices through the viability kernel in a single
% axis.
function SV = vk_kernel_slice_helper(V, slice_axis, plane, distance)
  if (isnan(plane))
      % If NaN, then we don't need to bother filtering.
      NV = V;
  else
      NV = V(find(abs(V(:,slice_axis) - plane) < distance/2),:);
  end

  % Create SV as all columns of NV except the one that we are slicing
  % through.
  SV = [NV(:,1:slice_axis-1), NV(:,slice_axis+1:end)];
end


