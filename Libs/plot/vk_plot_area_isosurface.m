%% VK_PLOT_AREA_ISOSURFACE Plots a 2D viability kernel using the `isosurface' function.
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
function vk_plot_area_isosurface(V, colour, varargin)

    alpha_val = 1;
    smooth = 0;
    if (nargin > 2)
        alpha_val = varargin{1};

        if (nargin > 4 && strcmp(varargin{2}, 'smooth'))
            smooth = varargin{3};
        end
    end

    xax = sort(unique(V(:,1)));
    yax = sort(unique(V(:,2)));
    [xx, yy, zz] = meshgrid(xax, yax, [0; 1]);

    volume = arrayfun( ...
      @(x,y,z) 2*any( ...
        all(V == [x*ones(size(V,1),1),y*ones(size(V,1),1)], 2) ...
      ), xx, yy, zz);

    if (smooth && exist('smooth3'))
        volume = smooth3(volume);
    end

    h_iso = patch(isosurface(xx, yy, zz, volume, 1));
    isonormals(xx, yy, zz,volume,h_iso);
    set(h_iso,'FaceColor',colour, 'EdgeColor', 'none');
    if (exist('alpha'))
        alpha(h_iso, alpha_val);
    end

    if (exist('isocaps'))
        h_caps = patch(isocaps(xx, yy, zz,volume,1));
        set(h_caps,'FaceColor',colour, 'EdgeColor', 'none');
        if (exist('alpha'))
            alpha(h_caps, alpha_val);
        end
    end
end
