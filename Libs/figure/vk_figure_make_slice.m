% VK_FIGURE_MAKE_SLICE Slices a viability kernel and then plots the result.
%
%   VK_FIGURE_MAKE_SLICE(V, slices, K, labels, colour, method, box, alpha_val, handle)
%
%  - V: The complete viability kernel
%  - slices: A nx3 matrix of [axis, point,distance] triples (see VK_KERNEL_SLICE).
%  - K: The constraint set
%  - labels: Labels to display on the axes.
%  - colour: The colour to draw the kernel.
%  - method: Which method to use in drawing the kernel.
%  - box: Whether or not to draw a box around the kernel.
%  - alpha_val: The transparency to give the kernel (certain drawing methods only)
%  - handle: The handle to display the figure in.
%
function vk_figure_make_slice(V, slices, K, labels, ...
    colour, method, box, alpha_val, handle)

    SV = vk_kernel_slice(V, slices);

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
        vk_figure_plot_area(SV, colour, method, alpha_val);
    else
        vk_figure_plot_surface(SV, colour, method, alpha_val);
        zlabel(labels(3,:));
        view(3);
    end

    if (box)
        limits = vk_figure_plot_box(K);
    else
        limits = K;
    end
    
    vk_figure_data_insert(handle, limits, slices);
    axis(limits);    
end
