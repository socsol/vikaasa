%% VK_KERNEL_INSIDE Test to see whether the given point is inside the kernel
%   This function determines whether the point x lies inside of V or not.
%
%   A point x is considered to be inside (for some distances and layers) if
%   x is surrounded neighbour points in V (i.e., for a 3D problem, there
%   would need to be 8 points in V around x).  See TOOLS/VK_NEIGHBOURS for
%   a definition of 'neighbour points'.
%
%   If the point is not inside, but it still has some neighbours in V, then
%   it is considered an 'edge' point instead.
%
%   Standard usage:
%   [inside, edge] = VK_KERNEL_INSIDE(x, V, distances, layers)
%
%   - 'x' is a column-vector, representing a point in the state space (see
%     VIABLE/VK_VIABLE for more information).
%
%   - 'V' is a viability kernel.  See TOOLS/VK_COMPUTE for the format of
%     this.
%
%   - 'distances' is a row-vector.  Each element gives the distance between
%     points in V in that dimension.  For some kernel discretisation, d,
%     the distance between points in the i-th dimension should be
%     calculable as: distances(i) = (upper(i) - lower(i)) / (d-1), where
%     'upper' and 'lower' represent the upper- and lower-bounds of the
%     constraint set.
%
%   - 'layers' is an integer > 0.  See TOOLS/VK_NEIGHBOURS for information
%     on how this is used.
%
% See also: VIABLE/VK_VIABLE_COMPUTE, VK_KERNEL_NEIGHBOURS, VIABLE/VK_VIABLE,
%   VCONTROLALGS
function [inside, edge] = vk_kernel_inside(x, V, distances, layers)
% Whether the point x is within the (assumed convex) viability kernel V.

    % Finds the point's neighbours.
    neighbour_elts = vk_kernel_neighbours(x, V, distances, layers);
    
    % Using these neighbours, we see if we can draw a box around the
    %  points.
    inside = vk_kernel_inside_rec(x, neighbour_elts, 1, 'leq') ...
        && vk_kernel_inside_rec(x, neighbour_elts, 1, 'geq');
        
    % If we are not inside, but there are still neighbours, then we are on
    % the edge.
    edge = ~inside && ~isempty(neighbour_elts);
end


%% Recursive helper function for VK_KERNEL_INSIDE
%   Look for elements that are either above or below the point x in the
%   given dimension.  Having found such points, we recurse to the next
%   dimension, and look for points in those dimensions that are both above
%   and below.  The function will return true if there are still points
%   left.
function inside = vk_kernel_inside_rec(x, N, dim, op)
    N1 = zeros(size(N));
    cnt = 0;
    for i = 1:size(N, 1)
        if (strcmp(op, 'leq'))
            if (N(i, dim) <= x(dim))
                cnt = cnt + 1;
                N1(cnt, :) = N(i, :);
            end
        elseif (strcmp(op, 'geq'))
            if (N(i, dim) >= x(dim))
                cnt = cnt + 1;
                N1(cnt, :) = N(i, :);
            end
        end
    end
    N1 = N1(1:cnt, :);
    
    % More dimensions, so do the same in those.
    if (~isempty(N1) && dim < size(N, 2))
        l_inside = vk_kernel_inside_rec(x, N1, dim+1, 'leq');
        u_inside = vk_kernle_inside_rec(x, N1, dim+1, 'geq');
        
        inside = l_inside && u_inside;
    else
        inside = cnt > 0;
    end
end