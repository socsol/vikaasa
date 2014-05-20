%% VK_PLOT_POINT Plots a single point into an existing plot

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
function vk_plot_point(pt, varargin)
    if (nargin > 1)
        colour = varargin{1};
    else
        colour = 'k';
    end

    hold on;
    if (length(pt) == 2)
        plot(pt(1), pt(2), 'Marker', 'x', 'Color', colour, 'MarkerSize', 5);
    elseif (length(pt) == 3)
        plot3(pt(1), pt(2), pt(3), 'Marker', 'x', 'Color', colour, 'MarkerSize', 5);
    end
end
