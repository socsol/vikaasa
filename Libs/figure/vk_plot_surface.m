% vk_plot_surface.m
%
% draws a 3D patch of the surface area of the viability kernel.
function vk_plot_surface(V, colour, method, alpha_val)

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
                camlight;
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




