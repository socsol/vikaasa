%% VK_PLOT_SURFACE Draw a 3D kernel
%
% SYNOPSIS
%   Draws a 3D representation of a viability kernel.
%
% Requires: vk_plot_surface_scatter, vk_plot_surface_qhull,
%   vk_plot_surface_isosurface
%
% See also: vk_figure_make, vk_figure_make_slice, vk_plot_area

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
function vk_plot_surface(V, colour, method, alpha_val)

    if (isempty(V))
        return;
    end

    hold on;
    grid on;

    if (length(method) > 6 && strcmp(method(end-6:end), '-smooth'))
        method = method(1:end-7);
        smoothopt = {'smooth', 1};
    else
        smoothopt = {};
    end

    fallbackfn = @vk_plot_surface_scatter;
    if (exist(['vk_plot_surface_',method]))
        plotfn = eval(['@vk_plot_surface_',method]);
    else
        plotfn = fallbackfn;
    end

    err = 0;
    try
        plotfn(V, colour, alpha_val, smoothopt{:});
    catch
        err = 1;
        exception = lasterror();
        warning(['Couldn''t plot kernel using "', method, '" method. Reverting to a scatterplot']);
        fallbackfn(V, colour, alpha_val);
    end

    if (err)
        rethrow(exception);
    end
end
