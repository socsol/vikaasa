%% VK_KERNEL_DISTANCES Calculate distances between points in each dimension.
%
% SYNOPSIS
%   This function returns a row array, giving the distance between points in K,
%   given the discretisation.  This can then be used to work out which elements
%   neighbour which others, for instance.
%
%   This information is also needed to produce slices. See vk_kernel_slice.
%
% USAGE
%   % Store the distance information in 'd':
%   d = vk_kernel_distances(K, discretisation);
%
%   `discretisation' is a column vector of length $n$, where $n$ is the number
%   of dimensions/variables in the viability problem.
%
%   `K' is a column vector with length $2n$, and should be viewed as consisting
%   of a sequence of paired values.  Each pair of values in `K' represents the
%   upper and lower bounds of the rectangular constraint set in that dimension.
%
% See also: vk_kernel_slice, vk_kernel_frontier, vk_kernel_inside,
%   vk_kernel_neighbours

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
function distances = vk_kernel_distances(K, discretisation)
    distances = zeros(1, length(K)/2);
    for i = 1:length(K)/2
        distances(i) = (K(2*i) - K(2*i - 1)) / (discretisation(i)-1);
    end
end
