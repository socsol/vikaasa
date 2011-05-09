function vk_make_figure_slice(V, slices, K, labels, ...
    colour, method, box, alpha_val, handle)
% vk_make_figure_slice - This function slices a viability kernel any number
% of times, and then plots the result.
%
%  - V: the complete viability kernel
%  - slices: a 2 x n matrix of [axis, point] pairs.
%  - handle: the handle to display the figure in.

    SV = vk_slice(V, slices);

    % Construct the figure name
    figure_name = 'Slice through ';
    for i = 1:size(slices, 1)
        if (isnan(slices(i,2)))
            figure_name = [figure_name, ...
                deblank(labels(slices(i, 1),:)), '=all'];
        else
            figure_name = [figure_name, ...
                deblank(labels(slices(i, 1),:)), '=', num2str(slices(i, 2))];
        end
        
        if (i < size(slices, 1))
            figure_name = [figure_name, ', '];
        end
    end
    figure(handle);
    title(figure_name);
    set(handle, 'Name', figure_name);
    

    % Sort by dimension from largest to smallest.
    if (size(slices, 1) > 1)
        slices = sortrows(slices, -1);
    end

    % Remove the info about the axis that has been sliced.
    for i = 1:size(slices, 1);
        slice_axis = slices(i, 1);
        labels = vertcat(labels(1:slice_axis-1,:), ...
            labels(slice_axis+1:size(labels, 1),:));
        K = [K(1:2*slice_axis-2), K(2*slice_axis+1:end)];
    end

    xlabel(labels(1,:));
    ylabel(labels(2,:));
    if (size(SV, 2) == 2)
        vk_plot_area(SV, colour, method, alpha_val);
    else
        vk_plot_surface(SV, colour, method, alpha_val);
        zlabel(labels(3,:));
        view(3);
    end

    if (box)
        limits = vk_plot_box(K);
    else
        limits = K;
    end
    
    vk_figure_data_insert(handle, limits, slices);
    axis(limits);    
end
