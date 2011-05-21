%% VK_KERNEL_MAKE_SLICES Construct a slice array from a cell array
%   The cell array conforms to the format displayed by the VIKAASA gui.
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
function slices = vk_kernel_make_slices(data, K, discretisation)

    slices = [];

    distances = vk_kernel_distances(K, discretisation);

    %% Loop through rows of data
    % There will be one row in data for each variable.
    for i = 1:size(data, 1)
        if (data{i,1})
            % If the first element is checked, then that dimension is
            % sliced for all values, essentially eliminating it from
            % consideration.
            slices = [slices; i, NaN, NaN];
        elseif (data{i,2})
            % If the second element is checked, then that dimension is
            % sliced at a particular value.
            % The third element is the 'distance', which tells the slicer how far to either side of the slice value
            slices = [slices; i, data{i, 3}, distances(i)];
        end
    end
end
