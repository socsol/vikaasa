%% VK_PLOT_AREA_PATHS Plot phase diagrams in 2D space.
%
%   This function only exists for convenience.

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
function vk_plot_surface_quiver(V, colour, alpha, varargin)
    vk_plot_surface_paths(V, colour, alpha, varargin{:})
end
