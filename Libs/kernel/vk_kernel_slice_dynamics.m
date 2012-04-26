%% VK_KERNEL_SLICE_DYNAMICS Slice a viability kernel according to a slices array
%

%%
%  Copyright 2012 Jacek B. Krawczyk and Alastair Pharo
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
function [sliced_points, sliced_dynamics] = ...
    vk_kernel_slice_dynamics(points, dynamics, slices)

    % Order slices from largest to smallest dimension.  There is a bug in
    % Octave which causes this to break if there is only one slice.
    if (size(slices, 1) > 1)
        slices = sortrows(slices, -1);
    end

    % Call the helper function for each slice.
    sliced_points = points;
    sliced_dynamics = dynamics;
    for i = 1:size(slices, 1)
        if (slices(i,1) <= size(sliced_points,1))
            [sliced_points, sliced_dynamics] = ...
                vk_kernel_slice_dynamics_helper(sliced_points, sliced_dynamics, ...
                slices(i,1), slices(i,2), slices(i, 3));
        else
            warning(['Could not slice through dimension ', num2str(slices(i,1)), ' -- dimension not present']);
        end
    end
end

% This function simply slices through the viability kernel in a single
% axis.
function [points, dynamics] = vk_kernel_slice_dynamics_helper(...
    points, dynamics, slice_axis, plane, distance)

    % Filter if required.
    if (~isnan(plane))
        dynamics = dynamics(:, find(abs(points(slice_axis, :) - plane) < distance/2)); 
        points = points(:, find(abs(points(slice_axis, :) - plane) < distance/2));
    end

    % Create SV as all columns of NV except the one that we are slicing
    % through.
    points = [points(1:slice_axis-1, :); points(slice_axis+1:end, :)];
    dynamics = [dynamics(1:slice_axis-1, :); dynamics(slice_axis+1:end, :)];
end


