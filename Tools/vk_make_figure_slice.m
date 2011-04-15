function vk_make_figure_slice(V, slices, constraint_set, labels, ...
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
        figure_name = [figure_name, ...
            deblank(labels(slices(i, 1),:)), '=', num2str(slices(i, 2))];
        if (i < size(slices, 1))
            figure_name = [figure_name, ', '];
        end
    end
    figure(handle);
    title(figure_name);
    set(handle, 'Name', figure_name);
    

    % Sort by dimension from largest to smallest.
    slices = sortrows(slices, -1);

    % Remove the info about the axis that has been sliced.
    for i = 1:size(slices, 1);
        slice_axis = slices(i, 1);
        labels = vertcat(labels(1:slice_axis-1,:), ...
            labels(slice_axis+1:size(labels, 1),:));
        constraint_set = horzcat(constraint_set(1:2*slice_axis-2), ...
            constraint_set(2*slice_axis+1:size(constraint_set,2)));
    end

    xlabel(labels(1,:));
    ylabel(labels(2,:));
    if (size(SV, 2) == 2)
        vk_plot_area(SV, colour, method, alpha_val);
    else
        vk_plot_surface(SV, colour, method, alpha_val);
        zlabel(labels(3,:));
        view(3);
        camlight;
        lighting gouraud;
    end

    if (box)
        limits = vk_plot_box(constraint_set);
    else
        limits = constraint_set;
    end
    
    vk_figure_data_insert(handle, limits, slices);
    axis(limits);    
end
