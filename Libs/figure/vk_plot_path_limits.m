function limits = vk_plot_path_limits(limits, path)
    for j = 1:length(limits) / 2
        limits(2*j - 1) = min([limits(2*j - 1), path(j, :)]);
        limits(2*j) = max([limits(2*j), path(j, :)]);
    end
end