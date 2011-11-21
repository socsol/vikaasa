%% VK_PLOT_AREA_QHULL Plots a 2D viability kernel as a convex area
%
% SYNOPSIS
%   This function uses the `convhull' function to make a convex area from the
%   points in the viability kernel.  This area is then filled using the `fill'
%   function.
%
% USAGE
%   % Standard:
%   vk_plot_area_qhull(V, colour);
%
%   % With transparency:
%   vk_plot_area_qhull(V, colour, 0.5);
%
% See also: convhull, alpha

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
function vk_plot_area_qhull(V, colour, varargin)

    alpha_val = 1;
    if (nargin > 2)
        alpha_val = varargin{1};
    end

    H = convhull(V(:,1), V(:,2));
    plot(V(H,1), V(H,2));
    ar = fill(V(H,1), V(H,2), colour);

    if (exist('alpha'))
        alpha(ar, alpha_val);
    end
end
