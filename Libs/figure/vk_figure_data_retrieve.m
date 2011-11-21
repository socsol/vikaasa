%% VK_FIGURE_DATA_RETRIEVE Retrieve data previously stored in figure
%
% SYNOPSIS
%   This function is used by VIKAASA to remember the current limits and slices
%   in a given figure.  The limits give either the maximum and minimum values
%   in each dimension, or the values of the rectangular constraint set.  In
%   this way, trajectories can be added to a figure at a later time, and the
%   axes of the figure readjusted without clipping any other information in the
%   figure.  This function retrieves data previously associated with a figure
%   using vk_figure_data_insert.
%
% USAGE
%   % For some figure, h, get the limits of the figure and the slices.
%   [limits, slices] = vk_figure_data_retrieve(h);
%
%   - `limits' is a row vector of length 4 (for a two-dimensional plot) or 6
%     (for a three-dimensional plot).  It is the same format used to represent
%     the rectangular constraint set, `K'.
%
%   - `slices' is a data structure of the type compatible with vk_kernel_slice.
%
% See also: vk_figure_data_retrieve

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
function [limits, slices] = vk_figure_data_retrieve(h)
    ud = get(h, 'UserData');
    limits = ud(1, 2:ud(1,1)+1);

    if (size(ud, 1) > 1)
        slices = ud(2:end, 2:ud(2,1)+1);
    else
        slices = [];
    end
end
