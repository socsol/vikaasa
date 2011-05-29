%% VK_KERNEL_NEIGHBOURS Find a point's neighbours in a viability kernel.
%
% SYNOPSIS
%   This function goes through the kernel `V', looking for all points that
%   are at most $layers\cdot distances(dim)$ away, and greater than
%   $(layers-1) \cdot distances(dim)$ away, along each axis.
%
% USAGE
%   % Standard usage:
%   neighbour_elts = vk_kernel_neighbourS(x, V, distances, layers)
%
%   - `x' is a column-vector, representing a point in the state space (see
%     vk_viable for more information).
%
%   - `V' is a viability kernel.  See vk_kernel_compute for the format
%     of this.
%
%   - `distances' is a row-vector.  Each element gives the distance between
%     points in V in that dimension.  For some kernel discretisation, $d$,
%     the distance between points in the i-th dimension should be
%     calculable as: $distances(i) = (upper(i) - lower(i)) / (d-1)$, where
%     $upper$ and $lower$ represent the upper- and lower-bounds of the
%     constraint set.
%
%   - `layers' is an integer > 0.  As explained above, this variable is used to
%     filter out elements in `V' that are too close to `V'.  Thus, a the higher
%     the layers, the fewer possible points can be considered within `V'.  This
%     can be used to make algorithms that care about whether they are on the
%     edge of the kernel or not take action ``sooner'' (something akin to being
%     more risk-averse).
%
% See also: vk_kernel_compute, vk_viable, VControlAlgs
%

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
function neighbour_elts = vk_kernel_neighbours(x, V, distances, layers)
    neighbour_elts = zeros(size(V));
    cnt = 0;
    for i = 1:size(V, 1)
        %% For each member of V, check each of it's elements.
        within = zeros(1, size(V, 2));
        for j = 1:size(V, 2)
            dist = abs(x(j) - V(i, j));
            if (dist <= layers*distances(j) ...
                    && dist > (layers - 1)*distances(j))
                within(j) = 1;
            end
        end

        %% If all elements are in the right zone, then add the point.
        if (all(within))
            cnt = cnt + 1;
            neighbour_elts(cnt, :) = V(i, :);
        end
    end

    %% return the list truncated to the correct size.
    neighbour_elts = neighbour_elts(1:cnt, :);
end
