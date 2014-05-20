%% VK_PLOT Draw a two- or three-dimensional kernel
%
% SYNOPSIS
%   Draws a viability kernel using one of the methods available, or
%   'scatter' as a fallback.  If V has two dimensions, then an `_area_'
%   function will be used.  If it has three dimensions, then a `_surface_'
%   function will be used.
%
% Requires:  vk_plot_
%
% See also: vk_figure_make, vk_figure_make_slice

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
function vk_plot(V, colour, method, varargin)

    if (size(V, 2) == 2)
        type = 'area';
    elseif (size(V, 2) == 3)
        type = 'surface';
    else
        warning('Kernel could not be plotted, because it does not have two or three dimensions.');
        return;
    end

    alpha_val = 1;
    opts = {};
    if (nargin > 3)
        alpha_val = varargin{1};
    end
    if (nargin > 5)
        opts = varargin(2:end);
    end

    hold on;
    grid on;


    fallbackfn = eval(['@vk_plot_',type,'_scatter']);
    if (exist(['vk_plot_',type,'_',method]))
        plotfn = eval(['@vk_plot_',type,'_',method]);
    else
        plotfn = fallbackfn;
    end

    err = 0;
    %try
        plotfn(V, colour, alpha_val, opts{:});
    %catch
    %    err = 1;
    %    exception = lasterror();
    %    warning(['Couldn''t plot kernel using "', method, '" method. Reverting to fall-back']);
    %    fallbackfn(V, colour, alpha_val);
    %end

    if (err)
        rethrow(exception);
    end
end
