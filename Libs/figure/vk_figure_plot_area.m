%% VK_FIGURE_PLOT_AREA Plots a 2D filled viability kernel
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
function vk_figure_plot_area(V, colour, method, alpha_val)
    grid on;

    hold on;
    if (isempty(V))
      return;
    end

    if (strcmp(method, 'qhull'))
        try
            H = convhull(V(:,1), V(:,2));
            plot(V(H,1), V(H,2));
            ar = fill(V(H,1), V(H,2), colour);
            alpha(ar, alpha_val);
        catch
            warning('Couldn''t do a isosurface around points, so reverting to a scatterplot');
            method = 'scatter';
        end
    elseif (strcmp(method, 'isosurface') || strcmp(method, 'isosurface-smooth'))
        try

            xax = sort(unique(V(:,1)));
            yax = sort(unique(V(:,2)));
            volume = zeros(length(yax), length(xax), 2);

            Vsorted = sortrows(V);
            Vidx = 1;
            for x = 1:length(xax)
                for y = 1:length(yax)
                    if (all(Vsorted(Vidx, :) == [xax(x),yax(y)]))
                        volume(y, x, 1) = 1;
                        volume(y, x, 2) = 2;
                        Vidx = Vidx + 1;
                    end
                end
            end

            if (strcmp(method, 'isosurface-smooth'))
                volume = smooth3(volume);
            end
            h_iso = patch(isosurface(xax, yax, [0,1], volume, 1));
            isonormals(xax,yax,[0,1],volume,h_iso);
            h_caps = patch(isocaps(xax,yax,[0,1],volume,1));
            set(h_iso,'FaceColor',colour, 'EdgeColor', 'none');
            set(h_caps,'FaceColor',colour, 'EdgeColor', 'none');
            alpha(h_iso, alpha_val);
            alpha(h_caps, alpha_val);
        catch
            warning('Couldn''t do a isosurface around points, so reverting to a scatterplot');
            method = 'scatter';
        end
    end

    if (strcmp(method, 'scatter'))
        scatter(V(:,1), V(:,2));
    end
end
