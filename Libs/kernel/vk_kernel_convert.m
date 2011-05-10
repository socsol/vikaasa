%% VK_CONVERT Converts viability kernels from an old format to new
%   Takes a cell array of axes, and a multi-dimensional array of points,
%   'dispgrid'. dispgrid represents the viability kernel.  If there is a
%   _zero_ in the (i, j, k)th element of dispgrid, then the point [ax1(i),
%   ax2(j), ax3(k)] was identified as viable.
%
%   The replacement format, V is a n x dim array (n = # of viable points;
%   dim = # of dimensions.  Each row thus represents a viable point
%   directly.
%
%   Standard usage:
%   V = vk_convert({xax, yax, zax}, dispgrid)
%
% See also: TOOLS
function V = vk_convert(axes, dispgrid)
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
  
  