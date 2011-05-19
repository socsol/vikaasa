%% VK_FIGURE_PLOT_SURFACE Draw a 3D kernel
%   Draws a 3D representation of a viability kernel.
%
% See also: VK_FIGURE_MAKE, VK_FIGURE_MAKE_SLICE, VK_FIGURE_PLOT_AREA
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
function vk_figure_plot_surface(V, colour, method, alpha_val)

    if (isempty(V))
        return;
    end

    hold on;
    grid on;

    err = 0;
    if (strcmp(method, 'qhull'))
        try
            % T is a set of triangles that together trace a surface around
            % V.
            T = convhulln(V);

            % Attempt to add lighting effects too.
            try
                camlight left;
                camlight right;
                lighting gouraud;

                %   p = trisurf(T, V(:,1), V(:,2), V(:,3));
                %   set(p,'FaceColor','yellow','EdgeColor','none');
                for i = 1:length(T)
                    p = patch(V(T(i,:), 1), V(T(i,:), 2), V(T(i,:), 3), ...
                        colour);
                    set(p,'FaceColor',colour,'EdgeColor','none');
                    alpha(p, alpha_val);
                end
            catch
                warning('Couldn''t set lighting');

                for i = 1:length(T)
                    p = patch(V(T(i,:), 1), V(T(i,:), 2), V(T(i,:), 3), ...
                        [0,1,1]);
                    set(p,'FaceColor',colour,'EdgeColor','black');
                end
            end
        catch
            % If we couldn't do a convexhull, we probably don't have enough
            % points. So, do a scatterplot instead.
            exception = lasterror();
            err = 1;
            warning('Couldn''t do a convex hull around points, so reverting to a scatterplot');
        end
    elseif (strcmp(method, 'isosurface') || strcmp(method, 'isosurface-smooth'))
        try
            xax = sort(unique(V(:,1)));
            yax = sort(unique(V(:,2)));
            zax = sort(unique(V(:,3)));

            volume = zeros(length(yax), length(xax), length(zax));

            Vsorted = sortrows(V);
            Vidx = 1;
            for x = 1:length(xax)
                for y = 1:length(yax)
                    for z = 1:length(zax)
                        if (all(Vsorted(Vidx, :) == [xax(x),yax(y),zax(z)]))
                            % If this is the edge of the graph, make is
                            volume(y, x, z) = 2;
                            Vidx = Vidx + 1;
                        end
                        if (Vidx > size(V, 1))
                            break;
                        end
                    end
                    if (Vidx > size(V, 1))
                        break;
                    end
                end
                if (Vidx > size(V, 1))
                    break;
                end
            end

            if (strcmp(method, 'isosurface-smooth'))
                volume = smooth3(volume);
            end

            %% Octave performs isosurface differently from MATLAB
            if (exist('octave_config_info'))
                [xx, yy, zz] = meshgrid(xax, yax, zax);
                h_iso = patch(isosurface(xx, yy, zz, volume, 1));
                isonormals(xx,yy,zz,volume,h_iso);
            else
                h_iso = patch(isosurface(xax, yax, zax, volume, 1));
                isonormals(xax,yax,zax,volume,h_iso);
                h_caps = patch(isocaps(xax,yax,zax,volume,1));
                set(h_caps,'FaceColor',colour, 'EdgeColor', 'none');
                alpha(h_caps, alpha_val);
                alpha(h_iso, alpha_val);
            end
            set(h_iso,'FaceColor',colour, 'EdgeColor', 'none');
        catch
            exception = lasterror();
            err = 1;
            warning('Couldn''t do a isosurface around points, so reverting to a scatterplot');
        end
    end

    if (err || strcmp(method, 'scatter'))
        scatter3(V(:, 1), V(:, 2), V(:, 3), 10, colour);
    end

    if (err)
        rethrow(exception);
    end
end
