% vk_slice.m
%
% Slices a viability kernel through any number of axes.
%
%  V: the viability kernel
%  slices: n x 3 array of [dimension, point, distance]
%    - dimension (> 0): the index of the dimensions to eliminate.
%    - point: the position to do the slice at. NaN means all points
%    - distance (> 0): the "width of the blade" -- i.e., the space to
%      either side of the point that will be considered within the range.
function SV = vk_slice(V, slices)

    % Order slices from largest to smallest dimension.
    slices = sortrows(slices, -1);

    % Call the helper function for each slice.
    SV = V;
    for i = 1:size(slices, 1)
        SV = vk_slice_helper(SV, slices(i,1), slices(i,2), slices(i, 3));
    end
end

% This function simply slices through the viability kernel in a single
% axis.
function SV = vk_slice_helper(V, slice_axis, plane, distance)

  if (isnan(plane))
      % If NaN, then we don't need to bother filtering.
      NV = V;     
  else
      % Pre-initialise NV for speed.
      NV = zeros(size(V));
      counter = 0;

      % Iterate through all the rows of V.  Copy any that have an axis-th
      % value that is leq than distance-away from plane into NV.
      for row = 1:size(V,1)
        if (abs(V(row, slice_axis) - plane) <= distance)
          counter = counter + 1;
          NV(counter, :) = V(row, :);
        end
      end

      % Remove any unused rows from NV.
      NV = NV(1:counter, :);
  end

  % Create SV as all columns of NV except the one that we are slicing
  % through.
  SV = horzcat(NV(:,1:slice_axis-1), NV(:,slice_axis+1:size(NV, 2)));
end

  