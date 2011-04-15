%% VK_NEIGHBOURS Find a point's neighbours in a viability kernel.
%   This function goes through the kernel V, looking for all points that
%   are leq than layers*distances(dim) away, and greater than
%   (layers-1)*distances(dim) away, along each axis.
%
%   Standard usage:
%   neighbour_elts = VK_NEIGHBOURS(x, V, distances, layers)
%
%   - 'x' is a column-vector, representing a point in the state space (see
%     TOOLS/VK_VIABLE for more information).
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
%   - 'layers' is an integer > 0.  As explained above, this variable
%     is used to filter out elements in V that are too close to V.  Thus, a
%     the higher the layers, the fewer possible points can be considered
%     within V.  This can be used to make algorithms that care about
%     whether they are on the edge of the kernel or not take action
%     'sooner' (something akin to being more risk-averse).
%
% See also: TOOLS, TOOLS/VK_COMPUTE, TOOLS/VK_VIABLE, VCONTROLALGS
function neighbour_elts = vk_neighbours(x, V, distances, layers)


    neighbour_elts = zeros(size(V));
    cnt = 0;
    for i = 1:size(V, 1)
        within = zeros(1, size(V, 2));        
        for j = 1:size(V, 2)            
            dist = abs(x(j) - V(i, j));
            if (dist <= layers*distances(j) ...
                    && dist > (layers - 1)*distances(j))
                within(j) = 1;
            end
        end
        if (all(within))
            cnt = cnt + 1;
            neighbour_elts(cnt, :) = V(i, :);
        end
    end
    neighbour_elts = neighbour_elts(1:cnt, :);